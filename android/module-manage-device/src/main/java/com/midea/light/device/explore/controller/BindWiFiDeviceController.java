package com.midea.light.device.explore.controller;

import static com.midea.light.common.config.AppCommonConfig.WIFI_DEVICE_SERVER_DOMAIN;

import android.content.Context;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.text.TextUtils;
import android.util.Log;

import com.midea.iot.sdk.MideaProgressCallback;
import com.midea.iot.sdk.MideaSDK;
import com.midea.iot.sdk.common.security.SecurityUtils;
import com.midea.iot.sdk.config.ConfigType;
import com.midea.iot.sdk.config.DeviceConfigStep;
import com.midea.iot.sdk.config.ap.DeviceApConfigParams;
import com.midea.iot.sdk.entity.MideaDevice;
import com.midea.iot.sdk.entity.MideaErrorMessage;
import com.midea.iot.sdk.event.MSmartCountryChannel;
import com.midea.iot.sdk.event.MSmartFunctionType;
import com.midea.iot.sdk.event.MSmartTimeZone;
import com.midea.light.device.explore.ClientMessenger;
import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.NetUtil;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.api.entity.ApplianceBean;
import com.midea.light.device.explore.beans.BindResult;
import com.midea.light.device.explore.beans.WiFiScanResult;
import com.midea.light.device.explore.beans.WrapBindingState;
import com.midea.light.device.explore.controller.utils.Utils;
import com.midea.light.log.LogUtil;
import com.midea.light.utils.CollectionUtil;
import com.midea.light.utils.TimeUtil;

import java.util.LinkedList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;


// 定义一个异步线程回调的绑定监听器
class AsyncMideaProgressCallback<T, Progress> extends MideaProgressCallback<T, Progress> {
    Handler asyncHandler;
    MideaProgressCallback<T, Progress> callback;

    public AsyncMideaProgressCallback(Handler asyncHandler) {
        this.asyncHandler = asyncHandler;
    }

    MideaProgressCallback<T, Progress> wrap(MideaProgressCallback<T, Progress> callback) {
        this.callback = callback;
        return this;
    }

    @Override
    public void onProgressUpdate(Progress progress) {
        asyncHandler.post(()->{
            if(callback != null) callback.onProgressUpdate(progress);
        });
    }

    @Override
    public void onComplete(T t) {
        asyncHandler.post(()->{
            if(callback != null) callback.onComplete(t);
        });
    }

    @Override
    public void onError(MideaErrorMessage mideaErrorMessage) {
        asyncHandler.post(()->{
            if(callback != null) callback.onError(mideaErrorMessage);
        });
    }
}
/**
 * @ClassName BindWiFiDeviceController
 * @Description 绑定wifi类型的设备
 * @Author weinp1
 * @Date 2022/12/23 9:21
 * @Version 1.0
 */
public class BindWiFiDeviceController extends AbstractController implements IServiceController {
    // 队列用于保存需要，已经，还未等状态设备
    LinkedList<WrapBindingState> mTaskCollection = new LinkedList<>();
    // WiFi管理器
    WifiManager wifiManager;

    public BindWiFiDeviceController(PortalContext context) {
        super(context);
        wifiManager = (WifiManager) getContext().getSystemService(Context.WIFI_SERVICE);
    }

    @Override
    public void request(String method, Bundle bundle) {
        // wifi设备绑定
        if (method.equals(Portal.METHOD_BIND_WIFI)) {
            WiFiScanResult[] parcelables = (WiFiScanResult[]) bundle.getParcelableArray(Portal.PARAM_WIFI_BIND_PARAMETER);
            String homeGroupId = bundle.getString(Portal.PARAM_BIND_WIFI_HOME_GROUP_ID);
            String roomId = bundle.getString(Portal.PARAM_BIND_WIFI_HOME_ROOM_ID);
            String wifiName = bundle.getString(Portal.PARAM_WIFI_NAME);
            String wifiBssId = bundle.getString(Portal.PARAM_WIFI_BSSID);
            String wifiPassword = bundle.getString(Portal.PARAM_WIFI_PASSWORD);
            String wifiEncryptType = bundle.getString(Portal.PARAM_WIFI_ENCRYPT_TYPE);
            if(!wifiManager.isWifiEnabled() || wifiManager.getConnectionInfo() == null) {
                throw new RuntimeException("请打开WiFi并保证当前wifi已经连接上");
            }
            if(TextUtils.isEmpty(wifiName)|| TextUtils.isEmpty(wifiEncryptType)|| TextUtils.isEmpty(wifiBssId) || wifiPassword == null) {
                throw new RuntimeException("请传wifi名称，密码");
            }
            if(parcelables.length > 0) {
                for (WiFiScanResult parcelable : parcelables) {
                    WrapBindingState state = WrapBindingState.wait(parcelable);
                    state.setHomeGroupId(homeGroupId);
                    state.setRoomId(roomId);
                    insertDataToQueue(mTaskCollection, state);
                }
                findSuitableDeviceAndBind(wifiName, wifiPassword, wifiEncryptType, wifiBssId);
            }
        } else if (method.equals(Portal.METHOD_STOP_WIFI_BIND)) {
            mTaskCollection.clear();
            MideaSDK.getInstance().getDeviceManager().stopConfigureDevice();
        } else {
            throw new RuntimeException("暂无实现此方法 = " + method);
        }
    }

    @Override
    protected void onHandleMessageToCallback(Message msg) {
        WrapBindingState wrapBean = (WrapBindingState) msg.obj;
        if (WrapBindingState.STATE_CONNECTED_SUC == wrapBean.getState()) {
            //成功
            sendDataToClient(wrapBean, BindResult.TYPE_WIFI, 0, "");
        } else if (WrapBindingState.STATE_CONNECTED_ERR == wrapBean.getState()) {
            //失败
            sendDataToClient(wrapBean, BindResult.TYPE_WIFI, -1, wrapBean.getErrorMsg());
        }
    }

    //发送数据到前台
    void sendDataToClient(WrapBindingState wrapBean, String bindType, int code, String msg) {

        LogUtil.i("设备 " + wrapBean + "\n"
                + "配网结果 " + code + "\n"
                + "还剩下设备" + collectionWaitingBindDevice() + "台数等待配网");
        for (ClientMessenger messenger : getMessengerList()) {
            Message message = Message.obtain();
            Bundle bundle = new Bundle();
            BindResult bindResult = new BindResult();
            bindResult.setCode(code);
            bindResult.setMessage(msg);
            bindResult.setWaitDeviceBind(collectionWaitingBindDevice());
            bindResult.setDeviceInfo(wrapBean.getScanResult());// ScanResult
            bindResult.setBindResult(wrapBean.getBindResult());// ApplianceBean
            bindResult.setBindType(bindType);
            bundle.putParcelable(Portal.RESULT_BIND_WIFI_DEVICES, bindResult);
            message.setData(bundle);
            LogUtil.tag("BindDeviceController").msg("测试3");
            try {
                messenger.send(message);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    int collectionWaitingBindDevice() {
        int count = 0;
        for (WrapBindingState state : mTaskCollection) {
            if (state.getState() == WrapBindingState.STATE_WAIT) {
                count++;
            }
        }
        return count;
    }

    // #将新数据插入到等待队列
    void insertDataToQueue(LinkedList<WrapBindingState> queue, WrapBindingState bean) {
        if(!queue.contains(bean)) {
            queue.offer(bean);
        } else {
            Integer targetIndex = null;
            //找到目标Bean，并重新设置STATE_WAIT状态
            for (int i = 0; i < queue.size(); i++) {
                WrapBindingState wrapBean = queue.get(i);
                if (Objects.equals(bean, wrapBean) && wrapBean.getState() != WrapBindingState.STATE_WAIT) {
                    targetIndex = i;
                    break;
                }
            }

            //更改完状态之后，重新插入到队尾
            if (targetIndex != null && targetIndex < queue.size()) {
                queue.remove((int)targetIndex);
                queue.offer(bean);
            }

        }
    }

    // #查找合适的设备并且去绑定
    private void findSuitableDeviceAndBind(String wifiName, String wifiPassword, String wifiEncryptType, String wifiBssId) {
        WrapBindingState wait = null;
        //找到正在连接的实体，即将要被连接的实体
        for (WrapBindingState wrapBean : mTaskCollection) {

            if (WrapBindingState.STATE_WAIT == wrapBean.getState()) {
                if (wait == null) wait = wrapBean;
            }
            // 如果存在正在绑定的设备，则中断这次绑定。直到这个设备绑定结束
            if (WrapBindingState.STATE_CONNECTING == wrapBean.getState()) {
                return ;
            }
        }
        // 去执行绑定
        if(wait != null) {
            doBind(wait, wifiName, wifiPassword, wifiEncryptType, wifiBssId);
        }
    }

    private void doBind(WrapBindingState wrapBean, String wifiName, String wifiPassword, String wifiEncryptType, String wifiBssId) {
        ScanResult result = ((WiFiScanResult) wrapBean.getScanResult()).getScanResult();
        LogUtil.i("Wifi设备 ： " + result + "进入配网");

        if (wifiManager.getConnectionInfo() == null) {
            //没连接wifi
            Message message = Message.obtain();
            message.what = -1;
            message.obj = wrapBean;
            wrapBean.setState(WrapBindingState.STATE_CONNECTED_ERR);
            wrapBean.setErrorMsg("请重新设置并连接WiFi....");
            getHandler().sendMessage(message);
            LogUtil.i("当前连接的WIFI并未记录在本地");
            return;
        }

        DeviceApConfigParams params = new DeviceApConfigParams(this.getContext(), result.SSID, wifiName, wifiEncryptType, wifiPassword);
        params.setRouterBSSID(result.BSSID);
        params.setModuleServerDomain(WIFI_DEVICE_SERVER_DOMAIN);
        params.setModuleServerPort(getDefaultPort());
        params.setCountryCode(getCountryCode());
        params.setCountryChannelList(getChannels());
        params.setTimeZone(getTimeZone());
        params.setRegionId(getRegionId());
        params.setFunctionType(getFunctionType());
        if(!result.capabilities.contains("WEP") && !result.capabilities.contains("PSK") && !result.capabilities.contains("EAP")) {
            params.setDeviceSecurityParams("NONE");
            params.setDevicePassword("");
        }

        LogUtil.i("当前绑定的wifi" + wifiManager.getConnectionInfo());

        try {
            MideaSDK.getInstance().getDeviceManager().startConfigureDevice(params, ConfigType.TYPE_AP, new AsyncMideaProgressCallback<MideaDevice, DeviceConfigStep>(getHandler())
                    .wrap(new MideaProgressCallback<MideaDevice, DeviceConfigStep>() {

                              @Override
                              public void onProgressUpdate(DeviceConfigStep deviceConfigStep) {
                                  Log.i("BindDeviceController", "onProgressUpdate" + deviceConfigStep.getStepName().name() + "(" + deviceConfigStep.getStep() + "/" + deviceConfigStep.getTotal() + ")" + deviceConfigStep.getMideaDevice());
                                  if (deviceConfigStep.getStep() == 11) {
                                      forgetDeviceWifiAndConnectTargetWifi(result,  wifiName, wifiPassword, wifiEncryptType, wifiBssId);
                                  }
                              }

                              @Override
                              public void onComplete(MideaDevice mideaDevice) {
                                  Log.i("BindDeviceController", "MideaSDK 流程跑通 回调的进程为 = " + Thread.currentThread());
                                  ApplianceBean applianceBean = null;
                                  // 请求绑定设备，最多尝试三次
                                  for (int i = 0; i < 3; i++) {
                                      if(applianceBean == null) {
                                          applianceBean = getApiService()
                                                  .bindDevice(
                                                          Portal.getBaseConfig().getUserId(), wrapBean.getHomeGroupId(),
                                                          wrapBean.getRoomId(), mideaDevice.getDeviceType(),
                                                          SecurityUtils.encodeAES128(mideaDevice.getDeviceSN(), Portal.getBaseConfig().getSeed()),
                                                          mideaDevice.getDeviceName(), UUID.randomUUID().toString(), TimeUtil.getTimestamp()
                                                  );
                                      }
                                  }
                                  if(applianceBean != null) {
                                      Log.i("BindDeviceController", " 调用Bind接口成功 ");
                                      // 请求成功
                                      Message message = Message.obtain();
                                      message.what = 1;
                                      message.obj = wrapBean;
                                      wrapBean.setState(WrapBindingState.STATE_CONNECTED_SUC);
                                      wrapBean.setBindResult(applianceBean);
                                      getHandler().sendMessage(message);
                                  } else {
                                      Log.i("BindDeviceController", " 调用Bind接口失败 ");
                                      // 请求失败
                                      Message message = Message.obtain();
                                      message.what = -1;
                                      message.obj = wrapBean;
                                      wrapBean.setState(WrapBindingState.STATE_CONNECTED_ERR);
                                      wrapBean.setErrorMsg("网络异常：当前连接wifi信息："+ wifiManager.getConnectionInfo());
                                      getHandler().sendMessage(message);
                                  }

                                  // 继续执行剩下的任务
                                  findSuitableDeviceAndBind(wifiName, wifiPassword, wifiEncryptType, wifiBssId);
                              }

                              @Override
                              public void onError(MideaErrorMessage mideaErrorMessage) {
                                  LogUtil.i("MIDEA_SDK_流程失败");
                                  forgetDeviceWifiAndConnectTargetWifi(result, wifiName, wifiPassword, wifiEncryptType, wifiBssId);
                                  MideaSDK.getInstance().getDeviceManager().stopConfigureDevice();
                                  Message message = Message.obtain();
                                  message.what = -1;
                                  message.obj = wrapBean;
                                  wrapBean.setState(WrapBindingState.STATE_CONNECTED_ERR);
                                  wrapBean.setErrorMsg("MideaSDk 报错：" + mideaErrorMessage.getErrorMessage());
                                  getHandler().sendMessage(message);
                                  Log.i("BindDeviceController","onError" + mideaErrorMessage.getErrorMessage()+" "+mideaErrorMessage.getErrorCode());
                                  // 继续执行剩下的任务
                                  findSuitableDeviceAndBind(wifiName, wifiPassword, wifiEncryptType, wifiBssId);
                              }
                          }
                    ));
        } catch (Exception e) {
            e.printStackTrace();
        }

    }


    public void forgetDeviceWifiAndConnectTargetWifi(ScanResult deviceResult, String wifiName, String wifiPassword, String wifiEncryptType, String wifiBssId) {
        WifiManager wifiManager = getContext().getSystemService(WifiManager.class);
        final WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        LogUtil.i("当前连接的WiFi " + wifiInfo + "\n"
                + "目标wifi " + wifiName + "\n"
                + "设备wifi " + deviceResult);

        final List<WifiConfiguration> configurations = NetUtil.getSaveWifiConfiguration(wifiManager, deviceResult.SSID, deviceResult.BSSID);
        if(CollectionUtil.isNotEmpty(configurations)) {
            NetUtil.forgetWiFi(wifiManager, configurations);
        }

        if (wifiInfo != null && Objects.equals(wifiInfo.getSSID().replace("\"", ""), wifiName.replace("\"", ""))) {
            //移除连接设备的记录
            LogUtil.i("无需重连Wifi 此时Wifi值为 + " + wifiManager.getConnectionInfo()
                    + "目标Wifi为 " + wifiName);

        } else {

            wifiManager.disconnect();
            List<WifiConfiguration> configuration1 = NetUtil.getSaveWifiConfiguration(wifiManager, wifiName, wifiBssId);
            if (CollectionUtil.isNotEmpty(configuration1)) {
                // 尝试重连3次。共花费6秒
                for (int i = 0; i < 2; i++) {
                    if (wifiManager.getConnectionInfo() == null || !NetUtil.equalRemoveDoubleQuotes(wifiManager.getConnectionInfo().getSSID(), wifiName)) {
                        NetUtil.connectAlreadySaveWifi(wifiManager, configuration1.get(0));
                        Utils.waitUntil(() ->
                                NetUtil.equalRemoveDoubleQuotes(wifiName, wifiManager.getConnectionInfo().getSSID()), 3);
                    }
                }
                LogUtil.i("尝试连接之后的结果：目标WiFi为：" + wifiName + "当前连接的Wifi为 " + wifiManager.getConnectionInfo());
            } else {
                throw new RuntimeException("之前连接过的wifi的配置，莫名不见了~ NG ");
            }

        }

    }


    public static int getDefaultPort() {
        return 28443;
    }

    public static String getCountryCode() {
        return "CN";
    }

    public static MSmartCountryChannel[] getChannels() {
        MSmartCountryChannel[] channels = new MSmartCountryChannel[4];
        channels[0] = new MSmartCountryChannel((byte) 1, (byte) 13, (byte) 27, false);
        channels[1] = new MSmartCountryChannel((byte) 36, (byte) 4, (byte) 23, false);
        channels[2] = new MSmartCountryChannel((byte) 52, (byte) 4, (byte) 23, true);
        channels[3] = new MSmartCountryChannel((byte) 149, (byte) 5, (byte) 27, false);
        return channels;
    }

    public static MSmartTimeZone getTimeZone() {
        return MSmartTimeZone.EAST_8;
    }

    public static int getRegionId() {
        return 1;
    }

    public static MSmartFunctionType getFunctionType() {
        return MSmartFunctionType.INTERNEL;
    }

}
