package com.midea.light.device.explore.controller.control485.controller;

import android.util.Log;

import com.google.gson.Gson;
import com.midea.light.RxBus;
import com.midea.light.bean.Update485DeviceBean;
import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.deviceModel.FloorHotModel;
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent;
import com.midea.light.device.explore.controller.control485.util.SumUtil;
import com.midea.light.gateway.GateWayUtils;

import java.util.ArrayList;
import java.util.List;

import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.ALL_FLOOR_HOT_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.COMMAND_FLOOR_HOT_FANG_DONG_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.COMMAND_FLOOR_HOT_ON_OFF_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.COMMAND_FLOOR_HOT_TEMP_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_CLOSE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_FANG_DONG_CLOSE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_FANG_DONG_OPEN;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_OFF_LINE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_ON_LINE;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_OPEN;
import static com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr.FLOOR_HOT_QUERY_CODE;


public class FloorHotController implements Data485Observer {

   public List<FloorHotModel>FloorHotList=new ArrayList<>();

   public List<FloorHotModel> TempFloorHotList=new ArrayList<>();

   public static FloorHotController Instance = new FloorHotController();

   public static FloorHotController getInstance() {
      return Instance;
   }

   public void open(FloorHotModel device){
      controlDataCombination(device,COMMAND_FLOOR_HOT_ON_OFF_CODE.data,"01");
   }

   public void close(FloorHotModel device){
      controlDataCombination(device,COMMAND_FLOOR_HOT_ON_OFF_CODE.data,"00");
   }

   public void setTemp(FloorHotModel device ,String temp){
      controlDataCombination(device,COMMAND_FLOOR_HOT_TEMP_CODE.data,temp);
   }

   public void setFrostProtectionOn(FloorHotModel device){
      controlDataCombination(device,COMMAND_FLOOR_HOT_FANG_DONG_CODE.data,"01");
   }

   public void setFrostProtectionOff(FloorHotModel device){
      controlDataCombination(device,COMMAND_FLOOR_HOT_FANG_DONG_CODE.data,"00");
   }

   @Override
   public void getMessage(String data) {
      String[] arrayData=data.split(" ");
      if(arrayData[1].equals(FLOOR_HOT_QUERY_CODE.data)&&arrayData[2].equals(ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到地暖数量
         FloorHotList.clear();
         for (int i = 0; i <num ; i++) {
            FloorHotModel device=new FloorHotModel();
            device.setOutSideAddress(arrayData[4+(i*3)]);
            device.setInSideAddress(arrayData[5+(i*3)]);
            if(arrayData[6+(i*3)].equals(FLOOR_HOT_ON_LINE.data)){
               device.setOnlineState(FLOOR_HOT_ON_LINE.data);
            }else{
               device.setOnlineState(FLOOR_HOT_OFF_LINE.data);
            }
            FloorHotList.add(device);
         }
      }else if(arrayData[1].equals(FLOOR_HOT_QUERY_CODE.data)&&arrayData[2].equals(ALL_FLOOR_HOT_QUERY_PARELETE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到地暖数量
         for (int i = 0; i <num ; i++) {
            for (int j = 0; j <FloorHotList.size() ; j++) {
               String querAddr=arrayData[4+(i*10)]+arrayData[5+(i*10)];
               String deviceAddr=FloorHotList.get(j).getOutSideAddress()+FloorHotList.get(j).getInSideAddress();
               if(querAddr.equals(deviceAddr)){
                  if(arrayData[6+(i*10)].equals(FLOOR_HOT_OPEN.data)){
                     FloorHotList.get(j).setOnOff(FLOOR_HOT_OPEN.data);
                  }else{
                     FloorHotList.get(j).setOnOff(FLOOR_HOT_CLOSE.data);
                  }
                  FloorHotList.get(j).setTemperature(arrayData[7+(i*10)]);
                  FloorHotList.get(j).setCurrTemperature(arrayData[10+(i*10)]);
                  FloorHotList.get(j).setErrorCode(arrayData[11+(i*10)]);
                  if(arrayData[12+(i*10)].equals(FLOOR_HOT_FANG_DONG_OPEN.data)){
                     FloorHotList.get(j).setFrostProtection(FLOOR_HOT_FANG_DONG_OPEN.data);
                  }else{
                     FloorHotList.get(j).setFrostProtection(FLOOR_HOT_FANG_DONG_CLOSE.data);
                  }
               }
            }
         }
         //判断是否有数据变化,有数据变化就找出来
         for (int i = 0; i <TempFloorHotList.size() ; i++) {
            for (int j = 0; j <FloorHotList.size() ; j++) {
               String querAddr=TempFloorHotList.get(i).getOutSideAddress()+TempFloorHotList.get(i).getInSideAddress();
               String deviceAddr=FloorHotList.get(j).getOutSideAddress()+FloorHotList.get(j).getInSideAddress();
               if(querAddr.equals(deviceAddr)){
                  String TempDeviceStr=new Gson().toJson(TempFloorHotList.get(i));
                  String DeviceStr=new Gson().toJson(FloorHotList.get(j));
                  if(!TempDeviceStr.equals(DeviceStr)){//json数据不相等说明数据有变化
                     if(arrayData[6+(i*10)].equals(FLOOR_HOT_OPEN.data)){
                        FloorHotList.get(j).setOnOff(FLOOR_HOT_OPEN.data);
                     }else{
                        FloorHotList.get(j).setOnOff(FLOOR_HOT_CLOSE.data);
                     }
                     FloorHotList.get(j).setTemperature(arrayData[7+(i*10)]);
                     FloorHotList.get(j).setCurrTemperature(arrayData[10+(i*10)]);
                     FloorHotList.get(j).setErrorCode(arrayData[11+(i*10)]);
                     if(arrayData[12+(i*10)].equals(FLOOR_HOT_FANG_DONG_OPEN.data)){
                        FloorHotList.get(j).setFrostProtection(FLOOR_HOT_FANG_DONG_OPEN.data);
                     }else{
                        FloorHotList.get(j).setFrostProtection(FLOOR_HOT_FANG_DONG_CLOSE.data);
                     }
                     //有数据变化就发event
                     Log.e("sky","数据有变化");
                     RxBus.getInstance().post(new FloorHotChangeEvent().setFloorHotModel(FloorHotList.get(j)));
                     ArrayList<Update485DeviceBean.PLC.AttributeUpdate> deviceList=new ArrayList<>();
                     Update485DeviceBean.PLC.AttributeUpdate Attribute=new Update485DeviceBean.PLC.AttributeUpdate();
                     Update485DeviceBean.PLC.AttributeUpdate.Event event=new Update485DeviceBean.PLC.AttributeUpdate.Event();
                     event.setOnOff(Integer.parseInt(FloorHotList.get(j).getOnOff()));
                     event.setCurrTemp(Integer.parseInt(FloorHotList.get(j).getCurrTemperature(),16));
                     event.setTargetTemp(Integer.parseInt(FloorHotList.get(j).getTemperature(),16));
                     event.setFrostProtection(Integer.parseInt(FloorHotList.get(j).getFrostProtection()));
                     Attribute.setAddr(FloorHotList.get(j).getOutSideAddress()+FloorHotList.get(j).getInSideAddress());
                     Attribute.setModelId("zhonghong.heat.001");
                     Attribute.setEvent(event);
                     deviceList.add(Attribute);
                     GateWayUtils.update485Device(deviceList);
                  }
               }
            }
         }
      }
   }

   private void controlDataCombination(FloorHotModel device ,String commandCode,String data){
      StringBuffer sb = new StringBuffer();
      sb.append("01");
      sb.append(" ");
      sb.append(commandCode);
      sb.append(" ");
      sb.append(data);
      sb.append(" ");
      sb.append("01");
      sb.append(" ");
      sb.append(device.getOutSideAddress());
      sb.append(" ");
      sb.append(device.getInSideAddress());
      sb.append(" ");
      sb.append(SumUtil.sum(sb.toString()));
      ControlManager.getInstance().write(sb.toString());
   }
}
