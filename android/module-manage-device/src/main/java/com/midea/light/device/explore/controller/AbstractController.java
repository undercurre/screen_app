package com.midea.light.device.explore.controller;


import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.Messenger;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.ClientMessenger;
import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.api.ApiService;
import com.midea.light.device.explore.api.IApiService;
import com.midea.light.device.explore.repository.DeviceRepository;
import com.midea.light.log.LogUtil;
import com.midea.light.thread.MainThread;

import java.util.LinkedList;
import java.util.List;
import java.util.function.Predicate;

/**
 * @ClassName AbstractController
 * @Description Controller 基类
 * @Author weinp1
 * @Date 2021/7/17 15:45
 * @Version 1.0
 */
public abstract class AbstractController implements IServiceController, LifecycleObserver {
    // 定义事件处理器
    private Handler mHandler;
    // 上下文
    private final Context mContext;
    // 设备仓库
    private DeviceRepository mDeviceRepository;
    // 网络API
    private IApiService apiService;

    private List<ClientMessenger> messengerList = new LinkedList<>();

    public void setDeviceRepository(DeviceRepository repository) {
        mDeviceRepository = repository;
    }

    public IApiService getApiService() {
        return apiService;
    }

    @Override
    public DeviceRepository getRepository() {
        return mDeviceRepository;
    }

    public AbstractController(PortalContext context) {
        this.mContext = context.geExploreService();
        this.apiService = context.getApiService();
        MainThread.run(() -> context.getLifecycleOwner().getLifecycle().addObserver(this));
        this.mHandler = new Handler(context.getHandlerThread().getLooper()) {
            @Override
            public void handleMessage(@NonNull Message msg) {
                super.handleMessage(msg);
                // 回复数据到客户端的函数
                onHandleMessageToCallback(msg);
            }
        };
    }

    public List<ClientMessenger> getMessengerList() {
        return messengerList;
    }

    /**
     * 子线程对应的Handler执行完的任务，可通过此方法回调到上层执行
     *
     * @param msg
     */
    protected abstract void onHandleMessageToCallback(Message msg);

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    public void onStart() {

    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy() {
        LogUtil.i("Action onDestroy messengerList will be clear ---> MessengerList Count = " + messengerList.size());
        messengerList.clear();
    }

    public Handler getHandler() {
        return mHandler;
    }

    void initHandler() {
        Looper looper = Looper.myLooper();
        if(looper == null) {
            Looper.prepare();
            Looper.loop();
        }
    }

    /**
     * 从Gateway中传递过来的请求
     *
     * @param messenger
     * @param bundle
     */
    public final void request(Messenger messenger, Bundle bundle) {
        LogUtil.tag("device").bundle(bundle);
        String method = bundle.getString(Portal.METHOD_TYPE);
        if (TextUtils.isEmpty(method))  return;
        ClientMessenger clientMessenger = ClientMessenger.wrap(messenger).request(bundle);
        if (Portal.METHOD_ACTION_CLEAR.equals(bundle.getString(Portal.METHOD_EXTRA))) {
            LogUtil.i("METHOD_FIND_CLEAR");
            messengerList.removeIf(new Predicate<ClientMessenger>() {
                @Override
                public boolean test(ClientMessenger clientMessenger) {
                    return clientMessenger.getAndroidOsMessenger().equals(messenger);
                }
            });
            LogUtil.i("MessengerList Count = " + messengerList.size());
        } else {
            if (!messengerList.contains(clientMessenger)) {
                messengerList.add(clientMessenger);
            }
        }

        request(method, bundle);

        request(method, bundle, clientMessenger);
    }

    // 该方法已经过期
    @Deprecated
    public void request(String method, Bundle bundle) {}

    public void request(String method, Bundle bundle, ClientMessenger clientMessenger) {}

    public Context getContext() {
        return mContext;
    }
}
