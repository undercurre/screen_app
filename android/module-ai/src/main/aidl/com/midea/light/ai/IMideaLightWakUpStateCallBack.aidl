// IMideaLightWakUpStateCallBack.aidl
package com.midea.light.ai;

// Declare any non-default types here with import statements

interface IMideaLightWakUpStateCallBack {
    /// 是否唤醒
    void wakUpState(boolean isWakUp);
}