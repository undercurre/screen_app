package com.midea.light.device.explore.controller.factory;

import android.os.Bundle;

import com.midea.light.device.explore.IServiceControllerFactory;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.controller.BindWiFiDeviceController;
import com.midea.light.device.explore.repository.DeviceRepository;

/**
 * @ClassName BindWiFiDeviceFactory
 * @Description
 * @Author weinp1
 * @Date 2022/12/23 9:23
 * @Version 1.0
 */
public class BindWiFiDeviceFactory implements IServiceControllerFactory<BindWiFiDeviceController> {
    BindWiFiDeviceController controller;
    final DeviceRepository repository;

    public BindWiFiDeviceFactory(DeviceRepository repository) {
        this.repository = repository;
    }

    @Override
    public BindWiFiDeviceController getOrCreate(PortalContext context, Bundle request) {
        if(controller == null) {
            controller = new BindWiFiDeviceController(context);
            controller.setDeviceRepository(repository);
        }
        return controller;
    }

}
