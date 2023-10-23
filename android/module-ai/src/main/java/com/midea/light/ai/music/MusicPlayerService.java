package com.midea.light.ai.music;

import android.annotation.TargetApi;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.os.RemoteException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.midea.light.ai.IMideaLightFinishListener;
import com.midea.light.ai.IMideaLightMusicPlayerInterface;
import com.midea.light.ai.MideaLightMusicInfo;

public class MusicPlayerService extends Service {

    public static ArrayList<MideaLightMusicInfo> musicInfoList; //音乐列表
    public static int position = 0;  //音乐索引
    public static SmartMideaPlayer mediaPlayer; //音乐播放器
    //当前播放时间
    private int currentTime;
    //音乐时长
    private int duration;
    /*
        判断用户点击的歌曲是否时当前正在播放的歌曲
    */
    public static Boolean MUSIC_STATE = false;

    private IBinder binder = new IMideaLightMusicPlayerInterface.Stub() {

        @Override
        public void setMusicInfoList(MideaLightMusicInfo[] musicInfoList) throws RemoteException {
            ArrayList<MideaLightMusicInfo> list = new ArrayList<>();
            if(musicInfoList != null) {
                Collections.addAll(list, musicInfoList);
            }
            MusicPlayerService.this.setMusicInfoList(list);
        }

        @Override
        public MideaLightMusicInfo[] getMusicInfoList() throws RemoteException {
            if(MusicPlayerService.this.getMusicInfoList() != null) {
                return MusicPlayerService.this.getMusicInfoList().toArray(new MideaLightMusicInfo[0]);
            }
            return null;
        }

        @Override
        public void claerMusicInfoList() throws RemoteException {
            MusicPlayerService.this.claerMusicInfoList();
        }

        @Override
        public MideaLightMusicInfo getPlayMusicInfo() throws RemoteException {
            return MusicPlayerService.this.getPlayMusicInfo();
        }

        @Override
        public void setPlayMode(int mode) throws RemoteException {
            MusicPlayerService.this.setPlayMode(mode);
        }

        @Override
        public int getPlayMode() throws RemoteException {
            return MusicPlayerService.this.getPlayMode();
        }

        @Override
        public boolean isPlaying() throws RemoteException {
            return MusicPlayerService.this.isPlaying();
        }

        @Override
        public void playIndexMusic(int index) throws RemoteException {
            MusicPlayerService.this.playIndexMusic(index);
        }

        @Override
        public void setOnFinishListener(IMideaLightFinishListener OnFinishListener) throws RemoteException {
            MusicPlayerService.this.setOnFinishListener(new SmartMideaPlayer.OnFinishListener() {
                @Override
                public void onAllFinish() {
                    try {
                        OnFinishListener.onAllFinish();
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onNextPartStart() {
                    try {
                        OnFinishListener.onNextPartStart();
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onLastPartEnd() {
                    try {
                        OnFinishListener.onLastPartEnd();
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                }
            });
        }

        @Override
        public void clearOnFinishListener() throws RemoteException {
            MusicPlayerService.this.clearOnFinishListener();
        }

        @Override
        public void seekToProgress(int position) throws RemoteException {
            MusicPlayerService.this.seekToProgress(position);
        }

        @Override
        public void startMusic() throws RemoteException {
            MusicPlayerService.this.startMusic();
        }

        @Override
        public void pauseMusic() throws RemoteException {
            MusicPlayerService.this.pauseMusic();
        }

        @Override
        public void nextMusic() throws RemoteException {
            MusicPlayerService.this.nextMusic();
        }

        @Override
        public void prevMusic() throws RemoteException {
            MusicPlayerService.this.prevMusic();
        }

        @Override
        public void stopMusic() throws RemoteException {
            MusicPlayerService.this.stopMusic();
        }

        @Override
        public int getCurrentIndex() throws RemoteException {
            return MusicPlayerService.this.getCurrentIndex();
        }

        @Override
        public String getMaxTime() throws RemoteException {
            return MusicPlayerService.this.getMaxTime();
        }

        @Override
        public int getProgress() throws RemoteException {
            return MusicPlayerService.this.getProgress();
        }

        @Override
        public int getMaxProgress() throws RemoteException {
            return MusicPlayerService.this.getMaxProgress();
        }

        @Override
        public String getCurrentTime() throws RemoteException {
            return MusicPlayerService.this.getCurrentTime();
        }

    };

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onCreate() {
        super.onCreate();
    }

    @TargetApi(Build.VERSION_CODES.O)
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    /*
    销毁数据
     */
    @Override
    public void onDestroy() {
        super.onDestroy();
        stopForeground(true);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    /*
    播放第几首
     */
    public void setIndex(int index) {
        /*
        判断用户点击的歌曲是否时当前正在播放的歌曲
         */
        MUSIC_STATE = index == position;
        position = index;
        startMusic();
    }

    public int getCurrentIndex() {
        return SmartMideaPlayer.getInstance().getCurrentIndex();
    }

    /*
    设置音乐列表
     */
    public void setMusicInfoList(ArrayList<MideaLightMusicInfo> list) {
        musicInfoList = list;
        SmartMideaPlayer.getInstance().playList(musicInfoList);
        position = 0;
    }

    /*
    播放音乐列表
     */
    public void actionMusic() {
        if (musicInfoList != null)
            SmartMideaPlayer.getInstance().playByIndex(SmartMideaPlayer.getInstance().getCurrentIndex());
    }

    /*
    播放音乐列表
     */
    public void startMusic() {
        if (musicInfoList != null)
            SmartMideaPlayer.getInstance().start();
    }

    /*
    下一曲
     */
    public void nextMusic() {
        if (musicInfoList != null)
            SmartMideaPlayer.getInstance().next();
    }

    /*
    上一曲
     */
    public void prevMusic() {
        if (musicInfoList != null)
            SmartMideaPlayer.getInstance().prev();
    }

    /*
    停止音乐
     */
    public void stopMusic() {
        if (musicInfoList != null){
            SmartMideaPlayer.getInstance().stop();
        }
    }

    /*
    暂停音乐
     */
    public void pauseMusic() {
        if (musicInfoList != null){
            SmartMideaPlayer.getInstance().pause();
        }
    }

    /*
    获取音乐进度,秒为单位
     */
    public int getProgress() {
        return SmartMideaPlayer.getInstance().getProgress();
    }

    /*
    获取音乐总时长,秒为单位
     */
    public int getMaxProgress() {
        return SmartMideaPlayer.getInstance().getDurationPosition() / 1000;
    }

    /*
    获取音乐总时长,时分秒
     */
    public String getMaxTime() {
        return SmartMideaPlayer.getInstance().getMaxTime();
    }

    /*
   获取音乐当前时长,时分秒
    */
    public String getCurrentTime() {
        return SmartMideaPlayer.getInstance().getCurrentTime();
    }

    public List<MideaLightMusicInfo> getMusicInfoList() {
        return musicInfoList;
    }

    public void claerMusicInfoList() {
        if (musicInfoList != null) {
            musicInfoList.clear();
        }
        SmartMideaPlayer.getInstance().claerMusicList();
    }

    public MideaLightMusicInfo getPlayMusicInfo() {
        if (musicInfoList != null) {
            return SmartMideaPlayer.getInstance().getCurrentMusic();
        } else {
            return null;
        }
    }

    public void setPlayMode(int mode) {
        SmartMideaPlayer.getInstance().setPlayMode(mode);
    }

    public int getPlayMode() {
        return SmartMideaPlayer.getInstance().getPlayMode();
    }

    public boolean isPlaying() {
        return SmartMideaPlayer.getInstance().isPlaying();
    }

    public void playIndexMusic(int index) {
        if (musicInfoList != null)
            SmartMideaPlayer.getInstance().playByIndex(index);
    }

    public void setOnFinishListener(SmartMideaPlayer.OnFinishListener OnFinishListener) {
        SmartMideaPlayer.getInstance().setOnFinishListener(OnFinishListener);
    }

    public void clearOnFinishListener() {
        SmartMideaPlayer.getInstance().clearOnFinishListener();
    }

    public void seekToProgress(int position) {
        SmartMideaPlayer.getInstance().seekTo(position);
    }
}