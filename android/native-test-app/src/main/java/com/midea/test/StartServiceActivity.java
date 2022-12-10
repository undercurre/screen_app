package com.midea.test;

import android.Manifest;
import android.app.Activity;
import android.app.Instrumentation;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.PowerManager;
import android.provider.Settings;
import android.view.KeyEvent;
import android.widget.Button;

import com.midea.light.ai.AiManager;
import com.midea.light.ai.music.MusicManager;
import com.midea.light.ai.utils.FileUtils;
import com.midea.light.common.utils.DialogUtil;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class StartServiceActivity extends Activity {

    boolean isMusicPlay = false;
    boolean isAiSleep = true;
    boolean isFlashMusic = false;

    private int REQUEST_CODE_PERMISSION = 0x00099;

    private final String[] permissions = new String[]{
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.CHANGE_WIFI_MULTICAST_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_service_layout);
        Button button=findViewById(R.id.button);
        Button button2=findViewById(R.id.button2);
        Button button3=findViewById(R.id.button3);

        requestPermission(permissions, 0x18);
        button.setOnClickListener(v -> startAiService());
        button2.setOnClickListener(v->{
            Intent intent =  new Intent(Settings.ACTION_SETTINGS);
            startActivity(intent);
        });
        button3.setOnClickListener(v->{
            finish();
        });
        if (!Settings.canDrawOverlays(this)) {
            Intent intent = new Intent();
            intent.setAction(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
            startActivity(intent);
        }
        new Thread(() -> {
            //复制assets/xiaomei文件夹中的文件到SD卡
            FileUtils.copyAssetsFilesAndDelete(StartServiceActivity.this, "xiaomei", Environment.getExternalStorageDirectory().getPath());
        }).start();
    }

    private void startAiService() {
        AiManager.getInstance().startAiServer(this, isBind -> {
            if (isBind) {
                setDeviceInfor();
            }
        }, isInitial -> {
            if (isInitial) {
                AiManager.getInstance().setAiEnable(true);
            }else{
                runOnUiThread(() -> DialogUtil.showToast("语音初始化失败,请重新启动智慧屏"));
            }
        });
    }

    private void setDeviceInfor() {
        AiManager.getInstance().setDeviceInfor("00001611FMSGWZ0100B0406B438D0000", "0x16",
                "211106233450716", "F0B0406B438D");
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

    public void requestPermission(String[] permissions, int requestCode) {
        this.REQUEST_CODE_PERMISSION = requestCode;
        if (checkPermissions(permissions)) {
            permissionSuccess(REQUEST_CODE_PERMISSION);
        } else {
            List<String> needPermissions = getDeniedPermissions(permissions);
            ActivityCompat.requestPermissions(this, needPermissions.toArray(new String[needPermissions.size()]), REQUEST_CODE_PERMISSION);
        }
    }

    private boolean checkPermissions(String[] permissions) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true;
        }

        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) !=
                    PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    public void permissionSuccess(int requestCode) {

    }

    /**
     * 获取权限集中需要申请权限的列表
     *
     * @param permissions
     * @return
     */
    private List<String> getDeniedPermissions(String[] permissions) {
        List<String> needRequestPermissionList = new ArrayList<>();
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) !=
                    PackageManager.PERMISSION_GRANTED ||
                    ActivityCompat.shouldShowRequestPermissionRationale(this, permission)) {
                needRequestPermissionList.add(permission);
            }
        }
        return needRequestPermissionList;
    }
}
