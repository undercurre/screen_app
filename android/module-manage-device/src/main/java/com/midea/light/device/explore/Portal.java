package com.midea.light.device.explore;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.Messenger;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.LifecycleOwner;

import com.midea.light.device.explore.api.ApiService;
import com.midea.light.device.explore.api.IApiService;
import com.midea.light.device.explore.config.BaseConfig;
import java.util.Objects;

/**
 * @ClassName ClientGateWay
 * @Description 类似于 “网关”  用于接收客户端请求，发送处理结果到客户端
 * @Author weinp1
 * @Date 2021/7/17 15:15
 * @Version 1.0
 */
public class Portal implements PortalContext {
    // #FindWiFiDeviceController #AutoFindWiFiDeviceController
    public final static String REQUEST_SCAN_WIFI_DEVICES = "request_scan_wifi_devices";
    public final static String METHOD_SCAN_WIFI_START = "method_wifi_scan";
    public final static String METHOD_SCAN_WIFI_STOP = "method_scan_wifi_stop";
    public final static String PARAM_SCAN_WIFI_LOOPER = "param_scan_wifi_looper"; // 用于切换FindDeviceController 与 AutoScanDeviceController  值：true -> Find , false -> Auto
    public final static String PARAM_AUTO_SCAN_WIFI_LOOPER = "param_auto_scan_wifi_looper"; // 用于切换FindDeviceController 与 AutoScanDeviceController  值：true -> Find , false -> Auto
    public final static String RESULT_SCAN_WIFI_DEVICES = "result_scan_devices"; // ArrayList<WiFiScanResult>
    // # FindZigbeeDeviceFactory
    public final static String REQUEST_SCAN_ZIGBEE_DEVICES = "request_scan_zigbee_devices";
    public final static String METHOD_SCAN_ZIGBEE_START = "method_zigbee_scan";
    public final static String METHOD_SCAN_ZIGBEE_STOP = "method_zigbee_stop";
    public final static String PARAM_SCAN_HOME_GROUP_ID = "param_scan_home_group_id";
    public final static String PARAM_GATEWAY_APPLIANCE_CODE = "param_gateway_appliance_code";
    public final static String RESULT_SCAN_ZIGBEE_DEVICES = "result_scan_devices_zigbee";
    // #BindZigbeeDeviceController
    public final static String REQUEST_BIND_ZIGBEE_DEVICES = "request_bind_zigbee_devices";
    public final static String METHOD_BIND_ZIGBEE = "method_bind_zigbee";
    public final static String METHOD_STOP_ZIGBEE_BIND = "method_stop_zigbee_bind";
    public final static String PARAM_BIND_PARAMETER = "param_bind_parameter";
    public final static String PARAM_BIND_ZIGBEE_HOME_GROUP_ID = "param_bind_home_group_id";
    public final static String PARAM_BIND_ZIGBEE_HOME_ROOM_ID = "param_bind_room_id";
    public final static String RESULT_BIND_ZIGBEE_DEVICES = "method_bind_zigbee_result";
    // #BindWifiDeviceController
    public final static String REQUEST_BIND_WIFI_DEVICES = "request_bind_wifi_devices";
    public final static String METHOD_BIND_WIFI = "method_bind_wifi";
    public final static String METHOD_STOP_WIFI_BIND = "method_stop_wifi_bind";
    public final static String PARAM_BIND_WIFI_HOME_GROUP_ID = "param_bind_home_group_id";
    public final static String PARAM_BIND_WIFI_HOME_ROOM_ID = "param_bind_room_id";
    public final static String PARAM_WIFI_NAME = "param_wifi_name";
    public final static String PARAM_WIFI_PASSWORD = "param_wifi_password";
    public final static String PARAM_WIFI_ENCRYPT_TYPE = "param_wifi_encrypt_type";
    public final static String PARAM_WIFI_BSSID = "param_wifi_bssid";
    public final static String RESULT_BIND_WIFI_DEVICES = "method_bind_wifi_result";
    // #ModifyDeviceBelogToRoomController
    public final static String REQUEST_MODIFY_DEVICE_ROOM = "request_modify_device_room";
    public final static String METHOD_MODIFY_DEVICE = "method_modify_device";
    public final static String PARAM_MODIFY_DEVICE_HOME_ID = "param_modify_home_id";
    public final static String PARAM_MODIFY_DEVICE_ROOM_ID = "param_modify_room_id";
    public final static String PARAM_MODIFY_DEVICE_APPLIANCE_CODE = "param_modify_appliance_code";
    public final static String RESULT_MODIFY_DEVICE = "result_modify_device"; // -1 0
    public final static String RESULT_MODIFY_DEVICE_DATA = "result_modify_device_data"; // ApplianceBean
    //用于保存请求action type
    public final static String ACTION_TYPE = "request_tag";
    public final static String METHOD_TYPE = "method_type";
    public final static String METHOD_EXTRA = "method_extra";
    public final static String METHOD_ACTION_CLEAR = "method_action_clear";

    // ================== 初始化 =====================
    static BaseConfig BASE_CONFIG;

    public static BaseConfig getBaseConfig() {
        return Objects.requireNonNull(BASE_CONFIG, "请先执行初始化initBaseConfig方法");
    }

    // 初始化【基础的、通用的】配置
    public static void initBaseConfig(BaseConfig baseConfig) {
        BASE_CONFIG = baseConfig;
    }

    public static void resetBaseConfig() { BASE_CONFIG = null; }


    // ================== 分割线 ======================
    public final DevicesExploreService devicesExploreService;
    private RequestServiceHandler requestHandler;
    private HandlerThread handlerThread;
    private Messenger messenger; //信使
    private IApiService apiService; // 网关请求服务
    boolean isInit = false;

    @Override
    public LifecycleOwner getLifecycleOwner() {
        return devicesExploreService;
    }

    public Context geExploreService() {
        return devicesExploreService;
    }

    @Override
    public IApiService getApiService() {
        return apiService;
    }

    @Override
    public HandlerThread getHandlerThread() {
        return handlerThread;
    }

    //接收客户端请求 [单线程，阻塞队列]
    private final class RequestServiceHandler extends Handler {

        public RequestServiceHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            Bundle bundle = msg.getData();
            if (bundle != null && msg.replyTo != null) {
                String tag = bundle.getString(ACTION_TYPE);
                if (!TextUtils.isEmpty(tag)) {
                    devicesExploreService.executeProgram(msg.replyTo, tag, msg.getData());
                }
            }
        }

    }

    public Portal(DevicesExploreService devicesExploreService) {
        this.devicesExploreService = devicesExploreService;
    }

    public void init() {
        if(!isInit) {
            if(BASE_CONFIG == null) throw new RuntimeException("请执行initBaseConfig方法，再启动服务");
            handlerThread = new HandlerThread("client-gateway");
            handlerThread.start();
            requestHandler = new RequestServiceHandler(handlerThread.getLooper());
            messenger = new Messenger(requestHandler);
            apiService = new ApiService();
            isInit = true;
        }
    }

    public void reset() {
        isInit = false;
        handlerThread.quit();
        messenger = null;
        requestHandler = null;
    }

    public Messenger getMessenger() {
        return Objects.requireNonNull(messenger, "请确保调用了ClientGateWay.init()方法");
    }


}
