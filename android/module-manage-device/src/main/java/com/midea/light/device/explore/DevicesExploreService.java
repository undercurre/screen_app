package com.midea.light.device.explore;

import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Messenger;

import androidx.annotation.Nullable;

import com.midea.iot.sdk.MideaSDK;
import com.midea.light.BaseApplication;
import com.midea.light.common.service.LifecycleService;
import com.midea.light.device.explore.controller.AbstractController;
import com.midea.light.device.explore.controller.factory.BindWiFiDeviceFactory;
import com.midea.light.device.explore.controller.factory.BindZigbeeDeviceFactory;
import com.midea.light.device.explore.controller.factory.FindWiFiDeviceFactory;
import com.midea.light.device.explore.controller.factory.FindZigbeeDeviceFactory;
import com.midea.light.device.explore.controller.factory.ModifyDeviceBelongToRoomFactory;
import com.midea.light.device.explore.database.DeviceDatabaseHelper;
import com.midea.light.device.explore.repository.DeviceRepository;
import com.midea.light.log.LogUtil;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * @ClassName DevicesExploreService
 * @Description 设备发现服务类
 * @Author weinp1
 * @Date 2021/7/17 13:35
 * @Version 1.0
 */
public class DevicesExploreService extends LifecycleService {
    // #定义线程池
    ExecutorService mExecutorService = new ThreadPoolExecutor(
            0, 3, 30,
            TimeUnit.SECONDS, new LinkedBlockingDeque<>(),
            new ThreadFactory() {
                int count = 0;
                @Override
                public Thread newThread(Runnable r) {
                    // 11:31:54.333
                    String time = new SimpleDateFormat("HH:mm:ss", Locale.US).format(new Date());
                    count += 1;
                    return new Thread(r, String.format(Locale.US, "explore %s.%d", time, count));
                }}
    );
    // #定义门户
    Portal portal = new Portal(this);
    // #定义处理器的集合
    Map<String, IServiceControllerFactory> mControllerMap;

    //处理自身业务逻辑  运行在子线程中
    @Override
    public void onCreate() {
        super.onCreate();
        LogUtil.i("onCreate");
        // 初始化数据库
        DeviceDatabaseHelper.getInstant().init();
        // 初始化门户
        portal.init();
        // 初始化Controller
        initControllers();
    }

    public void initControllers() {
        if (mControllerMap == null) {
            DeviceRepository repository = DeviceRepository.getInstance();
            mControllerMap = new HashMap<>();
            mControllerMap.put(Portal.REQUEST_SCAN_WIFI_DEVICES, new FindWiFiDeviceFactory(repository));
            mControllerMap.put(Portal.REQUEST_SCAN_ZIGBEE_DEVICES, new FindZigbeeDeviceFactory(repository));
            mControllerMap.put(Portal.REQUEST_BIND_WIFI_DEVICES, new BindWiFiDeviceFactory(repository));
            mControllerMap.put(Portal.REQUEST_BIND_ZIGBEE_DEVICES, new BindZigbeeDeviceFactory(repository));
            mControllerMap.put(Portal.REQUEST_MODIFY_DEVICE_ROOM, new ModifyDeviceBelongToRoomFactory(repository));
        }
    }

    public void executeProgram(Messenger messenger, String tag, Bundle bundle) {
        mExecutorService.execute(() -> {
            IServiceControllerFactory factory = mControllerMap.get(tag);
            if(factory == null) {
                LogUtil.e("没找到对应的controller, 当前传入的tag = " + tag);
                return;
            }
            IServiceController controller = factory.getOrCreate(portal, bundle);
            if (controller instanceof AbstractController) {
                // ## 在异步线程中运行
                ((AbstractController) controller).request(messenger, bundle);
            }
        });
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        LogUtil.i("onStartCommand");
        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        LogUtil.i("onBind");
        return portal.getMessenger().getBinder();
    }

    @Override
    public boolean onUnbind(Intent intent) {
        LogUtil.i("onUnbind");
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        LogUtil.i("onDestroy");
        portal.reset();
        super.onDestroy();
    }

}
