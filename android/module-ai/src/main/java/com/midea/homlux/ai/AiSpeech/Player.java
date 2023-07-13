package com.midea.homlux.ai.AiSpeech;

import android.content.Context;
import android.media.AudioManager;
import android.net.Uri;
import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;

public class Player {

    private static final String TAG = "MusicPlayer";

    private List<TTSItem> ttsItems;

    private IjkMediaPlayer mPlayer;

    private TTSItem currentTTSItem;

    private int mSize;

    private int currentIndex = 0;

    private int PLAY_MODE = 0;

    private static Player sInstance;

    private int currentDuration = 0;
    private int currentPosition = 0;
    private OnFinishListener onFinishListener;

    private Context mContext;

    public static synchronized Player getInstance() {
        if (sInstance == null) {
            sInstance = new Player();
            sInstance.init();
        }
        return sInstance;
    }

    private void init() {
        if (mPlayer == null) {
            IjkMediaPlayer.loadLibrariesOnce(null);
            IjkMediaPlayer.native_profileBegin("libijkplayer.so");
            mPlayer = new IjkMediaPlayer();
            mPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "soundtouch", 0);
            mPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzemaxduration", 50L);
        }
        mPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
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

    public IjkMediaPlayer getPlayer() {
        return mPlayer;
    }

    public void playList(List<TTSItem> ttsItems) {
        this.ttsItems = ttsItems;

        PLAY_MODE = PlayMode.PLAY_MODE_LIST;
        mSize = ttsItems.size();
        currentTTSItem = ttsItems.get(0);
        currentIndex = 0;

        mPlayer.setOnCompletionListener(new IMediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(IMediaPlayer mp) {
                if (currentPosition / 1000 - currentDuration / 1000 <= 1) {
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
                    currentTTSItem = ttsItems.get(currentIndex);
                    onFinishListener.onNextPart();
                }
                mPlayer.reset();
                setAndPrepared();
            }
        });
        mPlayer.setOnErrorListener(new IMediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(IMediaPlayer mediaPlayer, int what, int extra) {
                Log.e(TAG, "onError: " + what + "," + extra);
                next();
                return false;
            }
        });
        if (mPlayer.isPlaying()) mPlayer.pause();
        mPlayer.reset();
        setAndPrepared();
    }

    public void setOnPreparedListener(IMediaPlayer.OnPreparedListener onPreparedListener) {
        mPlayer.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer mp) {
                currentDuration = (int) mp.getDuration();
                onPreparedListener.onPrepared(mp);
            }
        });
    }

    public int getDuration() {
        return currentDuration;
    }

    public int getCurrentDuration() {
        try {
            if (mPlayer != null) {
                currentPosition = (int) mPlayer.getCurrentPosition();
            }
        } catch (Exception e) {
            return 0;
        }
        return currentPosition;
    }

    public int getProgress() {
        try {
            if (mPlayer != null) {
                return (int) (mPlayer.getCurrentPosition() / 1000);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }


    public TTSItem getCurrentMusic() {
        return currentTTSItem;
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

    public void playItem(TTSItem item) {
        currentTTSItem = item;
        if (mPlayer != null) {
            if (mPlayer.isPlaying()) mPlayer.pause();
            mPlayer.reset();
            setAndPrepared();
        }
    }

    public void playByIndex(int index) {
        Log.d(TAG, "playByIndex: " + index);
        currentIndex = index;
        currentTTSItem = ttsItems.get(currentIndex);
        if (mPlayer != null) {
            mPlayer.pause();
            mPlayer.reset();
            setAndPrepared();
        }
    }

    public boolean stop() {
        if (mPlayer != null) {
            mPlayer.stop();
            mPlayer.release();
            mPlayer = null;
            sInstance = null;
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
            currentTTSItem = ttsItems.get(currentIndex);
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
            currentTTSItem = ttsItems.get(currentIndex);
            setAndPrepared();
            return true;
        } else {
            return false;
        }
    }

    private void setAndPrepared() {
        try {
            Log.d(TAG, "tts url: " + currentTTSItem.getLinkUrl());

            Uri finalUri = Uri.parse(currentTTSItem.getLinkUrl());
            Map<String, String> headers = new HashMap<String, String>();
            headers.put("User-Agent", "My custom User Agent name");
            mPlayer.setDataSource(mContext, finalUri, headers);
            mPlayer.prepareAsync();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isPlaying() {
        return mPlayer.isPlaying();
    }

    public List<TTSItem> getTtsList() {
        return ttsItems;
    }

    public boolean fastForward(int relativeTime, int absoluteTime) {
        Log.d(TAG, "fastForward: " + relativeTime + "," + absoluteTime);
        relativeTime = relativeTime * 1000;
        absoluteTime = absoluteTime * 1000;
        if (mPlayer != null) {
            int duration = (int) mPlayer.getDuration();
            int position = (int) mPlayer.getCurrentPosition();
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
            int duration = (int) mPlayer.getDuration();
            int position = (int) mPlayer.getCurrentPosition();
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

    public interface OnFinishListener {
        void onAllFinish();

        void onNextPart();
    }

    public void setmContext(Context ctx) {
        this.mContext = ctx;
    }

    public void cleanPlayList() {
        try {
            mPlayer = null;
            mPlayer = new IjkMediaPlayer();
            currentIndex = mSize - 1;
            this.ttsItems.clear();
            this.ttsItems = null;
        } catch (Exception e) {

        }

    }

    public void setOnPlayErrorListener(IMediaPlayer.OnErrorListener Listener) {
        if (mPlayer == null) {
            mPlayer=new IjkMediaPlayer();
        }
        mPlayer.setOnErrorListener(Listener);
    }
}
