package com.midea.light.device.explore.controller.control485;

import android.serialport.SerialPort;
import android.util.Log;

import com.midea.light.RxBus;
import com.midea.light.bean.OnlineState485Bean;
import com.midea.light.device.explore.controller.control485.controller.AirConditionController;
import com.midea.light.device.explore.controller.control485.controller.FloorHotController;
import com.midea.light.device.explore.controller.control485.controller.FreshAirController;
import com.midea.light.device.explore.controller.control485.controller.GetWayController;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Subject;
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FreshAirChangeEvent;
import com.midea.light.gateway.GateWayUtils;

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

public class ControlManager implements Data485Subject {

    private SerialPort mSerialPort;
    private InputStream mInputStream;
    private OutputStream mOutputStream;
    private static final int BAUD_RATE = 9600;
    private boolean running = true, isFirstFrame = false, commandFinish = true, resetFlag = true;
    private StringBuffer total = new StringBuffer();
    private String[] commandStrArry;
    private int totalSize = 0;
    private long read0Times = 0;
    private static List<Data485Observer> observers = new ArrayList<>();
    private byte[] buffer = new byte[1024];
    private Timer timer;
    private Integer cacheTime = 2;
    private ExecutorService service, readService;


    public static ControlManager Instance = new ControlManager();

    public static ControlManager getInstance() {
        return Instance;
    }

    public static void regestOber() {
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
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        startReadRunnable();
    }

    BlockingQueue<String> queue = new LinkedBlockingQueue<>();
    boolean firstIn = true;
    long firstInTime = 0;

    public void write(String str) {
        //生产者生产数据
        queue.offer(str);
//        Log.e("sky", "放进去的数据:" + str);
        if (firstIn) {
            firstInTime = System.currentTimeMillis();
            firstIn = false;
            startConsumer();
        }
        if (System.currentTimeMillis() - firstInTime > 10000) {//10秒内没有任何设备就停止刷新查找设备
            if (AirConditionController.getInstance().AirConditionList.size() == 0 && FreshAirController.getInstance().FreshAirList.size() == 0 && FloorHotController.getInstance().FloorHotList.size() == 0) {
                queue.clear();
                stopFresh();
                running = false;
            }
        }
    }

    public void clearFlashCommand() {
        queue.clear();
        commandFinish = true;
        totalSize = 0;
        total = new StringBuffer();
    }

    private void startReadRunnable() {
        if (readService != null) {
            readService.shutdownNow();
        }
        readService = Executors.newCachedThreadPool();
        Reader reader = new Reader();
        readService.execute(reader);
    }

    private void startConsumer() {
        if (service != null) {
            service.shutdownNow();
        }
        service = Executors.newCachedThreadPool();
        Consumer consumer = new Consumer(queue);
        service.execute(consumer);
    }

    public class Reader implements Runnable {

        public void run() {
            while (running) {
                if (mInputStream != null) {
                    try {
                        //阻塞判断,如果超过读取100次还没数据就重新写新的数据
                        int size = 0;
                        if (mInputStream.available() > 0) {
                            size = mInputStream.read(buffer);
                            read0Times = 0;
                            resetFlag=true;
                        } else {
                            read0Times++;
//                            Log.e("sky", "1111xx的量:" + read0Times);
                            if (read0Times == 200) {
                                read0Times = 0;
//                                commandReset();
                            }
                        }

                        if (size > 0) {
                            read0Times = 0;
                            resetFlag=true;
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
                    throw new RuntimeException(e);
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
//                      Log.e("sky", "拿到要执行的数据:"+str);
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
        mInputStream = mSerialPort.getInputStream();
        commandFinish = true;
        totalSize = 0;
        total = new StringBuffer();
        queue.clear();
//        Log.e("sky", "到了阈值resetFlag:"+resetFlag);
        //整个网关断电,全部设备离线上报
        if(resetFlag==true){
            Log.e("sky", "485网关断开连接所有设备上报离线");
            resetFlag=false;
            upDataAllDeviceOffline();
        }

    }

    private void upDataAllDeviceOffline() {
        if(AirConditionController.getInstance().AirConditionList.size()>0){
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit=new ArrayList<>();
            for (int i = 0; i <AirConditionController.getInstance().AirConditionList.size() ; i++) {
                AirConditionController.getInstance().AirConditionList.get(i).setOnlineState("0");
                OnlineState485Bean.PLC.OnlineState state=new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(0);
                String address=AirConditionController.getInstance().AirConditionList.get(i).getOutSideAddress()+AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.cac.002");
                diffStatelsit.add(state);
                RxBus.getInstance().post(new AirConditionChangeEvent().setAirConditionModel(AirConditionController.getInstance().AirConditionList.get(i)));
            }
//            Log.e("sky","空调全部离线上报:"+ GsonUtils.stringify(diffStatelsit));
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }

        if(FloorHotController.getInstance().FloorHotList.size()>0){
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit=new ArrayList<>();
            for (int i = 0; i <FloorHotController.getInstance().FloorHotList.size() ; i++) {
                FloorHotController.getInstance().FloorHotList.get(i).setOnlineState("0");
                OnlineState485Bean.PLC.OnlineState state=new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(0);
                String address=FloorHotController.getInstance().FloorHotList.get(i).getOutSideAddress()+FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress();
                state.setAddr(address);
                state.setModelId("zhonghong.heat.001");
                diffStatelsit.add(state);
                RxBus.getInstance().post(new FloorHotChangeEvent().setFloorHotModel(FloorHotController.getInstance().FloorHotList.get(i)));

            }
//            Log.e("sky","地暖全部离线上报:"+ GsonUtils.stringify(diffStatelsit));
            GateWayUtils.updateOnlineState485(diffStatelsit);
        }

        if(FreshAirController.getInstance().FreshAirList.size()>0){
            ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit=new ArrayList<>();
            for (int i = 0; i <FreshAirController.getInstance().FreshAirList.size() ; i++) {
                FreshAirController.getInstance().FreshAirList.get(i).setOnlineState("0");
                OnlineState485Bean.PLC.OnlineState state=new OnlineState485Bean.PLC.OnlineState();
                state.setStatus(0);
                String address=FreshAirController.getInstance().FreshAirList.get(i).getOutSideAddress()+FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress();
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
                    Thread.sleep(2);
                    GetWayController.getInstance().findAllAirConditionOnlineState();
                    Thread.sleep(2);
                    GetWayController.getInstance().getAllAirConditionParamete();
                    Thread.sleep(2);
                    GetWayController.getInstance().findAllFreshAirOnlineState();
                    Thread.sleep(2);
                    GetWayController.getInstance().getAllFreshAirParamete();
                    Thread.sleep(2);
                    GetWayController.getInstance().findAllFloorHotOnlineState();
                    Thread.sleep(2);
                    GetWayController.getInstance().getAllFloorHotParamete();
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
        };
        timer.schedule(task, 0, cacheTime);
    }

    public void stopFresh() {
        if (timer != null) {
            timer.cancel();
        }
        if (task != null) {
            task.cancel();
        }
        commandFinish = true;
        totalSize = 0;
        total = new StringBuffer();
        queue.clear();
    }

    TimerTask task = new TimerTask() {
        @Override
        public void run() {

        }
    };


}
