package com.midea.light.homeos;

/**
 * 对controller做第二次封装，处理心跳包 和 设置消息监听
 *
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
        if(msg.contains("/local/controller/status")) {
            heartBeat(String.valueOf(System.currentTimeMillis()));
        } else {
            if(callback != null) {
                callback.msg(topic, msg);
            }
        }
    }

}
