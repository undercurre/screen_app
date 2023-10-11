package com.midea.light.device.explore.controller;

import android.os.Bundle;
import android.os.Message;
import android.os.RemoteException;

import com.google.gson.JsonObject;
import com.midea.iot.sdk.common.security.SecurityUtils;
import com.midea.light.device.explore.ClientMessenger;
import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.api.entity.SearchZigbeeDeviceResult;
import com.midea.light.device.explore.beans.ZigbeeScanResult;
import com.midea.light.device.explore.database.DeviceDatabaseHelper;
import com.midea.light.device.explore.database.entity.CommonDeviceIconAndNameEntity;
import com.midea.light.log.LogUtil;
import com.midea.light.utils.CollectionUtil;
import com.midea.light.utils.TimeUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.schedulers.Schedulers;

/**
 * @ClassName FindZigbeeDeviceController
 * @Description 发现zigbee设备的Controller
 * @Author weinp1
 * @Date 2022/12/22 9:27
 * @Version 1.0
 */
public class FindZigbeeDeviceController extends AbstractController implements IServiceController {
    private final static long ZIGBEE_SEARCH_INTERVAL = 3000;
    // 定时器句柄
    private Disposable mDisposable;
    // 是否启动扫描
    private Boolean startFind = Boolean.FALSE;

    private int cnt = 0;

    private int audio = 1;

    public FindZigbeeDeviceController(PortalContext context) {
        super(context);
    }

    @Override
    public void request(String method, Bundle bundle) {
        if (Portal.METHOD_SCAN_ZIGBEE_START.equals(method)) {
            String homeGroupId = Objects.requireNonNull(bundle.getString(Portal.PARAM_SCAN_HOME_GROUP_ID));
            String uid = Objects.requireNonNull(Portal.getBaseConfig().getUserId());
            String gatewayApplianceCode = Objects.requireNonNull(bundle.getString(Portal.PARAM_GATEWAY_APPLIANCE_CODE));
            audio = 1;
            startFindZigbee(homeGroupId, uid, gatewayApplianceCode);
        } else if (Portal.METHOD_SCAN_ZIGBEE_STOP.equals(method)) {
            String homeGroupId = Objects.requireNonNull(bundle.getString(Portal.PARAM_SCAN_HOME_GROUP_ID));
            String uid = Objects.requireNonNull(Portal.getBaseConfig().getUserId());
            String gatewayApplianceCode = Objects.requireNonNull(bundle.getString(Portal.PARAM_GATEWAY_APPLIANCE_CODE));
            stopFindZigbee(homeGroupId, uid, gatewayApplianceCode);
            audio = 0;
        }
    }

    @Override
    protected void onHandleMessageToCallback(Message msg) {}


    private void stopFindZigbee(String homeGroupId, String uid, String applianceCode) {
        if(mDisposable != null && !mDisposable.isDisposed()) {
            mDisposable.dispose();
        }
        startFind = false;
        cnt = 0;

        JsonObject root = new JsonObject();
        root.addProperty("applianceCode", applianceCode);
        root.addProperty("modelId", "");
        root.addProperty("topic", "/subdevice/add");
        JsonObject command = new JsonObject();
        command.addProperty("expire", 0);
        command.addProperty("buzz", 0);
        root.add("command", command);

        boolean result = getApiService().transmitCommandToGateway(
                uid, applianceCode,
                SecurityUtils.encodeAES128(root.toString(), Portal.getBaseConfig().getSeed()),
                homeGroupId, TimeUtil.getTimestamp(), UUID.randomUUID().toString());

        LogUtil.i("Zigbee Stop result = " + result);
    }

    private void startFindZigbee(String homeGroupId, String uid, String applianceCode) {
        if(startFind) return;
        Observable.interval(ZIGBEE_SEARCH_INTERVAL, TimeUnit.MILLISECONDS)
                .subscribeOn(Schedulers.io())
                .doOnSubscribe(disposable -> {
                    mDisposable = disposable;
                })
                .subscribe(l -> {
                    // 搜索Zigbee设备
                    if ((++cnt % 20) == 1) {
                        JsonObject root = new JsonObject();
                        root.addProperty("applianceCode", applianceCode);
                        root.addProperty("modelId", "");
                        root.addProperty("topic", "/subdevice/add");
                        JsonObject command = new JsonObject();
                        command.addProperty("expire", 60);
                        command.addProperty("buzz", audio);
                        root.add("command", command);

                        Boolean result = getApiService().transmitCommandToGateway(uid, applianceCode,
                                            SecurityUtils.encodeAES128(root.toString(), Portal.getBaseConfig().getSeed()),
                                            homeGroupId, TimeUtil.getTimestamp(), UUID.randomUUID().toString());

                        audio = 0;

                        LogUtil.i("Zigbee Search result = " + result);
                    }
                    // 查询是否有设备已被网关找到
                    List<SearchZigbeeDeviceResult.ZigbeeDevice> list =
                            getApiService().checkGatewayWhetherHasFindDevice(uid, TimeUtil.getTimestamp(),
                                        UUID.randomUUID().toString(), homeGroupId, applianceCode);

                    if(CollectionUtil.isEmpty(list)) {
                        LogUtil.i("Zigbee Search Empty");
                    } else {
                        // 发送数据到上层
                        getHandler().post(() -> sendDataToClientZigbee(list));
                    }

                });
        startFind = false;
    }

    void sendDataToClientZigbee(List<SearchZigbeeDeviceResult.ZigbeeDevice> list) {
        if (list != null && list.size() > 0) {
            try {
                if(CollectionUtil.isEmpty(getMessengerList())) {
                    LogUtil.i("Zigbee messenger is empty");
                } else {
                    for (ClientMessenger messenger : getMessengerList()) {
                        Message message = Message.obtain();
                        Bundle bundle = new Bundle();
                        bundle.putParcelableArrayList(Portal.RESULT_SCAN_ZIGBEE_DEVICES, zigbeeCovert(list));
                        message.setData(bundle);
                        messenger.send(message);
                    }
                }
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    private ArrayList<ZigbeeScanResult> zigbeeCovert(List<SearchZigbeeDeviceResult.ZigbeeDevice> list) {
        if (CollectionUtil.isEmpty(list)) return null;

        ArrayList<ZigbeeScanResult> addList = new ArrayList<>();
        for (SearchZigbeeDeviceResult.ZigbeeDevice device : list) {
            CommonDeviceIconAndNameEntity entity = DeviceDatabaseHelper.getInstant().finDeviceInCommon("1A");
            if (entity != null) {
                ZigbeeScanResult result = new ZigbeeScanResult(device, entity.icon, device.getName());
                addList.add(result);
            }
        }

        return addList;
    }

}
