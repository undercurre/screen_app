package com.midea.light;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Instrumentation;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.icu.util.Calendar;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.PowerManager;
import android.os.SystemClock;
import android.util.Log;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.midea.homlux.ai.api.HomluxAiApi;
import com.midea.light.ai.music.MusicManager;
import com.midea.light.ai.utils.FileUtils;
import com.midea.light.channel.Channels;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.utils.DialogUtil;
import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.controller.AirConditionController;
import com.midea.light.device.explore.controller.control485.controller.FloorHotController;
import com.midea.light.device.explore.controller.control485.controller.FreshAirController;
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FreshAirChangeEvent;
import com.midea.light.issued.distribution.GateWayDistributionEvent;
import com.midea.light.issued.plc.PLCControlEvent;
import com.midea.light.log.LogUtil;
import com.midea.light.push.AliPushReceiver;
import com.midea.light.setting.SystemUtil;
import com.midea.light.setting.ota.OTAUpgradeHelper;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Timer;
import java.util.TimerTask;

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

    private ArrayList<Float> SensorArry = new ArrayList<>();
    private float value;

    public void onCreate(Bundle bundle) {
        requestPermissions(permissions, 0x18);
        super.onCreate(bundle);
        MainApplication.mMainActivity = this;
        if (AppCommonConfig.getChannel().equals("LD")) {
            SensorManager mSensorManager = (SensorManager) this.getSystemService(this.SENSOR_SERVICE);
            MySensorEventListener sensorEventListener = new MySensorEventListener();
            Sensor als = mSensorManager.getDefaultSensor(Sensor.TYPE_LIGHT);
            mSensorManager.registerListener(sensorEventListener, als, SensorManager.SENSOR_DELAY_NORMAL);

            Sensor ps = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
            mSensorManager.registerListener(sensorEventListener, ps, SensorManager.SENSOR_DELAY_NORMAL);
            Integer cacheTime = 1;
            Timer timer = new Timer();
            // (TimerTask task, long delay, long period)任务，延迟时间，多久执行
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    getSensor(value);
                }
            }, 0, cacheTime);
        } else if (AppCommonConfig.getChannel().equals("JH")) {
            SensorManager mSensorManager = (SensorManager) this.getSystemService(this.SENSOR_SERVICE);
            MyJHSensorEventListener sensorEventListener = new MyJHSensorEventListener();
            Sensor ps = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
            mSensorManager.registerListener(sensorEventListener, ps, SensorManager.SENSOR_DELAY_NORMAL);
        }
        try {
            IntentFilter filter = new IntentFilter();
            filter.addAction(Intent.ACTION_TIME_TICK);
            registerReceiver(receiver, filter);
        } catch (Exception e) {
            e.printStackTrace();
        }
        SLKClear();
        ZH485Device();
        checkInstallResourceExitInLocal();
    }

    /**
     * 检查本地是否存在安装资源，并进行安装
     */
    public void checkInstallResourceExitInLocal() {
        if (OTAUpgradeHelper.checkInstallResourceExistLocally()) {
            Intent intent = new Intent(this, LocalResourceInstallActivity.class);
            this.startActivity(intent);
        }
    }

    /**
     * 中宏485设备接收网关消息处理
     */
    @SuppressLint("CheckResult")
    private void ZH485Device() {
        new Thread() {
            public void run() {
                try {
                    Thread.sleep(10000);
                    ControlManager.getInstance().initial();
                    ControlManager.getInstance().regestOber();
                    ControlManager.getInstance().startFresh();
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
        }.start();
        //485设备配网新增
        RxBus.getInstance().toObservableOnMain(this, GateWayDistributionEvent.class)
                .subscribe(mGateWayDistributionEvent -> {
                    new Thread() {
                        public void run() {
                            if (mGateWayDistributionEvent.getState() == 60) {
//                                Log.e("sky", "接收到网关配网状态,空调设备数量:" + AirConditionController.getInstance().AirConditionList.size());
//                                Log.e("sky", "接收到网关配网状态,新风设备数量:" + FreshAirController.getInstance().FreshAirList.size());
//                                Log.e("sky", "接收到网关配网状态,地暖设备数量:" + FloorHotController.getInstance().FloorHotList.size());
//                                ArrayList<Add485DeviceBean.PLC.AddDev> AddDevList = new ArrayList<>();
//                                for (int i = 0; i < AirConditionController.getInstance().AirConditionList.size(); i++) {
//                                    Add485DeviceBean.PLC.AddDev AddDev = new Add485DeviceBean.PLC.AddDev();
//                                    AddDev.setAddr(AirConditionController.getInstance().AirConditionList.get(i).getOutSideAddress() + AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress());
//                                    AddDev.setModelId("zhonghong.cac.002");
//                                    AddDevList.add(AddDev);
//                                }
//                                for (int i = 0; i < FreshAirController.getInstance().FreshAirList.size(); i++) {
//                                    Add485DeviceBean.PLC.AddDev AddDev = new Add485DeviceBean.PLC.AddDev();
//                                    AddDev.setAddr(FreshAirController.getInstance().FreshAirList.get(i).getOutSideAddress() + FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress());
//                                    AddDev.setModelId("zhonghong.air.001");
//                                    AddDevList.add(AddDev);
//                                }
//                                for (int i = 0; i < FloorHotController.getInstance().FloorHotList.size(); i++) {
//                                    Add485DeviceBean.PLC.AddDev AddDev = new Add485DeviceBean.PLC.AddDev();
//                                    AddDev.setAddr(FloorHotController.getInstance().FloorHotList.get(i).getOutSideAddress() + FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress());
//                                    AddDev.setModelId("zhonghong.heat.001");
//                                    AddDevList.add(AddDev);
//                                }
//                                Log.e("sky", "给网关的设备列表:" + new Gson().toJson(AddDevList));
                                runOnUiThread(() -> mChannels.local485DeviceControlChannel.cMethodChannel.invokeMethod("query485DeviceListByHomeId",null));
                            }
                        }
                    }.start();

                }, throwable -> Log.e("sky", "rxBus错误", throwable));

        //云端下发控制指令
        RxBus.getInstance().toObservableOnMain(this, PLCControlEvent.class)
                .subscribe(PLCControlEvent -> {
                    Log.e("sky", "接收到下发控制请求" + new Gson().toJson(PLCControlEvent));
                    if (PLCControlEvent.getPLCControlDevice().getModelId().contains("zhonghong.cac")) {
                        for (int i = 0; i < AirConditionController.getInstance().AirConditionList.size(); i++) {
                            String deviceAddr = AirConditionController.getInstance().AirConditionList.get(i).getOutSideAddress() + AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress();
                            if (deviceAddr.equals(PLCControlEvent.getPLCControlDevice().getAddr())) {
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getOnOff() != null && PLCControlEvent.getPLCControlDevice().getEvent().getOnOff() == 0) {
                                    AirConditionController.getInstance().close(AirConditionController.getInstance().AirConditionList.get(i));
                                } else {
                                    AirConditionController.getInstance().open(AirConditionController.getInstance().AirConditionList.get(i));
                                }
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getWindSpeed() != null) {
                                    String speed = Integer.toHexString(PLCControlEvent.getPLCControlDevice().getEvent().getWindSpeed());
                                    if (speed.length() == 1) {
                                        speed = "0" + speed;
                                    }
                                    AirConditionController.getInstance().setWindSpeedLevl(AirConditionController.getInstance().AirConditionList.get(i), speed);
                                }
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp() != null) {
                                    String temp = Integer.toHexString(PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp());
                                    if (temp.length() == 1) {
                                        temp = "0" + temp;
                                    }
                                    AirConditionController.getInstance().setTemp(AirConditionController.getInstance().AirConditionList.get(i), temp);
                                }
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getOperationMode() != null) {
                                    String modele = Integer.toHexString(PLCControlEvent.getPLCControlDevice().getEvent().getOperationMode());
                                    if (modele.length() == 1) {
                                        modele = "0" + modele;
                                    }
                                    AirConditionController.getInstance().setModel(AirConditionController.getInstance().AirConditionList.get(i), modele);
                                }
                            }
                        }

                    } else if (PLCControlEvent.getPLCControlDevice().getModelId().contains("zhonghong.air")) {
                        for (int i = 0; i < FreshAirController.getInstance().FreshAirList.size(); i++) {
                            String deviceAddr = FreshAirController.getInstance().FreshAirList.get(i).getOutSideAddress() + FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress();
                            if (deviceAddr.equals(PLCControlEvent.getPLCControlDevice().getAddr())) {
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getOnOff() != null && PLCControlEvent.getPLCControlDevice().getEvent().getOnOff() == 0) {
                                    FreshAirController.getInstance().close(FreshAirController.getInstance().FreshAirList.get(i));
                                } else {
                                    FreshAirController.getInstance().open(FreshAirController.getInstance().FreshAirList.get(i));
                                }
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getWindSpeed() != null) {
                                    String speed = Integer.toHexString(PLCControlEvent.getPLCControlDevice().getEvent().getWindSpeed());
                                    if (speed.length() == 1) {
                                        speed = "0" + speed;
                                    }
                                    FreshAirController.getInstance().setWindSpeedLevl(FreshAirController.getInstance().FreshAirList.get(i), speed);
                                }
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getOperationMode() != null) {
                                    String modele = Integer.toHexString(PLCControlEvent.getPLCControlDevice().getEvent().getOperationMode());
                                    if (modele.length() == 1) {
                                        modele = "0" + modele;
                                    }
                                    FreshAirController.getInstance().setModel(FreshAirController.getInstance().FreshAirList.get(i), modele);
                                }
                            }
                        }

                    } else if (PLCControlEvent.getPLCControlDevice().getModelId().contains("zhonghong.heat.")) {
                        for (int i = 0; i < FloorHotController.getInstance().FloorHotList.size(); i++) {
                            String deviceAddr = FloorHotController.getInstance().FloorHotList.get(i).getOutSideAddress() + FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress();
                            if (deviceAddr.equals(PLCControlEvent.getPLCControlDevice().getAddr())) {
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getOnOff() != null && PLCControlEvent.getPLCControlDevice().getEvent().getOnOff() == 0) {
                                    FloorHotController.getInstance().close(FloorHotController.getInstance().FloorHotList.get(i));
                                } else {
                                    FloorHotController.getInstance().open(FloorHotController.getInstance().FloorHotList.get(i));
                                }
                                if (PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp() != null) {
                                    if (PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp() <= 90 && PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp() >= 5) {
                                        String temp = Integer.toHexString(PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp());
                                        if (temp.length() == 1) {
                                            temp = "0" + temp;
                                        }
                                        FloorHotController.getInstance().setTemp(FloorHotController.getInstance().FloorHotList.get(i), temp);
                                    }
                                }
//                               if(PLCControlEvent.getPLCControlDevice().getEvent().getTargetTemp()!=null&&null!=PLCControlEvent.getPLCControlDevice().getEvent().getFrostProtection()&&PLCControlEvent.getPLCControlDevice().getEvent().getFrostProtection()==0){
//                                   FloorHotController.getInstance().setFrostProtectionOff(FloorHotController.getInstance().FloorHotList.get(i));
//                               }else{
//                                   FloorHotController.getInstance().setFrostProtectionOn(FloorHotController.getInstance().FloorHotList.get(i));
//                               }
                            }
                        }


                    }
                }, throwable -> Log.e("sky", "rxBus错误", throwable));
        //485空调数据有变化接收到数据后推送到flutter层
        RxBus.getInstance().toObservableOnMain(this, AirConditionChangeEvent.class)
                .subscribe(AirConditionChangeEvent -> {
                    String modelId = "zhonghong.cac.002";
                    String address = AirConditionChangeEvent.getAirConditionModel().getOutSideAddress() + AirConditionChangeEvent.getAirConditionModel().getInSideAddress();
                    int mode = Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getWorkModel(), 16);
                    int speed = Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getWindSpeed(), 16);
                    int temper = Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getTemperature(), 16);
                    int currTemperature = Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getCurrTemperature(), 16);
                    int onOff = Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getOnOff(), 16);
                    int online = Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getOnlineState(), 16);
                    if(speed==0){
                        return;
                    }
                    JSONObject json = new JSONObject();
                    json.put("modelId", modelId);
                    json.put("address", address);
                    json.put("mode", mode);
                    json.put("speed", speed);
                    json.put("temper", temper);
                    json.put("onOff", onOff);
                    json.put("online", online);
                    json.put("currTemperature", currTemperature);
//                    Log.e("sky","通知flutter更新空调:"+json);

                    mChannels.local485DeviceControlChannel.cMethodChannel.invokeMethod("Local485DeviceUpdate", json);

                }, throwable -> Log.e("sky", "rxbus错误", throwable));

        //485新风数据有变化接收到数据后推送到flutter层
        RxBus.getInstance().toObservableOnMain(this, FreshAirChangeEvent.class)
                .subscribe(AirConditionChangeEvent -> {
                    String modelId = "zhonghong.air.001";
                    String address = AirConditionChangeEvent.getFreshAirModel().getOutSideAddress() + AirConditionChangeEvent.getFreshAirModel().getInSideAddress();
                    int speed = Integer.parseInt(AirConditionChangeEvent.getFreshAirModel().getWindSpeed(), 16);
                    int onOff = Integer.parseInt(AirConditionChangeEvent.getFreshAirModel().getOnOff(), 16);
                    int online = Integer.parseInt(AirConditionChangeEvent.getFreshAirModel().getOnlineState(), 16);
                    if(speed==0){
                        return;
                    }
                    JSONObject json = new JSONObject();
                    json.put("modelId", modelId);
                    json.put("address", address);
                    json.put("mode", 1);
                    json.put("speed", speed);
                    json.put("temper", 26);
                    json.put("onOff", onOff);
                    json.put("online", online);
                    json.put("currTemperature", 0);
//                    Log.e("sky","通知flutter更新新风:"+json);
                    mChannels.local485DeviceControlChannel.cMethodChannel.invokeMethod("Local485DeviceUpdate", json);

                }, throwable -> Log.e("sky", "rxbus错误", throwable));

        //485地暖数据有变化接收到数据后推送到flutter层
        RxBus.getInstance().toObservableOnMain(this, FloorHotChangeEvent.class)
                .subscribe(AirConditionChangeEvent -> {
                    String modelId = "zhonghong.heat.001";
                    String address = AirConditionChangeEvent.getFloorHotModel().getOutSideAddress() + AirConditionChangeEvent.getFloorHotModel().getInSideAddress();
                    int temper = Integer.parseInt(AirConditionChangeEvent.getFloorHotModel().getTemperature(), 16);
                    int currTemperature = Integer.parseInt(AirConditionChangeEvent.getFloorHotModel().getCurrTemperature(), 16);
                    int onOff = Integer.parseInt(AirConditionChangeEvent.getFloorHotModel().getOnOff(), 16);
                    int online = Integer.parseInt(AirConditionChangeEvent.getFloorHotModel().getOnlineState(), 16);
                    JSONObject json = new JSONObject();
                    json.put("modelId", modelId);
                    json.put("address", address);
                    json.put("mode", 1);
                    json.put("speed", 1);
                    json.put("temper", temper);
                    json.put("onOff", onOff);
                    json.put("online", online);
                    json.put("currTemperature", currTemperature);
//                    Log.e("sky","通知flutter更新地暖:"+json);
                    mChannels.local485DeviceControlChannel.cMethodChannel.invokeMethod("Local485DeviceUpdate", json);

                }, throwable -> Log.e("sky", "rxbus错误", throwable));

    }


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 动态添加插件
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        // 初始化自定义的Channel
        mChannels.init(this, flutterEngine.getDartExecutor().getBinaryMessenger());
        initReceive();
        initNotifyChannel();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        try {
            unregisterReceiver(receiver);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initReceive() {
        try {
            IntentFilter filter = new IntentFilter();
            filter.addAction("com.alibaba.push2.action.NOTIFICATION_OPENED");
            filter.addAction("com.alibaba.push2.action.NOTIFICATION_REMOVED");
            filter.addAction("com.alibaba.sdk.android.push.RECEIVE");
            filter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
            AliPushReceiver receiver = new AliPushReceiver(mChannels.aliPushChannel);
            //注册广播接收
            registerReceiver(receiver, filter);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initNotifyChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager mNotificationManager = (NotificationManager) BaseApplication.getContext().getSystemService(Context.NOTIFICATION_SERVICE);
            // 通知渠道的id。
            String id = "1";
            // 用户可以看到的通知渠道的名字。
            CharSequence name = "notification channel";
            // 用户可以看到的通知渠道的描述。
            String description = "notification description";
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(id, name, importance);
            // 配置通知渠道的属性。
            mChannel.setDescription(description);
            // 设置通知出现时的闪灯（如果Android设备支持的话）。
            mChannel.enableLights(false);
            mChannel.setLightColor(Color.RED);
            // 设置通知出现时的震动（如果Android设备支持的话）。
            mChannel.enableVibration(false);
            mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            // 最后在notificationmanager中创建该通知渠道。
            mNotificationManager.createNotificationChannel(mChannel);
        }
    }

    public void initialMeiJuAi(String sn, String deviceId, String mac, boolean aiEnable) {
        new Thread(() -> {
            //复制assets/xiaomei文件夹中的文件到SD卡
            FileUtils.copyAssetsFilesAndDelete(MainActivity.this, "xiaomei", Environment.getExternalStorageDirectory().getPath());
            runOnUiThread(() -> startMeiJuAiService(sn, deviceId, mac, aiEnable));
        }).start();
    }

    private void startMeiJuAiService(String sn, String deviceId, String mac, boolean aiEnable) {
        com.midea.light.ai.AiManager.getInstance().startAiServer(this, isBind -> {
            if (isBind) {
                setDeviceInfor(sn, deviceId, mac);
            }
        }, isInitial -> {
            if (isInitial) {
                com.midea.light.ai.AiManager.getInstance().setAiEnable(aiEnable);
            } else {
                runOnUiThread(() -> DialogUtil.showToast("语音初始化失败,请重新启动智慧屏"));
            }
        });
    }

    public void initialHomluxAI(String uid, String token, boolean aiEnable, String houseId, String aiClientId) {
        HomluxAiApi.syncQueryDuiToken(houseId, aiClientId, token, entity -> {
            if (entity != null) {
                com.midea.homlux.ai.AiManager.getInstance().startDuiAi(MainActivity.this, uid, entity.getResult().getAccessToken(), entity.getResult().getRefreshToken(), entity.getResult().getAccessTokenExpireTime(), aiEnable, isWakUp -> {
                    LogUtil.i("Homlux语音是否被唤醒 " + isWakUp);
                    runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", isWakUp ? 1 : 0));
                }, Voice -> {
                    runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("AISetVoice", Voice));
                    LogUtil.i("Homlux语音大小 " + Voice);
                });
            }
        });
    }


    private void setDeviceInfor(String sn, String deviceId, String mac) {
        com.midea.light.ai.AiManager.getInstance().setDeviceInfor(sn, "0x16", deviceId, mac);
        MusicManager.getInstance().startMusicServer(this);
        com.midea.light.ai.AiManager.getInstance().addFlashMusicListCallBack(list -> {
            isFlashMusic = true;
            MusicManager.getInstance().setPlayList(list);
        });
        com.midea.light.ai.AiManager.getInstance().addWakUpStateCallBack(b -> {
            if (b) {
                isFlashMusic = false;
                if (!isScreenOn()) {
                    sendKeyEvent(KeyEvent.KEYCODE_BACK);
                }
                if (isAiSleep) {
                    isAiSleep = false;
                    isMusicPlay = MusicManager.getInstance().isPaying();
                    runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", 1));


                }
                if (MusicManager.getInstance().isPaying()) {
                    MusicManager.getInstance().pauseMusic();
                }
            } else {
                if (isAiSleep == false) {
                    isAiSleep = true;
                    runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", 0));

                }
                if (isMusicPlay || isFlashMusic) {
                    MusicManager.getInstance().startMusic();
                }
            }

        });
        com.midea.light.ai.AiManager.getInstance().addMusicPlayControlBack(Control -> {
            if (MusicManager.getInstance().getPlayMusicInfor() == null) {
                return;
            }
            switch (Control) {
                case "RESUME":
                    isMusicPlay = true;
                    MusicManager.getInstance().startMusic();
                    com.midea.light.ai.AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
                case "PAUSE":
                    isMusicPlay = false;
                    MusicManager.getInstance().pauseMusic();
                    com.midea.light.ai.AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "pause");
                    break;
                case "STOP":
                    isMusicPlay = false;
                    MusicManager.getInstance().stopMusic();
                    com.midea.light.ai.AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "stop");
                    break;
                case "prev":
                    isMusicPlay = true;
                    if (MusicManager.getInstance().getCurrentIndex() == 0) {
                        DialogUtil.showToast("已经是第一首了");
                        return;
                    }
                    MusicManager.getInstance().prevMusic();
                    com.midea.light.ai.AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
                case "next":
                    isMusicPlay = true;
                    if (MusicManager.getInstance().getCurrentIndex() == 14) {
                        DialogUtil.showToast("已经是最后一首了");
                        return;
                    }
                    MusicManager.getInstance().nextMusic();
                    com.midea.light.ai.AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(),
                            MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
            }
        });
        com.midea.light.ai.AiManager.getInstance().addAISetVoiceCallBack(Voice -> runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("AISetVoice", Voice)));
        com.midea.light.ai.AiManager.getInstance().addControlDeviceErrorCallBack(() -> runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("AiControlDeviceError",
                true)));
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

    private final class MySensorEventListener implements SensorEventListener {
        long curUpdateTime;

        @Override
        public void onSensorChanged(SensorEvent event) {
            boolean isCheck = SystemUtil.isScreenAutoMode();
            if (isCheck) {
                if (event.sensor.getType() == Sensor.TYPE_LIGHT) {
                    if (event.values[0] > 2500) {
                        changeSystemBrightness(255);
                    } else if (event.values[0] > 2400 && event.values[0] < 2500) {
                        changeSystemBrightness(250);
                    } else if (event.values[0] > 2300 && event.values[0] < 2400) {
                        changeSystemBrightness(245);
                    } else if (event.values[0] > 2200 && event.values[0] < 2300) {
                        changeSystemBrightness(240);
                    } else if (event.values[0] > 2100 && event.values[0] < 2200) {
                        changeSystemBrightness(235);
                    } else if (event.values[0] > 2000 && event.values[0] < 2100) {
                        changeSystemBrightness(230);
                    } else if (event.values[0] > 1900 && event.values[0] < 2000) {
                        changeSystemBrightness(225);
                    } else if (event.values[0] > 1800 && event.values[0] < 1900) {
                        changeSystemBrightness(220);
                    } else if (event.values[0] > 1700 && event.values[0] < 1800) {
                        changeSystemBrightness(215);
                    } else if (event.values[0] > 1600 && event.values[0] < 1700) {
                        changeSystemBrightness(210);
                    } else if (event.values[0] > 1500 && event.values[0] < 1600) {
                        changeSystemBrightness(205);
                    } else if (event.values[0] > 1400 && event.values[0] < 1500) {
                        changeSystemBrightness(200);
                    } else if (event.values[0] > 1300 && event.values[0] < 1400) {
                        changeSystemBrightness(195);
                    } else if (event.values[0] > 1200 && event.values[0] < 1300) {
                        changeSystemBrightness(190);
                    } else if (event.values[0] > 1100 && event.values[0] < 1200) {
                        changeSystemBrightness(185);
                    } else if (event.values[0] > 1000 && event.values[0] < 1100) {
                        changeSystemBrightness(180);
                    } else if (event.values[0] > 900 && event.values[0] < 1000) {
                        changeSystemBrightness(175);
                    } else if (event.values[0] > 850 && event.values[0] < 900) {
                        changeSystemBrightness(160);
                    } else if (event.values[0] > 700 && event.values[0] < 850) {
                        changeSystemBrightness(155);
                    } else if (event.values[0] > 650 && event.values[0] < 700) {
                        changeSystemBrightness(150);
                    } else if (event.values[0] > 600 && event.values[0] < 650) {
                        changeSystemBrightness(145);
                    } else if (event.values[0] > 550 && event.values[0] < 600) {
                        changeSystemBrightness(140);
                    } else if (event.values[0] > 500 && event.values[0] < 550) {
                        changeSystemBrightness(135);
                    } else if (event.values[0] > 450 && event.values[0] < 500) {
                        changeSystemBrightness(130);
                    } else if (event.values[0] > 350 && event.values[0] < 400) {
                        changeSystemBrightness(125);
                    } else if (event.values[0] > 300 && event.values[0] < 350) {
                        changeSystemBrightness(120);
                    } else if (event.values[0] > 250 && event.values[0] < 300) {
                        changeSystemBrightness(110);
                    } else if (event.values[0] > 200 && event.values[0] < 250) {
                        changeSystemBrightness(100);
                    } else if (event.values[0] > 150 && event.values[0] < 200) {
                        changeSystemBrightness(90);
                    } else if (event.values[0] > 100 && event.values[0] < 150) {
                        changeSystemBrightness(80);
                    } else if (event.values[0] > 80 && event.values[0] < 100) {
                        changeSystemBrightness(70);
                    } else if (event.values[0] > 60 && event.values[0] < 80) {
                        changeSystemBrightness(60);
                    } else if (event.values[0] > 40 && event.values[0] < 60) {
                        changeSystemBrightness(50);
                    } else if (event.values[0] > 20 && event.values[0] < 40) {
                        changeSystemBrightness(40);
                    } else if (event.values[0] < 20) {
                        changeSystemBrightness(0);
                    }

                }
            }
            boolean isNCheck = SystemUtil.isNearWakeup();
            if (isNCheck) {
                if (event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
                    value = event.values[0];
                }
            } else {
                value = -1;
            }


        }

        long maxUpdateTime = 0;
        long tempUpdateTime = 0;

        synchronized void changeSystemBrightness(int value) {
            if (SystemClock.uptimeMillis() - curUpdateTime >= 3000) {
                MainActivity.this.changeSystemBrightness(value);
                curUpdateTime = SystemClock.uptimeMillis();
                maxUpdateTime = 500;
                tempUpdateTime = System.currentTimeMillis();
            } else if (maxUpdateTime > 0) {
                MainActivity.this.changeSystemBrightness(value);
                maxUpdateTime = 500 - (System.currentTimeMillis() - tempUpdateTime);
            } else {
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }
    }

    private final class MyJHSensorEventListener implements SensorEventListener {
        @Override
        public void onSensorChanged(SensorEvent event) {
            boolean isNCheck = SystemUtil.isNearWakeup();
            if (isNCheck) {
                if (event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
                    float value = event.values[0];
                    if (value != -1) {
                        Log.e("sky", "距离传感器值:" + (value));
                        if (value == 0 && MainApplication.standbyState) {
                            if (!isScreenOn()) {
                                sendKeyEvent(KeyEvent.KEYCODE_BACK);
                            }
                            MainApplication.standbyState = false;
                            runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", 1));
                            new Thread() {
                                public void run() {
                                    try {
                                        Thread.sleep(1000);
                                    } catch (InterruptedException e) {
                                        e.printStackTrace();
                                    }
                                    runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", 0));
                                }
                            }.start();
                        }
                    }
                }
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }
    }

    public void changeSystemBrightness(int brightness) {
        if (brightness > 255) {
            SystemUtil.lightSet(255);
        } else {
            SystemUtil.lightSet(brightness);
        }

    }

    private void getSensor(float value) {
        if (value != -1) {
            SensorArry.add(value);
            if (SensorArry.size() > 200) {
                float max = Collections.max(SensorArry);
                float min = Collections.min(SensorArry);
//                Log.e("sky","差值:"+(max-min));
                SensorArry.clear();
                if (max - min > 50 && MainApplication.standbyState) {
                    LogUtil.e("######接触唤醒 -> 手机屏幕");
                    MainApplication.standbyState = false;
                    if (!isScreenOn()) {
                        sendKeyEvent(KeyEvent.KEYCODE_BACK);
                    }
                    runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", 1));
                    new Thread() {
                        public void run() {
                            try {
                                Thread.sleep(1000);
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                            runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("aiWakeUpState", 0));
                        }
                    }.start();
                    SensorArry.clear();
                }
            }

        } else {
            SensorArry.clear();
        }

    }

    private final BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(Intent.ACTION_TIME_TICK)) {
                Calendar cal = Calendar.getInstance();
                int min = cal.get(Calendar.MINUTE);
                if (min == 0 || min == 30) {
                    SLKClear();
                }
            }
        }
    };

    private void SLKClear() {
        try {
            Thread thread = new Thread() {
                public void run() {
                    FileUtils.deleteAllFile(Environment.getExternalStorageDirectory().getPath() + "/SLK");
                }
            };
            thread.start();
        } catch (Exception e) {

        }

    }



}
