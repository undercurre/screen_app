package com.midea.light.ai.music;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;

import com.midea.light.RxBus;
import com.midea.light.ai.AiManager;
import com.midea.light.ai.IMideaLightFinishListener;
import com.midea.light.ai.IMideaLightMusicPlayerInterface;
import com.midea.light.ai.MideaLightMusicInfo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static android.content.Context.BIND_AUTO_CREATE;
import static com.midea.light.ai.music.MusicPlayer.PlayState.PAUSE;
import static com.midea.light.ai.music.MusicPlayer.PlayState.PLAY;
import static com.midea.light.ai.music.MusicPlayer.PlayState.STOP;

public class MusicManager {

    private MusicManager() {
    }

    private IMideaLightMusicPlayerInterface sever;

    public static MusicManager Instance = new MusicManager();

    public static MusicManager getInstance() {
        return Instance;
    }

    private void addService(IMideaLightMusicPlayerInterface s) {
        sever = s;
    }

    public void startMusicServer(Context activity) {
        try {
            Intent intent = new Intent(activity, MusicPlayerService.class);
            activity.bindService(intent, conn, BIND_AUTO_CREATE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void stopMusicServer(Context activity) {
        try {
            if(sever != null) {
                sever.stopMusic();
            }
            activity.unbindService(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private final ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            Log.i("sky", "MusicManager 服务已经连接");
            addService(IMideaLightMusicPlayerInterface.Stub.asInterface(binder));
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.i("sky", "MusicManager 服务已经断开");
            sever = null;
        }
    };

    public void setPlayList(ArrayList<MideaLightMusicInfo> musicInfoList) {
        if (sever != null) {
            RxBus.getInstance().post(new MusicPlayStateEvent(PLAY));
            try {
                sever.setMusicInfoList(musicInfoList != null? musicInfoList.toArray(new MideaLightMusicInfo[0]): null);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            reportPlayerStatusToCloud("play");
        }
    }

    public List<MideaLightMusicInfo> getPlayList() {
        if (sever != null) {
            try {
                MideaLightMusicInfo[] result = sever.getMusicInfoList();
                if (result != null) {
                    return Arrays.asList(result);
                } else {
                    return null;
                }
            } catch (RemoteException e) {
                return null;
            }
        } else {
            return null;
        }
    }

    public void startMusic() {
        if (sever != null) {
            try {
                sever.startMusic();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            RxBus.getInstance().post(new MusicPlayStateEvent(PLAY));
            reportPlayerStatusToCloud("play");

        }
    }

    public void pauseMusic() {
        if (sever != null) {
            try {
                sever.pauseMusic();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            RxBus.getInstance().post(new MusicPlayStateEvent(PAUSE));
            reportPlayerStatusToCloud("pause");

        }
    }

    public void playIndexMusic(int index) {
        if (sever != null) {
            try {
                sever.playIndexMusic(index);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void nextMusic() {
        if (sever != null) {
            try {
                sever.nextMusic();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            reportPlayerStatusToCloud("play");
        }
    }

    public void prevMusic() {
        if (sever != null) {
            try {
                sever.prevMusic();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            reportPlayerStatusToCloud("play");
        }
    }

    public void stopMusic() {
        if (sever != null) {
            try {
                sever.stopMusic();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            RxBus.getInstance().post(new MusicPlayStateEvent(STOP));
            reportPlayerStatusToCloud("stop");
        }
    }

    public int getCurrentIndex() {
        if (sever != null) {
            try {
                return sever.getCurrentIndex();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public void setPlayMode(int mode) {
        if (sever != null) {
            try {
                sever.setPlayMode(mode);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public int getPlayMode() {
        if (sever != null) {
            try {
                return sever.getPlayMode();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return 1;
    }

    /*
    获取音乐总时长,时分秒
     */
    public String getMaxTime() {
        if (sever != null) {
            try {
                return sever.getMaxTime();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    /*
   获取音乐当前时长,时分秒
    */
    public String getCurrentTime() {
        if (sever != null) {
            try {
                return sever.getCurrentTime();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    /*
    获取音乐进度,秒为单位
     */
    public int getProgress() {
        if (sever != null) {
            try {
                return sever.getProgress();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    /*
    获取音乐总时长,秒为单位
     */
    public int getMaxProgress() {
        if (sever != null) {
            try {
                return sever.getMaxProgress();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public void seekToProgress(int p) {
        if (sever != null) {
            try {
                sever.seekToProgress(p);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public MideaLightMusicInfo getPlayMusicInfor() {
        if (sever != null) {
            try {
                return sever.getPlayMusicInfo();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public boolean isPaying() {
        if (sever != null) {
            try {
                return sever.isPlaying();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public void setOnFinishListener(SmartMideaPlayer.OnFinishListener OnFinishListener) {
        if (sever != null) {
            try {
                sever.setOnFinishListener(new IMideaLightFinishListener.Stub() {
                    @Override
                    public void onAllFinish() throws RemoteException {
                        OnFinishListener.onAllFinish();
                    }

                    @Override
                    public void onNextPartStart() throws RemoteException {
                        OnFinishListener.onNextPartStart();
                    }

                    @Override
                    public void onLastPartEnd() throws RemoteException {
                        OnFinishListener.onLastPartEnd();
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void claerMusicInfoList() {
        if (sever != null) {
            try {
                sever.claerMusicInfoList();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void clearOnFinishListener() {
        if (sever != null) {
            try {
                sever.clearOnFinishListener();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
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