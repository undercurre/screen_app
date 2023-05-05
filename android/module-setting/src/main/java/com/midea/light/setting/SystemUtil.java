package com.midea.light.setting;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.SmatekManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.PowerManager;
import android.os.SystemClock;
import android.provider.Settings;
import android.view.View;

import com.jhxs.ltmidea.tools.RelayControl;
import com.midea.light.BaseApplication;
import com.midea.light.bean.SNCodeBean;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.gateway.GateWayRepository;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.gateway.GatewayCallback;
import com.midea.light.utils.CommandExecution;
import com.midea.light.utils.MacUtil;
import com.midea.smart.open.common.util.StringUtils;

import java.lang.reflect.InvocationTargetException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.util.function.Function;

import static android.content.Context.AUDIO_SERVICE;

class JHSystemUtil {

    static {
        System.loadLibrary("ltmidea");
    }

    /**
     * 移除所有的数据
     */
    @SuppressLint("WrongConstant")
    public static void eraseAllData() {
        throw new RuntimeException("暂不支持此操作");
    }

    public static void setScreenAutoMode(boolean isAutoMode) {
        ContentResolver contentResolver = BaseApplication.getContext().getContentResolver();
        if (isAutoMode) {
            Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC);
        } else {
            Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL);
        }
    }

    public static boolean isScreenAutoMode() {
        boolean isAutoMode = false;
        ContentResolver contentResolver = BaseApplication.getContext().getContentResolver();
        try {
            int mode = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE);
            if (mode == Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC) {
                isAutoMode = true;
            } else {
                isAutoMode = false;
            }
        } catch (Settings.SettingNotFoundException e) {
            e.printStackTrace();
        }
        return isAutoMode;
    }

    /**
     * 重启
     */
    @SuppressLint("WrongConstant")
    public static void reboot() {
        String command = "setprop sys.powerctl reboot";
        CommandExecution.execCommand(command, false);
    }

    /**
     * 关机
     */
    @SuppressLint("WrongConstant")
    public static void shutdown() {
        String command = "setprop sys.powerctl shutdown";
        CommandExecution.execCommand(command, false);
    }

    //断开以太网
    @SuppressLint("WrongConstant")
    public static void disconnectEth() {
        throw new RuntimeException("暂不支持此操作");
    }

    //连接以太网
    @SuppressLint("WrongConstant")
    public static void connectEth() {
        throw new RuntimeException("暂不支持此操作");
    }

    /**
     * 调节亮度
     * 亮度值（0~255）
     */
    @SuppressLint("WrongConstant")
    public static void lightSet(int light) {
        Settings.System.putInt(BaseApplication.getContext().getContentResolver(), Settings.System.SCREEN_BRIGHTNESS, light);
    }

    /**
     * 亮度获取
     * 亮度值（0~255）
     */
    @SuppressLint("WrongConstant")
    public static int lightGet() {
        int systemBrightness = 0;
        try {
            systemBrightness = Settings.System.getInt(BaseApplication.getContext().getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
        } catch (Settings.SettingNotFoundException e) {
            e.printStackTrace();
        }
        return systemBrightness;
    }

    /**
     * 开关背光
     *
     * @param value
     */
    @SuppressLint("WrongConstant")
    public static void setLcdBlackLight(boolean value) {
        PowerManager powerManager = (PowerManager) BaseApplication.getContext().getSystemService(Context.POWER_SERVICE);
        if (value) {
            try {
                if (powerManager != null) {
                    powerManager.getClass().getMethod("wakeUp", long.class).invoke(powerManager, SystemClock.uptimeMillis());
                }
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            }
        } else {
            try {
                powerManager.getClass().getMethod("goToSleep", new Class[]{long.class}).invoke(powerManager, SystemClock.uptimeMillis());
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            }
        }


    }

    /**
     * 开关背光
     *
     * @param value
     */
    @SuppressLint("WrongConstant")
    public static void openOrCloseScreen(boolean value) {
        PowerManager powerManager = (PowerManager) BaseApplication.getContext().getSystemService(Context.POWER_SERVICE);
        if (!value) {
            try {
                if (powerManager != null) {
                    powerManager.getClass().getMethod("wakeUp", long.class).invoke(powerManager, SystemClock.uptimeMillis());
                }
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            }
        } else {
            try {
                powerManager.getClass().getMethod("goToSleep", new Class[]{long.class}).invoke(powerManager, SystemClock.uptimeMillis());
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 隐藏导航栏
     */
    public static void hideNavigationBar(Activity activity) {
        activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE);
    }

    /**
     * 显示导航栏
     *
     * @param context
     */
    public static void showNavigationBar(Context context) {
        throw new RuntimeException("暂不支持此方法调用");
    }

    /**
     * 继电器控制
     */
    @SuppressLint("WrongConstant")
    public static void CommandGP(int num, boolean onoff) {
        try {
            switch (num) {
                case 0:
                    RelayControl.SetRelayGpio1Status(onoff ? 1 : 0);
                    break;
                case 1:
                    RelayControl.SetRelayGpio2Status(onoff ? 1 : 0);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 继电器控制
     */
    @SuppressLint("WrongConstant")
    public static Object readGP(int num) {
        try {
            switch (num) {
                case 0:
                    return String.valueOf(RelayControl.GetRelayGpio1Status());
                case 1:
                    return String.valueOf(RelayControl.GetRelayGpio2Status());
            }
        } catch (Exception e) {
            e.printStackTrace();

        }
        return "0";
    }

    public static void clickScreen(int x, int y) {
        String command = "input tap " + x + " " + y;
        new Thread() {
            public void run() {
                CommandExecution.execCommand(command, false);
            }
        }.start();

    }

    public static void wakeupScreenAndClickScreen(int x, int y) {
        clickScreen(x, y);
    }

    /**
     * 系统音量设置
     */
    public static int getSystemAudio() {
        AudioManager am = (AudioManager) BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        int current = am.getStreamVolume(AudioManager.STREAM_MUSIC);
        return current;
    }

    /**
     * 系统音量控制
     */
    public static void setSystemAudio(int Audio) {
        AudioManager am = (AudioManager) BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        am.setStreamVolume(AudioManager.STREAM_MUSIC, Audio, AudioManager.FLAG_PLAY_SOUND);
    }

}

class LDSystemUtil {
    /**
     * 移除所有的数据
     */
    @SuppressLint("WrongConstant")
    public static void eraseAllData() {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.eraseAllData();
    }

    public static void setScreenAutoMode(boolean isAutoMode) {
        SharedPreferences sp = BaseApplication.getContext().getSharedPreferences("M-Smart-4", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putBoolean("isScreenAutoMode", isAutoMode).commit();
    }

    public static boolean isScreenAutoMode() {
        SharedPreferences sp = BaseApplication.getContext().getSharedPreferences("M-Smart-4", Context.MODE_PRIVATE);
        return sp.getBoolean("isScreenAutoMode", false);
    }


    /**
     * 重启
     */
    @SuppressLint("WrongConstant")
    public static void reboot() {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.reboot();
    }

    /**
     * 关机
     */
    @SuppressLint("WrongConstant")
    public static void shutdown() {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.shutdown();
    }

    //断开以太网
    @SuppressLint("WrongConstant")
    public static void disconnectEth() {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.disconnectEth("eth0");
    }

    //连接以太网
    @SuppressLint("WrongConstant")
    public static void connectEth() {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.connectEth("eth0");
    }

    /**
     * 调节亮度
     * 亮度值（0~255）
     */
    @SuppressLint("WrongConstant")
    public static void lightSet(int light) {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.setBrightness(light);
    }

    /**
     * 亮度获取
     * 亮度值（0~255）
     */
    @SuppressLint("WrongConstant")
    public static int lightGet() {
        int systemBrightness = 0;
        try {
            systemBrightness = Settings.System.getInt(BaseApplication.getContext().getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
        } catch (Settings.SettingNotFoundException e) {
            e.printStackTrace();
        }
        return systemBrightness;
    }

    /**
     * 开关背光
     *
     * @param value
     */
    @SuppressLint("WrongConstant")
    public static void setLcdBlackLight(boolean value) {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.setLcdBlackLight(value);
    }

    /**
     * 开关背光
     *
     * @param value
     */
    @SuppressLint("WrongConstant")
    public static void openOrCloseScreen(boolean value) {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        manager.openOrCloseScreen(value);
    }

    /**
     * 隐藏导航栏
     */
    public static void hideNavigationBar(Activity activity) {
        Intent intent = new Intent();
        intent.setAction("com.smatek.show.navigationbar");
        intent.putExtra("show_navigationbar", false);//auto true 为显⽰ ，false 为 隐
        activity.sendBroadcast(intent);
    }

    /**
     * 显示导航栏
     *
     * @param context
     */
    public static void showNavigationBar(Context context) {
        Intent intent = new Intent();
        intent.setAction("com.smatek.show.navigationbar");
        intent.putExtra("show_navigationbar", true);//auto true 为显⽰ ，false 为 隐
        context.sendBroadcast(intent);
    }

    /**
     * 继电器控制
     */
    @SuppressLint("WrongConstant")
    public static void CommandGP(int num, boolean onoff) {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        switch (num) {
            case 0:
                if (onoff) {
                    manager.writeToNode("sys/class/gpio/gpio114/value", "1");
                } else {
                    manager.writeToNode("sys/class/gpio/gpio114/value", "0");
                }
                break;
            case 1:
                if (onoff) {
                    manager.writeToNode("/sys/class/gpio/gpio115/value", "1");
                } else {
                    manager.writeToNode("/sys/class/gpio/gpio115/value", "0");
                }
                break;
        }
    }

    /**
     * 继电器控制
     */
    @SuppressLint("WrongConstant")
    public static Object readGP(int num) {
        SmatekManager manager = (SmatekManager) BaseApplication.getContext().getSystemService("smatek");
        switch (num) {
            case 0:
                return manager.getDataFromNode("sys/class/gpio/gpio114/value");
            case 1:
                return manager.getDataFromNode("/sys/class/gpio/gpio115/value");
        }
        return false;
    }

    public static void clickScreen(int x, int y) {
        String command = "input tap " + x + " " + y;
        new Thread() {
            public void run() {
                CommandExecution.execCommand(command, false);
            }
        }.start();

    }

    public static void wakeupScreenAndClickScreen(int x, int y) {
        clickScreen(x, y);
    }

    /**
     * 系统音量设置
     */
    public static int getSystemAudio() {
        AudioManager am = (AudioManager) BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        int current = am.getStreamVolume(AudioManager.STREAM_MUSIC);
        return current;
    }

    /**
     * 系统音量控制
     */
    public static void setSystemAudio(int Audio) {
        AudioManager am = (AudioManager) BaseApplication.getContext().getSystemService(AUDIO_SERVICE);
        am.setStreamVolume(AudioManager.STREAM_MUSIC, Audio, AudioManager.FLAG_PLAY_SOUND);
    }
}

public class SystemUtil {
    /**
     * 移除所有的数据
     */
    @SuppressLint("WrongConstant")
    public static void eraseAllData() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.eraseAllData();
        } else {
            LDSystemUtil.eraseAllData();
        }
    }

    public static void setScreenAutoMode(boolean isAutoMode) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.setScreenAutoMode(isAutoMode);
        } else {
            LDSystemUtil.setScreenAutoMode(isAutoMode);
        }
    }

    public static boolean isScreenAutoMode() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            return JHSystemUtil.isScreenAutoMode();
        } else {
            return LDSystemUtil.isScreenAutoMode();
        }
    }

    public static void setNearWakeup(boolean isNearWakeup) {
        SharedPreferences sp = BaseApplication.getContext().getSharedPreferences("M-Smart-4", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putBoolean("NearWakeup", isNearWakeup).commit();
    }

    public static boolean isNearWakeup() {
        SharedPreferences sp = BaseApplication.getContext().getSharedPreferences("M-Smart-4", Context.MODE_PRIVATE);
        return sp.getBoolean("NearWakeup", false);
    }

    /**
     * 重启
     */
    @SuppressLint("WrongConstant")
    public static void reboot() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.reboot();
        } else {
            LDSystemUtil.reboot();
        }
    }

    /**
     * 关机
     */
    @SuppressLint("WrongConstant")
    public static void shutdown() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.shutdown();
        } else {
            LDSystemUtil.shutdown();
        }
    }

    //断开以太网
    @SuppressLint("WrongConstant")
    public static void disconnectEth() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.disconnectEth();
        } else {
            LDSystemUtil.disconnectEth();
        }
    }

    //连接以太网
    @SuppressLint("WrongConstant")
    public static void connectEth() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.connectEth();
        } else {
            LDSystemUtil.connectEth();
        }
    }

    /**
     * 调节亮度
     * 亮度值（0~255）
     */
    @SuppressLint("WrongConstant")
    public static void lightSet(int light) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.lightSet(light);
        } else {
            LDSystemUtil.lightSet(light);
        }
    }

    /**
     * 调节亮度
     * 亮度值（0~255）
     */
    @SuppressLint("WrongConstant")
    public static int lightGet() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            return JHSystemUtil.lightGet();
        } else {
            return LDSystemUtil.lightGet();
        }
    }

    /**
     * 开关背光
     *
     * @param value
     */
    @SuppressLint("WrongConstant")
    public static void setLcdBlackLight(boolean value) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.setLcdBlackLight(value);
        } else {
            LDSystemUtil.setLcdBlackLight(value);
        }

    }

    public static boolean isScreenOn() {
        PowerManager powerManager = (PowerManager) BaseApplication.getContext().getSystemService(Context.POWER_SERVICE);
        return powerManager.isScreenOn();
    }

    /**
     * 开关背光
     *
     * @param value
     */
    @SuppressLint("WrongConstant")
    public static void openOrCloseScreen(boolean value) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.openOrCloseScreen(value);
        } else {
            LDSystemUtil.openOrCloseScreen(value);
        }
    }

    /**
     * 隐藏导航栏
     */
    public static void hideNavigationBar(Activity activity) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.hideNavigationBar(activity);
        } else {
            LDSystemUtil.hideNavigationBar(activity);
        }
    }

    /**
     * 显示导航栏
     *
     * @param context
     */
    public static void showNavigationBar(Context context) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.showNavigationBar(context);
        } else {
            LDSystemUtil.showNavigationBar(context);
        }
    }

    /**
     * 继电器控制
     */
    @SuppressLint("WrongConstant")
    public static void CommandGP(int num, boolean onoff) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.CommandGP(num, onoff);
        } else {
            LDSystemUtil.CommandGP(num, onoff);
        }
    }

    /**
     * 继电器控制
     */
    @SuppressLint("WrongConstant")
    public static Boolean readGP(int num) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            return JHSystemUtil.readGP(num).equals("1");
        } else {
            return LDSystemUtil.readGP(num).equals("1");
        }
    }

    public static void clickScreen(int x, int y) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.clickScreen(x, y);
        } else {
            LDSystemUtil.clickScreen(x, y);
        }

    }

    public static void wakeupScreenAndClickScreen(int x, int y) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.wakeupScreenAndClickScreen(x, y);
        } else {
            LDSystemUtil.wakeupScreenAndClickScreen(x, y);
        }
    }

    /**
     * 系统音量调节
     */
    public static void setSystemAudio(int audio) {
        if (AppCommonConfig.getChannel().equals("JH")) {
            JHSystemUtil.setSystemAudio(audio);
        } else {
            LDSystemUtil.setSystemAudio(audio);
        }
    }


    /**
     * 系统音量获取
     */
    public static int getSystemAudio() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            return JHSystemUtil.getSystemAudio();
        } else {
            return LDSystemUtil.getSystemAudio();
        }
    }


    public static String getMacAddress() {
        if (AppCommonConfig.getChannel().equals("JH")) {
            return MacUtil.macAddress("wlan0");
        } else {
            return MacUtil.macAddress("p2p0");
        }
    }

    public static String getIpAddress(Context context) {
        return IpAddressUtil.getIpAddress(context);
    }

    public static void getGatewaySn(Function<String, String> callback) {
        String rawSn = GateWayRepository.getInstance().getGatewaySn();
        boolean resultCallback = false;
        if(!StringUtils.isEmpty(rawSn)) {
            resultCallback = true;
            callback.apply(rawSn);
        }
        boolean finalResultCallback = resultCallback;
        GateWayUtils.bindGateWay(new GatewayCallback.SN(System.currentTimeMillis() + 4000, TimeUnit.MILLISECONDS) {
            @Override
            protected void callback(SNCodeBean msg) {
                if (null == msg) {
                    // 获取失败
                    if(!finalResultCallback) {
                        callback.apply("");
                    }
                } else {
                    // 获取成功
                    if(!finalResultCallback) {
                        callback.apply(msg.getCode().getSN());
                    }
                    GateWayRepository.getInstance().saveGatewaySn(msg.getCode().getSN());
                }
            }
        });
    }

    public static String getAppVersion(Context context) {
        return GatewayVersionUtil.getAppVersion(context);
    }

    public static String getGatewayVersion() {
        return GatewayVersionUtil.getGatewayVersion();
    }

    public static String getSystemVersion(Context context) {
        return GatewayVersionUtil.getSystemVersion(context);
    }

}

class IpAddressUtil {

    public static String getIpAddress(Context context) {
        NetworkInfo info = ((ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE)).getActiveNetworkInfo();
        if (info != null && info.isConnected()) {
            if (info.getType() == ConnectivityManager.TYPE_WIFI) {//当前使用无线网络
                return getIpAddress("wlan0");
            } else if (info.getType() == ConnectivityManager.TYPE_ETHERNET) {
                return getIpAddress("eth0");
            }
        }
        return "0.0.0.0";
    }

    public static String getIpAddress(String interfaceName) {
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
                NetworkInterface intf = en.nextElement();
                if (!Objects.equals(intf.getDisplayName(), interfaceName)) continue;
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
                        return inetAddress.getHostAddress();
                    }
                }
            }
        } catch (SocketException e) {
            e.printStackTrace();
        }

        return "0.0.0.0";
    }


}
