package com.midea.light.homeos;

import android.util.Log;

/**
 * 说明：通过controller可访问HomOS，可以控制局域网中的设备，场景，灯组等。
 * <p>点击访问: <a href="https://cf-msmart.midea.com/pages/viewpage.action?pageId=143640110" style="color: blue;">协议文档</a></p>
 *
 * @author Jerry
 * @ProjectName: Controller
 * @Package: com.midea.light.homeos
 * @ClassName: controller
 * @CreateDate: 2023/7/10 15:59
 */
public class controller {

    /**
     * HomOS上报设备状态，场景信息等数据。
     * 数据协议解析，可点击此处的链接《<a href="https://cf-msmart.midea.com/pages/viewpage.action?pageId=143640110" style="color: blue;">协议文档</a>》进行访问
     * @param topic mqtt中定义的topic，可忽略
     * @param msg HomOS传递的数据。包括：心跳，设备列表，场景列表，灯组列表，设备状态，灯组状态等数据。具体的消息体返回
     *            可参考上面的文档链接。
     */
    public void mqttMsgHandle(String topic,String msg) {
        Log.i("homeOs","topic = " + topic + " msg = " + msg);
    }

    /***
     * controller与HomOS连接状态的事件上报
     * @param logStr 与HomOS之间连接状态事件通知。包括下面的事件通知
     * <p>
     *               <ul>
     *                  <li>onSubscribeFailure 订阅失败</li>
     *                  <li>connectOk 连接成功</li>
     *                  <li>ConnectFail 连接失败</li>
     *                  <li>reconnectFail 重连失败</li>
     *                  <li>connectLost 连接断开</li>
     *                  <li>disconnectOK 断开连接成功</li>
     *                  <li>disconnectFail 断开连接失败</li>
     *                  <li>aesKeyMayBeExpire aesKey可能过期，调用接口获取新的key。如果新的key与旧的key不一样，
     *                  则表示key过期。需再次调用{@link #login(String, String)}}方法</li>
     *                  <li>discover send controller 发送UDP探针</li>
     *                  <li>recv host udp discover UDP探针响应</li>
     *                  <li>replay host info controller UDP探针响应</li>
     *                  <li>recv host broastcast discover 发送UDP探针</li>
     *               <ul/>
     *<p/>
     *
     */
    public void log(String logStr) {
        Log.i("homeOs","log = " + logStr);
    }

    /***
     * controller库初始化方法
     * <p style="color: red;">注意：保证全局只初始化一次</p>
     */
    public native void init();

    /***
     * 家庭登出调用
     * 退出登录或者切换账号时，需调用此接口。告知HomOs断开连接
     */
    public native void logout();

    /***
     * @param homeId 家庭Id
     * @param key aesKey需调用云端接口获取。并且此key具有时效性，需根据{@link #log(String)}事件通知，
     *            进行重新获取与重新登录
     * 登录家庭或者aes_key有更新调用
     */
    public native void login(String homeId, String key);

    /***
     *
     * 直接向HomOs发送指令
     * @param topic: 主题
     * @param msg: 指令
     */
    public native int send(String topic, String msg);

    /**
     * controller查询HomOS中的局域网设备列表
     * @param requestId 请求随机数。uuid即可
     */
    public native int getDeviceInfo(String requestId);

    /**
     * controller查询HomOS中指定设备的状态
     * @param requestId 请求随机数。uuid即可
     * @param deviceId 设备Id
     */
    public native int getDeviceStatus(String requestId, String deviceId);

    /**
     *
     * controller控制HomOS中的设备
     * @param requestId 请求随机数。uuid即可
     * @param deviceId 设备Id
     * @param action 控制设备指令 设备控制指令与属性由设备的物模型定义。可通过此处文档进行查询：
     *               《<a href="https://cf-msmart.midea.com/pages/viewpage.action?pageId=143640110" style="color: blue;">协议文档</a>》
     *
     */
    public native int deviceControl(String requestId, String deviceId, String action);

    /**
     * controller查询HomOS中灯组列表
     * @param requestId 请求随机数。uuid即可
     */
    public native int getGroupInfo(String requestId);

    /**
     * controller对HomOS中的某个灯组，下发控制指令
     * @param requestId 请求随机数。uuid即可
     * @param deviceId 灯组的Id 可通过{@link #getGroupInfo(String)}方法查询HomOS中的灯组列表
     * @param action 灯组控制指令 灯组控制指令与属性由灯组的物模型定义。可通过此处文档进行查询：
     *      *               《<a href="https://cf-msmart.midea.com/pages/viewpage.action?pageId=143640110" style="color: blue;">协议文档</a>》
     */
    public native int groupControl(String requestId, String deviceId, String action);

    /**
     * controller查询HomOS中的场景列表
     * @return
     */
    public native int getSceneInfo(String requestId);

    /**
     * controller启动HomOS中的场景
     * @param sceneId 场景ID
     * @return
     */
    public native int sceneExcute(String requestId, String sceneId);

    /**
     * 发送心跳到 mqtt
     * @param requestId 请求随机数。uuid即可
     * @return
     */
    public native int heartBeat(String requestId);

    static {
        System.loadLibrary("controller");
    }

}
