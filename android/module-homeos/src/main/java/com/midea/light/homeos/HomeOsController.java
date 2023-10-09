package com.midea.light.homeos;

/**
 * 增加请求超时机制
 */
public class HomeOsController extends controller {

    HomeOsControllerCallback callback;

    public void setCallback(HomeOsControllerCallback callback) {
        this.callback = callback;
    }

    @Override
    public void log(String logStr) {
        super.log(logStr);
        if(callback != null) {
            callback.log(logStr);
        }
    }

    @Override
    public void mqttMsgHandle(String topic, String msg) {
        super.mqttMsgHandle(topic, msg);
        if(msg == null) return;
        // 处理homeOs心跳
        if(msg.contains("/controller/status")) {
            heartBeat(String.valueOf(System.currentTimeMillis()));
        } else {
            if(callback != null) {
                callback.msg(topic, msg);
            }
        }
    }

}
