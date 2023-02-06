package com.midea.light.device.explore.controller.factory;

import android.os.Bundle;

import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.IServiceControllerFactory;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.controller.AutoFindWiFiDeviceController;
import com.midea.light.device.explore.controller.FindWiFiDeviceController;
import com.midea.light.device.explore.repository.DeviceRepository;

import java.util.Objects;

/**
 * @ClassName WiFiFindDeviceFactory
 * @Description wifi设备发现的工厂类
 * @Author weinp1
 * @Date 2022/12/22 13:34
 * @Version 1.0
 */
public class FindWiFiDeviceFactory implements IServiceControllerFactory<IServiceController>  {
    private final DeviceRepository repository;
    private FindWiFiDeviceController findDeviceController;
    private AutoFindWiFiDeviceController autoScanDeviceController;

    public FindWiFiDeviceFactory(DeviceRepository repository) {
        this.repository = repository;
    }

    @Override
    public IServiceController getOrCreate(PortalContext context, Bundle bundle) {
        synchronized (FindWiFiDeviceFactory.class) {
            Objects.requireNonNull(bundle, "请保证传入的Bundle不为空");
            if(bundle.getBoolean(Portal.PARAM_SCAN_WIFI_LOOPER, false)) {
                if (findDeviceController == null) {
                    findDeviceController = new FindWiFiDeviceController(context);
                    findDeviceController.setDeviceRepository(this.repository);
                }
                return findDeviceController;
            } else if (bundle.getBoolean(Portal.PARAM_AUTO_SCAN_WIFI_LOOPER, false)) {
                if (autoScanDeviceController == null) {
                    autoScanDeviceController = new AutoFindWiFiDeviceController(context);
                    autoScanDeviceController.setDeviceRepository(this.repository);
                }
                return autoScanDeviceController;
            } else {
                throw new RuntimeException("请保证传入进来的参数是正确的");
            }
        }
    }

}
