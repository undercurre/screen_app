package com.midea.homlux.ai.services;

import android.annotation.TargetApi;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dds.DDSAuthListener;
import com.aispeech.dui.dds.DDSConfig;
import com.aispeech.dui.dds.DDSInitListener;
import com.aispeech.dui.dds.auth.AuthInfo;
import com.aispeech.dui.dds.exceptions.DDSNotInitCompleteException;
import com.aispeech.dui.oauth.TokenListener;
import com.aispeech.dui.oauth.TokenResult;
import com.midea.homlux.ai.AiSpeech.AiConfig;
import com.midea.light.common.config.AppCommonConfig;

import static com.aispeech.dui.dds.utils.DeviceUtil.getMacAddress;

/**
 * 参见Android SDK集成文档: https://www.dui.ai/docs/operation/#/ct_common_Andriod_SDK
 */
public class DDSService extends Service {
    public static final String TAG = "DDSService";
    private static boolean isStarted = false;

    public DDSService() {
    }

    public static Intent newDDSServiceIntent(Context context, String action) {
        Intent intent = new Intent(context, DDSService.class);
        intent.setAction(action);
        return intent;
    }

    @Override
    public void onCreate() {
        Log.i(TAG, "DDSService on create");
        isStarted = false;
        setForeground();
        super.onCreate();
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @TargetApi(Build.VERSION_CODES.O)
    private void setForeground() {

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            String action = intent.getAction();
            Log.i(TAG, "action:" + action);
            if (TextUtils.equals(action, "start")) {
                if (isStarted) {
                    Log.i(TAG, "already started");
                    return super.onStartCommand(intent, flags, startId);
                }
                init();
                isStarted = true;
            } else if (TextUtils.equals(action, "stop")) {
                //关闭timerstopRefreshTokenTimer()
                if (!isStarted) {
                    Log.i(TAG, "already stopped");
                    return super.onStartCommand(intent, flags, startId);
                }
                isStarted = false;
                DDS.getInstance().releaseSync();
            }
        }
        return super.onStartCommand(intent, flags, startId);
    }

    // 初始化dds组件
    private void init() {
        DDS.getInstance().init(getApplicationContext(), createConfig(), mInitListener, mAuthListener);
        DDS.getInstance().setDebugMode(6); //在调试时可以打开sdk调试日志，在发布版本时，请关闭
        DDS.getInstance().stopDebug();
    }

    // dds初始状态监听器,监听init是否成功
    private DDSInitListener mInitListener = new DDSInitListener() {
        @Override
        public void onInitComplete(boolean isFull) {
            Log.d(TAG, "onInitComplete " + isFull);
            if (isFull) {
                // 发送一个init成功的广播
                sendBroadcast(new Intent("ddsdemo.intent.action.init_complete"));

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

                        }
                    });
                } catch (DDSNotInitCompleteException e) {
                    e.printStackTrace();
                }

            }
        }

        @Override
        public void onError(int what, final String msg) {
            Log.e(TAG, "Init onError: " + what + ", error: " + msg);
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    Log.e(TAG, "初始化失败...");
                }
            });
        }
    };

    // dds认证状态监听器,监听auth是否成功
    private DDSAuthListener mAuthListener = new DDSAuthListener() {
        @Override
        public void onAuthSuccess() {
            Log.d(TAG, "onAuthSuccess");
        }

        @Override
        public void onAuthFailed(final String errId, final String error) {
            Log.e(TAG, "onAuthFailed: " + errId + ", error:" + error);
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(getApplicationContext(),
                            "授权错误:" + errId + ":\n" + error + "\n请查看手册处理", Toast.LENGTH_SHORT).show();
                }
            });
            // 发送一个认证失败的广播
            sendBroadcast(new Intent("ddsdemo.intent.action.auth_failed"));
        }
    };


    @Override
    public void onDestroy() {
        super.onDestroy();
        // 在退出app时将dds组件注销
        isStarted = false;
        DDS.getInstance().releaseSync();
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

        Log.i(TAG, "config->" + config.toString());
        return config;
    }

}
