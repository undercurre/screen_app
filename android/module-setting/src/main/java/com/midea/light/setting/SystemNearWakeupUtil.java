package com.midea.light.setting;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import com.midea.light.BaseApplication;
import java.util.function.Consumer;
import java.lang.ref.WeakReference;
import com.midea.light.log.LogUtil;

public class SystemNearWakeupUtil {

    static NearWakeupSensorEventListener SENSOR_EVENT_LISTENER = new NearWakeupSensorEventListener();
    static WeakReference<Consumer<Boolean>> CALLBACK;

    public static void open(Consumer<Boolean> consumer) {
        if(!SENSOR_EVENT_LISTENER.isRegister()) {
            CALLBACK = new WeakReference<>(consumer);
            SensorManager sensorManager = (SensorManager) BaseApplication.getContext().getSystemService(BaseApplication.getContext().SENSOR_SERVICE);
            Sensor ps = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
            sensorManager.registerListener(SENSOR_EVENT_LISTENER, ps, SensorManager.SENSOR_DELAY_NORMAL);
            SENSOR_EVENT_LISTENER.setRegist(true);
        } else {
            LogUtil.i("SystemNearWakeupUtil 重复注册");
        }
    }

    public static void close() {
        if(SENSOR_EVENT_LISTENER.isRegister()) {
            SensorManager mSensorManager = (SensorManager) BaseApplication.getContext().getSystemService(BaseApplication.getContext().SENSOR_SERVICE);
            Sensor ps = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
            mSensorManager.unregisterListener(SENSOR_EVENT_LISTENER, ps);
            SENSOR_EVENT_LISTENER.setRegist(false);
            if(CALLBACK != null) {
                CALLBACK.clear();
                CALLBACK = null;
            }
        }
    }


    private static final class NearWakeupSensorEventListener implements SensorEventListener {

        boolean register = false;

        public void setRegist(boolean register) {
            this.register = register;
        }

        public boolean isRegister() {
            return register;
        }

        @Override
        public void onSensorChanged(SensorEvent event) {

            if (event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
                float value = event.values[0];
                if (value == 0) {
                    LogUtil.e("距离传感器值:" + (value));
                    if(CALLBACK != null && CALLBACK.get() != null) {
                        CALLBACK.get().accept(true);
                    } else {
                        LogUtil.i("SystemNearWakeupUtil CALLBACK ref is null");
                    }
                }
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }
    }

}