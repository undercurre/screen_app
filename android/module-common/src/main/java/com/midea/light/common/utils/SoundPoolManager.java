package com.midea.light.common.utils;

import android.media.AudioAttributes;
import android.media.SoundPool;
import android.util.SparseIntArray;

import androidx.annotation.RawRes;

import com.midea.light.BaseApplication;

public class SoundPoolManager {

    private static class Inner {
        private final static SoundPoolManager helper = new SoundPoolManager();
    }

    public static SoundPoolManager getInstance() {
        return Inner.helper;
    }

    private SoundPool.Builder mBuilder;
    private AudioAttributes.Builder mAudioAttributes;

    private int mStreamType;
    private SoundPool mSoundPool;
    private int mStreamId = 0;
    SparseIntArray array = new SparseIntArray();

    /**
     * @param rawId raw中的资源
     * @param volume (range 0 to 1.0)
     * @param streamType – one of AudioManager.STREAM_VOICE_CALL, AudioManager.STREAM_SYSTEM, AudioManager.STREAM_RING, AudioManager.STREAM_MUSIC, AudioManager.STREAM_ALARM, or AudioManager.STREAM_NOTIFICATION.
     * @param repeat 是否重复播放 (0 = no loop, -1 = loop forever)
     * @param rate 播放速率 playback rate (1.0 = normal playback, range 0.5 to 2.0)
     */
    public void play(@RawRes int rawId, float volume, int streamType, int repeat, float rate) {

        if (null == mBuilder || streamType != mStreamType) {
            release();
            mStreamType = streamType;
            mBuilder = new SoundPool.Builder();
            // 传入最多播放音频数量,
            mBuilder.setMaxStreams(1);
            mAudioAttributes = new AudioAttributes.Builder();

            mAudioAttributes.setLegacyStreamType(streamType); // 设置音频流的合适的属性
            mBuilder.setAudioAttributes(mAudioAttributes.build());
            mSoundPool = mBuilder.build();
            array.clear();
        }

        if(array.get(rawId) != 0) {
            mStreamId = mSoundPool.play(array.get(rawId), volume, volume, 1, repeat, rate);
        } else {
            final int voiceId = mSoundPool.load(BaseApplication.getContext(), rawId, 1);
            mSoundPool.setOnLoadCompleteListener((soundPool, sampleId, status) -> {
                array.put(rawId, voiceId);
                mStreamId = soundPool.play(voiceId, volume, volume, 1, repeat, rate);
            });
        }

    }

    public void stop() {
        if (null != mSoundPool && 0 < mStreamId) {
            mSoundPool.autoPause();
            mSoundPool.stop(mStreamId);
        }
    }

    public void release() {
        if (null != mSoundPool) {
            mSoundPool.autoPause();
            mSoundPool.release();
            mSoundPool = null;
            mBuilder = null;
            mAudioAttributes = null;
        }
    }
}