package com.midea.light.setting.ota;

import com.midea.light.upgrade.entity.UpgradeResultEntity;

/**
 * @ClassName IUpdateProgressCallback
 * @Description ota升级回调接口
 * @Author weinp1
 * @Date 2021/8/9 14:22
 * @Version 1.0
 */
public interface V2IUpdateProgressCallback {
    void upgrading(UpgradeResultEntity entity);//正在更新
    void upgradeSuc(UpgradeResultEntity entity);//更新成功
    void upgradeFail(int code , String msg);//更新失败
    void manualCancel();//手动取消下载，成功回调
    void upgradeProcess(int process);//更新进度
}
