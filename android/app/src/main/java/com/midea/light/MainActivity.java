package com.midea.light;

import android.Manifest;
import android.app.Instrumentation;
import android.content.Context;
import android.os.Bundle;
import android.os.Environment;
import android.os.PowerManager;
import android.view.KeyEvent;

import com.midea.light.ai.AiManager;
import com.midea.light.ai.music.MusicManager;
import com.midea.light.ai.utils.FileUtils;
import com.midea.light.channel.Channels;
import com.midea.light.common.utils.DialogUtil;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;

public class MainActivity extends FlutterActivity {
    // 与Flutter通信通道
    Channels mChannels = new Channels();
    boolean isMusicPlay = false;
    boolean isAiSleep = true;
    boolean isFlashMusic = false;
    private final String[] permissions = new String[]{
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.CHANGE_WIFI_MULTICAST_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
    };

    public void onCreate(Bundle bundle) {
        requestPermissions(permissions, 0x18);
        super.onCreate(bundle);
        MainApplication.mMainActivity=this;

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 动态添加插件
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        // 初始化自定义的Channel
        mChannels.init(this, flutterEngine.getDartExecutor().getBinaryMessenger());
    }

    public void initialAi(String sn,String deviceId,String mac){
        new Thread(() -> {
            //复制assets/xiaomei文件夹中的文件到SD卡
            FileUtils.copyAssetsFilesAndDelete(MainActivity.this, "xiaomei", Environment.getExternalStorageDirectory().getPath());
            runOnUiThread(() ->  startAiService(sn,deviceId,mac));
        }).start();
    }

    private void startAiService(String sn,String deviceId,String mac) {
        AiManager.getInstance().startAiServer(this, isBind -> {
            if (isBind) {
                setDeviceInfor(sn,deviceId,mac);
            }
        }, isInitial -> {
            if (isInitial) {
                AiManager.getInstance().setAiEnable(true);
            }else{
                runOnUiThread(() -> DialogUtil.showToast("语音初始化失败,请重新启动智慧屏"));
            }
        });
    }

    private void setDeviceInfor(String sn,String deviceId,String mac) {
        AiManager.getInstance().setDeviceInfor(sn, "0x16", deviceId, mac);
        MusicManager.getInstance().startMusicServer(this);
        AiManager.getInstance().addFlashMusicListCallBack(list -> {
            isFlashMusic=true;
            MusicManager.getInstance().setPlayList(list);
        });
        AiManager.getInstance().addWakUpStateCallBack(b -> {
            if (b) {
                isFlashMusic=false;
                if (!isScreenOn()) {
                    sendKeyEvent(KeyEvent.KEYCODE_BACK);
                }
                if (isAiSleep) {
                    isAiSleep = false;
                    isMusicPlay = MusicManager.getInstance().isPaying();
                }
                if (MusicManager.getInstance().isPaying()) {
                    MusicManager.getInstance().pauseMusic();
                }
            } else {
                isAiSleep = true;
                if (isMusicPlay||isFlashMusic) {
                    MusicManager.getInstance().startMusic();
                }
            }

        });
        AiManager.getInstance().addMusicPlayControlBack(Control -> {
            if(MusicManager.getInstance().getPlayMusicInfor()==null){
                return;
            }
            switch (Control) {
                case "RESUME":
                    isMusicPlay=true;
                    MusicManager.getInstance().startMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
                case "PAUSE":
                    isMusicPlay=false;
                    MusicManager.getInstance().pauseMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "pause");
                    break;
                case "STOP":
                    isMusicPlay=false;
                    MusicManager.getInstance().stopMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "stop");
                    break;
                case "prev":
                    isMusicPlay=true;
                    if (MusicManager.getInstance().getCurrentIndex() == 0) {
                        DialogUtil.showToast("已经是第一首了");
                        return;
                    }
                    MusicManager.getInstance().prevMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
                case "next":
                    isMusicPlay=true;
                    if (MusicManager.getInstance().getCurrentIndex() == 14) {
                        DialogUtil.showToast("已经是最后一首了");
                        return;
                    }
                    MusicManager.getInstance().nextMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(),
                            MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
            }
        });
        AiManager.getInstance().addAISetVoiceCallBack(Voice -> {

        });

    }

    public boolean isScreenOn() {
        PowerManager pm = (PowerManager) this.getSystemService(Context.POWER_SERVICE);
        boolean isScreenOn = pm.isInteractive();//如果为true，则表⽰屏幕“亮”了，否则屏幕“暗”了。
        return isScreenOn;
    }

    public void sendKeyEvent(final int KeyCode) {
        //不可在主线程中调用
        new Thread(() -> {
            try {
                Instrumentation inst = new Instrumentation();
                inst.sendKeyDownUpSync(KeyCode);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

}
