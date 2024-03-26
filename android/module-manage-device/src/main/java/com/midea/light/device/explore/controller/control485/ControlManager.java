package com.midea.light.device.explore.controller.control485;

import android.os.Handler;
import android.serialport.SerialPort;
import android.util.Log;

import com.google.gson.JsonObject;
import com.midea.light.RxBus;
import com.midea.light.bean.OnlineState485Bean;
import com.midea.light.device.explore.controller.control485.controller.AirConditionController;
import com.midea.light.device.explore.controller.control485.controller.FloorHotController;
import com.midea.light.device.explore.controller.control485.controller.FreshAirController;
import com.midea.light.device.explore.controller.control485.controller.GetWayController;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Subject;
import com.midea.light.device.explore.controller.control485.deviceModel.AirConditionModel;
import com.midea.light.device.explore.controller.control485.deviceModel.FloorHotModel;
import com.midea.light.device.explore.controller.control485.deviceModel.FreshAirModel;
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FreshAirChangeEvent;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.thread.MainThread;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;

import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.AIR_CONDITION_QUERY_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ALL_AIR_CONDITION_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.ALL_FLOOR_HOT_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_QUERY_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.ALL_FRESH_AIR_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_QUERY_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_AIR_CONDITION_ONLINE_STATE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_AIR_CONDITION_PARAMETE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FLOOR_HOT_ONLINE_STATE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FLOOR_HOT_PARAMETE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FRESH_AIR_ONLINE_STATE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FRESH_AIR_PARAMETE;

public class ControlManager implements Data485Subject {

    private SerialPort mSerialPort;
    private InputStream mInputStream;
    private OutputStream mOutputStream;
    private static final int BAUD_RATE = 9600;
    public boolean running = true, isFirstFrame = false, commandFinish = true;
    private StringBuffer total = new StringBuffer();
    private String[] commandStrArry;
    private int totalSize = 0, resetTime = 0;
    private long read0Times = 0;
    private static List<Data485Observer> observers = new ArrayList<>();
    private byte[] buffer = new byte[1024];
    private Timer timer, heatBet;
    private Integer cacheTime = 700;
    private ExecutorService writeService, readService;


    public static ControlManager Instance = new ControlManager();

    public static ControlManager getInstance() {
        return Instance;
    }

    public void registeOber() {
        observers.add(GetWayController.getInstance());
        observers.add(AirConditionController.getInstance());
        observers.add(FreshAirController.getInstance());
        observers.add(FloorHotController.getInstance());
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
            startReadRunnable();
            startConsumerRunnable();
            startFresh();
            MainThread.run(() -> new Handler().postDelayed(() -> {
                int AirConditionNum=AirConditionController.getInstance().AirConditionList.size();
                int FreshAirNum=FreshAirController.getInstance().FreshAirList.size();
                int FloorHotNum=FloorHotController.getInstance().FloorHotList.size();
                if(AirConditionNum==0&&FreshAirNum==0&&FloorHotNum==0){
                    ControlManager.getInstance().stopFresh();
                }
            },180000));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    BlockingQueue<String> queue = new LinkedBlockingQueue<>(100);

    public void write(String str) {
        //生产者生产数据
        if (queue.contains(str)) {
            return;
        }
        queue.offer(str);
//        Log.e("sky", "放进去的数据:" + str);
    }

    public void clearFlashCommand() {
        List<String> removeList = new ArrayList<>();
        removeList.add(GET_ALL_AIR_CONDITION_ONLINE_STATE.data);
        removeList.add(GET_ALL_AIR_CONDITION_PARAMETE.data);
        removeList.add(GET_ALL_FRESH_AIR_ONLINE_STATE.data);
        removeList.add(GET_ALL_FRESH_AIR_PARAMETE.data);
        removeList.add(GET_ALL_FLOOR_HOT_ONLINE_STATE.data);
        removeList.add(GET_ALL_FLOOR_HOT_PARAMETE.data);
        queue.removeAll(removeList);
    }

    private void startReadRunnable() {
        if (readService != null) {
            readService.shutdownNow();
        }
        readService = Executors.newSingleThreadExecutor(r -> new Thread(r,"read485"));
    }

    private void startConsumerRunnable() {
        if (writeService != null) {
            writeService.shutdownNow();
        }
        writeService = Executors.newSingleThreadExecutor(r -> new Thread(r,"write485"));
    }

    public class Reader implements Runnable {
        StringBuffer sb = new StringBuffer();
        public void run() {
            while (running) {
                if (mInputStream != null) {
                    try {
                        //阻塞判断,如果超过读取100次还没数据就重新写新的数据
                        int size = 0;
                        if (mInputStream.available() > 0) {
                            size = mInputStream.read(buffer);
                            read0Times = 0;
                            resetTime = 0;
                        } else {
                            read0Times++;
//                            Log.e("sky", "InputStream不可用read0Times:" + read0Times + "----queue数量:" + queue.size());
                            if (read0Times == 10) {
                                commandReset();
                                if (resetTime == 100) {
                                    read0Times = 0;
                                    resetTime = 0;
                                    upDataAllDeviceOffline();
                                }
                            }
                        }

                        if (size > 0) {
                            read0Times = 0;
                            resetTime = 0;
//                            Log.e("sky", "读到数据量:" + size);
//                                //判断请求指令,根据请求指令来判断是否数据完整
                            if (isFirstFrame) {
                                if (commandStrArry[1].equals(AIR_CONDITION_QUERY_CODE.data) && commandStrArry[2].equals(ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE.data)) {
                                    byte b = buffer[3];
                                    int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到空调数量
                                    totalSize = num * 3 + 5;
//                                        Log.e("sky", "数量需要数据量:" + totalSize);
                                } else if (commandStrArry[1].equals(AIR_CONDITION_QUERY_CODE.data) && commandStrArry[2].equals(ALL_AIR_CONDITION_QUERY_PARELETE_CODE.data)) {
                                    byte b = buffer[3];
                                    int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到空调数量
                                    totalSize = num * 10 + 5;
//                                        Log.e("sky", "属性需要数据量:" + totalSize);
                                } else if (commandStrArry[1].equals(FRESH_AIR_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE.data)) {
                                    byte b = buffer[3];
                                    int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到新风数量
                                    totalSize = num * 3 + 5;
//                                        Log.e("sky", "需要数据量:" + totalSize);
                                } else if (commandStrArry[1].equals(FRESH_AIR_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FRESH_AIR_QUERY_PARELETE_CODE.data)) {
                                    byte b = buffer[3];
                                    int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到新风数量
                                    totalSize = num * 10 + 5;
//                                        Log.e("sky", "需要数据量:" + totalSize);
                                } else if (commandStrArry[1].equals(FLOOR_HOT_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE.data)) {
                                    byte b = buffer[3];
                                    int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到地暖数量
                                    totalSize = num * 3 + 5;
//                                        Log.e("sky", "需要数据量:" + totalSize);
                                } else if (commandStrArry[1].equals(FLOOR_HOT_QUERY_CODE.data) && commandStrArry[2].equals(ALL_FLOOR_HOT_QUERY_PARELETE_CODE.data)) {
                                    byte b = buffer[3];
                                    int num = Integer.parseInt(Integer.toHexString(b & 0xFF).toUpperCase(), 16);//num为拿到地暖数量
                                    totalSize = num * 10 + 5;
//                                        Log.e("sky", "需要数据量:" + totalSize);
                                } else {
                                    totalSize = 7;
                                }
                                isFirstFrame = false;
                            }
                            sb.setLength(0);
                            for (int i = 0; i < size; i++) {
                                byte b = buffer[i];
                                if (Integer.toHexString(b & 0xFF).length() == 1) {
                                    sb.append("0").append(Integer.toHexString(b & 0xFF).toUpperCase());
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
//                                Log.e("sky", "完整数据:" + total);
                                notifyObservers(total.toString());
                                Thread.sleep(20);
                                commandFinish = true;
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                        Log.e("sky", "mInputStream报错:" + e.getMessage());

                    } catch (InterruptedException e) {
                    }

                } else {
                    Log.e("sky", "mInputStream为空");
                }
                try {
                    Thread.sleep(30);
                } catch (InterruptedException e) {

                }

            }

        }
    }

    public class Consumer implements Runnable {

        private BlockingQueue<String> queue;
        List<Byte> data = new ArrayList<>();

        //构造函数
        public Consumer(BlockingQueue<String> queue) {
            this.queue = queue;
        }

        public void run() {
            while (running) {
                //消费者消费数据,消费结束的标志是commandFinish为true
                if (commandFinish == true) {
                    String str = queue.poll();
                    isFirstFrame = true;
                    commandFinish = false;
                    if (null != str) {
//                      Log.e("sky", "拿到要执行的数据:"+str+"---queue大小:"+queue.size());
                        commandStrArry = str.split(" ");
                        if (mOutputStream != null) {
                            data.clear();
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
                }

            }
        }
    }

    private void commandReset() {
//        mInputStream = mSerialPort.getInputStream();
        commandFinish = true;
        totalSize = 0;
        total = new StringBuffer();
        resetTime++;
        read0Times = 0;
//        Log.e("sky", "离线判断次数:" + resetTime);
    }


    private void upDataAllDeviceOffline() {
        if (AirConditionController.getInstance().AirConditionList.size() > 0) {
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit = new ArrayList<>();
            for (int i = 0; i < AirConditionController.getInstance().AirConditionList.size(); i++) {
                AirConditionController.getInstance().AirConditionList.get(i).setOnlineState("0");
                OnlineState485Bean.PLC.OnlineState state = new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(0);
                String address = AirConditionController.getInstance().AirConditionList.get(i).getOutSideAddress() + AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.cac.002");
                diffStatelsit.add(state);
                RxBus.getInstance().post(new AirConditionChangeEvent().setAirConditionModel(AirConditionController.getInstance().AirConditionList.get(i)));
            }
//            Log.e("sky","空调全部离线上报:"+ GsonUtils.stringify(diffStatelsit));
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }

        if (FloorHotController.getInstance().FloorHotList.size() > 0) {
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit = new ArrayList<>();
            for (int i = 0; i < FloorHotController.getInstance().FloorHotList.size(); i++) {
                FloorHotController.getInstance().FloorHotList.get(i).setOnlineState("0");
                OnlineState485Bean.PLC.OnlineState state = new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(0);
                String address = FloorHotController.getInstance().FloorHotList.get(i).getOutSideAddress() + FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.heat.001");
                diffStatelsit.add(state);
                RxBus.getInstance().post(new FloorHotChangeEvent().setFloorHotModel(FloorHotController.getInstance().FloorHotList.get(i)));

            }
//            Log.e("sky","地暖全部离线上报:"+ GsonUtils.stringify(diffStatelsit));
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }

        if (FreshAirController.getInstance().FreshAirList.size() > 0) {
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit = new ArrayList<>();
            for (int i = 0; i < FreshAirController.getInstance().FreshAirList.size(); i++) {
                FreshAirController.getInstance().FreshAirList.get(i).setOnlineState("0");
                OnlineState485Bean.PLC.OnlineState state = new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(0);
                String address = FreshAirController.getInstance().FreshAirList.get(i).getOutSideAddress() + FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.air.001");
                diffStatelsit.add(state);
                RxBus.getInstance().post(new FreshAirChangeEvent().setFreshAirModel(FreshAirController.getInstance().FreshAirList.get(i)));

            }
//            Log.e("sky","新风全部离线上报:"+ GsonUtils.stringify(diffStatelsit));
            GateWayUtils.updateOnlineState485(diffStatelsit);
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
        if (observers.size() == 4) {
            for (Data485Observer observer : observers) {
                observer.getMessage(data);
            }
        }
        total.delete(0, total.length());
    }

    public void findDeviceControl(String nodeId, String uri, String value) {
        String add = nodeId.split("-")[1].replaceAll("\"","");
        for (AirConditionModel device : AirConditionController.getInstance().AirConditionList) {
            String addr = device.getOutSideAddress() + device.getInSideAddress();
            if (add.equals(addr)) {
                if (uri.contains("subDeviceControl")) {
                    if (value.equals("1")) {
                        AirConditionController.getInstance().open(device);
                    } else {
                        AirConditionController.getInstance().close(device);
                    }
                } else if (uri.contains("subWindSpeedControl")) {
                    String WindSpeed = Integer.toHexString(Integer.parseInt(value));
                    if (WindSpeed.length() == 1) {
                        WindSpeed = "0" + WindSpeed;
                    }
                    AirConditionController.getInstance().setWindSpeedLevl(device, WindSpeed);
                } else if (uri.contains("subTargetTempControl")) {
                    String TargetTemp = Integer.toHexString(Integer.parseInt(value));
                    AirConditionController.getInstance().setTemp(device, TargetTemp);
                } else if (uri.contains("airOperationModeControl")) {
                    String Mode = Integer.toHexString(Integer.parseInt(value));
                    if (Mode.length() == 1) {
                        Mode = "0" + Mode;
                    }
                    AirConditionController.getInstance().setModel(device, Mode);
                }
            }
        }

        for (FreshAirModel device : FreshAirController.getInstance().FreshAirList) {
            String addr = device.getOutSideAddress() + device.getInSideAddress();
            if (add.equals(addr)) {
                if (uri.contains("subDeviceControl")) {
                    if (value.equals("1")) {
                        FreshAirController.getInstance().open(device);
                    } else {
                        FreshAirController.getInstance().close(device);
                    }
                } else if (uri.contains("subWindSpeedControl")) {
                    String WindSpeed = Integer.toHexString(Integer.parseInt(value));
                    if (WindSpeed.length() == 1) {
                        WindSpeed = "0" + WindSpeed;
                    }
                    FreshAirController.getInstance().setWindSpeedLevl(device, WindSpeed);
                }
            }
        }

        for (FloorHotModel device : FloorHotController.getInstance().FloorHotList) {
            String addr = device.getOutSideAddress() + device.getInSideAddress();
            if (add.equals(addr)) {
                if (uri.contains("subDeviceControl")) {
                    if (value.equals("1")) {
                        FloorHotController.getInstance().open(device);
                    } else {
                        FloorHotController.getInstance().close(device);
                    }
                } else if (uri.contains("subTargetTempControl")) {
                    String TargetTemp = Integer.toHexString(Integer.parseInt(value));
                    if (TargetTemp.length() == 1) {
                        TargetTemp = "0" + TargetTemp;
                    }
                    FloorHotController.getInstance().setTemp(device, TargetTemp);
                }
            }
        }

    }


    public JsonObject getLocal485DeviceByID(String nodeId) {

        String add = nodeId.split("-")[1];
        for (AirConditionModel device : AirConditionController.getInstance().AirConditionList) {
            String addr = device.getOutSideAddress() + device.getInSideAddress();
            if (add.equals(addr)) {
                JsonObject hashMap = new JsonObject();
                hashMap.addProperty("modelId", "zhonghong.cac.002");
                hashMap.addProperty("address", device.getOutSideAddress() + device.getInSideAddress());
                hashMap.addProperty("mode", Integer.parseInt(device.getWorkModel(), 16));
                hashMap.addProperty("windSpeed", Integer.parseInt(device.getWindSpeed(),16));
                hashMap.addProperty("targetTemperature", Integer.parseInt(device.getTemperature(),16));
                hashMap.addProperty("power",  Integer.parseInt(device.getOnOff(),16));
                hashMap.addProperty("onLineStatus", Integer.parseInt(device.getOnlineState(),16));
                hashMap.addProperty("currTemperature", Integer.parseInt(device.getCurrTemperature(),16));
                return hashMap;
            }
        }

        for (FreshAirModel device : FreshAirController.getInstance().FreshAirList) {
            String addr = device.getOutSideAddress() + device.getInSideAddress();
            if (add.equals(addr)) {
                JsonObject hashMap = new JsonObject();
                hashMap.addProperty("modelId", "zhonghong.air.001");
                hashMap.addProperty("address", device.getOutSideAddress() + device.getInSideAddress());
                hashMap.addProperty("mode", Integer.parseInt(device.getWorkModel(), 16));
                hashMap.addProperty("windSpeed", Integer.parseInt(device.getWindSpeed(),16));
                hashMap.addProperty("targetTemperature", "");
                hashMap.addProperty("power",  Integer.parseInt(device.getOnOff(),16));
                hashMap.addProperty("onLineStatus", Integer.parseInt(device.getOnlineState(),16));
                hashMap.addProperty("currTemperature", "");
                return hashMap;
            }
        }

        for (FloorHotModel device : FloorHotController.getInstance().FloorHotList) {
            String addr = device.getOutSideAddress() + device.getInSideAddress();
            if (add.equals(addr)) {
                JsonObject hashMap = new JsonObject();
                hashMap.addProperty("modelId", "zhonghong.heat.001");
                hashMap.addProperty("address", device.getOutSideAddress() + device.getInSideAddress());
                hashMap.addProperty("mode", "");
                hashMap.addProperty("windSpeed", "");
                hashMap.addProperty("targetTemperature", Integer.parseInt(device.getTemperature(),16));
                hashMap.addProperty("power",  Integer.parseInt(device.getOnOff(),16));
                hashMap.addProperty("onLineStatus", Integer.parseInt(device.getOnlineState(),16));
                hashMap.addProperty("currTemperature", Integer.parseInt(device.getCurrTemperature(),16));
                return hashMap;
            }
        }

        return null;

    }

    public JsonObject getLocal485DeviceByID(String nodeId, String type) {

        String add = nodeId.split("-")[1];
        switch (type) {
            case "3017":
                for (AirConditionModel device : AirConditionController.getInstance().AirConditionList) {
                    String addr = device.getOutSideAddress() + device.getInSideAddress();
                    if (add.equals(addr)) {
                        JsonObject hashMap = new JsonObject();
                        hashMap.addProperty("modelId", "zhonghong.cac.002");
                        hashMap.addProperty("address", device.getOutSideAddress() + device.getInSideAddress());
                        hashMap.addProperty("mode", Integer.parseInt(device.getWorkModel(), 16));
                        hashMap.addProperty("windSpeed", Integer.parseInt(device.getWindSpeed(),16));
                        hashMap.addProperty("targetTemperature", Integer.parseInt(device.getTemperature(),16));
                        hashMap.addProperty("power",  Integer.parseInt(device.getOnOff(),16));
                        hashMap.addProperty("onLineStatus", Integer.parseInt(device.getOnlineState(),16));
                        hashMap.addProperty("currTemperature", Integer.parseInt(device.getCurrTemperature(),16));
                        return hashMap;
                    }
                }
                break;
            case "3018":
                for (FreshAirModel device : FreshAirController.getInstance().FreshAirList) {
                    String addr = device.getOutSideAddress() + device.getInSideAddress();
                    if (add.equals(addr)) {
                        JsonObject hashMap = new JsonObject();
                        hashMap.addProperty("modelId", "zhonghong.air.001");
                        hashMap.addProperty("address", device.getOutSideAddress() + device.getInSideAddress());
                        hashMap.addProperty("mode", Integer.parseInt(device.getWorkModel(), 16));
                        hashMap.addProperty("windSpeed", Integer.parseInt(device.getWindSpeed(),16));
                        hashMap.addProperty("targetTemperature", "");
                        hashMap.addProperty("power",  Integer.parseInt(device.getOnOff(),16));
                        hashMap.addProperty("onLineStatus", Integer.parseInt(device.getOnlineState(),16));
                        hashMap.addProperty("currTemperature", "");
                        return hashMap;
                    }
                }
                break;
            case "3019":
                for (FloorHotModel device : FloorHotController.getInstance().FloorHotList) {
                    String addr = device.getOutSideAddress() + device.getInSideAddress();
                    if (add.equals(addr)) {
                        JsonObject hashMap = new JsonObject();
                        hashMap.addProperty("modelId", "zhonghong.heat.001");
                        hashMap.addProperty("address", device.getOutSideAddress() + device.getInSideAddress());
                        hashMap.addProperty("mode", "");
                        hashMap.addProperty("windSpeed", "");
                        hashMap.addProperty("targetTemperature", Integer.parseInt(device.getTemperature(),16));
                        hashMap.addProperty("power",  Integer.parseInt(device.getOnOff(),16));
                        hashMap.addProperty("onLineStatus", Integer.parseInt(device.getOnlineState(),16));
                        hashMap.addProperty("currTemperature", Integer.parseInt(device.getCurrTemperature(),16));
                        return hashMap;
                    }
                }
                break;
        }
        return null;

    }


    private void upDataAllDeviceOnlineState() {
        if (AirConditionController.getInstance().AirConditionList.size() > 0) {
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit = new ArrayList<>();
            for (int i = 0; i < AirConditionController.getInstance().AirConditionList.size(); i++) {
                OnlineState485Bean.PLC.OnlineState state = new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(Integer.parseInt(AirConditionController.getInstance().AirConditionList.get(i).getOnlineState()));
                String address = AirConditionController.getInstance().AirConditionList.get(i).getOutSideAddress() + AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.cac.002");
                diffStatelsit.add(state);
//                RxBus.getInstance().post(new Device485OnlineChangeEvent(address,state.getStatus()));
            }
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }

        if (FloorHotController.getInstance().FloorHotList.size() > 0) {
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit = new ArrayList<>();
            for (int i = 0; i < FloorHotController.getInstance().FloorHotList.size(); i++) {
                OnlineState485Bean.PLC.OnlineState state = new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(Integer.parseInt(FloorHotController.getInstance().FloorHotList.get(i).getOnlineState()));
                String address = FloorHotController.getInstance().FloorHotList.get(i).getOutSideAddress() + FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.heat.001");
                diffStatelsit.add(state);
//                RxBus.getInstance().post(new Device485OnlineChangeEvent(address,state.getStatus()));
            }
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }

        if (FreshAirController.getInstance().FreshAirList.size() > 0) {
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit = new ArrayList<>();
            for (int i = 0; i < FreshAirController.getInstance().FreshAirList.size(); i++) {
                OnlineState485Bean.PLC.OnlineState state = new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(Integer.parseInt(FreshAirController.getInstance().FreshAirList.get(i).getOnlineState()));
                String address = FreshAirController.getInstance().FreshAirList.get(i).getOutSideAddress() + FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.air.001");
                diffStatelsit.add(state);
//                RxBus.getInstance().post(new Device485OnlineChangeEvent(address,state.getStatus()));

            }
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }
    }

    public void startFresh() {
        running=true;
        if (timer != null) {
            timer.cancel();
        }
        if(readService!=null){
            readService.shutdownNow();
            Reader reader = new Reader();
            readService = Executors.newSingleThreadExecutor(r -> new Thread(r,"read485"));
            readService.submit(reader);
        }
        if(writeService!=null){
            writeService.shutdownNow();
            Consumer consumer = new Consumer(queue);
            writeService = Executors.newSingleThreadExecutor(r -> new Thread(r,"write485"));
            writeService.submit(consumer);
        }
        timer = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                GetWayController.getInstance().getAllAirConditionParamete();
                GetWayController.getInstance().findAllAirConditionOnlineState();
                GetWayController.getInstance().getAllFreshAirParamete();
                GetWayController.getInstance().findAllFreshAirOnlineState();
                GetWayController.getInstance().getAllFloorHotParamete();
                GetWayController.getInstance().findAllFloorHotOnlineState();
            }
        };
        timer.schedule(task, 0, cacheTime);

        if (heatBet != null) {
            heatBet.cancel();
        }
        heatBet = new Timer();
        TimerTask heatBetTask = new TimerTask() {
            @Override
            public void run() {
                upDataAllDeviceOnlineState();
            }
        };
        heatBet.schedule(heatBetTask, 30000, 60000);
    }

    public void stopFresh() {
        running=false;
        if (timer != null) {
            timer.cancel();
        }
        if (heatBet != null) {
            heatBet.cancel();
        }
        commandFinish = true;
        totalSize = 0;
        total = new StringBuffer();
        queue.clear();
        if(writeService!=null){
            writeService.shutdownNow();
        }
        if(readService!=null){
            readService.shutdownNow();
        }

    }



}
