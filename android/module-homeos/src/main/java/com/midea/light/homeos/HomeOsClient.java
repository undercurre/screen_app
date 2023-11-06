package com.midea.light.homeos;

import androidx.annotation.Nullable;

/**
 * HomeOs 局域网控制客户端
 * <p>使用示例</p>
 * <pre>
 *
 *     // 1.访问云端接口获取 网关绑定的家庭ID、通信加解密key
 *     String homeId = "xxxx";
 *     String aseKey = "xxxx";
 *     // 2.访问登录方法，使得controller在局域网中主动发现HomOS
 *     HomeOsClient.getOsController().login(homeId, aseKey);
 *     // 3.注册消息监听方法
 *     HomeOsClient.getOsController().setCallback(new HomeOsControllerCallback() {
 *
 *             public void msg(String topic, String msg) {
 *                 // 处理设备，场景，灯组等数据 具体的数据处理可参考{@link controller#mqttMsgHandle(String, String)}方法说明，进行处理
 *             }
 *
 *             public void log(String msg) {
 *                 // 返回连接状态 状态类型可参考{@link controller#log(String)}方法说明
 *             }
 *         });
 *     // 4.适当的时候登出
 *     HomeOsClient.getOsController().logout();
 *
 * </pre>
 */
public class HomeOsClient {

    private static final HomeOsController OS_CONTROLLER = new HomeOsController();

    /**
     * 返回全局的HomeOsController对象
     * @return
     */
    public static HomeOsController getOsController() {
        return OS_CONTROLLER;
    }

    /**
     * 设置消息监听。可监听{@link controller#mqttMsgHandle(String, String)}与{@link controller#log(String)}两种事件
     * <p>具体使用说明可参考{@link  controller}类</p>
     * @param callback
     */
    public static void setCallback(@Nullable HomeOsControllerCallback callback) {
        OS_CONTROLLER.setCallback(callback);
    }

}
