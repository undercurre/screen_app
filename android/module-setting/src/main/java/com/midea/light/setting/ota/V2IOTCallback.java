package com.midea.light.setting.ota;

import com.midea.light.upgrade.control.UpgradeDownloadControl;
import com.midea.light.upgrade.control.UpgradeInstallControl;
import com.midea.light.upgrade.entity.UpgradeResultEntity;

/**
 * @ClassName V2IOTCallback
 * @Description TODO
 * @Author weinp1
 * @Date 2022/11/18 17:05
 * @Version 1.0
 */
public interface V2IOTCallback extends V2IUpdateProgressCallback {
    /**
     * 有新版本可更新
     */
    void newVersion(UpgradeResultEntity entity);

    /**
     * 已经在更新中，请稍后再尝试
     */
    void alreadyUpgrading(UpgradeResultEntity entity);

    void noUpgrade();

    default void setDownloadControl(UpgradeDownloadControl downloadControl){}

    default void setUpgradeInstallControl(UpgradeInstallControl control){}

    void confirmInstall(UpgradeResultEntity entity);

    void enableBackground();

    void enableForeground();
}
