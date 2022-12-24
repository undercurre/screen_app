package com.midea.light.device.explore.controller.factory;

import android.os.Bundle;

import com.midea.light.device.explore.IServiceControllerFactory;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.controller.BindZigbeeDeviceController;
import com.midea.light.device.explore.repository.DeviceRepository;

/**
 * @ClassName BindZigbeeDeviceFactory
 * @Description
 * @Author weinp1
 * @Date 2022/12/23 9:23
 * @Version 1.0
 */
public class BindZigbeeDeviceFactory implements IServiceControllerFactory<BindZigbeeDeviceController> {
    BindZigbeeDeviceController controller;

    public BindZigbeeDeviceFactory(DeviceRepository repository) {

    }

    @Override
    public BindZigbeeDeviceController getOrCreate(PortalContext context, Bundle request) {
        if(controller == null) {
            controller = new BindZigbeeDeviceController(context);
        }
        return controller;
    }
}
