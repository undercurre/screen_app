package com.midea.light.homeos;

import android.util.Log;

/**
 * @author Janner
 * @ProjectName: My Application
 * @Package: com.midea.light.homeos
 * @ClassName: controller
 * @CreateDate: 2023/7/10 15:59
 */
public class controller {

    /**
     * <a href="https://cf-msmart.midea.com/pages/viewpage.action?pageId=143640110">通信协议文档</a>
     * @param topic
     * @param msg
     */
    public void mqttMsgHandle(String topic,String msg) {
        Log.i("homeOs","topic = " + topic + " msg = " + msg);
    }

    /***
     * onSubscribe 订阅成功
     * onSubscribeFailure 订阅失败
     * connectOk 连接成功
     * ConnectFail 连接失败
     * reconnectFail 重连失败
     * connectLost 连接断开
     * disconnectOK 断开连接成功
     * disconnectFail 断开连接失败
     * aesKeyMayBeExpire aesKey可能过期，调用接口获取新的key，如果新的key过期则更新后调用login函数，如果新的key和旧的key相同则可以不用理会
     */
    public void log(String logStr) {
        Log.i("homeOs","log = " + logStr);
    }

    /***
     * 库初始化调用
     */
    public native void init();

    /***
     * 家庭登出调用
     */
    public native void logout();

    /***
     * 登录家庭或者aes_key有更新调用
     */
    public native void login(String homeId, String key);

    /***
     * 发送命令调用
     * <a href="https://cf-msmart.midea.com/pages/viewpage.action?pageId=143640110">通信协议文档</a>
     * topic: 标题
     * msg: 控制指令[json子串]
     */
    public native int send(String topic, String msg);

    /**
     * 获取Homlux 局域网中的家庭列表
     */
    public native int getDeviceInfo(String requestId);

    /**
     * 获取Homlux 局域网中设备详情
     */
    public native int getDeviceStatus(String requestId, String deviceId);

    /**
     * Homlux 局域网控制设备
     */
    public native int deviceControl(String requestId, String deviceId, String action);

    /**
     * Homlux 局域网获取灯分组信息
     */
    public native int getGroupInfo(String requestId);

    /**
     * Homlux 局域网灯组控制
     */
    public native int groupControl(String requestId, String deviceId, String action);

    /**
     * Homlux 局域网获取场景列表
     * @return
     */
    public native int getSceneInfo(String requestId);

    /**
     * Homlux 局域网场景控制
     * @param sceneId
     * @return
     */
    public native int sceneExcute(String requestId, String sceneId);

    static {
        System.loadLibrary("controller");
    }

}
