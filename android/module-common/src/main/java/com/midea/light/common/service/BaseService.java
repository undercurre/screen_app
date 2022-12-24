package com.midea.light.common.service;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

import androidx.annotation.Nullable;
/**
 * @ClassName BaseService
 * @Description
 * @Author weinp1
 * @Date 2021/8/10 19:40
 * @Version 1.0
 */
public class BaseService extends Service {

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
