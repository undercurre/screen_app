package com.midea.homlux.ai.AiSpeech;

public class AIDeviceInfo {
    private String sn;
    private String model;
    private String category;
    private String iot_id;
    private String mac;
    private String cfg_path;

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    private String ip;

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getIot_id() {
        return iot_id;
    }

    public void setIot_id(String iot_id) {
        this.iot_id = iot_id;
    }

    public String getMac() {
        return mac;
    }

    public void setMac(String mac) {
        this.mac = mac;
    }

    public String getCfg_path() {
        return cfg_path;
    }

    public void setCfg_path(String cfg_path) {
        this.cfg_path = cfg_path;
    }
}
