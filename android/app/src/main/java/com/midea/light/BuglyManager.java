package com.midea.light;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.midea.light.log.LogUtil;
import com.midea.light.utils.AndroidManifestUtil;
import com.midea.light.utils.MacUtil;
import com.tencent.bugly.crashreport.CrashReport;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import io.reactivex.rxjava3.schedulers.Schedulers;

public class BuglyManager {

    @FunctionalInterface
    public interface ILauncherErrorPager {
        boolean launch(Throwable throwable, String randomCode);
    }

    static class WrapThrowable {

        private Throwable throwable;
        private Thread thread;
        private long openTimeStamp;

        public WrapThrowable(Throwable throwable, Thread thread, long openTimeStamp) {
            this.throwable = throwable;
            this.thread = thread;
            this.openTimeStamp = openTimeStamp;
        }

        public Throwable getThrowable() {
            return throwable;
        }

        public void setThrowable(Throwable throwable) {
            this.throwable = throwable;
        }

        public Thread getThread() {
            return thread;
        }

        public void setThread(Thread thread) {
            this.thread = thread;
        }

        public long getOpenTimeStamp() {
            return openTimeStamp;
        }

        public void setOpenTimeStamp(long openTimeStamp) {
            this.openTimeStamp = openTimeStamp;
        }
    }

    static class CrashHandler implements Thread.UncaughtExceptionHandler {
        final ILauncherErrorPager launcherPage;
        final Map<String, WrapThrowable> map = new ConcurrentHashMap<>();
        Thread.UncaughtExceptionHandler mDefaultExceptionHandler;
        private CrashHandler(Thread.UncaughtExceptionHandler defaultHandler, ILauncherErrorPager iLauncherErrorPager) {
            this.launcherPage = iLauncherErrorPager;
            mDefaultExceptionHandler = defaultHandler;
            new Handler(Looper.getMainLooper()).post(() -> {
                try {
                    Looper.loop();
                } catch (Throwable e) {
                    e.printStackTrace();
                    runCaughtExceptionProcess(Thread.currentThread(), e);
                }
            });
        }


        @Override
        public void uncaughtException(@NonNull Thread t, @NonNull Throwable e) {

            runCaughtExceptionProcess(t, e);
        }

        void runCaughtExceptionProcess(Thread t, Throwable e) {
            try {
                LogUtil.e("java#thread=" + t.getName(), e);
                String randomCode = UUID.randomUUID().toString();
                WrapThrowable wrapThrowable = new WrapThrowable(e, t, System.currentTimeMillis());
                map.put(randomCode, wrapThrowable);
                if (Objects.equals(launcherPage.launch(e, randomCode), false)) {
                    postCatchExceptionBySystem(randomCode, true);
                }

            } catch (Throwable throwable) {
                LogUtil.e("java#thread=" + t.getName(), throwable);
                WrapThrowable wrapThrowable = new WrapThrowable(e, t, System.currentTimeMillis());
                String randomCode = UUID.randomUUID().toString();
                map.put(randomCode, wrapThrowable);
                postCatchExceptionBySystem(randomCode, true);
            }
        }

        void postCatchExceptionByUser(String randomCode) {
            WrapThrowable wrapThrowable = map.remove(randomCode);
            if (wrapThrowable != null) {
                CrashReport.postCatchedException(wrapThrowable.getThrowable(), wrapThrowable.getThread());
            }
        }

        void postCatchExceptionBySystem(String randomCode, boolean killProcess) {
            WrapThrowable wrapThrowable = map.remove(randomCode);
            if (wrapThrowable != null && mDefaultExceptionHandler != null) {
                mDefaultExceptionHandler.uncaughtException(wrapThrowable.getThread(), wrapThrowable.getThrowable());
                if(killProcess) {
                    Schedulers.computation().scheduleDirect(() -> {
                        try {
                            Thread.sleep(3000);
                            android.os.Process.killProcess(android.os.Process.myPid());
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    });
                }
            }

        }

    }

    public static void init(boolean debug, ILauncherErrorPager iLauncherErrorPager) {
        // 移除安卓系统默认的异常处理机制
        Thread.UncaughtExceptionHandler androidHandler = Thread.getDefaultUncaughtExceptionHandler();
        if (androidHandler != null &&
                "com.android.internal.os.RuntimeInit$KillApplicationHandler".equals(androidHandler.getClass().getName())) {
            Thread.setDefaultUncaughtExceptionHandler(null);
        }

        Context context = BaseApplication.getContext();
        // 获取当前包名
        String packageName = context.getPackageName();
        // 获取当前进程名
        String processName = getProcessName(android.os.Process.myPid());
        // 设置是否为上报进程
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(context);
        strategy.setUploadProcess(processName == null || processName.equals(packageName));

        // 初始化Bugly
        CrashReport.initCrashReport(context, AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "BUGLY_ID"), debug, strategy);
        CrashReport.setIsDevelopmentDevice(BaseApplication.getContext(), debug);
        //带上设备的mac地址
        CrashReport.putUserData(context, "mac_address",  MacUtil.macAddress("wlan0"));

        // 初始化捕获崩溃错误Handler
        Thread.setDefaultUncaughtExceptionHandler(new CrashHandler(Thread.getDefaultUncaughtExceptionHandler(), iLauncherErrorPager));
    }

    /**
     * 获取进程号对应的进程名
     *
     * @param pid 进程号
     * @return 进程名
     */
    private static String getProcessName(int pid) {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader("/proc/" + pid + "/cmdline"));
            String processName = reader.readLine();
            if (!TextUtils.isEmpty(processName)) {
                processName = processName.trim();
            }
            return processName;
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException exception) {
                exception.printStackTrace();
            }
        }
        return null;
    }

    public static void postCatchExceptionByUser(String randomCode) {
        if (Thread.getDefaultUncaughtExceptionHandler() instanceof CrashHandler) {
            CrashHandler handler = (CrashHandler) Thread.getDefaultUncaughtExceptionHandler();
            handler.postCatchExceptionByUser(randomCode);
        }
    }

    public static void postCatchExceptionBySystem(String randomCode, boolean killProcess) {
        if (Thread.getDefaultUncaughtExceptionHandler() instanceof CrashHandler) {
            CrashHandler handler = (CrashHandler) Thread.getDefaultUncaughtExceptionHandler();
            handler.postCatchExceptionBySystem(randomCode, killProcess);
        }
    }


    /**
     * 测试java代码崩溃
     */
    public static void testJavaCrash() {
        CrashReport.testJavaCrash();
    }

    /**
     * 测试Native层代码崩溃
     */
    public static void testNativeCrash() {
        CrashReport.testNativeCrash();
    }

    /**
     * 测试Android层的ANR
     */
    public static void testANRCrash() {
        CrashReport.testANRCrash();
    }

}
