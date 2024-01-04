package com.midea.light.homeos;

/**
 * 对controller做第二次封装，处理心跳包 和 设置消息监听
 *
 */
public class HomeOsController extends controller {
    static boolean enableAnalysis = false;

    HomeOsControllerCallback callback;

    public void setCallback(HomeOsControllerCallback callback) {
        this.callback = callback;
    }

    @Override
    public void log(String logStr) {
        super.log(logStr);
        if(enableAnalysis) {
            DataAnalysisHelper.INSTANCE.eventLogAnalysisEntrance(logStr);
        }
        if(callback != null) {
            callback.log(logStr);
        }
    }

    @Override
    public void mqttMsgHandle(String topic, String msg) {
        super.mqttMsgHandle(topic, msg);
        if(enableAnalysis) {
            DataAnalysisHelper.INSTANCE.dataLogAnalysisEntrance(msg);
        }
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

    @Override
    public int groupControl(String requestId, String deviceId, String action) {
        if(enableAnalysis) {
            DataAnalysisHelper.INSTANCE.groupControl(requestId, deviceId, action);
        }
        return super.groupControl(requestId, deviceId, action);
    }

    @Override
    public int deviceControl(String requestId, String deviceId, String action) {
        if(enableAnalysis) {
            DataAnalysisHelper.INSTANCE.deviceControl(requestId, deviceId, action);
        }
        return super.deviceControl(requestId, deviceId, action);
    }

    @Override
    public int sceneExcute(String requestId, String sceneId) {
        if(enableAnalysis) {
            DataAnalysisHelper.INSTANCE.sceneExcute(requestId, sceneId);
        }
        return super.sceneExcute(requestId, sceneId);
    }
}
