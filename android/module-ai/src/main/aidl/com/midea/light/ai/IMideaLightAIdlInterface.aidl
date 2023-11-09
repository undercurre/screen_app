// IMideaLightAidlInterface.aidl
package com.midea.light.ai;
import com.midea.light.ai.IMideaLightServerBindCallBack;
import com.midea.light.ai.IMideaLightServerInitialCallBack;
import com.midea.light.ai.IMideaLightFlashMusicListCallback;
import com.midea.light.ai.IMideaLightAISetVoiceCallBack;
import com.midea.light.ai.IMideaLightAiControlDeviceErrorCallBack;
import com.midea.light.ai.IMideaLightWakUpStateCallBack;
import com.midea.light.ai.IMideaLightMusicPlayControlBack;

interface IMideaLightAIdlInterface {

    void setServerInitialBack(IMideaLightServerInitialCallBack initialBack, IMideaLightServerBindCallBack BindCallBack);

    void setFlashMusicListCallBack(IMideaLightFlashMusicListCallback CallBack);

    void addAISetVoiceCallBack(IMideaLightAISetVoiceCallBack CallBack);

    void addAIControlDeviceErrorCallBack(IMideaLightAiControlDeviceErrorCallBack CallBack);

    void addWakUpStateCallBack(IMideaLightWakUpStateCallBack CallBack);

    void addMusicPlayControlCallBack(IMideaLightMusicPlayControlBack CallBack);

    void reportPlayerStatusToCloud(String MusicUrl, String Song, int index, String str_status);

    void getMusicList();

    void updateVoiceToCloud(int voice);

    void stop();

    void outt();

    void wakeupByHand();

    void startRecord();

    void stopRecord();

    void start(String sn, String deviceType, String deviceCode, String mac,String env);

}