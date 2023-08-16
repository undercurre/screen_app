package com.midea.homlux.ai;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.Log;

import com.aispeech.dca.Callback;
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
import com.midea.homlux.ai.impl.AISetVoiceCallBack;
import com.midea.homlux.ai.impl.WakUpStateCallBack;
import com.midea.homlux.ai.music.MusicManager;
import com.midea.homlux.ai.services.DDSService;
import com.midea.homlux.ai.services.MideaAiService;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.utils.DialogUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import static android.content.Context.BIND_AUTO_CREATE;


public class AiManager {
    private int mAuthCount = 0;// 授权次数,用来记录自动授权
    private boolean ddsIntial = false;
    private boolean isAiEnable = true;
    Activity context;
    WakUpStateCallBack mWakUpStateCallBack;
    AISetVoiceCallBack mAISetVoiceCallBack;
    MyReceiver mInitReceiver;

    private AiManager() {

    }

    public static AiManager Instance = new AiManager();

    public static AiManager getInstance() {
        return Instance;
    }

    public void startDuiAi(Activity context, String uid, String token, String refreshToken, int ExpiresTime, boolean aiEnable, WakUpStateCallBack mCallBack, AISetVoiceCallBack VoiceCallBack) {
        this.context = context;
        mWakUpStateCallBack = mCallBack;
        mAISetVoiceCallBack = VoiceCallBack;
        isAiEnable = aiEnable;
        new Thread() {
            public void run() {
                while (true) {
                    if (checkNet()) {
                        context.runOnUiThread(() -> {
//                            Log.e("sky","参数uid:"+uid+"---参数token:"+token+"---参数refreshToken:"+refreshToken+"---参数ExpiresTime:"+ExpiresTime);
                            DialogUtil.showLoadingMessage(context, "同步家庭数据中");
                            AccountLogin(uid, token, refreshToken, ExpiresTime);
                        });
                        break;
                    }
                }
            }
        }.start();
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
                AiConfig.authcode = authcode;
                AiConfig.codeVerifier = codeVerifier;
                AiConfig.userId = AccountManager.getInstance().getUserId();
                startDDSService();

            }
        });
        OAuthManager.getInstance().requestAuthCode(codeChallenge, AiConfig.redirectUri, AppCommonConfig.CLIENT_ID);
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


    public void startDDSService() {
        context.startService(DDSService.newDDSServiceIntent(context, "start"));
        new Thread() {
            public void run() {
                checkDDSReady();
            }
        }.start();
        IntentFilter filter = new IntentFilter();
        filter.addAction("ddsdemo.intent.action.init_complete");
        mInitReceiver = new MyReceiver();
        context.registerReceiver(mInitReceiver, filter);
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
                        if (ddsIntial == true) {
                            Intent intent2 = new Intent(AiManager.this.context, MideaAiService.class);
                            AiManager.this.context.bindService(intent2, conn, BIND_AUTO_CREATE);
                            context.runOnUiThread(() -> {
                                MusicManager.getInstance().startMusicServer(context);
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

    private ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            MideaAiService.MyBinder mMyBinder = (MideaAiService.MyBinder) binder;
            mMyBinder.getService().start(context);
            mMyBinder.getService().addWakUpStateCallBack(mWakUpStateCallBack);
            mMyBinder.getService().addAISetVoiceCallBack(mAISetVoiceCallBack);
            setAiEnable(isAiEnable);
            try {
//                if (GlobalSetting.getInstance().getHomluxAiFullDuplex()) {
//                    DDS.getInstance().getAgent().setDuplexMode(Agent.DuplexMode.FULL_DUPLEX);
//                } else {
//                    DDS.getInstance().getAgent().setDuplexMode(Agent.DuplexMode.HALF_DUPLEX);
//                }
                DDS.getInstance().getAgent().setDuplexMode(Agent.DuplexMode.HALF_DUPLEX);
            } catch (DDSNotInitCompleteException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    };

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

    public void wakeupAi() {
        try {
            if (DDS.getInstance().getAgent() != null) {
                DDS.getInstance().getAgent().avatarClick();
            }
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
    }

    public void setAiEnable(boolean enable) {
        try {
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

    /**
     * @return
     * @category 判断是否有外网连接（普通方法不能判断外网的网络是否连接，比如连接上局域网）必须要有外网才能初始化语音
     */
    public boolean checkNet() {
        String result = null;
        try {
            String ip = "www.baidu.com";// ping 的地址，可以换成任何一种可靠的外网
            Process p = Runtime.getRuntime().exec("ping -c 3 -w 100 " + ip);// ping网址3次
            // 读取ping的内容，可以不加
            InputStream input = p.getInputStream();
            BufferedReader in = new BufferedReader(new InputStreamReader(input));
            StringBuffer stringBuffer = new StringBuffer();
            String content;
            while ((content = in.readLine()) != null) {
                stringBuffer.append(content);
            }
            //Log.d("------ping-----", "result content : " + stringBuffer.toString());
            // ping的状态
            int status = p.waitFor();
            if (status == 0) {
                result = "success";
                return true;
            } else {
                result = "failed";
            }
        } catch (IOException e) {
            result = "IOException";
        } catch (InterruptedException e) {
            result = "InterruptedException";
        } finally {
            //Log.d("----result---", "result = " + result);
        }
        return false;
    }

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

    public void stopAi() {
        if (context != null) {
            try {
                Intent intentDDSService = new Intent(context, DDSService.class);
                Intent intentAiService = new Intent(context, MideaAiService.class);
                context.stopService(intentDDSService);
                context.stopService(intentAiService);
                context.unbindService(conn);
                context.unregisterReceiver(mInitReceiver);
                MusicManager.getInstance().stopService();
                AccountManager.getInstance().clearToken();
            } catch (IllegalArgumentException e) {

            }

        }

    }


}
