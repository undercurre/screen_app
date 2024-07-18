package com.midea.homlux.ai.services;

import static com.aispeech.dui.dds.utils.DeviceUtil.getMacAddress;
import static com.midea.homlux.ai.bean.MessageBean.TYPE_WIDGET_WEATHER;

import android.app.Service;
import android.content.Intent;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.IBinder;
import android.os.RemoteException;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.Nullable;

import com.aispeech.dca.Callback;
import com.aispeech.dca.DcaConfig;
import com.aispeech.dca.DcaListener;
import com.aispeech.dca.DcaSdk;
import com.aispeech.dca.smartHome.bean.SmartHomeSkillDetail;
import com.aispeech.dca.smartHome.bean.SmartHomeTokenRequest;
import com.aispeech.dui.account.AccountListener;
import com.aispeech.dui.account.AccountManager;
import com.aispeech.dui.account.OAuthCodeListener;
import com.aispeech.dui.account.OAuthManager;
import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dds.DDSAuthListener;
import com.aispeech.dui.dds.DDSConfig;
import com.aispeech.dui.dds.DDSInitListener;
import com.aispeech.dui.dds.agent.Agent;
import com.aispeech.dui.dds.auth.AuthInfo;
import com.aispeech.dui.dds.exceptions.DDSNotInitCompleteException;
import com.aispeech.dui.oauth.TokenListener;
import com.aispeech.dui.oauth.TokenResult;
import com.midea.homlux.ai.AiSpeech.AiConfig;
import com.midea.homlux.ai.AiSpeech.AiDialog;
import com.midea.homlux.ai.AiSpeech.WeatherDialog;
import com.midea.homlux.ai.api.HomluxAiApi;
import com.midea.homlux.ai.bean.MessageBean;
import com.midea.homlux.ai.bean.WeatherBean;
import com.midea.homlux.ai.impl.AISetVoiceCallBack;
import com.midea.homlux.ai.impl.IntialCallBack;
import com.midea.homlux.ai.impl.WakUpStateCallBack;
import com.midea.homlux.ai.music.MusicManager;
import com.midea.homlux.ai.observer.DuiCommandObserver;
import com.midea.homlux.ai.observer.DuiMessageObserver;
import com.midea.homlux.ai.observer.DuiNativeApiObserver;
import com.midea.homlux.ai.observer.DuiUpdateObserver;
import com.midea.light.ai.IHomluxAICompleteIntialCallBack;
import com.midea.light.ai.IHomluxAIInterface;
import com.midea.light.ai.IHomluxAISetVoiceCallBack;
import com.midea.light.ai.IHomluxWakeUpStateCallback;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.utils.DialogUtil;
import com.midea.light.common.utils.GsonUtils;
import com.midea.light.thread.MainThread;

import java.io.IOException;
import java.util.LinkedList;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.schedulers.Schedulers;
import com.midea.light.common.utils.AIFileLogRecord;


public class MideaAiService extends Service implements DuiUpdateObserver.UpdateCallback, DuiMessageObserver.MessageCallback {

    private LinkedList<MessageBean> mMessageList = new LinkedList<>();// 当前消息容器
    private DuiMessageObserver mMessageObserver = new DuiMessageObserver();// 消息监听器
    private DuiCommandObserver mCommandObserver = new DuiCommandObserver();// 命令监听器
    private DuiNativeApiObserver mNativeApiObserver = new DuiNativeApiObserver();// 本地方法回调监听器
    private WakUpStateCallBack mWakUpStateCallBack;

    private AiDialog mAiDialog;
    private WeatherDialog mWeatherDialog;
    private MessageBean mMessageBean;
    private boolean isPlayBefore=false;

    private boolean ddsIntial = false;
    private boolean isAiEnable = true;
    private boolean isIntial = false;
    private int mAuthCount = 0;// 授权次数,用来记录自动授权

    private String uid;
    private String token;
    private boolean aiEnable;
    private String houseId;
    private String aiClientId;

    private static boolean sdkInit = false;
    private IntialCallBack mIntialCallBack;

    IHomluxAIInterface.Stub binder = new IHomluxAIInterface.Stub() {
        @Override
        public void initSDK(String env) throws RemoteException {
            MideaAiService.this.initSDK(env);
        }

        @Override
        public void init(String uid, String token, boolean aiEnable, String houseId, String aiClientId) throws RemoteException {
            MideaAiService.this.init(uid, token, aiEnable, houseId, aiClientId);
        }

        @Override
        public void wakeupAi() throws RemoteException {
            MideaAiService.this.wakeupAi();
        }

        @Override
        public void setAiEnable(boolean enable) throws RemoteException {
            MideaAiService.this.setAiEnable(enable);
        }

        @Override
        public void stopAi() throws RemoteException {
            MideaAiService.this.stopService();
        }

        @Override
        public void addWakUpStateCallBack(IHomluxWakeUpStateCallback callback) throws RemoteException {
            MideaAiService.this.addWakUpStateCallBack(isWakUp -> {
                try {
                    callback.wakUpState(isWakUp);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            });
        }

        @Override
        public void addAISetVoiceCallBack(IHomluxAISetVoiceCallBack callback) throws RemoteException {
            MideaAiService.this.addAISetVoiceCallBack(Voice -> {
                try {
                    callback.SetVoice(Voice);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            });
        }

        @Override
        public void addAICompleteIntialCallBack(IHomluxAICompleteIntialCallBack callback) throws RemoteException {
            MideaAiService.this.addAISetIntialCallBack(Intial -> {
                try {
                    callback.CompleteIntial(Intial);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            });
        }

        @Override
        public boolean isDuplexModeFullDuplex() throws RemoteException {
            try {
                return DDS.getInstance().getAgent().getDuplexMode() == Agent.DuplexMode.FULL_DUPLEX;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

        @Override
        public boolean setDuplexMode(boolean isFullDuplex) throws RemoteException {
            try {
                DDS.getInstance().getAgent().setDuplexMode(isFullDuplex ? Agent.DuplexMode.FULL_DUPLEX: Agent.DuplexMode.HALF_DUPLEX);
                return true;
            } catch (DDSNotInitCompleteException e) {
                e.printStackTrace();
            }

            return false;
        }
    };

    public void initSDK(String env) {
        if(!sdkInit) {
            MainThread.run(() -> {
                AppCommonConfig.init(env.equals("prod") ? AppCommonConfig.CONFIG_TYPE_PRODUCT : AppCommonConfig.CONFIG_TYPE_DEVELOP);
                DcaConfig config = new DcaConfig.Builder()
                        .apiKey(AppCommonConfig.DCA_API_KEY)
                        .apiSecret(AppCommonConfig.DCA_API_SECRET)
                        .openDebugLog(true)
                        .publicKey(AppCommonConfig.DCA_PUB_KEY)
                        .build();
                DcaSdk.initialize(MideaAiService.this.getApplicationContext(), config);
                Log.e("sky", "初始化sdk");
            });
            sdkInit = true;
        }
    }

    public void init(String uid, String token, boolean aiEnable, String houseId, String aiClientId) {
        this.uid = uid;
        this.token = token;
        this.aiEnable = aiEnable;
        this.houseId = houseId;
        this.aiClientId = aiClientId;
        HomluxAiApi.syncQueryDuiToken(houseId, aiClientId, token)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .retryWhen(throwableObservable -> {
                return throwableObservable.map(error-> Observable.timer(10,TimeUnit.SECONDS));
            })
            .subscribe(entity -> {
                if (entity != null) {
                    startDuiAi(uid, entity.getResult().getAccessToken(), entity.getResult().getRefreshToken(),
                            entity.getResult().getAccessTokenExpireTime(), aiEnable);
                }
            });
    }

    private void cleanTokenAndInit() {
        isIntial = false;
        try {
            AccountManager.getInstance().clearToken();
            DDS.getInstance().getAgent().clearAuthCode();
            DDS.getInstance().releaseSync();
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
        init(uid,token,aiEnable,houseId,aiClientId);
    }

    public void startDuiAi(String uid, String token, String refreshToken, int ExpiresTime, boolean aiEnable) {
        isAiEnable = aiEnable;
        if (!isIntial) {
            MainThread.run(() -> {
                isIntial = true;
                DialogUtil.showLoadingMessage(MideaAiService.this, "同步家庭数据中");
                AccountLogin(uid, token, refreshToken, ExpiresTime);
            });
        }
    }

    /**
     * 登录
     */
    private void AccountLogin(String uid, String token, String refreshToken, int ExpiresTime) {
        //如果是使用贵司自己的账号，就调用AccountManager.linkAccount
        AIFileLogRecord.INSTANCE.record("aiTest linkAccount uid = "+uid+" token = "+token+" refreshToken = "+refreshToken+" ExpiresTime " +ExpiresTime);
        Log.e("sky","aiTest linkAccount uid = "+uid+" token = "+token+" refreshToken = "+refreshToken+" ExpiresTime " +ExpiresTime);
        AccountManager.getInstance().linkAccount(uid, token, AppCommonConfig.MANUFACTURE, new AccountListener() {
            @Override
            public void onError(int i, String s) {
                MainThread.run(()-> {
                    DialogUtil.closeLoadingDialog();
                    DialogUtil.showToast("语音初始化失败!");
                });
                Log.e("sky", "linkAccountOnError : " + s);
                AIFileLogRecord.INSTANCE.record("linkAccountOnError : " + s);
            }

            @Override
            public void onSuccess() {
                getSkillDetail(token, refreshToken, ExpiresTime);
            }
        });
    }

    public void getSkillDetail(String token, String refreshToken, int ExpiresTime) {
        DcaSdk.getSmartHomeManager().querySmartHomeSkillDetail(AppCommonConfig.SKILL_ID, new Callback<SmartHomeSkillDetail>() {
            @Override
            public void onSuccess(SmartHomeSkillDetail smartHomeSkillDetail) {
                smartHomeSkillDetail.getSkillDirection();
                AiConfig.skillVersion = smartHomeSkillDetail.getVersion();
                UpdateTokenInfo(token, refreshToken, ExpiresTime);
            }

            @Override
            public void onFailure(int i, String s) {
                MainThread.run(()-> {
                    DialogUtil.closeLoadingDialog();
                    DialogUtil.showToast("获取技能失败");
                });
                Log.e("sky", "获取技能失败");
                AIFileLogRecord.INSTANCE.record("获取技能失败");
            }
        });
    }


    /**
     * 跳过二次登录
     */
    private void UpdateTokenInfo(String token, String refreshToken, int ExpiresTime) {
        SmartHomeTokenRequest request = new SmartHomeTokenRequest();
        request.setProductId(AppCommonConfig.PRODUCT_ID);
        request.setSkillId(AppCommonConfig.SKILL_ID);
        //设置智能家居技能id，技能id写死，在dui平台的技能页面可以看到
        request.setSkillVersion(AiConfig.skillVersion);
        //设置技能版本号，版本号可以通过 13.11 智能家居技能详情接口动态获取
        request.setSmartHomeAccessToken(token);
        //这个token是第三方智能家居厂商自己的token，用来访问智能家居厂商的后台服务


        if (ExpiresTime != -1) {
            request.setSmartHomeRefreshToken(refreshToken);
            //除非AccessToken永久有效，否则需要传入refreshtoken、ExpiresIn相关参数以保证思必驰定时刷token
            //思必驰后台会在ExpiresIn的时间后刷新token，如果开发者想要自己维护token，
            //那么请确保在使用智能家居相关功能前，调用updateSmartHomeTokenInfo，确保AccessToken有效
            //请注意：一旦更新某个用户的token(永久token)，那么该用户历史设置的token立即失效，无法在其他接口中使用
            request.setAccessTokenExpiresIn(ExpiresTime);
            //如果没有refreshtoken，那么可以不用调用该接口
        }

        DcaSdk.getSmartHomeManager().updateSmartHomeTokenInfo(request, new DcaListener() {
            @Override
            public void onResult(int httpResponseCode, String httpResponseBody) {
                OAuth();
            }

            @Override
            public void onFailure(IOException e) {
                MainThread.run(()-> {
                    DialogUtil.closeLoadingDialog();
                    DialogUtil.showToast("Dca授权失败");
                });
                Log.e("sky", "Dca授权失败");
                AIFileLogRecord.INSTANCE.record("Dca授权失败");
            }
        });


    }

    public void wakeupAi() {
        try {
            if (DDS.getInstance().getAgent() != null) {
                DDS.getInstance().getAgent().avatarClick();
            }
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
    }

    private void ddsInitFinish()
    {
        DcaSdk.setNeedOnLoginListener(()->cleanTokenAndInit());
        start();
        setAiEnable(isAiEnable);
        MainThread.run(() -> {
            try {
                MusicManager.getInstance().startMusicServer(MideaAiService.this);
                mIntialCallBack.intialState(true);
                DialogUtil.closeLoadingDialog();
            }catch (Exception e){

            }
        });
    }

    // dds初始状态监听器,监听init是否成功
    private DDSInitListener mInitListener = new DDSInitListener() {
        @Override
        public void onInitComplete(boolean isFull) {
            if (isFull) {
                ddsInitFinish();

                //以下代码是 oauth 初始化的代码，必须在初始化成功后才可调用,执行账号授权
                AuthInfo authInfo = new AuthInfo();
                authInfo.setClientId(AppCommonConfig.CLIENT_ID);
                authInfo.setUserId(AiConfig.userId + "");
                authInfo.setAuthCode(AiConfig.authcode);
                authInfo.setCodeVerifier(AiConfig.codeVerifier);
                authInfo.setRedirectUri(AiConfig.redirectUri);//若不设置，使用默认地址值 http://dui.callback
                try {
                    DDS.getInstance().getAgent().setAuthCode(authInfo, new TokenListener() {
                        @Override
                        public void onSuccess(TokenResult tokenResult) {

                        }

                        @Override
                        public void onError(int i, String s) {
                            MainThread.run(()->{
                                DialogUtil.closeLoadingDialog();
                                DialogUtil.showToast("AI获取token失败");
                            });
                            Log.e("sky", "AI获取token失败");
                            AIFileLogRecord.INSTANCE.record("AI获取token失败");
                        }
                    });
                } catch (DDSNotInitCompleteException e) {
                    e.printStackTrace();
                }
            } else {
                MainThread.run(()->{
                    DialogUtil.closeLoadingDialog();
                    DialogUtil.showToast("DDS 初始化失败");
                });
                Log.e("sky", "DDS 初始化失败");
                AIFileLogRecord.INSTANCE.record("DDS 初始化失败");
            }
        }

        @Override
        public void onError(int what, final String msg) {
            MainThread.run(()->{
                DialogUtil.closeLoadingDialog();
                DialogUtil.showToast("DDS 初始化失败");
            });

            Log.e("sky", "DDS 初始化失败 "+msg);
            AIFileLogRecord.INSTANCE.record("DDS 初始化失败 "+msg);
        }
    };

    // dds认证状态监听器,监听auth是否成功
    private DDSAuthListener mAuthListener = new DDSAuthListener() {
        @Override
        public void onAuthSuccess() {

        }

        @Override
        public void onAuthFailed(final String errId, final String error) {
            Log.e("sky", "onAuthFailed errId = "+errId+" err = " +error);
            AIFileLogRecord.INSTANCE.record( "onAuthFailed errId = "+errId+" err = " +error);
            if (mAuthCount < 3) {
                mAuthCount ++;
                Schedulers.computation().scheduleDirect(()->{
                    try {
                        DDS.getInstance().doAuth();
                    } catch (DDSNotInitCompleteException e) {
                        e.printStackTrace();
                    }
                },1,TimeUnit.SECONDS);
            } else {
                mAuthCount = 0;
                MainThread.run(()->{
                    DialogUtil.closeLoadingDialog();
                    cleanTokenAndInit();
                });
            }

        }
    };

    /**
     * 请求验证
     */
    private void OAuth() {
        final String codeVerifier = OAuthManager.getInstance().genCodeVerifier();
        String codeChallenge = OAuthManager.getInstance().genCodeChallenge(codeVerifier);
        OAuthManager.getInstance().setOAuthListener(new OAuthCodeListener() {

            @Override
            public void onError(String s) {
                Log.e("sky", "OAuthOnError : " + s);
                AIFileLogRecord.INSTANCE.record("OAuthOnError : " + s);
                MainThread.run(()-> {
                    DialogUtil.showToast("语音初始化失败!");
                    DialogUtil.closeLoadingDialog();
                });
            }

            @Override
            public void onSuccess(final String authcode) {
                Log.e("sky", "OAuthSuc");
                AiConfig.authcode = authcode;
                AiConfig.codeVerifier = codeVerifier;
                AiConfig.userId = AccountManager.getInstance().getUserId();
                DDS.getInstance().init(getApplicationContext(), createConfig(), mInitListener, mAuthListener);
                DDS.getInstance().setDebugMode(6); //在调试时可以打开sdk调试日志，在发布版本时，请关闭
                DDS.getInstance().stopDebug();
            }
        });
        OAuthManager.getInstance().requestAuthCode(codeChallenge, AiConfig.redirectUri, AppCommonConfig.CLIENT_ID);
    }

    // 创建dds配置信息
    private DDSConfig createConfig() {
        // 用户设置自己实现的单个功能，目前支持 wakeup 和 vad。WakeupII.class 是一个使用示例
        // DDS.getInstance().setOutsideEngine(IEngine.Name.WAKEUP_SINGLE_MIC, WakeupII.class);
        DDSConfig config = new DDSConfig();
        // 基础配置项
        config.addConfig(DDSConfig.K_PRODUCT_ID, AppCommonConfig.PRODUCT_ID); // 产品ID -- 必填
        //        if(HomluxService.getInstance().getUserInfo()!=null){
        //            config.addConfig(DDSConfig.K_USER_ID, HomluxService.getInstance().getUserInfo().getUserId());  // 用户ID -- 必填
        //        }else{
        //            config.addConfig(DDSConfig.K_USER_ID, "xiaomei");  // 用户ID -- 必填
        //        }
        config.addConfig(DDSConfig.K_USER_ID, "xiaomei");  // 用户ID -- 必填
        config.addConfig(DDSConfig.K_ALIAS_KEY, AppCommonConfig.isDevelop?"test":"prod");   // 产品的发布分支 -- 必填
        config.addConfig(DDSConfig.K_PRODUCT_KEY, AppCommonConfig.PRODUCT_KEY);// Product Key -- 必填
        config.addConfig(DDSConfig.K_PRODUCT_SECRET, AppCommonConfig.PRODUCT_SECRET);// Product Secre -- 必填
        config.addConfig(DDSConfig.K_API_KEY, AppCommonConfig.API_KEY);  // 产品授权秘钥，服务端生成，用于产品授权 -- 必填
        config.addConfig(DDSConfig.K_DEVICE_NAME, getMacAddress(getApplicationContext()));//填入唯一的deviceId -- 选填
        config.addConfig("USE_LOCAL_DEVICE_NAME", "true");
        config.addConfig(DDSConfig.K_MIC_TYPE, "5");
        config.addConfig(DDSConfig.K_AEC_MODE, "internal");
        config.addConfig(DDSConfig.K_USE_SSPE, "true");
        config.addConfig(DDSConfig.K_MIC_ARRAY_SSPE_BIN, "sspe_aec_uda_wkp_30mm_ch4_2mic_1ref_release-v2.0.0.130.bin");
        config.addConfig(DDSConfig.K_AUDIO_CHANNEL_COUNT, "4");
        config.addConfig(DDSConfig.K_AUDIO_SAMPLERATE, "32000");
        config.addConfig(DDSConfig.K_AUDIO_CHANNEL_CONF, AudioFormat.CHANNEL_IN_MONO);
        config.addConfig(DDSConfig.K_WAKEUP_BIN, "wkp_aihome_mzgd_20221202_pre.bin");
        config.addConfig(DDSConfig.K_USE_DUAL_WAKEUP, "true");
        config.addConfig(DDSConfig.K_DUAL_WAKEUP_INIT_ENV,"{\n" +
                "    \"xiao_mei_xiao_mei\":{\n" +
                "        \"customNet\":1,\n" +
                "        \"enableNet\":1,\n" +
                //                "        \"greeting\":[\n" +
                //                "            \"叫我干啥\"\n" +
                //                "        ],\n" +
                "        \"major\":0,\n" +
                "        \"name\":\"小美小美\",\n" +
                "        \"pinyin\":\"xiao_mei_xiao_mei\",\n" +
                "        \"threshHigh\":\"0.9\",\n" +
                "        \"threshLow\":\"0.01\",\n" +
                "        \"threshold\":0.75,\n" +
                "        \"type\":\"major\"\n" +
                "    },\n" +
                "    \"xiao mei xiu mei\":{\n" +
                "        \"customNet\":0,\n" +
                "        \"enableNet\":1,\n" +
                //             "        \"greeting\":[\n" +
                //             "            \"我是小美秀美\"\n" +
                //             "        ],\n" +
                "        \"major\":0,\n" +
                "        \"name\":\"小美小美\",\n" +
                "        \"pinyin\":\"xiao mei xiu mei\",\n" +
                "        \"threshHigh\":\"10\",\n" +
                "        \"threshLow\":\"0.01\",\n" +
                "        \"threshold\":0.54,\n" +
                "        \"type\":\"major\"\n" +
                "    },\n" +
                "    \"xiu mei xiu mei\":{\n" +
                "        \"customNet\":0,\n" +
                "        \"enableNet\":1,\n" +
                //             "        \"greeting\":[\n" +
                //             "            \"我是修眉修眉\"\n" +
                //             "        ],\n" +
                "        \"major\":0,\n" +
                "        \"name\":\"小美小美\",\n" +
                "        \"pinyin\":\"xiu mei xiu mei\",\n" +
                "        \"threshHigh\":\"10\",\n" +
                "        \"threshLow\":\"0.25\",\n" +
                "        \"threshold\":0.45,\n" +
                "        \"type\":\"major\"\n" +
                "    },\n" +
                "    \"xiao mei xiao mei\":{\n" +
                "        \"customNet\":0,\n" +
                "        \"enableNet\":1,\n" +
                //              "        \"greeting\":[\n" +
                //              "            \"表叫我小美\"\n" +
                //              "        ],\n" +
                "        \"major\":0,\n" +
                "        \"name\":\"小美小美\",\n" +
                "        \"pinyin\":\"xiao mei xiao mei\",\n" +
                "        \"threshHigh\":\"10\",\n" +
                "        \"threshLow\":\"0.3\",\n" +
                "        \"threshold\":0.6,\n" +
                "        \"type\":\"major\"\n" +
                "    },\n" +
                "    \"xiu_mei_xiu_mei\":{\n" +
                "        \"customNet\":1,\n" +
                "        \"enableNet\":1,\n" +
                //           "        \"greeting\":[\n" +
                //           "            \"我是修眉修眉e2e\"\n" +
                //           "        ],\n" +
                "        \"major\":0,\n" +
                "        \"name\":\"小美小美\",\n" +
                "        \"pinyin\":\"xiu_mei_xiu_mei\",\n" +
                "        \"threshHigh\":\"0.5\",\n" +
                "        \"threshLow\":\"0.01\",\n" +
                "        \"threshold\":0.4,\n" +
                "        \"type\":\"major\"\n" +
                "    },\n" +
                "    \"xiu mei xiao mei\":{\n" +
                "        \"customNet\":0,\n" +
                "        \"enableNet\":1,\n" +
                //          "        \"greeting\":[\n" +
                //          "            \"我是小美\"\n" +
                //          "        ],\n" +
                "        \"major\":0,\n" +
                "        \"name\":\"小美小美\",\n" +
                "        \"pinyin\":\"xiu mei xiao mei\",\n" +
                "        \"threshHigh\":\"10\",\n" +
                "        \"threshLow\":\"0.01\",\n" +
                "        \"threshold\":0.66,\n" +
                "        \"type\":\"major\"\n" +
                "    }\n" +
                "}");




        // 更多高级配置项,请参考文档: https://www.dui.ai/docs/ct_common_Andriod_SDK 中的 --> 四.高级配置项

        config.addConfig(DDSConfig.K_DUICORE_ZIP, "duicore.zip"); // 预置在指定目录下的DUI内核资源包名, 避免在线下载内核消耗流量, 推荐使用
        config.addConfig(DDSConfig.K_USE_UPDATE_DUICORE, "false"); //设置为false可以关闭dui内核的热更新功能，可以配合内置dui内核资源使用

        // 资源更新配置项
        config.addConfig(DDSConfig.K_CUSTOM_ZIP, "product.zip"); // 预置在指定目录下的DUI产品配置资源包名, 避免在线下载产品配置消耗流量, 推荐使用
        config.addConfig(DDSConfig.K_USE_UPDATE_NOTIFICATION, "false"); // 是否使用内置的资源更新通知栏

        // 录音配置项
        // config.addConfig(DDSConfig.K_RECORDER_MODE, "internal"); //录音机模式：external（使用外置录音机，需主动调用拾音接口）、internal（使用内置录音机，DDS自动录音）
        // config.addConfig(DDSConfig.K_IS_REVERSE_AUDIO_CHANNEL, "false"); // 录音机通道是否反转，默认不反转
        // config.addConfig(DDSConfig.K_AUDIO_SOURCE, AudioSource.DEFAULT); // 内置录音机数据源类型
        // config.addConfig(DDSConfig.K_AUDIO_BUFFER_SIZE, (16000 * 1 * 16 * 100 / 1000)); // 内置录音机读buffer的大小

        // TTS配置项
        config.addConfig(DDSConfig.K_STREAM_TYPE, AudioManager.STREAM_MUSIC); // 内置播放器的STREAM类型
        config.addConfig(DDSConfig.K_TTS_MODE, "internal"); // TTS模式：external（使用外置TTS引擎，需主动注册TTS请求监听器）、internal（使用内置DUI TTS引擎）
        // config.addConfig(DDSConfig.K_CUSTOM_TIPS, "{\"71304\":\"请讲话\",\"71305\":\"不知道你在说什么\",\"71308\":\"咱俩还是聊聊天吧\"}"); // 指定对话错误码的TTS播报。若未指定，则使用产品配置。

        //唤醒配置项
        // config.addConfig(DDSConfig.K_WAKEUP_ROUTER, "dialog"); //唤醒路由：partner（将唤醒结果传递给partner，不会主动进入对话）、dialog（将唤醒结果传递给dui，会主动进入对话）
        // config.addConfig(DDSConfig.K_WAKEUP_BIN, "/sdcard/wakeup.bin"); //商务定制版唤醒资源的路径。如果开发者对唤醒率有更高的要求，请联系商务申请定制唤醒资源。
        // config.addConfig(DDSConfig.K_ONESHOT_MIDTIME, "500");// OneShot配置：
        // config.addConfig(DDSConfig.K_ONESHOT_ENDTIME, "2000");// OneShot配置：

        //识别配置项
        // config.addConfig(DDSConfig.K_ASR_ENABLE_PUNCTUATION, "false"); //识别是否开启标点
        // config.addConfig(DDSConfig.K_ASR_ROUTER, "dialog"); //识别路由：partner（将识别结果传递给partner，不会主动进入语义）、dialog（将识别结果传递给dui，会主动进入语义）
        // config.addConfig(DDSConfig.K_VAD_TIMEOUT, 5000); // VAD静音检测超时时间，默认8000毫秒
        // config.addConfig(DDSConfig.K_ASR_ENABLE_TONE, "true"); // 识别结果的拼音是否带音调
        // config.addConfig(DDSConfig.K_ASR_TIPS, "true"); // 识别完成是否播报提示音
        // config.addConfig(DDSConfig.K_VAD_BIN, "/sdcard/vad.bin"); // 商务定制版VAD资源的路径。如果开发者对VAD有更高的要求，请联系商务申请定制VAD资源。

        // 麦克风阵列配置项
        // config.addConfig(DDSConfig.K_MIC_TYPE, 0); // 设置硬件采集模组的类型 0：无。默认值。 1：单麦回消 2：线性四麦 3：环形六麦 4：车载双麦 5：家具双麦 6: 环形四麦  7: 新车载双麦 8: 线性6麦


        // config.addConfig(DDSConfig.K_MIC_ARRAY_AEC_CFG, "/data/aec.bin"); // 麦克风阵列aec资源的磁盘绝对路径,需要开发者确保在这个路径下这个资源存在
        // config.addConfig(DDSConfig.K_MIC_ARRAY_BEAMFORMING_CFG, "/data/beamforming.bin"); // 麦克风阵列beamforming资源的磁盘绝对路径，需要开发者确保在这个路径下这个资源存在

        // 全双工/半双工配置项
        // config.addConfig(DDSConfig.K_DUPLEX_MODE, "HALF_DUPLEX");// 半双工模式
        // config.addConfig(DDSConfig.K_DUPLEX_MODE, "FULL_DUPLEX");// 全双工模式

        // 声纹配置项
        // config.addConfig(DDSConfig.K_VPRINT_ENABLE, "true");// 是否使用声纹
        // config.addConfig(DDSConfig.K_USE_VPRINT_IN_WAKEUP, "true");// 是否与唤醒结合使用声纹
        // config.addConfig(DDSConfig.K_VPRINT_BIN, "/sdcard/vprint.bin");// 声纹资源的绝对路径

        // asrpp配置荐
        // config.addConfig(DDSConfig.K_USE_GENDER, "true");// 使用性别识别
        // config.addConfig(DDSConfig.K_USE_AGE, "true");// 使用年龄识别

        return config;
    }


    public void setAiEnable(boolean enable) {
        try {
            isAiEnable = enable;
            if (enable) {
                if (DDS.getInstance() != null && DDS.getInstance().getAgent() != null && DDS.getInstance().getAgent().getWakeupEngine() != null) {
                    DDS.getInstance().getAgent().getWakeupEngine().enableWakeup();
                }
            } else {
                if (DDS.getInstance() != null && DDS.getInstance().getAgent() != null && DDS.getInstance().getAgent().getWakeupEngine() != null) {
                    DDS.getInstance().getAgent().getWakeupEngine().disableWakeup();
                }
            }
        } catch (DDSNotInitCompleteException e) {

        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    public void start() {
        // 添加一个初始成功的广播监听器
        MainThread.run(() -> {
            mAiDialog = new AiDialog(MideaAiService.this, this);
            mWeatherDialog=new WeatherDialog(MideaAiService.this,this);
        });
        registMsg();
    }

    @Override
    public void onUpdate(int type, String result) {

    }


    @Override
    public void onMessage(MessageBean mMessageBean) {
        this.mMessageBean = mMessageBean;
        MainThread.run(() -> {
            mWeatherDialog.dismissDialog();
            if (!mAiDialog.isShowing()) {
                mAiDialog.show();
            }
            if (mMessageBean.getType() == TYPE_WIDGET_WEATHER) {
                try {
                    WeatherBean.WebhookRespBean.ExtraBean.ForecastBean today = mMessageBean.getWeatherBean().getWebhookResp().getExtra().getForecast().get(0);
                    Log.e("sky", "天气内容:" + GsonUtils.serializedToJson(today));
                    mWeatherDialog.setWeatherDetail(mMessageBean.getWeatherBean().getWebhookResp().getCityName(),today.getLowTemp(),today.getHighTemp(),
                            today.getWeather(),mMessageBean.getWeatherBean().getWebhookResp().getExtra().getIndex().getAqi().getAQL());
                    mWeatherDialog.show();
                    mAiDialog.initalDialog();
                } catch (Exception e) {

                }
            } else {
                Log.e("sky", "消息内容:" + mMessageBean.getText()+"--类型:"+mMessageBean.getType());
                if (!TextUtils.isEmpty(mMessageBean.getText())) {
                    if(mMessageBean.getText().contains("全天")&&mMessageBean.getText().contains("气温")&&mMessageBean.getText().contains("级")&&mMessageBean.getType()==0){
                        mAiDialog.initalDialog();
                    }else{
                        mAiDialog.addAnsAskItem(mMessageBean.getText());
                    }
                }
            }
        });
    }

    long curUpdateTime=0;
    @Override
    public void onState(String state) {
//        Log.e("sky", "语音状态:" + state);
        switch (state) {
            case "avatar.silence"://等待唤醒
                if(mMessageBean!=null&&mMessageBean.getText().contains("网络好像")){//网络故障延时4秒等播报玩提示后才消失
                    int resID = MideaAiService.this.getResources().getIdentifier("net_error","raw",MideaAiService.this.getPackageName());
                    MediaPlayer mm = MediaPlayer.create(MideaAiService.this, resID);
                    mm.setOnCompletionListener(mediaPlayer -> {
                        mediaPlayer.reset();
                        mediaPlayer.release();
                    });
                    mm.start();
                    new Handler().postDelayed(() -> {
                        Log.e("sky", "等待唤醒");
                        if(SystemClock.uptimeMillis() - curUpdateTime < 1000){
                            //对话状态切换小于1秒时不给响应状态变化
                            return;
                        }
                        MainThread.run(() -> {
                            mWeatherDialog.dismissDialog();
                            mAiDialog.dismissDialog();
                            if(mWakUpStateCallBack!=null){
                                mWakUpStateCallBack.wakUpState(false);
                            }
                            if(isPlayBefore){
                                if(mCommandObserver.hasMediaControlResult){
                                    if(mCommandObserver.mediaControlResult){
                                        MusicManager.getInstance().startMusic();
                                    }
                                }else{
                                    MusicManager.getInstance().startMusic();
                                }
                            }
                        });
                    },4000);
                }else{
                    Log.e("sky", "等待唤醒");
                    if(SystemClock.uptimeMillis() - curUpdateTime < 1000){
                        //对话状态切换小于1秒时不给响应状态变化
                        break;
                    }
                    MainThread.run(() -> {
                        mWeatherDialog.dismissDialog();
                        mAiDialog.dismissDialog();
                        if(mWakUpStateCallBack!=null){
                            mWakUpStateCallBack.wakUpState(false);
                        }
                        if(isPlayBefore){
                            if(mCommandObserver.hasMediaControlResult){
                                if(mCommandObserver.mediaControlResult){
                                    MusicManager.getInstance().startMusic();
                                }
                            }else{
                                MusicManager.getInstance().startMusic();
                            }
                        }
                    });
                }
                break;
            case "avatar.listening"://监听中
                Log.e("sky", "监听中");
                MainThread.run(() -> {
                    if(mWakUpStateCallBack!=null){
                        mWakUpStateCallBack.wakUpState(true);
                    }
                    mWeatherDialog.dismissDialog();
                    if (!mAiDialog.isShowing()) {
                        mAiDialog.show();
                    }
                });
                break;
            case "avatar.understanding"://理解中
                break;
            case "avatar.speaking"://播放语音中
                break;
            case "sys.wakeup.result"://唤醒播放语音中
                Log.e("sky", "唤醒播放语音中");
                curUpdateTime=SystemClock.uptimeMillis();
                MainThread.run(() -> {
                    mWeatherDialog.dismissDialog();
                    if (!mAiDialog.isShowing()) {
                        mAiDialog.show();
                    }
                    mCommandObserver.mediaControlResult=false;
                    mCommandObserver.hasMediaControlResult=false;
                    isPlayBefore= MusicManager.getInstance().isPaying();
                    MusicManager.getInstance().pauseMusic();
                    int wakeupnum = new Random().nextInt(7) + 1;
                    int resID = MideaAiService.this.getResources().getIdentifier("greeting"+wakeupnum,"raw",MideaAiService.this.getPackageName());
                    MediaPlayer mm = MediaPlayer.create(MideaAiService.this, resID);
                    mm.setOnCompletionListener(mediaPlayer -> {
                        mediaPlayer.reset();
                        mediaPlayer.release();
                    });
                    mm.start();
                });
                break;
        }
    }


    // 停止service, 释放dds组件
    public void stopService() {
        try {
            MusicManager.getInstance().stopService();
            AccountManager.getInstance().clearToken();
            DDS.getInstance().getAgent().clearAuthCode();
            DDS.getInstance().releaseSync();
            mCommandObserver.unregist();
            mMessageObserver.unregist();
        }catch (Exception e){

        }
    }

    // 打开唤醒，调用后才能语音唤醒
    void enableWakeup() {
        try {
            DDS.getInstance().getAgent().getWakeupEngine().enableWakeup();
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
    }

    // 关闭唤醒, 调用后将无法语音唤醒
    void disableWakeup() {
        try {
            DDS.getInstance().getAgent().stopDialog();
            DDS.getInstance().getAgent().getWakeupEngine().disableWakeup();
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
    }

    private void registMsg() {
        // 注册消息监听器
        mMessageObserver.regist(this, mMessageList);
        mCommandObserver.regist();
        mNativeApiObserver.regist();
    }

    public void addWakUpStateCallBack(WakUpStateCallBack CallBack){
        mWakUpStateCallBack=CallBack;
    }

    public void addAISetVoiceCallBack(AISetVoiceCallBack CallBack){
        mCommandObserver.addAISetVoiceCallBack(CallBack);
    }

    public void addAISetIntialCallBack(IntialCallBack CallBack){
        mIntialCallBack=CallBack;
    }
}
