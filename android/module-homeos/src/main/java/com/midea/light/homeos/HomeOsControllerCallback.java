package com.midea.light.homeos;

/**
 * 监听HomeOS返回的数据
 */
public interface HomeOsControllerCallback {
    /**
     * 对HomOS数据返回进行监听。具体可参考{@link controller#mqttMsgHandle(String, String)}方法说明
     * @param topic
     * @param msg
     */
    void msg(String topic, String msg);

    /**
     * 对HomOS连接状态进行事件上报。具体可参考{@link controller#log(String)}方法说明
     * @param msg
     */
    void log(String msg);
}
