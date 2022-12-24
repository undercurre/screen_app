package com.midea.light.device.explore;

import android.content.Context;
import android.os.HandlerThread;

import androidx.lifecycle.LifecycleOwner;

import com.midea.light.device.explore.api.IApiService;

/**
 * @ClassName PortalContext
 * @Description 门户上下文
 * @Author weinp1
 * @Date 2022/12/21 19:47
 * @Version 1.0
 */
public interface PortalContext {
    HandlerThread getHandlerThread();
    IApiService getApiService();
    Context geExploreService();
    LifecycleOwner getLifecycleOwner();
}
