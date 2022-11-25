package com.midea.light.setting.wifi.impl.entity;

/**
 * @ClassName WiFiAccountPasswordBean
 * @Description wifi密码与账号
 * @Author weinp1
 * @Date 2021/8/17 15:04
 * @Version 1.0
 */
public class WiFiAccountPasswordBean {
    private String ssid;
    private String bssid;
    private String password;
    private String encryptType;

    public WiFiAccountPasswordBean() {

    }

    public WiFiAccountPasswordBean(String ssid, String bssid, String password, String encryptType) {
        this.ssid = ssid;
        this.password = password;
        this.encryptType = encryptType;
        this.bssid = bssid;
    }

    public String getBssid() {
        return bssid;
    }

    public void setBssid(String bssid) {
        this.bssid = bssid;
    }

    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setEncryptType(String encryptType) {
        this.encryptType = encryptType;
    }

    public String getSsid() {
        return ssid;
    }

    public String getPassword() {
        return password;
    }

    public String getEncryptType() {
        return encryptType;
    }

    @Override
    public String toString() {
        return "WiFiAccountPasswordBean{" +
                "ssid='" + ssid + '\'' +
                ", password='" + password + '\'' +
                ", encryptType='" + encryptType + '\'' +
                '}';
    }
}
