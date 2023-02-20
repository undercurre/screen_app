package com.midea.light.common.config;

import android.text.TextUtils;

import com.midea.light.BaseApplication;
import com.midea.light.basic.BuildConfig;
import com.midea.light.utils.AndroidManifestUtil;
import com.midea.light.utils.SDCardUtil;

import java.util.Objects;

/**
 * @ClassName AppCommonConfig
 * @Description App应用全局配置
 * @Author weinp1
 * @Date 2022/4/25 10:47
 * @Version 1.0
 */

public class AppCommonConfig {
    private static final boolean PRODUCT_NOT_DIRECTOR = false;
    // 配置--开发环境
    public static final String CONFIG_TYPE_DEVELOP = "development";
    // 配置--正式环境
    public static final String CONFIG_TYPE_PRODUCT = "production";

    // 当前应用运行的类型
    private static String SYSTEM_TYPE;
    //腾讯MMKV 加密数据密钥 (固定写死，后期可与后台参与定制此类密钥交换机制)
    public static final String MMKV_CRYPT_KEY = "16a62e2997ae0dda";
    //中台的openId
    public static final String CENTER_OPEN_ID = "meizhiguangdian";
    //阿里推送
    public static String KEY_ALIPUSH = "333452890";
    public static String SECRET_ALIPUSH = "67e79bff6db54f85a71d7b06d766868a";
    //IOT平台开发者账号
    public static final String IOT_APP_COUNT = "12002";
    public static final String IOT_SECRET = "82d678d345679603628d1c2934e0f8ab";

    public static final String SSE_SECRET = "&c6cf1eb6b5de40cba85a14ad5711d315";
    public static final String ALI_PUSH_USER_NAME = "82dc6694";
    public static final String ALI_PUSH_PASSWORD = "5e987ac6d2e04d95a9d8f0d1";
    //代表Android平台
    public static final int PLATFORM = 1;
    //bugly密钥
    private static String KEY_BUGLY;
    //iot开发者平台的产品编码
    private static String PRODUCT_CODE;
    //网络配置 -- 中台 http://confluence.msmart.com/pages/viewpage.action?pageId=10022526
    public static String HOST;
    //SSE推送host配置
    public static String SSE_HOST;
    //天气网络配置
    public static String WEATHER_URL_HOST;
    //Rom升级网络配置
    public static String  ROM_UP_GRADE_HOST;
    //Ai授权后中台通知A云配置
    public static String NOTICE_AI_CLOUD_HOST;
    //设备wifi配网的server
    public static String WIFI_DEVICE_SERVER_DOMAIN;
    //网络配置 --- 登录模块Netty客户端连接的URL
    public static String HOST_LOGIN_NETTY;
    // 网络连接相关时间配置。(单位为：秒)
    public static final long TIME_READ = 20;
    public static final long TIME_WRITE = 20;
    public static final long TIME_CONNECT = 30;
    //进行网络请求时，请求数据加密的操作 --- 测试环境
    public static String HTTP_SIGN_SECRET;
    //用于设备绑定中的RequestHeaderDataKEY
    public static String HTTP_REQUEST_HEADER_DATA_KEY;


    public static boolean IS_LOGIN_DIRECT() {
        //直接进入登录不判断是否需要绑定 | System.getProperty("bind-gateway", "null") 用于控制登录是否可以绕开绑定网关，可以到开发者界面中进行设置
        return !BuildConfig.DEBUG ? PRODUCT_NOT_DIRECTOR : System.getProperty("bind-gateway", "null").equals("null");
    }

    //美智平台Host配置
    public static String MZ_HOST;
    public static String MZ_APP_ID;
    public static String MZ_APP_SECRET;

    public static int ASD_ID;
    private static String CHANNEL; // LD -》灵动 JH -》 晶华

    // ##动态获取当前的渠道
    public static String getChannel() {
        if (TextUtils.isEmpty(CHANNEL)) {
            CHANNEL = AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "channel");
        }
        return CHANNEL;
    }

    // ##动态获取当前Bugly的ID
    public static String getBuglyID() {
        if (TextUtils.isEmpty(KEY_BUGLY))
            KEY_BUGLY = AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "BUGLY_ID");
        return KEY_BUGLY;
    }

    // ##判断当前运行的环境是否为十寸屏
    public static boolean isTenSystem() {
        if (TextUtils.isEmpty(SYSTEM_TYPE))
            SYSTEM_TYPE = AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "SYSTEM_TYPE");
        return Objects.equals(SYSTEM_TYPE, "PAD_TEN");
    }

    // ##判断当前运行的环境是否为四寸屏
    public static boolean isFourSystem() {
        if (TextUtils.isEmpty(SYSTEM_TYPE))
            SYSTEM_TYPE = AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "SYSTEM_TYPE");
        return Objects.equals(SYSTEM_TYPE, "PAD_FOUR");
    }

    // ##动态获取PRODUCT_CODE
    public static String getProductCode() {
        if (TextUtils.isEmpty(PRODUCT_CODE))
            PRODUCT_CODE = AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "PRODUCT_CODE");
        return PRODUCT_CODE;
    }


    private static class DeveloperConfig {
        public static void init() {
            HOST = "https://mp-sit.smartmidea.net";
            WEATHER_URL_HOST = "http://iot-support-sit.smartmidea.net";
            NOTICE_AI_CLOUD_HOST = "http://sit.aimidea.cn:11003";
            HOST_LOGIN_NETTY = "mp-sit.smartmidea.net";
            HTTP_SIGN_SECRET = "sit_secret123@muc";
            HTTP_REQUEST_HEADER_DATA_KEY = "SIT_4VjZdg19laDoIrut";
            WIFI_DEVICE_SERVER_DOMAIN = "iotlab.midea.com.cn";
            ROM_UP_GRADE_HOST = "http://8.135.27.6:8007/v1/base2pro/uploadFile";
            MZ_HOST = "http://47.106.94.129:8001";
            MZ_APP_ID = "testMidea001";
            MZ_APP_SECRET = "test001";
            ROM_UP_GRADE_HOST= "http://8.135.27.6:8007/v1/base2pro/uploadFile";
            SSE_HOST = "sse-sit.smartmidea.net";
            ASD_ID = 0x010102;
        }
    }

    private static class ProductConfig {
        public static void init() {
            HOST = "https://mp-prod.smartmidea.net";
            WEATHER_URL_HOST = "http://iot-support.smartmidea.net";
            NOTICE_AI_CLOUD_HOST = "https://api.aimidea.cn:11003";
            HOST_LOGIN_NETTY = "mline.smartmidea.net";
            HTTP_SIGN_SECRET = "prod_secret123@muc";
            HTTP_REQUEST_HEADER_DATA_KEY = "PROD_VnoClJI9aikS8dyy";
            WIFI_DEVICE_SERVER_DOMAIN = "iot1.midea.com.cn";
            ROM_UP_GRADE_HOST = "https://mzcategory.meizgd.com/v1/base2pro/uploadFile";
            MZ_HOST = "https://mzaio.meizgd.com";
            MZ_APP_ID = "smartScreen001";
            MZ_APP_SECRET = "6f7d48b9d40f41f7b841885b5fe12829";
            ROM_UP_GRADE_HOST= "https://mzcategory.meizgd.com/v1/base2pro/uploadFile";
            SSE_HOST = "sse.smartmidea.net";
            ASD_ID = 0x010101;
        }
    }

    /**
     * ===================================     全局配置文件路径    ==================================
     */
    // { /data/user/0/${packName}/cache }
    private static final String APP_CACHE = BaseApplication.getContext().getCacheDir().getAbsolutePath();
    // { /data/user/0/${packName}/files }
    private static final String APP_FILE = BaseApplication.getContext().getFilesDir().getAbsolutePath();
    // { /storage/emulated/0/Android/data/&{packageName}/cache }
    private static final String STORAGE_CACHE = BaseApplication.getContext().getExternalCacheDir().getAbsolutePath();
    // { /storage/emulated/0/Android/data/&{packageName}/files }
    private static final String STORAGE_FILE = BaseApplication.getContext().getExternalFilesDir(null).getAbsolutePath();

    // 下面指定业务路径
    // 存放与用户相关数据的路径
    public static final String USER_SETTING_DIR = APP_CACHE + "/setting/user";
    // 存放全局系统配置或其他全局配置的数据路径
    public static final String SYSTEM_SETTING_DIR = STORAGE_CACHE + "/setting/system";
    // 本地数据库保存的路径
    public static final String STORAGE_DATABASE = STORAGE_FILE + "/db";
    // 保存设备配网的状态信息
    public static final String DEVICE_SETTING_DIR = APP_CACHE + "/setting/device";
    //保存wifi密码等信息
    public static final String WIFI_RECORD = STORAGE_CACHE + "/setting/wifi";
    //保存网关SN applianceCode等信息
    public static final String GATE_WAY_DIR = APP_CACHE + "/setting/gateway";
    //场景模块保存路径
    public static final String SCENE_DIR = STORAGE_CACHE + "/scene";
    //记录卡片中心需要保存的id
    public static final String CARD_CENTER_DIR = APP_CACHE + "/card/center";
    // 设备模块保存的路径
    public static final String DEVICE_DIR = STORAGE_CACHE + "/device";

    // Glide保存缓存图片的保存到SD卡路径
    public static final String STORAGE_IMAGE_CACHE = SDCardUtil.existSDCard() ? STORAGE_FILE : APP_FILE + "/image_cache";
    // Glide缓存到本地文件的最高缓存大小
    public static final int IMAGE_CACHE_SIZE = 1024 * 1024 * 50;


    public static void init(String type) {
        if (Objects.equals(type, CONFIG_TYPE_DEVELOP)) {
            DeveloperConfig.init();
        } else if (Objects.equals(type, CONFIG_TYPE_PRODUCT)) {
            ProductConfig.init();
        }
    }


}
