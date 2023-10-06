package com.midea.light.ai;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;

import com.midea.light.ai.AiSpeech.TTSItem;
import com.midea.light.ai.impl.AISetVoiceCallBack;
import com.midea.light.ai.impl.AiControlDeviceErrorCallBack;
import com.midea.light.ai.impl.FlashMusicListCallBack;
import com.midea.light.ai.impl.MusicPlayControlBack;
import com.midea.light.ai.impl.ServerBindCallBack;
import com.midea.light.ai.impl.ServerInitialBack;
import com.midea.light.ai.impl.WakUpStateCallBack;
import com.midea.light.ai.services.MideaAiService;
import com.midea.light.common.utils.DialogUtil;

import static android.content.Context.BIND_AUTO_CREATE;

public class AiManager {
    private MideaAiService sever;
    private Context context;
    private String sn;
    private String deviceType;
    private String deviceCode;
    private String mac;
    private FlashMusicListCallBack CallBack;
    private WakUpStateCallBack mWakUpStateCallBack;
    private ServerBindCallBack BindCallBack;
    private ServerInitialBack InitialBack;
    private MusicPlayControlBack MusicPlayControl;
    private AISetVoiceCallBack SetVoiceCallBack;
    private AiControlDeviceErrorCallBack ControlDeviceErrorCallBack;

    private Intent intent;

    private AiManager() {

    }

    public static AiManager Instance = new AiManager();

    public static AiManager getInstance() {
        return Instance;
    }

    private void addService(MideaAiService s) {
        sever = s;
        sever.setServerInitialBack(InitialBack, BindCallBack);
        BindCallBack.isServerBind(true);
    }

    public void setDeviceInfor(String sn, String deviceType, String deviceCode, String mac) {
        this.sn = sn;
        this.deviceType = deviceType;
        this.deviceCode = deviceCode;
        this.mac = mac;
        Message message = new Message();
        message.arg1 = 1;
        mHandler.sendMessage(message);
    }

    public void startAiServer(Context activity, ServerBindCallBack BindCallBack, ServerInitialBack InitialBack) {
        this.context = activity;
        intent = new Intent(activity, MideaAiService.class);
        this.context.bindService(intent, conn, BIND_AUTO_CREATE);
        this.BindCallBack = BindCallBack;
        this.InitialBack = InitialBack;
    }

    private ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            MideaAiService.MyBinder mMyBinder = (MideaAiService.MyBinder) binder;
            addService(mMyBinder.getService());
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    };


    public void addFlashMusicListCallBack(FlashMusicListCallBack CallBack) {
        this.CallBack = CallBack;
        if (sever != null) {
            sever.setFlashMusicListCallBack(CallBack);
        }
    }

    public void addWakUpStateCallBack(WakUpStateCallBack CallBack) {
        this.mWakUpStateCallBack = CallBack;
        if (sever != null) {
            sever.addWakUpStateCallBack(mWakUpStateCallBack);
        }
    }

    public void addMusicPlayControlBack(MusicPlayControlBack CallBack) {
        this.MusicPlayControl = CallBack;
        if (sever != null) {
            sever.addMusicPlayControlCallBack(MusicPlayControl);
        }
    }

    public void addAISetVoiceCallBack(AISetVoiceCallBack CallBack) {
        this.SetVoiceCallBack = CallBack;
        if (sever != null) {
            sever.addAISetVoiceCallBack(SetVoiceCallBack);
        }
    }

    public void addControlDeviceErrorCallBack(AiControlDeviceErrorCallBack CallBack) {
        this.ControlDeviceErrorCallBack = CallBack;
        if (sever != null) {
            sever.addAIControlDeviceErrorCallBack(ControlDeviceErrorCallBack);
        }
    }

    public void getMusicList() {
        if (sever != null) {
            sever.getMusicList();
        }
    }

    private Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            switch (message.arg1) {
                case 1:
                    if (sever != null) {
                        sever.start(context, sn, deviceType, deviceCode, mac);
                    }
                    break;
            }
            return true;
        }
    });

    public void setAiEnable(boolean aiEnable) {
        if (sever != null) {
            if (aiEnable) {
                sever.isAiEnable = true;
                sever.startRecord();
            } else {
                sever.isAiEnable = false;
                sever.stopRecord();
            }

        }
    }

    public void wakeupAi() {
        if (sever != null) {
            sever.wakeupByHand();
        } else {
            DialogUtil.showToast("小美语音服务启动失败,请重启设备");
        }
    }

    public void updateVoiceToCloud(int voice) {
        if (sever != null) {
            sever.updateVoiceToCloud(voice);
        }
    }

    public void reportPlayerStatusToCloud(String MusicUrl, String Song, int index, String str_status) {
        TTSItem ttsItem = new TTSItem(MusicUrl);
        ttsItem.setAutoResume(true);
        ttsItem.setUrlType("media");
        ttsItem.setLabel(Song);
        ttsItem.setSkillType("");
        ttsItem.setSeq(index + 1);
        if (sever != null) {
            sever.reportPlayerStatusToCloud(ttsItem, str_status);
        }
    }

    public void stopAi() {
        try {
            if (sever != null) {
                sever.stop();
                context.unbindService(conn);
                sever.stopService(intent);
                sever.stopSelf();
            }
        } catch (Exception e) {

        }

    }

    public boolean isAiStop() {
        if (sever == null) {
            return true;
        } else {
            if (sever != null) {
                if (sever.mMediaMwEngine == null) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

}
