package com.midea.light.ai.services;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Parcelable;
import android.os.RemoteException;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.midea.aispeech.Mw;
import com.midea.light.ai.AiSpeech.AIDeviceInfo;
import com.midea.light.ai.AiSpeech.AiDialog;
import com.midea.light.ai.AiSpeech.Player;
import com.midea.light.ai.AiSpeech.TTSItem;
import com.midea.light.ai.AiSpeech.WeatherDialog;
import com.midea.light.ai.IMideaLightAISetVoiceCallBack;
import com.midea.light.ai.IMideaLightAIdlInterface;
import com.midea.light.ai.IMideaLightAiControlDeviceErrorCallBack;
import com.midea.light.ai.IMideaLightFlashMusicListCallback;
import com.midea.light.ai.IMideaLightMusicPlayControlBack;
import com.midea.light.ai.IMideaLightServerBindCallBack;
import com.midea.light.ai.IMideaLightServerInitialCallBack;
import com.midea.light.ai.IMideaLightWakUpStateCallBack;
import com.midea.light.ai.MideaLightMusicInfo;
import com.midea.light.ai.music.MusicBean;
import com.midea.light.common.utils.DialogUtil;
import com.midea.light.common.utils.GsonUtils;
import com.midea.light.thread.MainThread;
import com.midea.light.utils.CollectionUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.reactivex.rxjava3.schedulers.Schedulers;
import tv.danmaku.ijk.media.player.IMediaPlayer;


public class MideaAiService extends Service {
    boolean wakeUpState = false, isManLoadMusic = false,isWifiLink = true,hasReportDisconnect=false,hasReportConnect=false;
    private static final String TAG = "sky";
    public Mw mMediaMwEngine=Mw.getInstance();
    public static final int SAMPLE_RATE_IN_HZ = 32000;//采样率，线mic：32000，环mic：48000
    public static final int CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO;
    public static final int AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;//音频数据格式

    private ArrayList<TTSItem> ttsList;

    private Gson mGson = new Gson();

    private Player player;
    boolean isWk = false, isTimeOut = false;
    public boolean isClickOut = false;
    private String lastSessionid;
    private boolean lastEndSession = false;
    private AudioRecord mAudioRecord = null;
    public boolean mIsRecording = false;
    private AiDialog mAiDialog;
    private WeatherDialog mWeatherDialog;
    IMideaLightServerInitialCallBack serverInitialCallBack;
    IMideaLightServerBindCallBack serverBindCallBack;

    IMideaLightFlashMusicListCallback flashMusicListCallback;

    IMideaLightAISetVoiceCallBack aiSetVoiceCallBack;

    IMideaLightAiControlDeviceErrorCallBack aiControlDeviceErrorCallBack;

    public IMideaLightWakUpStateCallBack wakUpStateCallBack;

    IMideaLightMusicPlayControlBack musicPlayControlBack;

    AtomicInteger initialState = new AtomicInteger(0);

    String mSn, mDeviceType, mDeviceCode, mMac, mEnv;

    private final IBinder binder = new IMideaLightAIdlInterface.Stub() {

        @Override
        public void setServerInitialBack(IMideaLightServerInitialCallBack initialBack, IMideaLightServerBindCallBack BindCallBack) throws RemoteException {
            serverBindCallBack = BindCallBack;
            serverInitialCallBack = initialBack;
            registerNetworkReceiver();
        }

        @Override
        public void setFlashMusicListCallBack(IMideaLightFlashMusicListCallback CallBack) throws RemoteException {
            flashMusicListCallback = CallBack;
        }

        @Override
        public void addAISetVoiceCallBack(IMideaLightAISetVoiceCallBack CallBack) throws RemoteException {
            aiSetVoiceCallBack = CallBack;
        }

        @Override
        public void addAIControlDeviceErrorCallBack(IMideaLightAiControlDeviceErrorCallBack CallBack) throws RemoteException {
            aiControlDeviceErrorCallBack = CallBack;
        }

        @Override
        public void addWakUpStateCallBack(IMideaLightWakUpStateCallBack CallBack) throws RemoteException {
            wakUpStateCallBack = CallBack;
        }

        @Override
        public void addMusicPlayControlCallBack(IMideaLightMusicPlayControlBack CallBack) throws RemoteException {
            musicPlayControlBack = CallBack;
        }

        @Override
        public void reportPlayerStatusToCloud(String MusicUrl, String Song, int index, String str_status) throws RemoteException {
            MideaAiService.this.reportPlayerStatusToCloud(MusicUrl, Song, index, str_status);
        }

        @Override
        public void getMusicList() throws RemoteException {
            MideaAiService.this.getMusicList();
        }

        @Override
        public void updateVoiceToCloud(int voice) throws RemoteException {
            MideaAiService.this.updateVoiceToCloud(voice);
        }

        @Override
        public void stop() throws RemoteException {
            MideaAiService.this.stop();
        }

        @Override
        public void outt() throws RemoteException {
            MideaAiService.this.out();
        }

        @Override
        public void wakeupByHand() throws RemoteException {
            MideaAiService.this.wakeupByHand();
        }

        @Override
        public void startRecord() throws RemoteException {
            synchronized (binder) {
                MideaAiService.this.startRecord();
            }
        }

        @Override
        public void stopRecord() throws RemoteException {
            MideaAiService.this.stopRecord();
        }

        @Override
        public void start(String sn, String deviceType, String deviceCode, String mac,String env) throws RemoteException {
            MideaAiService.this.start(sn, deviceType, deviceCode, mac,env);
        }

    };
    void retryStart(String reason) {
        if (TextUtils.isEmpty(mSn)
                || TextUtils.isEmpty(mDeviceType)
                || TextUtils.isEmpty(mDeviceCode)
                || TextUtils.isEmpty(mMac)
                || TextUtils.isEmpty(mEnv)) {
            Log.e("sky",String.format("检查初始化参数不完整，sn(%s) dt(%s) dc(%s) mac(%s) env(%s) ", mSn, mDeviceType, mDeviceCode, mMac, mEnv));
            return;
        }
        Log.e("sky", "重试原因：" + reason);
        start(mSn, mDeviceType, mDeviceCode, mMac, mEnv);
    }

    public synchronized void start(String sn, String deviceType, String deviceCode, String mac, String env) {
        this.mSn = sn;
        this.mDeviceType = deviceType;
        this.mDeviceCode = deviceCode;
        this.mMac = mac;
        this.mEnv = env;

        player = Player.getInstance();
        player.setmContext(this);

        MainThread.run(() -> {
            if(mAiDialog == null) {
                mAiDialog = new AiDialog(this, this);
            }

            if(mWeatherDialog == null) {
                mWeatherDialog = new WeatherDialog(this, this);
            }
        });

        Schedulers.computation().scheduleDirect(() -> {
            try {
                if (initialState.compareAndSet(0, 1)) {
                    AIDeviceInfo aiDeviceInfo = new AIDeviceInfo();
                    aiDeviceInfo.setSn(sn);
                    aiDeviceInfo.setModel("172");
                    aiDeviceInfo.setCategory(deviceType.replace("0x", ""));
                    aiDeviceInfo.setIot_id(deviceCode);
                    aiDeviceInfo.setMac(mac);
                    aiDeviceInfo.setEnv(env);
                    aiDeviceInfo.setLink_status(1);
                    aiDeviceInfo.setCfg_path("/sdcard/res/config.json");

                    String json = mGson.toJson(aiDeviceInfo);

                    Log.e(TAG, "deviceInfo:" + json);
                    mMediaMwEngine.init(json);
                    Log.e(TAG, "CRC mMediaMwEngine created");
                    if (mMediaMwEngine.getLicense() != 0) {
                        Log.e(TAG, "license not exist!!!");
                        mMediaMwEngine.registerLicense(aiDeviceInfo.getMac());
                    }
                    String[] type = {"Mw"};
                    int state = mMediaMwEngine.registerEvent(0, type, func);
                    Log.e(TAG, "获取语音证书状态:" + state);
                    if(state == 0) {
                        Log.e(TAG,"初始化成功");
                        initialState.set(2);
                        isWifiLink = true;
                        String linkstatus = "{\"link_status\":1}";
                        if (mMediaMwEngine != null) {
                            mMediaMwEngine.routerLinkStatusUpdate(linkstatus);
                        }
                    } else {
                        Log.e(TAG,"初始化失败");
                        initialState.set(0);
                    }
                    try {
                        serverInitialCallBack.isInitial(state == 0);
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                } else {
                    if(initialState.get() != 2) {
                        Log.e(TAG, "语音正在初始化中...");
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    public void startRecord() {
        retryStart("开始录音");
        try {
            MideaAiService.this.stopRecord();
            Log.e(TAG, "开始录音");
            final int minBufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE_IN_HZ, CHANNEL_CONFIG, AUDIO_FORMAT);
            mAudioRecord = new AudioRecord(MediaRecorder.AudioSource.VOICE_RECOGNITION, SAMPLE_RATE_IN_HZ, CHANNEL_CONFIG, AUDIO_FORMAT, minBufferSize);
            mAudioRecord.startRecording();
            mIsRecording = true;
            final byte data[] = new byte[6144];
            Thread thread = new Thread() {
                public void run() {
                    while (mIsRecording) {
                        int read = mAudioRecord.read(data, 0, data.length);
                        if (mAudioRecord.getRecordingState() == 3) {
                            if (read != AudioRecord.ERROR_INVALID_OPERATION) {
                                mMediaMwEngine.audioDataToSpeech(data, data.length);
                            }
                        }
                    }
                }
            };
            thread.start();
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (Exception d) {
            Log.e(TAG, "语音异常:" + d.getMessage());
        }
    }

    public void stopRecord() {
        Log.e("sky", "停止录音");
        mIsRecording = false;
        if (mAudioRecord != null) {
            mAudioRecord.release();
            mAudioRecord = null;
        }
    }


    public void wakeUpSession() {
        isManLoadMusic = false;
        wakeUpState = true;
        isClickOut = false;
        if (player.isPlaying()) {
            player.pause();
            player.cleanPlayList();
        }
        int wakeupnum = new Random().nextInt(7) + 1;
        String path = "/sdcard/tts/greeting" + wakeupnum + ".mp3";
        player = Player.getInstance();
        TTSItem m = new TTSItem(path);
        player.playItem(m);
        dismissWeatherDialog();
    }

    private void thinkSession(final String data) {
        if (isClickOut) {
            return;
        }
        try {
            JSONObject Stateobject = new JSONObject(data);
            int state = Stateobject.getInt("speechState");
            if (state == 1 || state == 2) {
                isTimeOut = false;
                isWk = true;
                Message message = new Message();
                message.arg1 = 7;
                mHandler.sendMessage(message);
            }
            if (state == 0) {
                Message message = new Message();
                message.arg1 = 1;
                mHandler.sendMessage(message);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }


    }

    private void AlermSession(final String data) {
        if (data.contains("场景设置")) {
            return;
        }
        Log.e("sky", "下发指令值：" + data);
        try {
            dismissWeatherDialog();
            JSONObject object = new JSONObject(data);
            if (object.has("skill")) {
                String Type = object.getJSONObject("skill").getString("skillType");
                if ("music".equals(Type) || "crosstalk".equals(Type) || "otherAudio".equals(Type) || "story".equals(Type) || "joke".equals(Type)) {
                    JSONArray data_array =
                            new JSONArray(object.getJSONObject("skill").getJSONObject("data").getJSONObject("generalSkill").getJSONArray("listItems").toString());
                    MusicBean.DataBean.GeneralSkillBean xx = new MusicBean.DataBean.GeneralSkillBean();
                    for (int i = 0; i < data_array.length(); i++) {
                        MideaLightMusicInfo infor = new MideaLightMusicInfo();
                        if ("music".equals(Type)) {
                            infor.setMusicUrl(data_array.getJSONObject(i).getString("musicUrl"));
                            infor.setSong(data_array.getJSONObject(i).getString("song"));
                            infor.setImageUrl(data_array.getJSONObject(i).getString("imageUrl"));
                            infor.setSinger(data_array.getJSONObject(i).getString("singer"));
                        } else {
                            infor.setMusicUrl(data_array.getJSONObject(i).getString("audioUrl"));
                            infor.setSong(data_array.getJSONObject(i).getString("title"));
                            infor.setImageUrl(data_array.getJSONObject(i).getString("imageUrl"));
                        }
                        xx.getListItems().add(infor);
                    }
                    if (flashMusicListCallback != null) {
                        flashMusicListCallback.FlashMusicList(xx.getListItems().toArray(new MideaLightMusicInfo[0]));
                    }
                } else {
                    {
                        ttsList = loadTTSItem(data);
                        JSONObject AlermObject = null;
                        String Alermtimeout = null;
                        String Alermasr = null;
                        try {
                            AlermObject = new JSONObject(data);
                            Alermtimeout = AlermObject.getString("timeout");
                            Alermasr = AlermObject.getString("asr");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        if (ttsList != null && ttsList.size() > 0) {
                            player = Player.getInstance();
                            if (ttsList.size() > 1 && ttsList.get(1) != null) {
                                ttsList.get(1).setLabel(ttsList.get(0).getLabel().replace("即将播放", ""));
                            }
                            player.playList(ttsList);
                            player.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
                                @Override
                                public void onPrepared(IMediaPlayer mp) {
                                    if (mp != null) {
                                        mp.start();
                                    }
                                }
                            });

                            player.setOnFinishListener(new Player.OnFinishListener() {
                                @Override
                                public void onAllFinish() {
                                    Message message = new Message();
                                    message.arg1 = 1;
                                    mHandler.sendMessage(message);
                                }

                                @Override
                                public void onNextPart() {
                                    player.getCurrentMusic().getLabel();
                                    Message message = new Message();
                                    message.arg1 = 8;
                                    mHandler.sendMessage(message);
                                }
                            });
                            player.setOnPlayErrorListener(new IMediaPlayer.OnErrorListener() {
                                @Override
                                public boolean onError(IMediaPlayer mediaPlayer, int i, int i1) {
                                    noticeCheckNet();
                                    return false;
                                }
                            });
                            Log.e("sky", "回答的内容:" + ttsList.get(0).getLabel());
                            Message message = new Message();
                            message.arg1 = 6;
                            mHandler.sendMessage(message);
                        } else if ("wakeup".equals(Alermtimeout) || "nlu".equals(Alermtimeout)) {
                            isTimeOut = true;
                            Message message = new Message();
                            message.arg1 = 3;
                            mHandler.sendMessage(message);
                        } else if ("NULL".equals(Alermasr)) {
                            Message message = new Message();
                            message.arg1 = 2;
                            mHandler.sendMessage(message);
                        } else {
                            if (!mAiDialog.isShowing()) {
                                DialogUtil.showToast("网络故障,请检查网络!");
                            }
                        }
                    }
                }
            } else {
                {
                    ttsList = loadTTSItem(data);
                    JSONObject AlermObject = null;
                    String Alermtimeout = null;
                    String Alermasr = null;
                    try {
                        AlermObject = new JSONObject(data);
                        Alermtimeout = AlermObject.getString("timeout");
                        Alermasr = AlermObject.getString("asr");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    if (ttsList != null && ttsList.size() > 0) {
                        player = Player.getInstance();
                        if (ttsList.size() > 1 && ttsList.get(1) != null) {
                            ttsList.get(1).setLabel(ttsList.get(0).getLabel().replace("即将播放", ""));
                        }
                        player.playList(ttsList);
                        player.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
                            @Override
                            public void onPrepared(IMediaPlayer mp) {
                                if (mp != null) {
                                    mp.start();
                                }
                            }
                        });

                        player.setOnFinishListener(new Player.OnFinishListener() {
                            @Override
                            public void onAllFinish() {
                                Message message = new Message();
                                message.arg1 = 1;
                                mHandler.sendMessage(message);
                            }

                            @Override
                            public void onNextPart() {
                                player.getCurrentMusic().getLabel();
                                Message message = new Message();
                                message.arg1 = 8;
                                mHandler.sendMessage(message);
                            }
                        });
                        player.setOnPlayErrorListener(new IMediaPlayer.OnErrorListener() {
                            @Override
                            public boolean onError(IMediaPlayer mediaPlayer, int i, int i1) {
                                noticeCheckNet();
                                return false;
                            }
                        });
                        Log.e("sky", "回答的内容:" + ttsList.get(0).getLabel());
                        Message message = new Message();
                        message.arg1 = 6;
                        mHandler.sendMessage(message);
                    } else if ("wakeup".equals(Alermtimeout) || "nlu".equals(Alermtimeout)) {
                        isTimeOut = true;
                        Message message = new Message();
                        message.arg1 = 3;
                        mHandler.sendMessage(message);
                    } else if ("NULL".equals(Alermasr)) {
                        Message message = new Message();
                        message.arg1 = 2;
                        mHandler.sendMessage(message);
                    } else {
                        if (!mAiDialog.isShowing()) {
                            DialogUtil.showToast("网络故障,请检查网络!");
                        }
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }

    }

    private void answerSession(final String data) {
        if (isClickOut) {
            return;
        }

        if (!isWifiLink) {
            Message message = new Message();
            message.arg1 = 9;
            mHandler.sendMessage(message);
            return;
        }
        wakeUpState = false;
        ttsList = loadTTSItem(data);
        JSONObject object = null;
        String timeout = null;
        String asr = null;
        try {
            object = new JSONObject(data);
            lastSessionid = object.getJSONObject("nlu").getString("sessionId");
            lastEndSession = object.getJSONObject("nlu").getBoolean("endSession");
            if(object.getJSONObject("nlu").has("timeout")){
                timeout = object.getJSONObject("nlu").getString("timeout");
            }
            if(object.getJSONObject("nlu").has("asr")){
                asr = object.getJSONObject("nlu").getString("asr");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        //如果是音乐就交给音乐播放器播放,此处不做音乐播放处理
        player = Player.getInstance();
        if (isMusic(data)) {
            out();
            if (ttsList != null && ttsList.size() > 0) {
                if (isManLoadMusic) {
                    //如果是手动拉取则提示音乐都不要
                    return;
                } else {
                    //只提示播放音乐开始
                    TTSItem x = ttsList.get(0);
                    ttsList.clear();
                    ttsList.add(x);
                    player.playList(ttsList);
                }

            }
        } else if (isWeather(data)) {
            //如果是天气就只播音频不显示文字
            ttsList.get(0).setLabel("");
            player.playList(ttsList);
        } else if (ttsList != null && ttsList.size() > 0) {
            player.playList(ttsList);
        }

        if (ttsList != null && ttsList.size() > 0) {
            player.setOnFinishListener(new Player.OnFinishListener() {
                @Override
                public void onAllFinish() {
                    reportPlayerEnd(lastSessionid, lastEndSession);
                }

                @Override
                public void onNextPart() {
                    player.getCurrentMusic().getLabel();
                    Message message = new Message();
                    message.arg1 = 5;
                    mHandler.sendMessage(message);
                }
            });
            Log.e("sky", "回答的内容:" + ttsList.get(0).getLabel());
            Message message = new Message();
            message.arg1 = 4;
            mHandler.sendMessage(message);
        } else if ("wakeup".equals(timeout) || "nlu".equals(timeout)) {
            isTimeOut = true;
            Message message = new Message();
            message.arg1 = 3;
            mHandler.sendMessage(message);
        } else if ("NULL".equals(asr)) {
            Message message = new Message();
            message.arg1 = 2;
            mHandler.sendMessage(message);
        } else {
            if (!mAiDialog.isShowing()) {
                DialogUtil.showToast("网络故障,请检查网络!");
            }
            isTimeOut = true;
            Message message = new Message();
            message.arg1 = 3;
            mHandler.sendMessage(message);
        }
    }

    private void AudioChangeSession(final String data) {
        JSONObject audioObject;
        String volume = null;
        try {
            audioObject = new JSONObject(data);
            volume = audioObject.getJSONObject("audio").getString("volume");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (volume != null) {
            setSystemAudio(volume);
        }
    }

    public void reportPlayerEnd(String sessionid, boolean isEnd) {
        Log.d(TAG, "---reportPlayerEnd---");

        try {

            JSONObject Obj1 = new JSONObject();
            JSONArray ttsArray = new JSONArray();
            Obj1.put("endSession", isEnd);
            if (!sessionid.isEmpty()) {
                Obj1.put("sessionId", sessionid);
            }
            ttsArray.put(0, Obj1);

            JSONObject resultObj = new JSONObject();
            resultObj.put("player_status", 2002);
            resultObj.put("tts_array", ttsArray);
            mMediaMwEngine.playStatusToSpeech(resultObj.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return;
    }

    private Mw.Callback func = (type, eventName, data) -> {
        Log.e(TAG, "mwCallback type:" + "0x" + Integer.toHexString(type) + " ,eventName:" + eventName + " , data:" + data);

        switch (type) {
            case 0x61160200:    //唤醒阶段
                wakeUpSession();
                break;
            case 0x61160201:    //MCRC_EV_OUTER_REQ_ANDROID_USER_VAD_TIMEOUT
                break;
            case 0x61160202:    //MCRC_EV_OUTER_REQ_ANDROID_USER_DOA
                break;
            case 0x61130009:    //AICLOUD_RESULT_STATE
                break;
            case 0x61130008:    //思考阶段
                thinkSession(data);
                break;
            case 0x61130003:    //提的问题云端识别后返回阶段
            case 0x6113001c:    //实时识别问的内容
                askSession(data);
                break;
            case 0x61160501://闹铃功能
                AlermSession(data);
                break;
            case 0x61130002:    //识别后回答阶段
                answerSession(data);
                break;
            case 0x61130006:    //技能
                skillType(data);
                break;
            case 0x61130001:    //MCRC_EV_OUTER_REQ_USER_QUERY_DEVICE
                break;
            case 0x61130000:    //MCRC_EV_OUTER_REQ_USER_DEVICE_CONTROL
                break;
            case 0x6113000b:    //音量调节
                AudioChangeSession(data);
                break;
            case 0x61160502:    //继续/停止播放
                PauseResumeSession(data);
                break;
            default:
                break;
        }
    };

    private void PauseResumeSession(String data) {

        try {
            JSONObject object = new JSONObject(data);
            String player = object.getString("player");
            if (!TextUtils.isEmpty(player)) {
                if (player.equals("PAUSE")) {
                    if (musicPlayControlBack != null) {
                        musicPlayControlBack.playControl("PAUSE");
                    }
                } else if (player.equals("RESUME")) {
                    if (musicPlayControlBack != null) {
                        musicPlayControlBack.playControl("RESUME");
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    public void wakeup() {
        try {
            if (wakUpStateCallBack != null) {
                wakUpStateCallBack.wakUpState(true);
            }
            if (mAiDialog == null) {
                mAiDialog = new AiDialog(this, this);
            }
            if (mAiDialog.isShowing()) {
                mAiDialog.wakeupInitialData();
                return;
            }
            mAiDialog.create();
            mAiDialog.wakeupInitialData();
            mAiDialog.show();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }

    }

    String ask = "";

    private void askSession(String data) {
        if (isClickOut) {
            return;
        }
        ask = askTTSItem(data);
        Log.e("sky", "问的内容:" + ask);
        isTimeOut = false;
        isWk = true;
        if (TextUtils.isEmpty(ask)) {
            return;
        }
        Message message = new Message();
        message.arg1 = 10;
        mHandler.sendMessage(message);
    }

    private void setAskString(String s) {
        mAiDialog.addAnsAskItem(s);
    }

    private void setAnsString(String s) {
        mAiDialog.addAnsAskItem(s);
    }

    private void setDialogTimeOut() {
        isTimeOut = true;
        player = Player.getInstance();
        String path = "/sdcard/tts/unknowinputbye.mp3";
        TTSItem m = new TTSItem(path);
        player.playItem(m);
        mAiDialog.addAnsAskItem("小美没有听懂再见!");
        sayOver();

    }

    private void listenAgain() {
        isTimeOut = true;
        player = Player.getInstance();
        String path = "/sdcard/tts/timeout.mp3";
        TTSItem m = new TTSItem(path);
        player.playItem(m);
        mAiDialog.addAnsAskItem("抱歉,刚刚有和我说话吗?请再呼唤小美吧!");
        sayOver();

    }

    private void sayOver() {
        if (mAiDialog != null) {
            mAiDialog.timeOut();
        }
        if (mWeatherDialog != null) {
            mWeatherDialog.timeOut();
        }
//        GateWayLightControlUtil.stopLightShow();
        if (wakUpStateCallBack != null) {
            try {
                wakUpStateCallBack.wakUpState(false);
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private ArrayList<TTSItem> loadTTSItem(String data) {
        try {
            Log.e(TAG, "loadTTS: " + data);
            JSONObject object = new JSONObject(data);
            JSONArray ttsArray = object.getJSONObject("nlu").getJSONObject("tts").optJSONArray("data");
            Log.d(TAG, "ttsArray: " + ttsArray.toString());
            TTSItem[] items = mGson.fromJson(ttsArray.toString(), TTSItem[].class);

            ArrayList<TTSItem> list = new ArrayList<>();
            List<TTSItem> temp = Arrays.asList(items);
            for (int i = 0; i < temp.size(); i++) {
                if (!temp.get(i).getLabel().contains("场景触发")) {
                    list.add(temp.get(i));
                }
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String askTTSItem(String data) {
        try {
            Log.e(TAG, "loadTTS: " + data);
            JSONArray ttsArray = new JSONArray(data);
            JSONObject ob = (JSONObject) ttsArray.get(0);
            return ob.getString("text");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        try {
//            FileUtils.copyAssetsFile(this, "xiaomei.zip", Environment.getExternalStorageDirectory().getAbsolutePath());
//            FileInputStream stream = new FileInputStream(Environment.getExternalStorageDirectory().getAbsolutePath() + "/xiaomei.zip");
//            ZipUtils.UnZipFolder(stream, Environment.getExternalStorageDirectory().getAbsolutePath());
//            FileUtils.delete(Environment.getExternalStorageDirectory().getAbsolutePath() + "/xiaomei.zip");
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return false;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stop();
    }

    private static String getWakeupInfo() {
        try {
            JSONObject resultObj = new JSONObject();
            resultObj.put("player_status", 2004);
            return resultObj.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public void wakeupByHand() {
        mMediaMwEngine.playStatusToSpeech(getWakeupInfo());
    }

    private void setSystemAudio(String Audio) {
        int toCloud = 0;
        int voice = 0;//调整系统声音的等级0-63
        AudioManager am = (AudioManager) this.getSystemService(AUDIO_SERVICE);
        int maxValue = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        switch (Audio) {
            case "L1":
            case "-1":
                voice = 1;
                toCloud = 1;
                break;
            case "L2":
                toCloud = 25;
                break;
            case "L3":
                toCloud = 50;
                break;
            case "L4":
                toCloud = 75;
                break;
            case "L5":
            case "100":
                toCloud = 100;
                voice = maxValue;
                break;
        }

        int curent = getSystemAudio();
        if (curent <= 0) {
            curent = 0;
        } else {
            curent = getSystemAudio();
        }
        Log.e("sky", "当前音量:" + curent);

        //如果是数字说明是调整到百分之多少
        if (isNumeric(Audio)) {
            float percentValue = Float.valueOf(Audio);

            voice = (int) (maxValue * percentValue) / 100;

            if (percentValue == 100) {
                voice = maxValue;
            } else if (percentValue == 0) {
                voice = 1;
            }

        }

        //有加号表示增加百分之多少
        if (Audio.contains("+")) {
            voice = curent + (int) (maxValue * 0.2);
            if (voice >= maxValue) {
                voice = maxValue;
            }
            //有减号表示减少百分之多少
        } else if (Audio.contains("-") && !Audio.equals("-1")) {
            voice = curent - (int) (maxValue * 0.2);
            if (voice <= 0) {
                voice = 0;
            }
        }

        Log.e("sky", "音量调整到:" + voice);
        am.setStreamVolume(AudioManager.STREAM_MUSIC, voice, AudioManager.FLAG_PLAY_SOUND);
        if (aiSetVoiceCallBack != null) {
            try {
                aiSetVoiceCallBack.SetVoice(voice);
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }


        float bilixishu = 100f / maxValue;
        toCloud = (int) (voice * bilixishu);


//        if (toCloud <= 1) {
//            Log.e("sky", "最小传给云端的音量:" + 1);
//            mMediaMwEngine.deviceStatusToCloudResp(volStatus(1));
//        } else if(toCloud >= 100){
//            Log.e("sky", "最大传给云端的音量:" + 100);
//            mMediaMwEngine.deviceStatusToCloudResp(volStatus(100));
//        }else {
//            Log.e("sky", "一般传给云端的音量:" + toCloud);
//            mMediaMwEngine.deviceStatusToCloudResp(volStatus(toCloud));
//        }
    }

    private void alarm(String ans) {
        if (wakUpStateCallBack != null) {
            try {
                wakUpStateCallBack.wakUpState(true);
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }
        if (mAiDialog.isShowing()) {
            setAnsString(ans);
            return;
        }
        mAiDialog.create();
        mAiDialog.wakeupInitialData();
        mAiDialog.show();
        setAnsString(ans);

    }

    public String volStatus(int vol) {
        try {
            JSONObject resultObj = new JSONObject();
            resultObj.put("type", 1003);

            JSONObject volume = new JSONObject();
            volume.put("volume", vol);

            JSONObject audio = new JSONObject();
            audio.put("audio", volume);

            resultObj.put("value", audio);

            return resultObj.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private int getSystemAudio() {
        AudioManager am = (AudioManager) this.getSystemService(AUDIO_SERVICE);
        int current = am.getStreamVolume(AudioManager.STREAM_MUSIC);
        return current;
    }

    private boolean isNumeric(String str) {

        Pattern pattern = Pattern.compile("[0-9]*");

        Matcher isNum = pattern.matcher(str);

        if (!isNum.matches()) {

            return false;
        }
        return true;

    }

    public void out() {
        player.pause();
        isClickOut = true;
        player.cleanPlayList();
        dismissAiDialog();
    }

    public void stop() {
        mSn = null;
        mDeviceType = null;
        mDeviceCode = null;
        mMac = null;
        mEnv = null;
        initialState.set(0);
        mIsRecording = false;
        mMediaMwEngine = null;
        unreregisterNetworkReceiver();
        stopRecord();
    }

    private void alarm110(String ans) {
        if (mAiDialog.isShowing()) {
            setAnsString(ans);
            return;
        }
        mAiDialog.create();
        mAiDialog.wakeupShow110();
        mAiDialog.show();
        setAnsString(ans);

    }

    private void skillType(final String data) {
        JSONArray data_array;
        try {
            data_array = new JSONArray(data);
            if (data_array.getJSONObject(0).has("skillType")) {
                if (data_array.getJSONObject(0).getString("skillType").equals("music") || data_array.getJSONObject(0).getString("skillType").equals("crosstalk") || data_array.getJSONObject(0).getString("skillType").equals("otherAudio") || data_array.getJSONObject(0).getString("skillType").equals("story") || data_array.getJSONObject(0).getString("skillType").equals("joke")) {
                    MusicBean mMusicBean = GsonUtils.getBeanFromJSONString(data_array.getJSONObject(0).toString(), MusicBean.class);
                    mMusicBean.getData().getGeneralSkill().getListItems();
                    if (flashMusicListCallback != null) {
                        flashMusicListCallback.FlashMusicList(mMusicBean.getData().getGeneralSkill().getListItems().toArray(new MideaLightMusicInfo[0]));
                    }
                } else if (data_array.getJSONObject(0).getString("skillType").equals("mediaControl")) {
                    if (data_array.getJSONObject(0).getJSONObject("data").has("player")) {
                        if (data_array.getJSONObject(0).getJSONObject("data").getString("player").contains("RESUME")) {
                            Log.e("sky", "收到继续播放指令");
                            if (musicPlayControlBack != null) {
                                musicPlayControlBack.playControl("RESUME");
                            }
                            dismissAiDialog();
                        } else if (data_array.getJSONObject(0).getJSONObject("data").getString("player").contains("PAUSE")) {
                            Log.e("sky", "收到暂停指令");
                            if (musicPlayControlBack != null) {
                                musicPlayControlBack.playControl("PAUSE");
                            }
                        } else if (data_array.getJSONObject(0).getJSONObject("data").getString("player").contains("STOP")) {
                            Log.e("sky", "收到停止指令");
                            if (musicPlayControlBack != null) {
                                musicPlayControlBack.playControl("STOP");
                            }
                        }
                    } else if (data_array.getJSONObject(0).getJSONObject("data").has("playbackCtrlViaTts")) {
                        if (data_array.getJSONObject(0).getJSONObject("data").getString("playbackCtrlViaTts").contains("prev")) {
                            Log.e("sky", "收到上一曲指令");
                            if (musicPlayControlBack != null) {
                                musicPlayControlBack.playControl("prev");
                            }
                            dismissAiDialog();
                        } else if (data_array.getJSONObject(0).getJSONObject("data").getString("playbackCtrlViaTts").contains("next")) {
                            Log.e("sky", "收到下一曲指令");
                            if (musicPlayControlBack != null) {
                                musicPlayControlBack.playControl("next");
                            }
                            dismissAiDialog();
                        }
                    }
                } else if (data_array.getJSONObject(0).getString("skillType").equals("weather")) {
                    if (isClickOut) {
                        return;
                    }
                    JSONObject generalSkill = data_array.getJSONObject(0).getJSONObject("data").getJSONObject("generalSkill");
                    String cityName = generalSkill.getString("cityName");
                    String level = generalSkill.getJSONObject("index").getJSONObject("aqi").getString("aQL");
                    String low = generalSkill.getJSONArray("forecasts").getJSONObject(0).getString("lowTemp");
                    String high = generalSkill.getJSONArray("forecasts").getJSONObject(0).getString("highTemp");
                    String weather = generalSkill.getJSONArray("forecasts").getJSONObject(0).getString("weather");
                    showWeatherScreen(cityName, low, high, weather, level);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    private void showWeatherScreen(String place, String low, String high, String weather, String level) {
        if (mWeatherDialog != null) {
            mWeatherDialog.setWeatherDetail(place, low, high, weather, level);
            Message message = new Message();
            message.arg1 = 11;
            mHandler.sendMessage(message);
        }
    }

    private void noticeCheckNet() {
        isTimeOut = true;
        player = Player.getInstance();
        String path = "/sdcard/tts/network_config_fail.mp3";
        TTSItem m = new TTSItem(path);
        player.playItem(m);
        alarm110("请检查网络!");
        Message message = new Message();
        message.arg1 = 1;
        mHandler.sendMessage(message);
    }

    public void updateVoiceToCloud(int voice) {
//        mMediaMwEngine.deviceStatusToCloudResp(volStatus(voice));
    }

    private boolean isMusic(String data) {
        boolean isMusic = false;
        try {
            JSONObject object = new JSONObject(data);
            JSONObject nlu = object.getJSONObject("nlu").getJSONObject("skill");
            if (nlu.has("skillType")) {
                Log.e("sky", "类型:" + nlu.getString("skillType"));
                if (nlu.getString("skillType").equals("music") || nlu.getString("skillType").equals("story") || nlu.getString("skillType").equals("otherAudio") || nlu.getString("skillType").equals("crosstalk") || nlu.getString("skillType").equals("joke")) {
                    isMusic = true;
                } else {
                    isMusic = false;
                }
            } else {
                isMusic = false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return isMusic;
    }

    private boolean isWeather(String data) {
        boolean isWeather = false;
        try {
            JSONObject object = new JSONObject(data);
            JSONObject nlu = object.getJSONObject("nlu").getJSONObject("skill");
            if (nlu.has("skillType")) {
                Log.e("sky", "类型:" + nlu.getString("skillType"));
                if (nlu.getString("skillType").equals("weather")) {
                    isWeather = true;
                } else {
                    isWeather = false;
                }
            } else {
                isWeather = false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return isWeather;
    }

    private boolean isDeviceControlError(String data) {
        boolean isDeviceControl = false;
        try {
            JSONObject object = new JSONObject(data);
            JSONObject nlu = object.getJSONObject("nlu").getJSONObject("skill");
            if (nlu.has("skillType")) {
                if (nlu.getString("skillType").contains("DeviceControl")) {
                    JSONArray ttsArray = object.getJSONObject("nlu").getJSONObject("tts").optJSONArray("data");
                    if (ttsArray.getJSONObject(0).getString("text").contains("家电设备信息") || ttsArray.getJSONObject(0).getString("text").contains("绑定设备")) {
                        isDeviceControl = true;
                    } else {
                        isDeviceControl = false;
                    }
                } else {
                    isDeviceControl = false;
                }
            } else {
                isDeviceControl = false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return isDeviceControl;
    }


    private Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            switch (message.arg1) {
                case 1:
                    sayOver();
                    break;
                case 2:
                    listenAgain();
                    break;
                case 3:
                    setDialogTimeOut();
                    break;
                case 4:
                    if (CollectionUtil.isNotEmpty(ttsList)) {
                        if (!TextUtils.isEmpty(ttsList.get(0).getLabel())) {
                            setAnsString(ttsList.get(0).getLabel());
                        }
                    } else {
                        setAnsString("没听清,再说一次");
                    }
                    break;
                case 5:
                    setAnsString(player.getCurrentMusic().getLabel());
                    break;
                case 6:
                    if (CollectionUtil.isNotEmpty(ttsList)) {
                        alarm(ttsList.get(0).getLabel());
                    } else {
                        alarm("没听清,再说一次");
                    }
                    break;
                case 7:
                    wakeup();
                    break;
                case 8:
                    alarm(player.getCurrentMusic().getLabel());
                    break;
                case 9:
                    noticeCheckNet();
                    break;
                case 10:
                    setAskString(ask);
                    break;
                case 11:
                    mWeatherDialog.show();
                    break;
            }
            return true;
        }
    });

    public void getMusicList() {
        isManLoadMusic = true;
        mMediaMwEngine.getNLPwithText("我要听歌");
    }

    public void reportPlayerStatusToCloud(String MusicUrl, String Song, int index, String str_status) {
        try {
            TTSItem tar_item = new TTSItem(MusicUrl);
            tar_item.setAutoResume(true);
            tar_item.setUrlType("media");
            tar_item.setLabel(Song);
            tar_item.setSkillType("");
            tar_item.setSeq(index + 1);

            if (tar_item == null) {
                Log.e(TAG, "tar_item is null");
                return;
            }
            JSONObject play_element = new JSONObject();
            JSONObject root = new JSONObject();
            JSONObject player_meta = new JSONObject();
            play_element.put("urlType", tar_item.getUrlType());
            play_element.put("skillType", tar_item.getSkillType());
            play_element.put("autoResume", tar_item.isAutoResume());
            play_element.put("text", tar_item.getLabel());
            play_element.put("url", tar_item.getLinkUrl());
            play_element.put("seq", tar_item.getSeq());

            root.put("class", "player");
            player_meta.put("status", str_status);
            player_meta.put("resource", play_element);
            root.put("player", player_meta);
            Log.d(TAG, "report_playerStatus_to_cloud: " + root);

            boolean isgreeting = false;
            if (tar_item.getUrlType().isEmpty()) {
                isgreeting = true;
            }
            mMediaMwEngine.reportPlayerStatus(root.toString(), isgreeting);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void dismissAiDialog() {
        if (mAiDialog != null) {
            mAiDialog.dismissDialog();
        }
    }

    public void dismissWeatherDialog() {
        if (mWeatherDialog != null) {
            mWeatherDialog.dismissDialog();
        }
    }

    public void registerNetworkReceiver() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
        filter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        registerReceiver(receiver, filter);
    }

    public void unreregisterNetworkReceiver() {
        try {
            unregisterReceiver(receiver);
        }catch (RuntimeException e){

        }
    }

    private final NetWorkStateReceiver receiver = new NetWorkStateReceiver();

    private class NetWorkStateReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (WifiManager.NETWORK_STATE_CHANGED_ACTION.equals(intent.getAction())) {
                Parcelable parcelableExtra = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
                if (null != parcelableExtra) {
                    //获取联网状态的NetWorkInfo对象
                    NetworkInfo networkInfo = (NetworkInfo) parcelableExtra;
                    //获取的State对象则代表着连接成功与否等状态
                    NetworkInfo.State state = networkInfo.getState();
                    //判断网络是否已经连接
                    boolean isConnected = state == NetworkInfo.State.CONNECTED;
                    if (isConnected) {
                        isWifiLink=true;
                        String linkstatus = "{\"link_status\":1}";
                        if (mMediaMwEngine != null&&!hasReportConnect) {
                            try {
                                Thread.sleep(1000);
                                hasReportDisconnect=false;
                                hasReportConnect=true;
                                mMediaMwEngine.routerLinkStatusUpdate(linkstatus);
                            } catch (InterruptedException e) {}
                        }
                    }else{
                        isWifiLink=false;
                        String linkstatus2 = "{\"link_status\":0}";
                        if (mMediaMwEngine != null&&!hasReportDisconnect) {
                            hasReportDisconnect=true;
                            hasReportConnect=false;
                            mMediaMwEngine.routerLinkStatusUpdate(linkstatus2);
                        }
                    }
                }else{
                    isWifiLink=false;
                    String linkstatus2 = "{\"link_status\":0}";
                    if (mMediaMwEngine != null&&!hasReportDisconnect) {
                        hasReportDisconnect=true;
                        hasReportConnect=false;
                        mMediaMwEngine.routerLinkStatusUpdate(linkstatus2);
                    }
                }
            }
        }
    }
}
