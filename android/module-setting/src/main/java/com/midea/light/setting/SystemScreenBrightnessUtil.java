package com.midea.light.setting;
import com.midea.light.log.LogUtil;
import com.midea.light.BaseApplication;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.database.ContentObserver;
import android.content.ContentResolver;
import android.provider.Settings;
import android.os.Handler;
import android.os.Looper;
import android.content.Context;
import com.midea.light.BaseApplication;


public class SystemScreenBrightnessUtil {
    // 屏幕亮度
    static int BRIGHTNESS = 0;
    // 自动亮度模式
    static boolean IS_BRIGHTNESS_AUTO_MODE = false;

    static MySensorEventListener SENSOR_EVENT_LISTENER = new MySensorEventListener();

    static {
        LogUtil.i("SystemScreenLightUtil static block init");
        BRIGHTNESS = SystemUtil.lightGet();
        LogUtil.i("SystemScreenLightUtil brightness " + BRIGHTNESS);
        IS_BRIGHTNESS_AUTO_MODE = SystemUtil.isScreenAutoMode();
        LogUtil.i("SystemScreenLightUtil auto_brightness " + IS_BRIGHTNESS_AUTO_MODE);
//        setBrightnesslistener(IS_BRIGHTNESS_AUTO_MODE);

        Context context = BaseApplication.getContext();
        context.getContentResolver().registerContentObserver(
                Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS),
                true,
                new BrightnessObserver(new Handler(Looper.getMainLooper()))
        );
        context.getContentResolver().registerContentObserver(
                Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS_MODE),
                true,
                new BrightnessAutoModeObserver(new Handler(Looper.getMainLooper()))
        );
    }

    static void setBrightnesslistener(boolean listener) {
        if(listener) {
            if(!SENSOR_EVENT_LISTENER.isRegister()) {
                SensorManager mSensorManager = (SensorManager) BaseApplication.getContext().getSystemService(BaseApplication.getContext().SENSOR_SERVICE);
                Sensor als = mSensorManager.getDefaultSensor(Sensor.TYPE_LIGHT);
                mSensorManager.registerListener(SENSOR_EVENT_LISTENER, als, SensorManager.SENSOR_DELAY_NORMAL);
            } else {
                LogUtil.i("SystemScreenLightUtil Sensor 重复注册");
            }
        } else {
            if(SENSOR_EVENT_LISTENER.isRegister()) {
                SensorManager mSensorManager = (SensorManager) BaseApplication.getContext().getSystemService(BaseApplication.getContext().SENSOR_SERVICE);
                Sensor als = mSensorManager.getDefaultSensor(Sensor.TYPE_LIGHT);
                mSensorManager.unregisterListener(SENSOR_EVENT_LISTENER, als);
            }
        }
    }

    public static void setBrightnessAutoMode(boolean isAutoMode) {
        SystemUtil.setScreenAutoMode(isAutoMode);
        IS_BRIGHTNESS_AUTO_MODE = isAutoMode;
//        setBrightnesslistener(isAutoMode);
    }

    public static boolean isBrightnessAutoMode() {
        return IS_BRIGHTNESS_AUTO_MODE;
    }

    public static void setBrightness(int light) {
        SystemUtil.lightSet(light);
        BRIGHTNESS = light;
    }

    public static int getBrightness() {
        return BRIGHTNESS;
    }

    static class BrightnessAutoModeObserver extends ContentObserver {

        public BrightnessAutoModeObserver(Handler handler) {
            super(handler);
        }

        @Override
        public void onChange(boolean selfChange) {
            super.onChange(selfChange);
            IS_BRIGHTNESS_AUTO_MODE = SystemUtil.isScreenAutoMode();
//            setBrightnesslistener(IS_BRIGHTNESS_AUTO_MODE);
            LogUtil.i("SystemScreenLightUtil brightness auto " + IS_BRIGHTNESS_AUTO_MODE);
        }

    }

    static class BrightnessObserver extends ContentObserver {

        public BrightnessObserver(Handler handler) {
            super(handler);
        }

        @Override
        public void onChange(boolean selfChange) {
            super.onChange(selfChange);
            BRIGHTNESS = SystemUtil.lightGet();

            LogUtil.i("SystemScreenLightUtil brightness change " + BRIGHTNESS);
        }

    }

    static class MySensorEventListener implements SensorEventListener {

        boolean register = false;

        public void setRegist(boolean register) {
            this.register = register;
        }

        public boolean isRegister() {
            return register;
        }

        @Override
        public void onSensorChanged(SensorEvent event) {

            if (event.sensor.getType() == Sensor.TYPE_LIGHT) {
                float value = event.values[0];
                int brightness;
                if (value >= 2550) {
                    brightness = 255;
                } else if (value >= 2450) {
                    brightness = 245;
                } else if (value >= 2350) {
                    brightness = 235;
                } else if (value >= 2250) {
                    brightness = 225;
                } else if (value >= 2150) {
                    brightness = 215;
                } else if (value >= 2050) {
                    brightness = 205;
                } else if (value >= 1950) {
                    brightness = 195;
                } else if (value >= 1850) {
                    brightness = 185;
                } else if (value >= 1750) {
                    brightness = 175;
                } else if (value >= 1650) {
                    brightness = 165;
                } else if (value >= 1550) {
                    brightness = 155;
                } else if (value >= 1450) {
                    brightness = 145;
                } else if (value >= 1350) {
                    brightness = 135;
                } else if (value >= 1250) {
                    brightness = 125;
                } else if (value >= 1150) {
                    brightness = 115;
                } else if (value >= 1050) {
                    brightness = 105;
                } else if (value >= 950) {
                    brightness = 95;
                } else if (value >= 850) {
                    brightness = 85;
                } else if (value >= 750) {
                    brightness = 75;
                } else if (value >= 650) {
                    brightness = 65;
                } else if (value >= 550) {
                    brightness = 55;
                } else if (value >= 450) {
                    brightness = 45;
                } else if (value >= 350) {
                    brightness = 35;
                } else if (value >= 250) {
                    brightness = 25;
                } else if (value >= 150) {
                    brightness = 15;
                } else if (value >= 50) {
                    brightness = 5;
                } else {
                    brightness = 1;
                }
                LogUtil.i("SystemScreenLightUtil.MySensorEventListener.onSensorChanged: ************ " + "; value = " + value + "; brightness = " + brightness);
                // 当自动亮度和当前亮度的值超过 最大值的 10% 的时候，应用该亮度值
                if (Math.abs(BRIGHTNESS - brightness) < 25) {
                    return;
                }
                setBrightness(brightness);
            }

        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {}

    }

}