package com.midea.light.device.explore.controller.factory;

import android.os.Bundle;

import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.IServiceControllerFactory;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.controller.FindZigbeeDeviceController;
import com.midea.light.device.explore.repository.DeviceRepository;

/**
 * @ClassName FindZigbeeDeviceFactory
 * @Description
 * @Author weinp1
 * @Date 2022/12/22 14:43
 * @Version 1.0
 */
public class FindZigbeeDeviceFactory implements IServiceControllerFactory<IServiceController> {
    FindZigbeeDeviceController controller;
    final DeviceRepository repository;

    public FindZigbeeDeviceFactory(DeviceRepository repository) {
        this.repository = repository;
    }

    @Override
    public IServiceController getOrCreate(PortalContext context, Bundle request) {
        if(controller == null) {
            controller = new FindZigbeeDeviceController(context);
        }
        return controller;
    }

}
