package com.midea.light.device.explore.controller.factory;

import android.os.Bundle;

import com.midea.light.device.explore.IServiceControllerFactory;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.controller.ModifyDeviceBelongToRoomController;
import com.midea.light.device.explore.repository.DeviceRepository;

/**
 * @ClassName ModifyDeviceBelongToRoomFactory
 * @Description
 * @Author weinp1
 * @Date 2022/12/24 16:28
 * @Version 1.0
 */
public class ModifyDeviceBelongToRoomFactory implements IServiceControllerFactory<ModifyDeviceBelongToRoomController> {

    public ModifyDeviceBelongToRoomFactory(DeviceRepository deviceRepository) {}
    @Override
    public ModifyDeviceBelongToRoomController getOrCreate(PortalContext context, Bundle request) {
        return new ModifyDeviceBelongToRoomController(context);
    }

}
