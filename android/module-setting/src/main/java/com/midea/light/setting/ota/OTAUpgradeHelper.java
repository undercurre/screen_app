package com.midea.light.setting.ota;

import android.content.Context;
import android.util.Log;

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


class ProxyV2IOTCallback implements V2IOTCallback {

    V2IOTCallback callback;

    @Override
    public void setDownloadControl(UpgradeDownloadControl downloadControl) {
        callback.setDownloadControl(downloadControl);
    }

    @Override
    public void setUpgradeInstallControl(UpgradeInstallControl control) {
        callback.setUpgradeInstallControl(control);
    }

    public ProxyV2IOTCallback(V2IOTCallback callback) {
        this.callback = Objects.requireNonNull(callback);
    }

    @Override
    public void newVersion(UpgradeResultEntity entity) {
        callback.newVersion(entity);
    }

    @Override
    public void alreadyUpgrading(UpgradeResultEntity entity) {
        callback.alreadyUpgrading(entity);
    }

    @Override
    public void noUpgrade() {
        callback.noUpgrade();
    }

    @Override
    public void confirmInstall(UpgradeResultEntity entity) {
        callback.confirmInstall(entity);
    }

    @Override
    public void enableBackground() {
        callback.enableBackground();
    }

    @Override
    public void enableForeground() {
        callback.enableForeground();
    }

    @Override
    public void upgrading(UpgradeResultEntity entity) {
        callback.upgrading(entity);
    }

    @Override
    public void upgradeSuc(UpgradeResultEntity entity) {
        callback.upgradeSuc(entity);
    }

    @Override
    public void upgradeFail(int code, String msg) {
        callback.upgradeFail(code, msg);
    }

    @Override
    public void manualCancel() {
        callback.manualCancel();
    }

    @Override
    public void upgradeProcess(int process) {
        callback.upgradeProcess(process);
    }
}

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

    public static void init(Context context, V2IOTCallback callback, String uid,String deviceId, String mzToken, String gatewaySn) {
        String channel = AppCommonConfig.getChannel();
        String roomCategoryCode = Objects.equals(channel, "JH") ? "JH-Q" : "LD-Q";
        String appCategoryCode = Objects.equals(channel, "JH") ? "JH" : "LD";
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
        UpgradeConfig normal = new UpgradeConfig()
                .withOtaType(4)
                .withVersion(Integer.parseInt(SystemUtil.getGatewayVersion()))
                .withCategoryCode(appCategoryCode)
                .withDebug(true)
                .withExecutorService(executorService)
                .withSn(_void -> gatewaySn)
                .withUserIdFunction(_void -> uid)
                .withApiServiceFunction(debug -> {
                    NormalApiService service1 = new NormalApiService(AppCommonConfig.MZ_HOST, deviceId, mzToken, AppCommonConfig.MZ_APP_SECRET);
                    service1.setDebug(true);
                    return service1;
                });
        UpgradeClient.getInstant().putConfig(UpgradeType.NORMAL, normal);
        UpgradeClient.getInstant().putConfig(UpgradeType.DIRECT, normal);
        UpgradeClient.getInstant().putConfig(UpgradeType.ROOM, room);
        UpgradeClient.getInstant().init(context);

        defaultCallback = Objects.requireNonNull(callback);
        isInit = true;
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

    public static void queryAppAndRoomUpgrade(boolean background) {

        ProxyV2IOTCallback proxy = new ProxyV2IOTCallback(defaultCallback) {
            UpgradeType type = UpgradeType.NORMAL;

            @Override
            public void noUpgrade() {
                if (type == UpgradeType.ROOM) {
                    super.noUpgrade();
                }
                if (type == UpgradeType.NORMAL) {
                    type = UpgradeType.ROOM;
                    queryUpgrade(UpgradeType.ROOM, this);
                }
            }
        };
        if (background) {
            defaultCallback.enableBackground();
        } else {
            defaultCallback.enableForeground();
        }
        // 先查询ROOM
        queryUpgrade(UpgradeType.NORMAL, proxy);

    }

    public static boolean queryUpgrade(UpgradeType type, V2IOTCallback iotaCallback) {
        if (unable() || isDownload())
            return false;
        LogUtil.e("query type = " + type);
        UpgradeClient.getInstant().queryUpgrade(type, new Callback() {
            @Override
            public void result(int type, UpgradeResultEntity entity, IUpgradeControl control) {
                LogUtil.i("type = " + type);
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
                                iotaCallback.upgradeFail(-1, "网络异常");
                            }

                            @Override
                            public void downloadComplete() {
                                iotaCallback.upgradeProcess(100);
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
