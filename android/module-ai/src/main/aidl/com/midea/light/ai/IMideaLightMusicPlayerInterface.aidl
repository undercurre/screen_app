// IMideaLightMusicPlayerInterface.aidl
package com.midea.light.ai;
import com.midea.light.ai.IMideaLightFinishListener;
import com.midea.light.ai.MideaLightMusicInfo;

// Declare any non-default types here with import statements

interface IMideaLightMusicPlayerInterface {

    void setMusicInfoList(in MideaLightMusicInfo[] musicInfoList);

    MideaLightMusicInfo[] getMusicInfoList();

    void claerMusicInfoList();

    MideaLightMusicInfo getPlayMusicInfo();

    void setPlayMode(int mode);

    int getPlayMode();

    boolean isPlaying();

    void playIndexMusic(int index);

    void setOnFinishListener(IMideaLightFinishListener OnFinishListener);

    void clearOnFinishListener();

    void seekToProgress(int position);

    void startMusic();

    void pauseMusic();

    void nextMusic();

    void prevMusic();

    void stopMusic();

    int getCurrentIndex();

    String getMaxTime();

    int getProgress();

    int getMaxProgress();

    String getCurrentTime();
}