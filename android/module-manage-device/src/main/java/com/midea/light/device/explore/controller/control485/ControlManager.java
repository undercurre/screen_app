package com.midea.light.device.explore.controller.control485;

import android.serialport.SerialPort;
import android.util.Log;

import com.midea.light.device.explore.controller.control485.controller.AirConditionController;
import com.midea.light.device.explore.controller.control485.controller.FloorHotController;
import com.midea.light.device.explore.controller.control485.controller.FreshAirController;
import com.midea.light.device.explore.controller.control485.controller.GetWayController;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Subject;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.AIR_CONDITION_QUERY_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ALL_AIR_CONDITION_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.ALL_FLOOR_HOT_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_QUERY_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.ALL_FRESH_AIR_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_QUERY_CODE;

public class ControlManager implements Data485Subject {

    private SerialPort mSerialPort;
    private InputStream mInputStream;
    private OutputStream mOutputStream;
    private static final int BAUD_RATE = 9600;
    private boolean running = true, isFirstFrame = false, commandFinsh = true;
    private StringBuffer total = new StringBuffer();
    private String[] commandStrArry;
    private int totalSize = 0;
    private List<Data485Observer> observers = new ArrayList<>();
    private byte[] buffer = new byte[1024];
    private Timer timer;
    private Integer cacheTime = 100;

    public static ControlManager Instance = new ControlManager();

    public static ControlManager getInstance() {
        return Instance;
    }

    public void initial() {
        try {
            mSerialPort = SerialPort
                    .newBuilder("/dev/ttyS3", BAUD_RATE)
                    // 校验位；0:无校验位(NONE，默认)；1:奇校验位(ODD);2:偶校验位(EVEN)
                    .parity(2)
                    // 数据位,默认8；可选值为5~8
                    .dataBits(8)
                    // 停止位，默认1；1:1位停止位；2:2位停止位
                    .stopBits(1)
                    .build();
            mInputStream = mSerialPort.getInputStream();
            mOutputStream = mSerialPort.getOutputStream();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        registerObserver(GetWayController.getInstance());
        registerObserver(AirConditionController.getInstance());
        registerObserver(FreshAirController.getInstance());
        registerObserver(FloorHotController.getInstance());
        new Thread() {
            public void run() {
                while (running) {
                    if (mInputStream != null) {
                        try {
                            int size = mInputStream.read(buffer);
                            if (size > 0) {
//                                Log.e("sky", "读到数据量:" + size);
//                                //判断请求指令,根据请求指令来判断是否数据完整
                                if (isFirstFrame) {
                                    if (commandStrArry[1].equals(AIR_CONDITION_QUERY_CODE.data) && commandStrArry[2].equals(ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE.data)) {
                                        byte b = buffer[3];
                                        int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到空调数量
                                        totalSize = num * 3 + 5;
//                                        Log.e("sky", "需要数据量:" + totalSize);
                                    } else if (commandStrArry[1].equals(AIR_CONDITION_QUERY_CODE.data) && commandStrArry[2].equals(ALL_AIR_CONDITION_QUERY_PARELETE_CODE.data)) {
                                        byte b = buffer[3];
                                        int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到空调数量
                                        totalSize = num * 10 + 5;
//                                        Log.e("sky", "需要数据量:" + totalSize);
                                    } else if (commandStrArry[1].equals(FRESH_AIR_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE.data)) {
                                        byte b = buffer[3];
                                        int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到新风数量
                                        totalSize = num * 3 + 5;
                                        Log.e("sky", "需要数据量:" + totalSize);
                                    } else if (commandStrArry[1].equals(FRESH_AIR_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FRESH_AIR_QUERY_PARELETE_CODE.data)) {
                                        byte b = buffer[3];
                                        int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到新风数量
                                        totalSize = num * 10 + 5;
                                        Log.e("sky", "需要数据量:" + totalSize);
                                    } else if (commandStrArry[1].equals(FLOOR_HOT_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE.data)) {
                                        byte b = buffer[3];
                                        int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到地暖数量
                                        totalSize = num * 3 + 5;
                                        Log.e("sky", "需要数据量:" + totalSize);
                                    } else if (commandStrArry[1].equals(FLOOR_HOT_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FLOOR_HOT_QUERY_PARELETE_CODE.data)) {
                                        byte b = buffer[3];
                                        int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到地暖数量
                                        totalSize = num * 10 + 5;
                                        Log.e("sky", "需要数据量:" + totalSize);
                                    } else {
                                        totalSize = 7;
                                    }
                                    isFirstFrame = false;
                                }
                                StringBuffer sb = new StringBuffer();
                                for (int i = 0; i < size; i++) {
                                    byte b = buffer[i];
                                    if (Integer.toHexString(b & 0xFF).length() == 1) {
                                        sb.append("0" + Integer.toHexString(b & 0xFF).toUpperCase());
                                    } else {
                                        sb.append(Integer.toHexString(b & 0xFF).toUpperCase());
                                    }
                                    sb.append(" ");
                                }
//                                Log.e("sky", "读取数据:" + sb);
                                total.append(sb);
//                                Log.e("sky", "部分数据:" + total);
                                String[] totalArry = total.toString().split(" ");
//                                Log.e("sky", "当前数据量:" + totalArry.length);
                                //拿到所有数据后再发出
                                if (totalArry.length == totalSize) {
//                                    Log.e("sky", "完整数据:" + total);
                                    commandFinsh = true;
                                    notifyObservers(total.toString());
                                }
                            }
                        } catch (IOException e) {
                            e.printStackTrace();
                            Log.e("sky", "mInputStream报错:" + e.getMessage());
                        }
                    } else {
                        Log.e("sky", "mInputStream为空");
                    }
                }
            }
        }.start();




    }

    public void write(String str) {
//        Log.e("sky", "发出去的数据:" + str);
        if (commandFinsh == false) {
            //上次任务没完成,不执行这次任务
            return;
        }
        isFirstFrame = true;
        commandFinsh = false;
        commandStrArry = str.split(" ");
        if (mOutputStream != null) {
            List<Byte> data = new ArrayList<>();
            String[] strArry = str.split(" ");
            for (int i = 0; i < strArry.length; i++) {
                data.add(hexToByte(strArry[i]));
            }
            byte[] destinationArray = new byte[data.size()];
            for (int i = 0; i < data.size(); i++) {
                destinationArray[i] = data.get(i);
            }
            try {
                mOutputStream.write(destinationArray);
            } catch (IOException e) {
                e.printStackTrace();
                Log.e("sky", "mOutputStream报错:" + e.getMessage());
            }
        } else {
            Log.e("sky", "mOutputStream为空");
        }

    }

    public void close() {
        if (mSerialPort != null) {
            running = false;
            mSerialPort.tryClose();
            mSerialPort = null;
            observers.clear();
        }
    }

    public byte hexToByte(String arg) {
        int val = Integer.valueOf(arg, 16).intValue();
        byte c = (byte) (val & 0xff);
        return c;
    }

    @Override
    public void registerObserver(Data485Observer observer) {
        observers.add(observer);
    }

    @Override
    public void removeObserver(Data485Observer observer) {
        observers.remove(observer);
    }

    @Override
    public void notifyObservers(String data) {
        isFirstFrame = false;
        for (Data485Observer observer : observers) {
            observer.getMessage(data);
        }
        total.delete(0, total.length());
    }

    public void startFresh() {
        if (task != null) {
            task.cancel();
        }
        if (timer != null) {
            timer.cancel();
        }
        timer = new Timer();
        task = new TimerTask() {
            @Override
            public void run() {
                try {
                    Thread.sleep(100);
                    GetWayController.getInstance().findAllAirConditionOnlineState();
                    Thread.sleep(100);
                    GetWayController.getInstance().getAllAirConditionParamete();
//                    Thread.sleep(500);
//                    GetWayController.getInstance().getAllAirConditionParamete();
//                    Thread.sleep(300);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
        };
        timer.schedule(task, 0, cacheTime);
    }

    public void stopFresh() {
        if (task != null) {
            task.cancel();
        }
        if (timer != null) {
            timer.cancel();
        }
        commandFinsh=true;
        totalSize=0;
        total = new StringBuffer();
    }

    TimerTask task = new TimerTask() {
        @Override
        public void run() {

        }
    };
}
