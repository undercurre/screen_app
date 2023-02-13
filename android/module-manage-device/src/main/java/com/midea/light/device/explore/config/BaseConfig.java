package com.midea.light.device.explore.config;

/**
 * @ClassName BaseConfig
 * @Description 绑定设备的通用配置
 * @Author weinp1
 * @Date 2022/12/21 14:33
 * @Version 1.0
 */
public class BaseConfig {
    boolean debug = true; // 是否打开调试
    String host; // 当前服务器url
    String token; // 当前登录的it Token
    String httpSign; // 当前环境的http请求密钥
    String seed; // 登录成功之后，云端返回的敏感数据加密密钥 比如加密SN等
    String key; // 登录成功之后，云端返回的敏感数据加密密钥
    String deviceId; // 设备ID
    String userId; // 当前IT uid
    String iotAppCount; // app账号
    String iotSecret; // iot密钥
    String httpHeaderDataKey; //iot头部请求密钥


    public BaseConfig(String host, String token, String httpSign,
                      String seed, String key, String deviceId, String userId,
                      String iotAppCount, String iotSecret, String httpHeaderDataKey
    ) {
        this.host = host;
        this.token = token;
        this.httpSign = httpSign;
        this.seed = seed;
        this.key = key;
        this.deviceId = deviceId;
        this.userId = userId;
        this.iotAppCount = iotAppCount;
        this.iotSecret = iotSecret;
        this.httpHeaderDataKey = httpHeaderDataKey;
    }

    // 因为token的有效期为三个小时，所以对外需要暴露更新token的方法
    public void updateToken(String token) {
        this.token = token;
    }

    public String getHttpHeaderDataKey() {
        return httpHeaderDataKey;
    }

    public String getIotSecret() {
        return iotSecret;
    }

    public String getIotAppCount() {
        return iotAppCount;
    }

    public String getUserId() {
        return userId;
    }

    public String getHost() {
        return host;
    }

    public void setDebug(boolean debug) {
        this.debug = debug;
    }

    public boolean isDebug() {
        return debug;
    }

    public String getToken() {
        return token;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public String getHttpSign() {
        return httpSign;
    }

    public String getKey() {
        return key;
    }

    public String getSeed() {
        return seed;
    }
}
