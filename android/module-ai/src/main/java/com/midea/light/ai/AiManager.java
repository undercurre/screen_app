package com.midea.light.ai;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;

import com.midea.light.BaseApplication;
import com.midea.light.ai.impl.AISetVoiceCallBack;
import com.midea.light.ai.impl.AiControlDeviceErrorCallBack;
import com.midea.light.ai.impl.FlashMusicListCallBack;
import com.midea.light.ai.impl.MusicPlayControlBack;
import com.midea.light.ai.impl.ServerBindCallBack;
import com.midea.light.ai.impl.ServerInitialBack;
import com.midea.light.ai.impl.WakUpStateCallBack;
import com.midea.light.ai.services.MideaAiService;
import com.midea.light.common.utils.DialogUtil;
import com.midea.light.thread.MainThread;

import static android.content.Context.BIND_AUTO_CREATE;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Timer;

public class AiManager {
    private IMideaLightAIdlInterface sever;
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

    private AiManager() {}

    public static AiManager Instance = new AiManager();

    public static AiManager getInstance() {
        return Instance;
    }

    private void addService(IMideaLightAIdlInterface s) {
        sever = s;
        try {
            sever.setServerInitialBack(new IMideaLightServerInitialCallBack.Stub() {
                @Override
                public void isInitial(boolean isInitial) throws RemoteException {
                    Log.e("sky", "语音初始化完成");
                    InitialBack.isInitial(isInitial);
                }
            }, new IMideaLightServerBindCallBack.Stub() {
                @Override
                public void isServerBind(boolean isbind) throws RemoteException {
                    Log.e("sky", "service bind 完成");
                    BindCallBack.isServerBind(isbind);
                }
            });
        } catch (RemoteException e) {
            e.printStackTrace();
        }
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

    public void startAiServer(ServerBindCallBack BindCallBack, ServerInitialBack InitialBack) {
        this.context = BaseApplication.getContext();
        intent = new Intent(context, MideaAiService.class);
        this.context.bindService(intent, conn, BIND_AUTO_CREATE);
        this.BindCallBack = BindCallBack;
        this.InitialBack = InitialBack;
    }



    private ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            Log.e("sky", "MideaAiService已启动");
            IMideaLightAIdlInterface.Stub.asInterface(binder);
            addService(IMideaLightAIdlInterface.Stub.asInterface(binder));
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.e("sky", "语音服务异常断开");
            sever = null;
            //ServiceConnection.onServiceDisconnected() 方法是在 Service 和客户端之间的连接意外中断时调用的。
            // 这种情况通常是由于 Service 崩溃或被系统杀死导致的。
            MainThread.postDelayed(() -> {
                try {
                    intent = new Intent(context, MideaAiService.class);
                    context.bindService(intent, conn, BIND_AUTO_CREATE);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }, 10 * 1000);

        }
    };


    public void addFlashMusicListCallBack(FlashMusicListCallBack callBack) {
        this.CallBack = callBack;
        if (sever != null) {
            try {
                sever.setFlashMusicListCallBack(new IMideaLightFlashMusicListCallback.Stub(){
                    @Override
                    public void FlashMusicList(MideaLightMusicInfo[] musics) throws RemoteException {
                        ArrayList<MideaLightMusicInfo> list = new ArrayList<>();
                        if(musics != null) {
                            Collections.addAll(list, musics);
                        }
                        CallBack.FlashMusicList(list);
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void addWakUpStateCallBack(WakUpStateCallBack callBack) {
        this.mWakUpStateCallBack = callBack;
        if (sever != null) {
            try {
                sever.addWakUpStateCallBack(new IMideaLightWakUpStateCallBack.Stub() {
                    @Override
                    public void wakUpState(boolean isWakUp) throws RemoteException {
                        mWakUpStateCallBack.wakUpState(isWakUp);
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void addMusicPlayControlBack(MusicPlayControlBack callBack) {
        this.MusicPlayControl = callBack;
        if (sever != null) {
            try {
                sever.addMusicPlayControlCallBack(new IMideaLightMusicPlayControlBack.Stub() {
                    @Override
                    public void playControl(String Control) throws RemoteException {
                        MusicPlayControl.playControl(Control);
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void addAISetVoiceCallBack(AISetVoiceCallBack callBack) {
        this.SetVoiceCallBack = callBack;
        if (sever != null) {
            try {
                sever.addAISetVoiceCallBack(new IMideaLightAISetVoiceCallBack.Stub() {
                    @Override
                    public void SetVoice(int Voice) throws RemoteException {
                        SetVoiceCallBack.SetVoice(Voice);
                    }
                });
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public void addControlDeviceErrorCallBack(AiControlDeviceErrorCallBack callBack) {
        this.ControlDeviceErrorCallBack = callBack;
        if (sever != null) {
            try {
                sever.addAIControlDeviceErrorCallBack(new IMideaLightAiControlDeviceErrorCallBack.Stub() {
                    @Override
                    public void ControlDeviceError() throws RemoteException {
                        ControlDeviceErrorCallBack.ControlDeviceError();
                    }
                });
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public void getMusicList() {
        if (sever != null) {
            try {
                sever.getMusicList();
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
                    if (sever != null) {
                        try {
                            sever.start(sn, deviceType, deviceCode, mac);
                        } catch (RemoteException e) {
                            e.printStackTrace();
                        }
                    }
                    break;
            }
            return true;
        }
    });

    public void setAiEnable(boolean aiEnable) {
        if (sever != null) {
            if (aiEnable) {
                try {
                    sever.startRecord();
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            } else {
                try {
                    sever.stopRecord();
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void wakeupAi() {
        if (sever != null) {
            try {
                sever.wakeupByHand();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        } else {
            DialogUtil.showToast("小美语音服务启动失败,请重启设备");
        }
    }

    public void updateVoiceToCloud(int voice) {
        if (sever != null) {
            try {
                sever.updateVoiceToCloud(voice);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void reportPlayerStatusToCloud(String MusicUrl, String Song, int index, String str_status) {
        if (sever != null) {
            try {
                sever.reportPlayerStatusToCloud(MusicUrl, Song, index, str_status);
            } catch (RemoteException e) {
                e.printStackTrace();
            }

        }
    }

    public void stopAi() {
        try {
            if (sever != null) {
                sever.stop();
            }
            context.unbindService(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
