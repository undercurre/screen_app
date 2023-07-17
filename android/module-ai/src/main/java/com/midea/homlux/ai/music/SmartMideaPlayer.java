package com.midea.homlux.ai.music;

import android.media.AudioManager;

import com.midea.light.RxBus;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Random;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;

import static com.midea.homlux.ai.music.MusicPlayer.PlayMode.PLAY_MODE_LIST;
import static com.midea.homlux.ai.music.MusicPlayer.PlayState.PLAY;


public class SmartMideaPlayer {

    private IjkMediaPlayer ijkMediaPlayer;
    private int currentDuration = 0;
    private int currentPosition = 0;
    private int currentIndex = 0;
    private int PLAY_MODE = 1;
    private List<MusicInfo> MusicList=new ArrayList<>();
    private MusicInfo currentMusic;
    private int mSize;
    private static SmartMideaPlayer sInstance;
    private OnFinishListener onFinishListener;

    public IjkMediaPlayer getPlayer() {
        return ijkMediaPlayer;
    }

    public static synchronized SmartMideaPlayer getInstance() {
        if (sInstance == null) {
            sInstance = new SmartMideaPlayer();
            sInstance.init();
        }
        return sInstance;
    }

    private void init() {
        if (ijkMediaPlayer == null) {
            IjkMediaPlayer.loadLibrariesOnce(null);
            IjkMediaPlayer.native_profileBegin("libijkplayer.so");
            ijkMediaPlayer = new IjkMediaPlayer();
            ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "soundtouch", 0);
            ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzemaxduration", 50L);
            ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_clear", 1);
            ijkMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        }
    }

    public void setPathAndPrepare(String uri) {
        try {
            ijkMediaPlayer.reset();
            ijkMediaPlayer.setDataSource(uri);
            ijkMediaPlayer.prepareAsync();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void start() {
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.start();
        }
    }

    public void pause() {
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.pause();
        }
    }

    public void stop() {
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.reset();
            ijkMediaPlayer.stop();
        }
    }

    public void prev() {
        if (ijkMediaPlayer != null) {
            switch (PLAY_MODE) {
                case PLAY_MODE_LIST:
                    if (currentIndex == 0) {
                    } else {
                        currentIndex--;
                    }
                    break;
                case MusicPlayer.PlayMode.PLAY_MODE_REPEAT_ONE:
                case MusicPlayer.PlayMode.PLAY_MODE_REPEAT_LIST:
                    if (currentIndex == 0) {
                        currentIndex = mSize - 1;
                    } else {
                        currentIndex--;
                    }
                    break;
                case MusicPlayer.PlayMode.PLAY_MODE_SHUFFLE:
                    int tempIndex = currentIndex;
                    int index = new Random().nextInt(mSize);
                    while (index == tempIndex) {
                        index = new Random().nextInt(mSize);
                    }
                    currentIndex = index;
                    break;
                default:
            }
            pause();
            currentMusic = MusicList.get(currentIndex);
            setAndPrepared();
        }
    }

    public void next() {
        if (ijkMediaPlayer != null) {
            switch (PLAY_MODE) {
                case PLAY_MODE_LIST:
                    if (currentIndex == mSize - 1) {
                    } else {
                        currentIndex++;
                    }
                    break;
                case MusicPlayer.PlayMode.PLAY_MODE_REPEAT_ONE:
                case MusicPlayer.PlayMode.PLAY_MODE_REPEAT_LIST:
                    if (currentIndex == mSize - 1) {
                        currentIndex = 0;
                    } else {
                        currentIndex++;
                    }
                    break;
                case MusicPlayer.PlayMode.PLAY_MODE_SHUFFLE:
                    int tempIndex = currentIndex;
                    int index = new Random().nextInt(mSize);
                    while (index == tempIndex) {
                        index = new Random().nextInt(mSize);
                    }
                    currentIndex = index;
                    break;
                default:
            }
            pause();
            if(currentIndex<MusicList.size()){
                currentMusic = MusicList.get(currentIndex);
            }
            setAndPrepared();
        }
    }

    public void setAndPrepared() {
        setPathAndPrepare(currentMusic.getMusicUrl());
        ijkMediaPlayer.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer iMediaPlayer) {
                RxBus.getInstance().post(new MusicPlayEvent(getCurrentMusic()));
                RxBus.getInstance().post(new MusicPlayStateEvent(PLAY));
                start();
            }
        });
    }

    public MusicInfo getCurrentMusic() {
        return currentMusic;
    }

    public void seekTo(int position) {
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.seekTo(position);
        }
    }

    public int getDurationPosition() {
        if (ijkMediaPlayer != null) {
            return (int) ijkMediaPlayer.getDuration();
        } else {
            return 0;
        }
    }

    public int getCurrentDuration() {
        if (ijkMediaPlayer != null) {
            currentPosition = (int) ijkMediaPlayer.getCurrentPosition();
        }
        return currentPosition;
    }

    public int getProgress() {
        if (ijkMediaPlayer != null) {
            return (int) (ijkMediaPlayer.getCurrentPosition() / 1000);
        }
        return 0;
    }

    public boolean isPlaying() {
        return ijkMediaPlayer.isPlaying();
    }

    public void playList(List<MusicInfo> musicList) {
        this.MusicList = new ArrayList<>(musicList);
        mSize = MusicList.size();
        currentMusic = MusicList.get(0);
        currentIndex = 0;
        ijkMediaPlayer.setOnCompletionListener(mp -> {
            if (getDurationPosition() / 1000 - getCurrentDuration() / 1000 <= 1) {
                if (onFinishListener != null) {
                    onFinishListener.onLastPartEnd();
                }
                switch (PLAY_MODE) {
                    case PLAY_MODE_LIST:
                        if (currentIndex == mSize - 1) {
                            if (onFinishListener != null) {
                                onFinishListener.onAllFinish();
                            } else {
                                stop();
                                reset();
                            }
                            return;
                        } else {
                            currentIndex++;
                        }
                        break;
                    case MusicPlayer.PlayMode.PLAY_MODE_REPEAT_LIST:
                        if (currentIndex == mSize - 1) {
                            currentIndex = 0;
                        } else {
                            currentIndex++;
                        }
                        break;
                    case MusicPlayer.PlayMode.PLAY_MODE_REPEAT_ONE:
                        break;
                    case MusicPlayer.PlayMode.PLAY_MODE_SHUFFLE:
                        int tempIndex = currentIndex;
                        int index = new Random().nextInt(mSize);
                        while (index == tempIndex) {
                            index = new Random().nextInt(mSize);
                        }
                        currentIndex = index;
                        break;
                    default:
                }
                currentMusic = MusicList.get(currentIndex);
                if (onFinishListener != null) {
                    onFinishListener.onNextPartStart();
                }
            }
            reset();
            setAndPrepared();
        });
        ijkMediaPlayer.setOnErrorListener((mp, what, extra) -> {
            next();
            return false;
        });
        if (isPlaying()) pause();
        reset();
        setAndPrepared();
    }

    /**
     * 耗时
     */
    public void reset() {
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.reset();
        }
    }

    public void release() {
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.reset();
            ijkMediaPlayer.release();
            ijkMediaPlayer = null;
        }
    }

    public void setPlayMode(int mode) {
        PLAY_MODE = mode;
    }

    public int getCurrentIndex() {
        return this.currentIndex;
    }

    public void playByIndex(int index) {
        currentIndex = index;
        currentMusic = MusicList.get(currentIndex);
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.pause();
            ijkMediaPlayer.reset();
            setAndPrepared();
        }
    }

    public String getMaxTime() {
        return formatDuration(getDurationPosition());
    }

    public String getCurrentTime() {
        return formatDuration(getCurrentDuration());
    }

    public static String formatDuration(int duration) {
        // milliseconds into seconds
        duration /= 1000;
        int minute = duration / 60;
        int hour = minute / 60;
        minute %= 60;
        int second = duration % 60;
        if (hour != 0) {
            return String.format(Locale.CHINA, "%2d:%02d:%02d", hour, minute, second);
        } else {
            return String.format(Locale.CHINA, "%02d:%02d", minute, second);
        }
    }

    public int getPlayMode() {
        return PLAY_MODE;
    }

    public void setOnFinishListener(OnFinishListener listener) {
        this.onFinishListener = listener;
    }

    public void clearOnFinishListener() {
        this.onFinishListener = null;
    }

    public interface OnFinishListener {
        void onAllFinish();

        void onNextPartStart();

        void onLastPartEnd();
    }

    public void claerMusicList(){
        MusicList.clear();
        currentMusic=null;
        currentIndex=0;
    }

}
