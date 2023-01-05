package com.midea.light.device.explore.controller;

import android.os.Bundle;
import android.os.Message;
import android.os.RemoteException;

import com.midea.light.device.explore.ClientMessenger;
import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.api.entity.ApplianceBean;

import java.util.Objects;

/**
 * @ClassName ModifyDeviceBelongToRoom
 * @Description 更改设备属于的房间
 * @Author weinp1
 * @Date 2022/12/24 15:58
 * @Version 1.0
 */
public class ModifyDeviceBelongToRoomController extends AbstractController implements IServiceController {

    public ModifyDeviceBelongToRoomController(PortalContext context) {
        super(context);
    }

    @Override
    protected void onHandleMessageToCallback(Message msg) {}


    @Override
    public void request(String method, Bundle bundle, ClientMessenger clientMessenger) {
        if(Objects.equals(Portal.METHOD_MODIFY_DEVICE, method)) {
            String homeId = Objects.requireNonNull(bundle.getString(Portal.PARAM_MODIFY_DEVICE_HOME_ID));
            String roomId = Objects.requireNonNull(bundle.getString(Portal.PARAM_MODIFY_DEVICE_ROOM_ID));
            String applianceCode = Objects.requireNonNull(bundle.getString(Portal.PARAM_MODIFY_DEVICE_APPLIANCE_CODE));

            ApplianceBean applianceBean = getApiService().modifyRoom(homeId, roomId, applianceCode);

            if(applianceBean == null) {
                // 修改失败
                getHandler().post(() -> {
                    Message message = new Message();
                    Bundle data = new Bundle();
                    data.putInt(Portal.RESULT_MODIFY_DEVICE, -1);
                    message.setData(data);
                    try {
                        clientMessenger.send(message);
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                });
            } else {
                // 修改成功
                getHandler().post(() -> {
                    Message message = new Message();
                    Bundle data = new Bundle();
                    data.putInt(Portal.RESULT_MODIFY_DEVICE, 0);
                    data.putParcelable(Portal.RESULT_MODIFY_DEVICE_DATA, applianceBean);
                    message.setData(data);
                    try {
                        clientMessenger.send(message);
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                });
            }
            getMessengerList().remove(clientMessenger);
        }
        throw new RuntimeException("暂时没有实现该方法：" + method);
    }
}
