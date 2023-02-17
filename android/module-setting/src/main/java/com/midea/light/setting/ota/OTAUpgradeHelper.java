package com.midea.light.setting.ota;

import android.content.Context;
import android.util.Log;

import com.midea.light.BaseApplication;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.ld.setting.BuildConfig;
import com.midea.light.log.LogUtil;
import com.midea.light.setting.SystemUtil;
import com.midea.light.thread.MainThread;
import com.midea.light.upgrade.Callback;
import com.midea.light.upgrade.UpgradeClient;
import com.midea.light.upgrade.UpgradeConfig;
import com.midea.light.upgrade.UpgradeType;
import com.midea.light.upgrade.api.NormalApiService;
import com.midea.light.upgrade.control.IUpgradeControl;
import com.midea.light.upgrade.control.UpgradeDownloadControl;
import com.midea.light.upgrade.control.UpgradeInstallControl;
import com.midea.light.upgrade.download.IUpgradeDownload;
import com.midea.light.upgrade.entity.UpgradeResultEntity;
import com.midea.light.upgrade.install.IUpgradeInstaller;
import com.midea.smart.open.common.util.StringUtils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Objects;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.internal.Util;

class RoomUtils {
    /**
     * 这里的版本号规则为：1.0 1.2 1.3  2.0 2.1 3.0 3.2 等等
     * 注意： 必须为三位。超过三位需要与开发商协商，重新定义版本号
     */
    final static String REGEX = "MSP-A040A-B1_PX30_V(...)";

    public final static int getRoomVersion() {
//        px30_evb-userdebug 8.1.0 1669166465 MSP-A040A-B1_PX30_V1.0
        try {
            Class systemProperties = Class.forName("android.os.SystemProperties");
            Method get = systemProperties.getDeclaredMethod("get", String.class);
            get.setAccessible(true);
            String property = (String) get.invoke(null, "ro.build.display.id");
            if (!StringUtils.isEmpty(property)) {
                Pattern p = Pattern.compile(REGEX);
                Matcher m = p.matcher(property);
                if (m.find()) {
                    Log.i("room", "room version = " + m.group(1));
                    try {
                        return (int) Math.floor(Float.parseFloat(m.group(1)) * 10);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (ClassNotFoundException | NoSuchMethodException | InvocationTargetException | IllegalAccessException e) {
            e.printStackTrace();
        }

        if (BuildConfig.DEBUG) {
            throw new RuntimeException("获取不到系统版本信息失败");
        } else {
            return Integer.MAX_VALUE;
        }
    }

}
/**
 * @ClassName V2OTAUpgradeHelper
 * @Description
 * @Author weinp1
 * @Date 2022/11/18 14:58
 * @Version 1.0
 */
public class OTAUpgradeHelper {
    private OTAUpgradeHelper() {}

    private final static ExecutorService executorService = new ThreadPoolExecutor(0, 3, 60, TimeUnit.MILLISECONDS, (BlockingQueue<Runnable>) new LinkedBlockingQueue<Runnable>(), Util.threadFactory("Upgrade", true));
    private static V2IOTCallback defaultCallback;
    // 是否有更新
    public static boolean hasNewUpgrade = false;
    public static boolean isInit = false;

    //定义配置
    public static boolean supportNormalOTA = false; //是否支持普通模式ota
    public static boolean supportDirectOTA = false; //是否支持定向ota
    public static boolean supportRomOTA = false; //是否支持Rom升级

    public static void init(Context context, V2IOTCallback callback, String uid,String deviceId, String mzToken, String gatewaySn) {
        String channel = AppCommonConfig.getChannel();
        // 初始化支持的OTA类型
        supportNormalOTA = Objects.equals("JH", channel) || Objects.equals("LD", channel);
        supportDirectOTA = Objects.equals("JH", channel) || Objects.equals("LD", channel);
        supportRomOTA = Objects.equals("JH", channel);

        initRomOTAConfig(channel, uid, deviceId, mzToken);
        initNormalOTAConfig(channel, uid, deviceId, mzToken);
        initDirectOTAConfig(channel, uid, deviceId, mzToken, gatewaySn);

        UpgradeClient.getInstant().init(context);
        defaultCallback = Objects.requireNonNull(callback);
        isInit = true;
    }


    static void initRomOTAConfig(String channel, String uid, String deviceId, String mzToken) {
        if(supportRomOTA) {
            String roomCategoryCode = Objects.equals(channel, "JH") ? "JH-Q" : "LD-Q";
            UpgradeConfig room = new UpgradeConfig()
                    .withOtaType(2)
                    .withVersion(RoomUtils.getRoomVersion())
                    .withCategoryCode(roomCategoryCode)
                    .withDebug(true)
//                .withDebug(BuildConfig.DEBUG)
                    .withExecutorService(executorService)
                    .withUserIdFunction(_void -> uid)
                    .withInstallerFunction(UpgradeConfig.JH_ROOM_INSTALLER_FUNCTION)
                    .withFilePath("/sdcard/")
                    .withFileCompressName("update.zip")
                    .withApiServiceFunction(debug -> {
                        NormalApiService service1 = new NormalApiService(AppCommonConfig.MZ_HOST, deviceId, mzToken, AppCommonConfig.MZ_APP_SECRET);
                        service1.setDebug(true);
                        return service1;
                    });
            UpgradeClient.getInstant().putConfig(UpgradeType.ROOM, room);
        }
    }

    public static void initDirectOTAConfig(String channel, String uid, String deviceId, String mzToken, String gatewaySn) {
        if(supportDirectOTA) {
            String appCategoryCode = Objects.equals(channel, "JH") ? "JH" : "LD";

            UpgradeConfig direct = new UpgradeConfig()
                    .withOtaType(4)
                    .withVersion(Integer.parseInt(SystemUtil.getSystemVersion(BaseApplication.getContext())))
                    .withCategoryCode(appCategoryCode)
                    .withDebug(true)
                    .withSn(_void-> gatewaySn)
                    .withExecutorService(executorService)
                    .withUserIdFunction(_void -> uid)
                    .withApiServiceFunction(debug -> {
                        NormalApiService service1 = new NormalApiService(AppCommonConfig.MZ_HOST, deviceId, mzToken, AppCommonConfig.MZ_APP_SECRET);
                        service1.setDebug(true);
                        return service1;
                    });
            UpgradeClient.getInstant().putConfig(UpgradeType.DIRECT, direct);
        }
    }

    public static void initNormalOTAConfig(String channel, String uid, String deviceId, String mzToken) {
        if(supportNormalOTA) {
            String appCategoryCode = Objects.equals(channel, "JH") ? "JH" : "LD";

            UpgradeConfig normal = new UpgradeConfig()
                    .withOtaType(4)
                    .withVersion(Integer.parseInt(SystemUtil.getSystemVersion(BaseApplication.getContext())))
                    .withCategoryCode(appCategoryCode)
                    .withDebug(true)
                    .withExecutorService(executorService)
                    .withUserIdFunction(_void -> uid)
                    .withApiServiceFunction(debug -> {
                        NormalApiService service1 = new NormalApiService(AppCommonConfig.MZ_HOST, deviceId, mzToken, AppCommonConfig.MZ_APP_SECRET);
                        service1.setDebug(true);
                        return service1;
                    });
            UpgradeClient.getInstant().putConfig(UpgradeType.NORMAL, normal);
        }
    }

    public static void treatDown() {
        isInit = false;
        defaultCallback = null;
        hasNewUpgrade = false;
    }

    public static boolean unable() {
        return !isInit;
    }

    public static boolean isDownload() {
        return UpgradeClient.getInstant().isDownloading();
    }

    public static boolean queryUpgrade(UpgradeType type) {
        return queryUpgrade(type, defaultCallback);
    }

    public static boolean queryUpgrade(UpgradeType type, V2IOTCallback iotaCallback) {
        if (unable() || isDownload())
            return false;
        LogUtil.e("query type = " + type);
        UpgradeClient.getInstant().queryUpgrade(type, new Callback() {
            @Override
            public void result(int type, UpgradeResultEntity entity, IUpgradeControl control) {
                LogUtil.i("ota-type = " + type);
                if (Callback.TYPE_DOWNLOAD == type) {
                    // 是否需要下载
                    if (control instanceof UpgradeDownloadControl) {
                        UpgradeDownloadControl downloadControl = (UpgradeDownloadControl) control;
                        downloadControl.setDownLoadListener(new IUpgradeDownload.DownloadListener() {
                            @Override
                            public void downloading(int process, long time) {
                                iotaCallback.upgradeProcess(process);
                            }

                            @Override
                            public void downloadFail() {
                                iotaCallback.downloadFail();
                            }

                            @Override
                            public void downloadComplete() {
                                iotaCallback.upgradeProcess(100);
                                iotaCallback.downloadSuc();
                            }
                        });
                        iotaCallback.setDownloadControl(downloadControl);
                        MainThread.run(() -> {
                            hasNewUpgrade = true;
                            iotaCallback.newVersion(entity);
                        });
                    }
                } else if (Callback.TYPE_INSTALL == type) {
                    if (control instanceof UpgradeInstallControl) {
                        ((UpgradeInstallControl) control).setInstallListener(new IUpgradeInstaller.IInstallerListener() {
                            @Override
                            public void installSuccess() {
                                iotaCallback.upgradeSuc(entity);
                            }

                            @Override
                            public void installFail() {
                                iotaCallback.upgradeFail(-1, "网络异常");
                            }
                        });
                        iotaCallback.setUpgradeInstallControl((UpgradeInstallControl) control);
                        MainThread.run(() -> iotaCallback.confirmInstall(entity));
                    }
                } else if (Callback.SUB_TYPE_QUERY_EMPTY == type) {
                    MainThread.run(iotaCallback::noUpgrade);
                    hasNewUpgrade = false;
                }
            }
        });
        return true;
    }


}
