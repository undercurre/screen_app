package com.midea.light;

import android.Manifest;
import android.app.Application;
import android.app.Instrumentation;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.IntentFilter;
import android.graphics.Color;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.PowerManager;
import android.os.SystemClock;
import android.view.KeyEvent;

import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.noonesdk.PushInitConfig;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;
import com.midea.light.ai.AiManager;
import com.midea.light.ai.music.MusicManager;
import com.midea.light.ai.utils.FileUtils;
import com.midea.light.channel.Channels;
import com.midea.light.channel.method.AliPushChannel;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.utils.DialogUtil;
import com.midea.light.log.LogUtil;
import com.midea.light.push.AliPushReceiver;
import com.midea.light.setting.SystemUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Timer;
import java.util.TimerTask;

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
    }

    private void registerAliPushReceiver() {
        IntentFilter filter = new IntentFilter();
        filter.addAction("com.alibaba.push2.action.NOTIFICATION_OPENED");
        filter.addAction("com.alibaba.push2.action.NOTIFICATION_REMOVED");
        filter.addAction("com.alibaba.sdk.android.push.RECEIVE");
        filter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
        AliPushReceiver receiver = new AliPushReceiver(mChannels.aliPushChannel);
        registerReceiver(receiver, filter);
    }

    private void initNotifyChannel(){
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


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 动态添加插件
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        // 初始化自定义的Channel
        mChannels.init(this, flutterEngine.getDartExecutor().getBinaryMessenger());
        registerAliPushReceiver();
        initNotifyChannel();
    }

    public void initialAi(String sn, String deviceId, String mac, boolean aiEnable) {
        new Thread(() -> {
            //复制assets/xiaomei文件夹中的文件到SD卡
            FileUtils.copyAssetsFilesAndDelete(MainActivity.this, "xiaomei", Environment.getExternalStorageDirectory().getPath());
            runOnUiThread(() -> startAiService(sn, deviceId, mac, aiEnable));
        }).start();
    }

    private void startAiService(String sn, String deviceId, String mac, boolean aiEnable) {
        AiManager.getInstance().startAiServer(this, isBind -> {
            if (isBind) {
                setDeviceInfor(sn, deviceId, mac);
            }
        }, isInitial -> {
            if (isInitial) {
                AiManager.getInstance().setAiEnable(aiEnable);
            } else {
                runOnUiThread(() -> DialogUtil.showToast("语音初始化失败,请重新启动智慧屏"));
            }
        });
    }

    private void setDeviceInfor(String sn, String deviceId, String mac) {
        AiManager.getInstance().setDeviceInfor(sn, "0x16", deviceId, mac);
        MusicManager.getInstance().startMusicServer(this);
        AiManager.getInstance().addFlashMusicListCallBack(list -> {
            isFlashMusic = true;
            MusicManager.getInstance().setPlayList(list);
        });
        AiManager.getInstance().addWakUpStateCallBack(b -> {
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
        AiManager.getInstance().addMusicPlayControlBack(Control -> {
            if (MusicManager.getInstance().getPlayMusicInfor() == null) {
                return;
            }
            switch (Control) {
                case "RESUME":
                    isMusicPlay = true;
                    MusicManager.getInstance().startMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
                case "PAUSE":
                    isMusicPlay = false;
                    MusicManager.getInstance().pauseMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "pause");
                    break;
                case "STOP":
                    isMusicPlay = false;
                    MusicManager.getInstance().stopMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "stop");
                    break;
                case "prev":
                    isMusicPlay = true;
                    if (MusicManager.getInstance().getCurrentIndex() == 0) {
                        DialogUtil.showToast("已经是第一首了");
                        return;
                    }
                    MusicManager.getInstance().prevMusic();
                    AiManager.getInstance().reportPlayerStatusToCloud(MusicManager.getInstance().getPlayMusicInfor().getMusicUrl(),
                            MusicManager.getInstance().getPlayMusicInfor().getSong(), MusicManager.getInstance().getCurrentIndex(), "play");
                    break;
                case "next":
                    isMusicPlay = true;
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
        AiManager.getInstance().addAISetVoiceCallBack(Voice -> runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("AISetVoice", Voice)));
        AiManager.getInstance().addControlDeviceErrorCallBack(() -> runOnUiThread(() -> mChannels.aiMethodChannel.cMethodChannel.invokeMethod("AiControlDeviceError",
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
//                        Log.e("sky", "距离传感器值:" + (value));
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

}
