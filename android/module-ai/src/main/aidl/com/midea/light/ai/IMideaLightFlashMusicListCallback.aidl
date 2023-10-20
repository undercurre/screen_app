// IMideaLightFlashMusicListCallback.aidl
package com.midea.light.ai;
import com.midea.light.ai.MideaLightMusicInfo;
// Declare any non-default types here with import statements

interface IMideaLightFlashMusicListCallback {
    // 刷新音乐列表
    void FlashMusicList(inout MideaLightMusicInfo[] musics);
}