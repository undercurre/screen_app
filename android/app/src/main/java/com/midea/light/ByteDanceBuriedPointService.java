package com.midea.light;

import com.bytedance.applog.AppLog;
import com.bytedance.applog.InitConfig;
import com.bytedance.applog.UriConfig;
import com.bytedance.applog.exception.AppCrashType;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.record.BuriedPointService;
import com.midea.light.setting.SystemUtil;

import org.json.JSONObject;

import java.util.HashMap;

public class ByteDanceBuriedPointService implements BuriedPointService {

    static {
        initAppLog();
    }

    @Override
    public void reportEvent(String eventName, JSONObject value) {
        AppLog.onEventV3(eventName, value);
    }

    @Override
    public void reportEvent(String eventName) {
        AppLog.onEventV3(eventName);
    }

    public static void initAppLog() {
        assert AppCommonConfig.BURIED_POINT_ID != null;
        final InitConfig config = new InitConfig(AppCommonConfig.BURIED_POINT_ID, "p10_channel");
        // 设置数据上送地址
        config.setUriConfig(UriConfig.createByDomain("https://iotsdk.midea.com", null));
        // 是否 init 后自动 start 可改为 false，并请在用户授权后调用 start 开启采集
        config.setAutoStart(true);
        // 全埋点开关，true开启，false关闭
        config.setAutoTrackEnabled(false);
        // true:开启日志，参考4.3节设置logger，false:关闭日志
        config.setLogEnable(false);
        //java奔溃采集
        config.setTrackCrashType(AppCrashType.JAVA);
        // Fragment页面事件采集
        config.setAutoTrackFragmentEnabled(true);
        // 加密开关，true开启，false关闭
        AppLog.setEncryptAndCompress(true);
        // 初始化一次即可
        // Applition 中初始化建议使用该方法
        try {
            AppLog.init(BaseApplication.getContext(), config);
        } catch (Exception e) {
            /*
             *
             * Android SDK 接入为什么会出现Didn't find class "com.android.id.impl.IdProviderImpl" 报错？
             * 这个报错不会影响SDK的正常初始化。
             * 错误的原因是当前版本的SDK提供了对华为、小米最新版本（AndroidQ）手机设备id获取能力，当在模拟器或低版本设备中运行时，控制台会打印这个错误信息，但不会影响SDK的正常初始化和使用。
             *
             */
        }
        AppLog.setUserUniqueID(SystemUtil.getMacAddress());
        AppLog.setHeaderInfo(new HashMap<String, Object>() {
            {
                put("screen_dimension", "4ch");
                put("hardware", "JH");
            }
        });
    }

}
