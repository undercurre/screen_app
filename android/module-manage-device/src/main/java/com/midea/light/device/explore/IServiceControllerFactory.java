package com.midea.light.device.explore;

import android.os.Bundle;

/**
 * @ClassName IServiceControllerFactory
 * @Description 创建Controller的工厂类接口
 * @Author weinp1
 * @Date 2021/7/17 15:37
 * @Version 1.0
 */
public interface IServiceControllerFactory<T extends IServiceController> {

    T getOrCreate(PortalContext context, Bundle request);

}
