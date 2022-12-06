package com.midea.light.ai.music;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;

import com.midea.light.RxBus;
import com.midea.light.ai.AiManager;

import java.util.ArrayList;
import java.util.List;

import static android.content.Context.BIND_AUTO_CREATE;
import static com.midea.light.ai.music.MusicPlayer.PlayState.PAUSE;
import static com.midea.light.ai.music.MusicPlayer.PlayState.PLAY;
import static com.midea.light.ai.music.MusicPlayer.PlayState.STOP;

public class MusicManager {

    private MusicManager() {
    }

    private MusicPlayerService sever;

    public static MusicManager Instance = new MusicManager();

    public static MusicManager getInstance() {
        return Instance;
    }

    private void addService(MusicPlayerService s) {
        sever = s;
    }

    public void startMusicServer(Context activity) {
        Intent intent = new Intent(activity, MusicPlayerService.class);
        activity.bindService(intent, conn, BIND_AUTO_CREATE);
    }

    private final ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            MusicPlayerService.MusicBind mMyBinder = (MusicPlayerService.MusicBind) binder;
            addService(mMyBinder.getService());
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
        }
    };

    public void setPlayList(ArrayList<MusicInfo> musicInfoList) {
        if (sever != null) {
            RxBus.getInstance().post(new MusicPlayStateEvent(PLAY));
            sever.setMusicInfoList(musicInfoList);
            reportPlayerStatusToCloud("play");

        }
    }

    public List<MusicInfo> getPlayList() {
        if (sever != null) {
            return sever.getMusicInfoList();
        } else {
            return null;
        }
    }

    public void startMusic() {
        if (sever != null) {
            sever.startMusic();
            RxBus.getInstance().post(new MusicPlayStateEvent(PLAY));
            reportPlayerStatusToCloud("play");

        }
    }

    public void pauseMusic() {
        if (sever != null) {
            sever.pauseMusic();
            RxBus.getInstance().post(new MusicPlayStateEvent(PAUSE));
            reportPlayerStatusToCloud("pause");

        }
    }

    public void playIndexMusic(int index) {
        if (sever != null) {
            sever.playIndexMusic(index);
        }
    }

    public void nextMusic() {
        if (sever != null) {
            sever.nextMusic();
            reportPlayerStatusToCloud("play");
        }
    }

    public void prevMusic() {
        if (sever != null) {
            sever.prevMusic();
            reportPlayerStatusToCloud("play");
        }
    }

    public void stopMusic() {
        if (sever != null) {
            sever.stopMusic();
            RxBus.getInstance().post(new MusicPlayStateEvent(STOP));
            reportPlayerStatusToCloud("stop");
        }
    }

    public int getCurrentIndex() {
        if (sever != null) {
            return sever.getCurrentIndex();
        } else {
            return 0;
        }
    }

    public void setPlayMode(int mode) {
        if (sever != null) {
            sever.setPlayMode(mode);
        }
    }

    public int getPlayMode() {
        if (sever != null) {
            return sever.getPlayMode();
        } else {
            return 1;
        }
    }

    /*
    获取音乐总时长,时分秒
     */
    public String getMaxTime() {
        if (sever != null) {
            return sever.getMaxTime();
        } else {
            return null;
        }
    }

    /*
   获取音乐当前时长,时分秒
    */
    public String getCurrentTime() {
        if (sever != null) {
            return sever.getCurrentTime();
        } else {
            return null;
        }
    }

    /*
    获取音乐进度,秒为单位
     */
    public int getProgress() {
        if (sever != null) {
            return sever.getProgress();
        } else {
            return 0;
        }
    }

    /*
    获取音乐总时长,秒为单位
     */
    public int getMaxProgress() {
        if (sever != null) {
            return sever.getMaxProgress();
        } else {
            return 0;
        }
    }

    public void seekToProgress(int p) {
        if (sever != null) {
            sever.seekToProgress(p);
        }
    }

    public MusicInfo getPlayMusicInfor() {
        if (sever != null) {
            return sever.getPlayMusicInfo();
        } else {
            return null;
        }
    }

    public boolean isPaying() {
        if (sever != null) {
            return sever.isPlaying();
        } else {
            return false;
        }
    }

    public void setOnFinishListener(SmartMideaPlayer.OnFinishListener OnFinishListener) {
        if (sever != null) {
            sever.setOnFinishListener(OnFinishListener);
        }
    }

    public void claerMusicInfoList() {
        if (sever != null) {
            sever.claerMusicInfoList();
        }
    }

    public void clearOnFinishListener() {
        if (sever != null) {
            sever.clearOnFinishListener();
        }
    }

    private Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            switch (message.arg1) {
                case 1:
                    break;
            }
            return true;
        }
    });

    private void reportPlayerStatusToCloud(String state){
        if(MusicManager.getInstance().getPlayMusicInfor()!=null){
            AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),MusicManager.getInstance().getPlayMusicInfor().getSong(),
                    MusicManager.getInstance().getCurrentIndex(), state);
        }
    }


}