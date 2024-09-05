// IHomluxAIInterface.aidl
package com.midea.light.ai;
import com.midea.light.ai.IHomluxWakeUpStateCallback;
import com.midea.light.ai.IHomluxAISetVoiceCallBack;
import com.midea.light.ai.IHomluxAICompleteIntialCallBack;
import com.midea.light.ai.IHomluxAISetDuplexModeCallBack;
// Declare any non-default types here with import statements

interface IHomluxAIInterface {
    void initSDK(String env);
    void init(String uid, String token, boolean aiEnable, String houseId, String aiClientId);
    void wakeupAi();
    void setAiEnable(boolean enable);
    void stopAi();
    void addWakUpStateCallBack(IHomluxWakeUpStateCallback callback);
    void addAISetVoiceCallBack(IHomluxAISetVoiceCallBack callback);
    void addAICompleteIntialCallBack(IHomluxAICompleteIntialCallBack callback);
    boolean isDuplexModeFullDuplex();
    boolean setDuplexMode(boolean isFullDuplex);
    void addAISetDuplexModeCallBack(IHomluxAISetDuplexModeCallBack callback);
}