package com.midea.light.device.explore.api;

import com.midea.light.device.explore.api.entity.ApplianceBean;
import com.midea.light.device.explore.api.entity.SearchZigbeeDeviceResult;

import java.util.List;

/**
 * @ClassName IApiService
 * @Description 声明需要使用到的接口
 * @Author weinp1
 * @Date 2022/12/21 14:15
 * @Version 1.0
 */
public interface IApiService {
    // 1.绑定设备
    ApplianceBean bindDevice(String uid, String homeGroupId, String roomId, String applianceType,
                             String deviceSN, String name, String reqId, String stamp);
    // 2.发送指令到网关中
    boolean transmitCommandToGateway(String uid, String applianceCode, String order,
                                     String homeGroupId, String stamp, String reqId);
    // 3.查询网关是否有发现设备
    List<SearchZigbeeDeviceResult.ZigbeeDevice> checkGatewayWhetherHasFindDevice(String uid, String reqId,
                                                                                 String stamp, String homeGroupId, String applianceCode);

    // 4. 修改设备绑定的房间
    ApplianceBean modifyRoom(String homeGroupId, String roomId, String applianceCode);
}
