package com.midea.light.device.explore;


import com.midea.light.device.explore.repository.DeviceRepository;

/**
 * @ClassName IServiceController
 * @Description 业务控制器
 * @Author weinp1
 * @Date 2021/7/17 15:17
 * @Version 1.0
 */
public interface IServiceController {

    DeviceRepository getRepository();

    void setDeviceRepository(DeviceRepository repository);

}
