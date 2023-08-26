package com.midea.light.homeos;

/**
 * 增加请求超时机制
 */
public class HomeOsController extends controller {

    public interface ICallback {
        void msg(String topic, String msg);

        void log(String msg);
    }
    ICallback callback;

    public void setCallback(ICallback callback) {
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
        if(callback != null) {
            callback.msg(topic, msg);
        }
    }

}
