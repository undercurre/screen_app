package com.midea.light.common.thread;

import android.os.Handler;
import android.os.Looper;

public class MainThread {

    static Handler handler;

    public static void run(Runnable runnable) {
        if (handler == null)
            handler = new Handler(Looper.getMainLooper());
        handler.post(runnable);
    }

    public static void postDelayed(Runnable runnable, long delayMills) {
        if (handler == null)
            handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(runnable, delayMills);
    }

}
