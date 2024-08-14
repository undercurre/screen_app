package com.midea.homlux.ai.observer;

import android.media.AudioManager;
import android.util.Log;

import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dsk.duiwidget.CommandObserver;
import com.midea.homlux.ai.impl.AISetVoiceCallBack;
import com.midea.homlux.ai.music.MusicManager;
import com.midea.light.BaseApplication;
import com.midea.light.setting.SystemUtil;

import org.json.JSONObject;

import static android.content.Context.AUDIO_SERVICE;


/**
 * 客户端CommandObserver, 用于处理客户端动作的执行以及快捷唤醒中的命令响应.
 * 例如在平台配置客户端动作： command://call?phone=$phone$&name=#name#,
 * 那么在CommandObserver的onCall方法中会回调topic为"call", data为
 */
public class DuiCommandObserver implements CommandObserver {
    private String TAG = "sky";
    public  boolean mediaControlResult=false;
    public  boolean hasMediaControlResult=false;
    private AISetVoiceCallBack mAISetVoiceCallBack;

    private static final String COMMAND_SET_VOLUME = "DUI.MediaController.SetVolume";
    private static final String COMMAND_STE_BRIGHTNESS = "DUI.System.Display.SetBrightness";
    private static final String COMMAND_MEDIA_PREV = "DUI.MediaController.Prev";
    private static final String COMMAND_MEDIA_NEXT = "DUI.MediaController.Next";
    private static final String COMMAND_MEDIA_PAUSE = "DUI.MediaController.Pause";
    private static final String COMMAND_MEDIA_STOP = "DUI.MediaController.Stop";
    private static final String COMMAND_MEDIA_PLAY = "DUI.MediaController.Play";


    public DuiCommandObserver() {
    }

    // 注册当前更新消息
    public void regist() {
        if (DDS.getInstance() != null && DDS.getInstance().getAgent() != null) {
            DDS.getInstance().getAgent().subscribe(new String[]{COMMAND_SET_VOLUME, COMMAND_STE_BRIGHTNESS, COMMAND_MEDIA_PREV, COMMAND_MEDIA_NEXT, COMMAND_MEDIA_PAUSE,
                            COMMAND_MEDIA_STOP, COMMAND_MEDIA_PLAY},
                    this);
        }
    }

    // 注销当前更新消息
    public void unregist() {
        if (DDS.getInstance() != null && DDS.getInstance().getAgent() != null) {
            DDS.getInstance().getAgent().unSubscribe(this);
        }
    }

    @Override
    public void onCall(String command, String data) {
        Log.e(TAG, "command: " + command + "  data: " + data);
        try {
            if (COMMAND_SET_VOLUME.equals(command)) {
                JSONObject dataObject = new JSONObject(data);
                if (dataObject.has("volume")) {
                    int max=getMaxAudio();
                    String volumeStr = dataObject.getString("volume");
                    volumeStr= volumeStr.replace("%","");
                    if(volumeStr.equals("max")){
                        volumeStr="100";
                    }
                    if(volumeStr.equals("min")){
                        volumeStr="10";
                    }
                    int volumeInt = Integer.parseInt(volumeStr);
                    float bili = (float) volumeInt / (float) 100;
                    SystemUtil.setSystemAudio((int) (max * bili));
                    DDS.getInstance().getAgent().getTTSEngine().speak("当前音量已调整到" + volumeStr, 1, "100", AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK);
                    if(mAISetVoiceCallBack!=null){
                        mAISetVoiceCallBack.SetVoice((int) (max * bili));
                    }

                }
            } else if (COMMAND_STE_BRIGHTNESS.equals(command)) {
                JSONObject dataObject = new JSONObject(data);
                if (dataObject.has("brightness")) {
                    String lightStr = dataObject.getString("brightness");
                    lightStr= lightStr.replace("%","");
                    if(lightStr.equals("max")){
                        lightStr="100";
                    }
                    if(lightStr.equals("min")){
                        lightStr="10";
                    }
                    int lightInt = Integer.parseInt(lightStr);
                    float bili = (float) lightInt / (float) 100;
                    SystemUtil.lightSet((int) (255 * bili));
                    DDS.getInstance().getAgent().getTTSEngine().speak("当前亮度已调整到" + lightStr, 1, "100", AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK);

                }
            } else if (COMMAND_MEDIA_PREV.equals(command)) {
                MusicManager.getInstance().prevMusic();
                mediaControlResult=true;
                hasMediaControlResult=true;
            } else if (COMMAND_MEDIA_NEXT.equals(command)) {
                MusicManager.getInstance().nextMusic();
                mediaControlResult=true;
                hasMediaControlResult=true;
            } else if (COMMAND_MEDIA_PAUSE.equals(command)) {
                MusicManager.getInstance().pauseMusic();
                mediaControlResult=false;
                hasMediaControlResult=true;
            } else if (COMMAND_MEDIA_STOP.equals(command)) {
                MusicManager.getInstance().stopMusic();
                mediaControlResult=false;
                hasMediaControlResult=true;
            } else if (COMMAND_MEDIA_PLAY.equals(command)) {
                MusicManager.getInstance().startMusic();
                mediaControlResult=true;
                hasMediaControlResult=true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void addAISetVoiceCallBack(AISetVoiceCallBack CallBack){
        mAISetVoiceCallBack=CallBack;
    }

    public static int getMaxAudio(){
        AudioManager am = (AudioManager)  BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        int max = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        return max;
    }


}
