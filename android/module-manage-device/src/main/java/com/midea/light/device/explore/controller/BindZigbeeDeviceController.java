package com.midea.light.device.explore.controller;

import android.os.Bundle;
import android.os.Message;
import android.os.RemoteException;

import com.midea.iot.sdk.common.security.SecurityUtils;
import com.midea.light.device.explore.ClientMessenger;
import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.api.entity.ApplianceBean;
import com.midea.light.device.explore.api.entity.SearchZigbeeDeviceResult;
import com.midea.light.device.explore.beans.BindResult;
import com.midea.light.device.explore.beans.WrapBindingState;
import com.midea.light.device.explore.beans.ZigbeeScanResult;
import com.midea.light.log.LogUtil;
import com.midea.light.utils.TimeUtil;

import java.util.LinkedList;
import java.util.Objects;
import java.util.UUID;

/**
 * @ClassName BindZigbeeDeviceController
 * @Description 绑定zigbee类型设备
 * @Author weinp1
 * @Date 2022/12/23 9:22
 * @Version 1.0
 */
public class BindZigbeeDeviceController extends AbstractController implements IServiceController {
    // 队列用于保存需要，已经，还未等状态设备
    LinkedList<WrapBindingState> mTaskCollection = new LinkedList<>();

    public BindZigbeeDeviceController(PortalContext context) {
        super(context);
    }

    @Override
    public void request(String methodType, Bundle bundle) {
        if (Portal.METHOD_BIND_ZIGBEE.equals(methodType)) {
            ZigbeeScanResult[] parcelables = (ZigbeeScanResult[]) bundle.getParcelableArray(Portal.PARAM_BIND_ZIGBEE_PARAMETER);
            String homeGroupId = bundle.getString(Portal.PARAM_BIND_ZIGBEE_HOME_GROUP_ID);
            String roomId = bundle.getString(Portal.PARAM_BIND_ZIGBEE_HOME_ROOM_ID);
            if (parcelables != null && parcelables.length > 0) {
                for (ZigbeeScanResult parcelable : parcelables) {
                    WrapBindingState state = WrapBindingState.wait(parcelable);
                    state.setHomeGroupId(homeGroupId);
                    state.setRoomId(roomId);
                    insertDataToQueue(mTaskCollection, state);
                }
                findSuitableDeviceAndBind();
            }

        } else if (Portal.METHOD_STOP_ZIGBEE_BIND.equals(methodType)) {
            mTaskCollection.clear();
        } else {
            throw new RuntimeException("暂无实现此方法 = " + methodType);
        }
    }

    @Override
    protected void onHandleMessageToCallback(Message msg) {
        WrapBindingState wrapBean = (WrapBindingState) msg.obj;
        if (WrapBindingState.STATE_CONNECTED_SUC == wrapBean.getState()) {
            //成功
            sendDataToClient(wrapBean, 0, "");
        } else if (WrapBindingState.STATE_CONNECTED_ERR == wrapBean.getState()) {
            //失败
            sendDataToClient(wrapBean, -1, wrapBean.getErrorMsg());
        }
        //无论成功还是失败，继续执行任务
        findSuitableDeviceAndBind();
    }


    // #查找合适的设备并且去绑定
    private void findSuitableDeviceAndBind() {
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
            doBind(wait);
        }
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

    //发送数据到前台
    void sendDataToClient(WrapBindingState wrapBean, int code, String msg) {

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
            bindResult.setDeviceInfo(wrapBean.getScanResult());// SearchZigbeeDeviceResult.ZigbeeDevice
            bindResult.setBindResult(wrapBean.getBindResult());// ApplianceBean
            bindResult.setBindType(BindResult.TYPE_ZIGBEE);
            bundle.putParcelable(Portal.RESULT_BIND_ZIGBEE_DEVICES, bindResult);
            message.setData(bundle);
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


    void doBind(WrapBindingState state) {
        com.midea.light.device.explore.beans.ZigbeeScanResult scanResult = (com.midea.light.device.explore.beans.ZigbeeScanResult) state.getScanResult();
        SearchZigbeeDeviceResult.ZigbeeDevice zigbeeDevice = scanResult.getDevice();

        ApplianceBean applianceBean = null;
        for (int i = 0; i < 3; i++) {
            if(applianceBean == null) {
                applianceBean = getApiService().bindDevice(
                        Portal.getBaseConfig().getUserId(), state.getHomeGroupId(), state.getRoomId(), zigbeeDevice.getApplianceType(),
                        zigbeeDevice.getSn(),
                        zigbeeDevice.getName(), UUID.randomUUID().toString(), TimeUtil.getTimestamp()
                );
            }
        }

        if(applianceBean == null) {
            // 绑定失败
            Message message = Message.obtain();
            message.what = -1;
            message.obj = state;
            state.setState(WrapBindingState.STATE_CONNECTED_ERR);
            state.setErrorMsg("网络异常~");
            getHandler().sendMessage(message);
        } else {
            // 绑定成功
            Message message = Message.obtain();
            message.what = 1;
            message.obj = state;
            state.setState(WrapBindingState.STATE_CONNECTED_SUC);
            state.setBindResult(applianceBean);
            getHandler().sendMessage(message);
        }

    }

}
