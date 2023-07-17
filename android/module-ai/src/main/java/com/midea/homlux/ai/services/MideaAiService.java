package com.midea.homlux.ai.services;

import android.app.Activity;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dds.exceptions.DDSNotInitCompleteException;
import com.midea.homlux.ai.AiSpeech.AiDialog;
import com.midea.homlux.ai.AiSpeech.WeatherDialog;
import com.midea.homlux.ai.bean.MessageBean;
import com.midea.homlux.ai.bean.WeatherBean;
import com.midea.homlux.ai.impl.AISetVoiceCallBack;
import com.midea.homlux.ai.impl.WakUpStateCallBack;
import com.midea.homlux.ai.music.MusicManager;
import com.midea.homlux.ai.observer.DuiCommandObserver;
import com.midea.homlux.ai.observer.DuiMessageObserver;
import com.midea.homlux.ai.observer.DuiNativeApiObserver;
import com.midea.homlux.ai.observer.DuiUpdateObserver;
import com.midea.light.common.utils.GsonUtils;

import java.util.LinkedList;
import java.util.Random;

import androidx.annotation.Nullable;

import static com.midea.homlux.ai.bean.MessageBean.TYPE_WIDGET_WEATHER;


public class MideaAiService extends Service implements DuiUpdateObserver.UpdateCallback, DuiMessageObserver.MessageCallback {

    private LinkedList<MessageBean> mMessageList = new LinkedList<>();// 当前消息容器
    private DuiMessageObserver mMessageObserver = new DuiMessageObserver();// 消息监听器
    private DuiCommandObserver mCommandObserver = new DuiCommandObserver();// 命令监听器
    private DuiNativeApiObserver mNativeApiObserver = new DuiNativeApiObserver();// 本地方法回调监听器
    private WakUpStateCallBack mWakUpStateCallBack;

    private AiDialog mAiDialog;
    private WeatherDialog mWeatherDialog;
    private MessageBean mMessageBean;
    private Activity context;
    private boolean isPlayBefore=false;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {

        return binder;
    }

    public void start(Activity context) {
        this.context = context;
        // 添加一个初始成功的广播监听器
        mAiDialog = new AiDialog(context, this);
        mWeatherDialog=new WeatherDialog(context,this);
        registMsg();
        enableWakeup();
    }

    @Override
    public void onUpdate(int type, String result) {

    }

    //client 能够经过Binder获取Service实例
    public class MyBinder extends Binder {
        public MideaAiService getService() {
            return MideaAiService.this;
        }
    }

    //经过binder实现调用者client与Service之间的通讯
    private MyBinder binder = new MyBinder();


    @Override
    public void onMessage(MessageBean mMessageBean) {
        this.mMessageBean = mMessageBean;
        context.runOnUiThread(() -> {
            mWeatherDialog.dismissDialog();
            if (!mAiDialog.isShowing()) {
                mAiDialog.show();
            }
            if (mMessageBean.getType() == TYPE_WIDGET_WEATHER) {
                try {
                    WeatherBean.WebhookRespBean.ExtraBean.ForecastBean today = mMessageBean.getWeatherBean().getWebhookResp().getExtra().getForecast().get(0);
                    Log.e("sky", "天气内容:" + GsonUtils.serializedToJson(today));
                    mWeatherDialog.setWeatherDetail(mMessageBean.getWeatherBean().getWebhookResp().getCityName(),today.getLowTemp(),today.getHighTemp(),
                            today.getWeather(),mMessageBean.getWeatherBean().getWebhookResp().getExtra().getIndex().getAqi().getAQL());
                    mWeatherDialog.show();
                    mAiDialog.initalDialog();
                } catch (Exception e) {

                }
            } else {
                Log.e("sky", "消息内容:" + mMessageBean.getText()+"--类型:"+mMessageBean.getType());
                if (!TextUtils.isEmpty(mMessageBean.getText())) {
                    if(mMessageBean.getText().contains("全天")&&mMessageBean.getText().contains("气温")&&mMessageBean.getText().contains("级")&&mMessageBean.getType()==0){
                        mAiDialog.initalDialog();
                    }else{
                        mAiDialog.addAnsAskItem(mMessageBean.getText());
                    }
                }
            }
        });
    }

    long curUpdateTime=0;
    @Override
    public void onState(String state) {
//        Log.e("sky", "语音状态:" + state);
        switch (state) {
            case "avatar.silence"://等待唤醒
                if(mMessageBean!=null&&mMessageBean.getText().contains("网络好像")){//网络故障延时4秒等播报玩提示后才消失
                    int resID = context.getResources().getIdentifier("net_error","raw",context.getPackageName());
                    MediaPlayer mm = MediaPlayer.create(context, resID);
                    mm.setOnCompletionListener(mediaPlayer -> {
                        mediaPlayer.reset();
                        mediaPlayer.release();
                    });
                    mm.start();
                    new Handler().postDelayed(() -> {
                        Log.e("sky", "等待唤醒");
                        if(SystemClock.uptimeMillis() - curUpdateTime < 1000){
                            //对话状态切换小于1秒时不给响应状态变化
                            return;
                        }
                        context.runOnUiThread(() -> {
                            mWeatherDialog.dismissDialog();
                            mAiDialog.dismissDialog();
                            if(mWakUpStateCallBack!=null){
                                mWakUpStateCallBack.wakUpState(false);
                            }
                            if(isPlayBefore){
                                if(mCommandObserver.hasMediaControlResult){
                                    if(mCommandObserver.mediaControlResult){
                                        MusicManager.getInstance().startMusic();
                                    }
                                }else{
                                    MusicManager.getInstance().startMusic();
                                }
                            }
                        });
                    },4000);
                }else{
                    Log.e("sky", "等待唤醒");
                    if(SystemClock.uptimeMillis() - curUpdateTime < 1000){
                        //对话状态切换小于1秒时不给响应状态变化
                        break;
                    }
                    context.runOnUiThread(() -> {
                        mWeatherDialog.dismissDialog();
                        mAiDialog.dismissDialog();
                        if(mWakUpStateCallBack!=null){
                            mWakUpStateCallBack.wakUpState(false);
                        }
                        if(isPlayBefore){
                            if(mCommandObserver.hasMediaControlResult){
                                if(mCommandObserver.mediaControlResult){
                                    MusicManager.getInstance().startMusic();
                                }
                            }else{
                                MusicManager.getInstance().startMusic();
                            }
                        }
                    });
                }
                break;
            case "avatar.listening"://监听中
                Log.e("sky", "监听中");
                context.runOnUiThread(() -> {
                    if(mWakUpStateCallBack!=null){
                        mWakUpStateCallBack.wakUpState(true);
                    }
                    mWeatherDialog.dismissDialog();
                    if (!mAiDialog.isShowing()) {
                        mAiDialog.show();
                    }
                });
                break;
            case "avatar.understanding"://理解中
                break;
            case "avatar.speaking"://播放语音中
                break;
            case "sys.wakeup.result"://唤醒播放语音中
                Log.e("sky", "唤醒播放语音中");
                curUpdateTime=SystemClock.uptimeMillis();
                context.runOnUiThread(() -> {
                    mWeatherDialog.dismissDialog();
                    if (!mAiDialog.isShowing()) {
                        mAiDialog.show();
                    }
                    mCommandObserver.mediaControlResult=false;
                    mCommandObserver.hasMediaControlResult=false;
                    isPlayBefore= MusicManager.getInstance().isPaying();
                    MusicManager.getInstance().pauseMusic();
                    int wakeupnum = new Random().nextInt(7) + 1;
                    int resID = context.getResources().getIdentifier("greeting"+wakeupnum,"raw",context.getPackageName());
                    MediaPlayer mm = MediaPlayer.create(context, resID);
                    mm.setOnCompletionListener(mediaPlayer -> {
                        mediaPlayer.reset();
                        mediaPlayer.release();
                    });
                    mm.start();
                });
                break;
        }
    }


    // 停止service, 释放dds组件
    private void stopService(Context context) {
        stopService(new Intent(context, DDSService.class));
        mCommandObserver.unregist();
        mMessageObserver.unregist();
    }

    // 打开唤醒，调用后才能语音唤醒
    void enableWakeup() {
        try {
            DDS.getInstance().getAgent().getWakeupEngine().enableWakeup();
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
    }

    // 关闭唤醒, 调用后将无法语音唤醒
    void disableWakeup() {
        try {
            DDS.getInstance().getAgent().stopDialog();
            DDS.getInstance().getAgent().getWakeupEngine().disableWakeup();
        } catch (DDSNotInitCompleteException e) {
            e.printStackTrace();
        }
    }

    private void registMsg() {
        // 注册消息监听器
        mMessageObserver.regist(this, mMessageList);
        mCommandObserver.regist();
        mNativeApiObserver.regist();
    }

    public void addWakUpStateCallBack(WakUpStateCallBack CallBack){
        mWakUpStateCallBack=CallBack;
    }

    public void addAISetVoiceCallBack(AISetVoiceCallBack CallBack){
        mCommandObserver.addAISetVoiceCallBack(CallBack);
    }


}
