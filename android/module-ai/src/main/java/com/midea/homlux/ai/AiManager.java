package com.midea.homlux.ai;

import static android.content.Context.BIND_AUTO_CREATE;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import com.midea.homlux.ai.impl.AISetVoiceCallBack;
import com.midea.homlux.ai.impl.WakUpStateCallBack;
import com.midea.homlux.ai.services.MideaAiService;
import com.midea.light.BaseApplication;
import com.midea.light.ai.IHomluxAIInterface;
import com.midea.light.ai.IHomluxAISetVoiceCallBack;
import com.midea.light.ai.IHomluxAICompleteIntialCallBack;
import com.midea.light.ai.IHomluxWakeUpStateCallback;
import com.midea.light.ai.IMideaLightWakUpStateCallBack;
import com.midea.light.thread.MainThread;
import com.midea.homlux.ai.impl.IntialCallBack;
import java.util.Objects;

public class AiManager {
    private boolean isAiEnable = true;
    Context context;
    WakUpStateCallBack mWakUpStateCallBack;
    AISetVoiceCallBack mAISetVoiceCallBack;
    IntialCallBack mIntialCallBack;
    public boolean isAiWork=false;

    private String env;
    private String uid;
    private String token;
    private String houseId;
    private String aiClientId;
    private boolean isInit = false;

    IHomluxAIInterface mMyBinder;

    private AiManager() {}

    public static AiManager Instance = new AiManager();

    public static AiManager getInstance() {
        return Instance;
    }

    public void setEnv(String env) {
        this.env = env;
    }

    private ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            Log.e("sky", "语音开始进入初始化");
            mMyBinder = IHomluxAIInterface.Stub.asInterface(binder);
            try {
                mMyBinder.initSDK(env);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            try {
                mMyBinder.init(uid, token, isAiEnable, houseId, aiClientId);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            try {
                mMyBinder.addWakUpStateCallBack(new IHomluxWakeUpStateCallback.Stub() {
                    @Override
                    public void wakUpState(boolean isWakUp) throws RemoteException {
                        if(mWakUpStateCallBack != null) {
                            mWakUpStateCallBack.wakUpState(isWakUp);
                        }
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            try {
                mMyBinder.addAISetVoiceCallBack(new IHomluxAISetVoiceCallBack.Stub() {
                    @Override
                    public void SetVoice(int Voice) throws RemoteException {
                        mAISetVoiceCallBack.SetVoice(Voice);
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }

            try {
                mMyBinder.addAICompleteIntialCallBack(new IHomluxAICompleteIntialCallBack.Stub() {
                    @Override
                    public void CompleteIntial(boolean Intial) throws RemoteException {
                        isInit = Intial;
                        mIntialCallBack.intialState(Intial);
                    }
                });
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mMyBinder = null;
            Log.i("sky", "语音异常连接断开");
            MainThread.postDelayed(() -> {
                try {
                    if (!Objects.equals(token,"")) {
                        Log.i("sky", "重启语音服务");
                        Intent intent2 = new Intent(AiManager.this.context, MideaAiService.class);
                        AiManager.this.context.bindService(intent2, conn, BIND_AUTO_CREATE);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }, 10 * 1000);
        }
    };

    public void init(String uid, String token, boolean aiEnable, String houseId, String aiClientId, WakUpStateCallBack mCallBack, AISetVoiceCallBack VoiceCallBack,IntialCallBack intialCallBack) {
        this.context = BaseApplication.getContext();
        this.uid = uid;
        this.token = token;
        this.isAiEnable = aiEnable;
        this.houseId = houseId;
        this.aiClientId = aiClientId;
        this.mWakUpStateCallBack = mCallBack;
        this.mAISetVoiceCallBack = VoiceCallBack;
        this.mIntialCallBack=intialCallBack;
        try {
            Log.i("sky", "初始化语音服务");
            Intent intent2 = new Intent(AiManager.this.context, MideaAiService.class);
            AiManager.this.context.bindService(intent2, conn, BIND_AUTO_CREATE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void wakeupAi() {
        if(mMyBinder != null) {
            try {
                mMyBinder.wakeupAi();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void setAiEnable(boolean enable) {
        if(mMyBinder != null) {
            try {
                mMyBinder.setAiEnable(enable);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void stopAi() {
        if (context != null) {
            try {
                uid = "";
                token = "";
                houseId = "";
                aiClientId = "";
                if(mMyBinder != null) {
                    mMyBinder.stopAi();
                }

                context.unbindService(conn);
            } catch (IllegalArgumentException e) {
                e.printStackTrace();
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public boolean isDuplexModeFullDuplex()
    {
        return true;
    }

    public boolean setDuplexModeFullDuplex(boolean isEnable) {
        if(mMyBinder != null && isInit) {
            try {
                if (mMyBinder.setDuplexMode(isEnable)){

                    return true;
                }
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }

        return false;
    }
}
