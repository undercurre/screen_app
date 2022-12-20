package com.midea.light.setting.voice;

import android.media.AudioManager;
import android.util.Log;

import com.midea.light.BaseApplication;

import static android.content.Context.AUDIO_SERVICE;

public class VoiceSettingManager {

    public static int getSystemAudio() {
        AudioManager am = (AudioManager) BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        int current = am.getStreamVolume(AudioManager.STREAM_MUSIC);
        return current;
    }

    public static void setSystemAudio(int Audio) {
        Log.e("sky", "设置音量:" + Audio);
        AudioManager am = (AudioManager) BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        am.setStreamVolume(AudioManager.STREAM_MUSIC, Audio, AudioManager.FLAG_PLAY_SOUND);
    }
}
