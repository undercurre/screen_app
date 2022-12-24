package com.midea.light.device.explore.config;

/**
 * @ClassName BaseConfig
 * @Description 绑定设备的通用配置
 * @Author weinp1
 * @Date 2022/12/21 14:33
 * @Version 1.0
 */
public class BaseConfig {
    boolean debug = false; // 是否打开调试
    String host; // 当前服务器url
    String token; // 当前登录的it Token
    String httpSign; // 当前环境的http请求密钥
    String httpDataSecret; // 登录成功之后，云端返回的敏感数据加密密钥
    String deviceId; // 设备ID
    String userId; // 当前IT uid


    public BaseConfig(String host, String token, String httpSign,
                      String httpDataSecret, String deviceId, String userId) {
        this.host = host;
        this.token = token;
        this.httpSign = httpSign;
        this.httpDataSecret = httpDataSecret;
        this.deviceId = deviceId;
        this.userId = userId;
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

    public String getHttpDataSecret() {
        return httpDataSecret;
    }

}
