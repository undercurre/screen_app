package com.midea.light.ai.music;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.Log;

import com.midea.light.RxBus;
import com.midea.light.ai.MideaLightMusicInfo;
import com.midea.light.common.utils.DialogUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;

public class MusicPlayer {

    private static String TAG = "MusicPlayer";

    private List<MideaLightMusicInfo> MusicList;
    private MediaPlayer mPlayer = new MediaPlayer();

    private MideaLightMusicInfo currentMusic;

    private int mSize;

    private int currentIndex = 0;

    private int PLAY_MODE = 1;

    private static MusicPlayer sInstance;

    private int currentDuration = 0;
    private int currentPosition = 0;
    private OnFinishListener onFinishListener;

    private Context mContext;
    private boolean isPause = false;

    public static synchronized MusicPlayer getInstance() {
        if (sInstance == null) {
            sInstance = new MusicPlayer();
        }
        return sInstance;
    }

    interface PlayMode {

        /**
         * 顺序播放
         */
        int PLAY_MODE_LIST = 0;

        /**
         * 列表循环
         */
        int PLAY_MODE_REPEAT_LIST = 1;

        /**
         * 单曲循环
         */
        int PLAY_MODE_REPEAT_ONE = 2;

        /**
         * 随机播放
         */
        int PLAY_MODE_SHUFFLE = 3;
    }

    public interface PlayState {

        /**
         * 停止
         */
        int STOP = 0;

        /**
         * 播放
         */
        int PLAY = 1;

        /**
         * 暂停
         */
        int PAUSE = 2;

    }

    public MusicPlayer() {
    }

    public void playList(List<MideaLightMusicInfo> musicList) {
        this.MusicList = new ArrayList<>(musicList);
        mSize = MusicList.size();
        currentMusic = MusicList.get(0);
        currentIndex = 0;
        mPlayer.setOnCompletionListener(mp -> {
            if (getDurationPosition() / 1000 - getCurrentDuration() / 1000 <= 1) {
                if (onFinishListener != null) {
                    onFinishListener.onLastPartEnd();
                }
                switch (PLAY_MODE) {
                    case PlayMode.PLAY_MODE_LIST:
                        if (currentIndex == mSize - 1) {
                            if (onFinishListener != null) {
                                onFinishListener.onAllFinish();
                            } else {
                                mPlayer.stop();
                                mPlayer.reset();
                            }
                            return;
                        } else {
                            currentIndex++;
                        }
                        break;
                    case PlayMode.PLAY_MODE_REPEAT_LIST:
                        if (currentIndex == mSize - 1) {
                            currentIndex = 0;
                        } else {
                            currentIndex++;
                        }
                        break;
                    case PlayMode.PLAY_MODE_REPEAT_ONE:
                        break;
                    case PlayMode.PLAY_MODE_SHUFFLE:
                        int tempIndex = currentIndex;
                        int index = new Random().nextInt(mSize);
                        while (index == tempIndex) {
                            index = new Random().nextInt(mSize);
                        }
                        currentIndex = index;
                        break;
                    default:
                }
                Log.e(TAG, "playlist currentIndex=  " + currentIndex);
                currentMusic = MusicList.get(currentIndex);
                if (onFinishListener != null) {
                    onFinishListener.onNextPartStart();
                }
            }
            mPlayer.reset();
            setAndPrepared();
        });
        mPlayer.setOnErrorListener((mp, what, extra) -> {
            DialogUtil.showToast("抱歉，当前资源找不到，即将播放下一个");
            Log.e(TAG, "onError: " + what + "," + extra);
            next();
            return false;
        });
        if (mPlayer.isPlaying()) mPlayer.pause();
        mPlayer.reset();
        setAndPrepared();
    }

    public void setOnPreparedListener(MediaPlayer.OnPreparedListener onPreparedListener) {
        mPlayer.setOnPreparedListener(mp -> {
            currentDuration = mp.getDuration();
            onPreparedListener.onPrepared(mp);
        });
    }

    public int getDuration() {
        return currentDuration;
    }

    public int getCurrentDuration() {
        try {
            if (mPlayer != null) {
                currentPosition = mPlayer.getCurrentPosition();
            }
        } catch (Exception e) {
            return 0;
        }
        return currentPosition;
    }

    public int getProgress() {
        try {
            if (mPlayer != null) {
                return mPlayer.getCurrentPosition() / 1000;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    public MideaLightMusicInfo getCurrentMusic() {
        return currentMusic;
    }

    public MideaLightMusicInfo getNextMusic() {
        if (currentIndex + 1 < MusicList.size()) {
            Log.e(TAG, "next music,currentIndex:" + (currentIndex + 1));
            return MusicList.get(currentIndex + 1);
        } else {
            Log.e(TAG, "no next music,currentIndex:" + currentIndex);
            return null;
        }
    }

    public MideaLightMusicInfo getPrevMusic() {
        if (currentIndex - 1 >= 0) {
            Log.e(TAG, "prev music,currentIndex:" + (currentIndex - 1));
            return MusicList.get(currentIndex - 1);
        } else {
            Log.e(TAG, "no prev music,currentIndex:" + currentIndex);
            return null;
        }
    }

    public void seekTo(int progress) {
        mPlayer.seekTo(progress);
    }

    public int getSize() {
        return mSize;
    }

    public boolean start() {
        if (mPlayer != null) {
            mPlayer.start();
            return true;
        } else {
            return false;
        }
    }

    public void playItem(MideaLightMusicInfo item) {
        currentMusic = item;
        if (mPlayer != null) {
            if (mPlayer.isPlaying()) mPlayer.pause();
            mPlayer.reset();
            setAndPrepared();
        }
    }

    public void playByIndex(int index) {
        Log.d(TAG, "playByIndex: " + index);
        currentIndex = index;
        currentMusic = MusicList.get(currentIndex);
        if (mPlayer != null) {
            mPlayer.pause();
            mPlayer.reset();
            setAndPrepared();
        }
    }

    public boolean stop() {
        if (mPlayer != null) {
            mPlayer.stop();
            mPlayer.reset();
            //mPlayer.release();  先不要释放
            //mPlayer = null;
            //sInstance = null;
            return true;
        } else {
            return false;
        }
    }

//    private void save(TTSItem title) {
//        LocalMusicSp.get().favorite(title);
//    }
//
//    private void remove(TTSItem title) {
//        LocalMusicSp.get().unFavorite(title);
//    }

    public boolean rePlay() {
        if (mPlayer != null) {
            mPlayer.seekTo(0);
            return true;
        } else {
            return false;
        }
    }

    public boolean pause() {
        if (mPlayer != null) {
            mPlayer.pause();
            return true;
        } else {
            return false;
        }
    }

    public boolean resume() {
        if (mPlayer != null) {
            mPlayer.start();
            isPause = false;
            return true;
        } else {
            return false;
        }
    }

    public boolean reset() {
        if (mPlayer != null) {
            mPlayer.reset();
            return true;
        } else {
            return false;
        }
    }

    public boolean release() {
        if (mPlayer != null) {
            mPlayer.release();
            return true;
        } else {
            return false;
        }
    }

    public void setPlayMode(int mode) {
        PLAY_MODE = mode;
        //LocalMusicSp.get().put("playMode", PLAY_MODE);
    }

    public int getPlayMode() {
        return PLAY_MODE;
    }

    public boolean prev() {
        if (mPlayer != null) {
            switch (PLAY_MODE) {
                case PlayMode.PLAY_MODE_LIST:
                    if (currentIndex == 0) {
                        return false;
                    } else {
                        currentIndex--;
                    }
                    break;
                case PlayMode.PLAY_MODE_REPEAT_ONE:
                case PlayMode.PLAY_MODE_REPEAT_LIST:
                    if (currentIndex == 0) {
                        currentIndex = mSize - 1;
                    } else {
                        currentIndex--;
                    }
                    break;
                case PlayMode.PLAY_MODE_SHUFFLE:
                    int tempIndex = currentIndex;
                    int index = new Random().nextInt(mSize);
                    while (index == tempIndex) {
                        index = new Random().nextInt(mSize);
                    }
                    currentIndex = index;
                    break;
                default:
            }
            mPlayer.pause();
            mPlayer.reset();
            currentMusic = MusicList.get(currentIndex);
            setAndPrepared();
            return true;
        } else {
            return false;
        }
    }

    public boolean next() {
        if (mPlayer != null) {
            switch (PLAY_MODE) {
                case PlayMode.PLAY_MODE_LIST:
                    if (currentIndex == mSize - 1) {
                        return false;
                    } else {
                        currentIndex++;
                    }
                    break;
                case PlayMode.PLAY_MODE_REPEAT_ONE:
                case PlayMode.PLAY_MODE_REPEAT_LIST:
                    if (currentIndex == mSize - 1) {
                        currentIndex = 0;
                    } else {
                        currentIndex++;
                    }
                    break;
                case PlayMode.PLAY_MODE_SHUFFLE:
                    int tempIndex = currentIndex;
                    int index = new Random().nextInt(mSize);
                    while (index == tempIndex) {
                        index = new Random().nextInt(mSize);
                    }
                    currentIndex = index;
                    break;
                default:
            }
            mPlayer.pause();
            mPlayer.reset();
            currentMusic = MusicList.get(currentIndex);
            setAndPrepared();
            return true;
        } else {
            return false;
        }
    }

    private void setAndPrepared() {
        try {
            Log.d(TAG, "url: " + currentMusic.getMusicUrl());

            Uri finalUri = Uri.parse(currentMusic.getMusicUrl());
            Map<String, String> headers = new HashMap<String, String>();
            headers.put("User-Agent", "My custom User Agent name");
            mPlayer.setDataSource(mContext, finalUri, headers);
            mPlayer.setAudioAttributes(new AudioAttributes.Builder()
                    .setLegacyStreamType(AudioManager.STREAM_MUSIC)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build());
            mPlayer.prepareAsync();
            isPause = false;
//            mPlayer.prepare();

            setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    RxBus.getInstance().post(new MusicPlayEvent(getCurrentMusic()));
                    RxBus.getInstance().post(new MusicPlayStateEvent(PlayState.PLAY));
                    mPlayer.start();
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isPlaying() {
        return mPlayer.isPlaying();
    }

    public void clearList() {
        MusicList.clear();
        mSize = 0;
        currentIndex = 0;
        currentMusic = null;
    }

    public List<MideaLightMusicInfo> getTtsList() {
        return MusicList;
    }

//    public boolean favorite() {
//        if (currentTTSItem != null) {
//            currentTTSItem.setFavorite(true);
//            save(currentTTSItem);
//            return true;
//        } else {
//            return false;
//        }
//    }

    public boolean fastForward(int relativeTime, int absoluteTime) {
        Log.d(TAG, "fastForward: " + relativeTime + "," + absoluteTime);
        relativeTime = relativeTime * 1000;
        absoluteTime = absoluteTime * 1000;
        if (mPlayer != null) {
            int duration = mPlayer.getDuration();
            int position = mPlayer.getCurrentPosition();
            if (absoluteTime != 0) {
                mPlayer.seekTo(absoluteTime);
                return true;
            } else if (relativeTime != 0) {
                if (relativeTime + position > duration) {
                    return false;
                } else {
                    mPlayer.seekTo(relativeTime + position);
                    return true;
                }
            } else {
                if (position + 10 > duration) {
                    return false;
                } else {
                    mPlayer.seekTo(position + 10000);
                    return true;
                }
            }
        } else {
            return false;
        }
    }

    public boolean backForward(int relativeTime, int absoluteTime) {
        Log.d(TAG, "backForward: " + relativeTime + "," + absoluteTime);
        relativeTime = relativeTime * 1000;
        absoluteTime = absoluteTime * 1000;
        if (mPlayer != null) {
            int duration = mPlayer.getDuration();
            int position = mPlayer.getCurrentPosition();
            if (absoluteTime != 0) {
                mPlayer.seekTo(absoluteTime);
                return true;
            } else if (relativeTime != 0) {
                if (position - relativeTime < 0) {
                    mPlayer.seekTo(0);
                    return false;
                } else {
                    mPlayer.seekTo(position - relativeTime);
                    return true;
                }
            } else {
                if (position - 10 < 0) {
                    return false;
                } else {
                    mPlayer.seekTo(position - 10000);
                    return true;
                }
            }
        } else {
            return false;
        }
    }

//    public boolean unFavorite() {
//        if (currentTTSItem != null) {
//            currentTTSItem.setFavorite(false);
//            remove(currentTTSItem);
//            return true;
//        } else {
//            return false;
//        }
//    }
//
//    public boolean isFavorite() {
//        return currentTTSItem.isFavorite();
//    }

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

    public static int getIntTime(String time) {
        try {
            String[] my = time.split(":");
            if (my.length == 3) {
                int hour = Integer.parseInt(my[0]);
                int min = Integer.parseInt(my[1]);
                int sec = Integer.parseInt(my[2]);
                return hour * 3600 + min * 60 + sec;
            } else if (my.length == 2) {
                int min = Integer.parseInt(my[0]);
                int sec = Integer.parseInt(my[1]);
                return min * 60 + sec;
            } else {
                return Integer.parseInt(my[0]);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
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

    public void setContext(Context ctx) {
        this.mContext = ctx;
    }

    public int getCurrentIndex() {
        return this.currentIndex;
    }

    public void setPauseStatus(boolean status) {
        this.isPause = status;
    }

    public boolean getPauseStatus() {
        return this.isPause;
    }

    public String getMaxTime() {
        return formatDuration(getDurationPosition());
    }

    public String getCurrentTime() {
        return formatDuration(getCurrentDuration());
    }

    public int getDurationPosition() {
        return mPlayer.getDuration();
    }
}