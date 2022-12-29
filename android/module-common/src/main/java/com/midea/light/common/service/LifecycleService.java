package com.midea.light.common.service;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

/**
 * @ClassName LifecycleService
 * @Description
 * @Author weinp1
 * @Date 2021/7/19 14:05
 * @Version 1.0
 */
public abstract class LifecycleService extends BaseService implements LifecycleOwner {

    private LifecycleRegistry lifecycleRegistry;

    @Override
    public void onCreate() {
        super.onCreate();
        lifecycleRegistry = new LifecycleRegistry(this);
        lifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int result = super.onStartCommand(intent, flags, startId);
        lifecycleRegistry.setCurrentState(Lifecycle.State.STARTED);
        return result;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        lifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }

}
