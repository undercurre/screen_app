package com.midea.homlux.ai.services;

import static com.midea.homlux.ai.bean.MessageBean.TYPE_WIDGET_WEATHER;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.os.Binder;
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
import com.aispeech.dui.dds.agent.Agent;
import com.aispeech.dui.dds.exceptions.DDSNotInitCompleteException;
import com.midea.homlux.ai.AiSpeech.AiConfig;
import com.midea.homlux.ai.AiSpeech.AiDialog;
import com.midea.homlux.ai.AiSpeech.WeatherDialog;
import com.midea.homlux.ai.api.HomluxAiApi;
import com.midea.homlux.ai.bean.MessageBean;
import com.midea.homlux.ai.bean.WeatherBean;
import com.midea.homlux.ai.impl.AISetVoiceCallBack;
import com.midea.homlux.ai.impl.WakUpStateCallBack;
import com.midea.homlux.ai.music.MusicManager;
import com.midea.homlux.ai.observer.DuiCommandObserver;
import com.midea.homlux.ai.observer.DuiMessageObserver;
import com.midea.homlux.ai.observer.DuiNativeApiObserver;
import com.midea.homlux.ai.observer.DuiUpdateObserver;
import com.midea.light.ai.IHomluxAIInterface;
import com.midea.light.ai.IHomluxAISetVoiceCallBack;
import com.midea.light.ai.IHomluxWakeUpStateCallback;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.utils.DialogUtil;
import com.midea.light.common.utils.GsonUtils;
import com.midea.light.common.utils.NetUtil;
import com.midea.light.thread.MainThread;

import java.io.IOException;
import java.util.LinkedList;
import java.util.Random;


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

    private int mAuthCount = 0;// 授权次数,用来记录自动授权
    private boolean ddsIntial = false;
    private boolean isAiEnable = true;
    private boolean isIntial = false;

    private static boolean sdkInit = false;

    MyReceiver mInitReceiver;

    class MyReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String name = intent.getAction();
            Log.e("sky", "DDS初始化接收广播:" + name);
            if (!TextUtils.isEmpty(name) && name.equals("ddsdemo.intent.action.init_complete")) {
                Log.e("sky", "DDS初始化完成");
                ddsIntial = true;
            }
        }
    }

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
        new Thread() {
            public void run() {
                while (true) {
                    if (NetUtil.checkNet()) {
                        HomluxAiApi.syncQueryDuiToken(houseId, aiClientId, token, entity -> {
                            if (entity != null) {
                                startDuiAi(uid, entity.getResult().getAccessToken(), entity.getResult().getRefreshToken(),
                                        entity.getResult().getAccessTokenExpireTime(), aiEnable);
                            }
                        });
                        break;
                    }
                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
        }.start();
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
        AccountManager.getInstance().linkAccount(uid, token, AppCommonConfig.MANUFACTURE, new AccountListener() {
            @Override
            public void onError(int i, String s) {
                DialogUtil.closeLoadingDialog();
                DialogUtil.showToast("语音初始化失败!");
                Log.d("sky", "linkAccountOnError : " + s);
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
                DialogUtil.showToast("语音初始化失败!");
                DialogUtil.closeLoadingDialog();
            }

            @Override
            public void onSuccess(final String authcode) {
                Log.e("sky", "OAuthSuc");
                AiConfig.authcode = authcode;
                AiConfig.codeVerifier = codeVerifier;
                AiConfig.userId = AccountManager.getInstance().getUserId();
                startDDSService();
            }
        });
        OAuthManager.getInstance().requestAuthCode(codeChallenge, AiConfig.redirectUri, AppCommonConfig.CLIENT_ID);
    }


    public void startDDSService() {
        startService(DDSService.newDDSServiceIntent(MideaAiService.this, "start"));
        new Thread() {
            public void run() {
                checkDDSReady();
            }
        }.start();
        IntentFilter filter = new IntentFilter();
        filter.addAction("ddsdemo.intent.action.init_complete");
        mInitReceiver = new MyReceiver();
        MideaAiService.this.registerReceiver(mInitReceiver, filter);
    }


    // 检查dds是否初始成功
    public void checkDDSReady() {
        while (true) {
            if (DDS.getInstance().getInitStatus() == DDS.INIT_COMPLETE_FULL || DDS.getInstance().getInitStatus() == DDS.INIT_COMPLETE_NOT_FULL) {
                Log.e("sky", "DDS初始化");
                try {
                    if (DDS.getInstance().isAuthSuccess()) {
                        //开启DDS服务成功
                        Log.e("sky", "开启DDS服务成功");
                        if (ddsIntial) {
                            start();
                            setAiEnable(isAiEnable);
                            try {
                                DDS.getInstance().getAgent().setDuplexMode(Agent.DuplexMode.HALF_DUPLEX);
                            } catch (DDSNotInitCompleteException e) {
                                e.printStackTrace();
                            }
                            MainThread.run(() -> {
                                MusicManager.getInstance().startMusicServer(MideaAiService.this);
                                DialogUtil.closeLoadingDialog();
                            });
                            break;
                        }
                    } else {
                        // 自动授权
                        Log.e("sky", "自动授权");
                        doAutoAuth();
                        if (mAuthCount == 5) {
                            DialogUtil.closeLoadingDialog();
                            break;
                        }
                    }
                } catch (Exception e) {
                    DialogUtil.closeLoadingDialog();
                    Log.e("sky", "DDS错误:" + e.getMessage());
                }
            } else {
                Log.e("sky", "waiting  init complete finish..." + DDS.getInstance().getInitStatus());
            }
            try {
                Thread.sleep(800);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    // 执行自动授权,这次只是语音证书授权并不是账号打通授权
    private void doAutoAuth() {
        // 自动执行授权5次,如果5次授权失败之后,给用户弹提示框
        if (mAuthCount < 5) {
            try {
                Log.e("sky", "DDS授权");
                DDS.getInstance().doAuth();
                mAuthCount++;
            } catch (DDSNotInitCompleteException e) {
                e.printStackTrace();
            }
        } else {
            DialogUtil.closeLoadingDialog();
            DialogUtil.showToast("语音授权失败!");
        }
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
        enableWakeup();
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
        AccountManager.getInstance().clearToken();
        MideaAiService.this.unregisterReceiver(mInitReceiver);
        MusicManager.getInstance().stopService();
        stopService(new Intent(MideaAiService.this, DDSService.class));
        mCommandObserver.unregist();
        mMessageObserver.unregist();
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


}
