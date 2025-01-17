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
    void downloadSuc(); // 下载成功
    void downloadFail(); // 下载失败
    void upgradeSuc(UpgradeResultEntity entity);//更新成功
    void upgradeFail(int code , String msg);//更新失败
    void upgradeProcess(int process);//更新进度
}
