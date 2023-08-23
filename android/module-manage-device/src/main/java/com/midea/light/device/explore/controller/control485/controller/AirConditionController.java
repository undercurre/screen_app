package com.midea.light.device.explore.controller.control485.controller;

import android.util.Log;

import com.google.gson.Gson;
import com.midea.light.RxBus;
import com.midea.light.bean.OnlineState485Bean;
import com.midea.light.bean.Update485DeviceBean;
import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.deviceModel.AirConditionModel;
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent;
import com.midea.light.device.explore.controller.control485.util.SumUtil;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.utils.GsonUtils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.AIR_CONDITION_QUERY_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ALL_AIR_CONDITION_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.CLOSE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.OFF_LINE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.ON_LINE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.OPEN;


public class AirConditionController implements Data485Observer {

   public List<AirConditionModel>AirConditionList=new ArrayList<>();

   public List<AirConditionModel> TempAirConditionList=new ArrayList<>();

   public static AirConditionController Instance = new AirConditionController();

   public static AirConditionController getInstance() {
      return Instance;
   }

   public void open(AirConditionModel device){
      controlDataCombination(device, AirConditionAgr.COMMAND_ON_OFF_CODE.data,"01");
   }

   public void close(AirConditionModel device){
      controlDataCombination(device,AirConditionAgr.COMMAND_ON_OFF_CODE.data,"00");
   }

   public void setTemp(AirConditionModel device ,String temp){
      controlDataCombination(device,AirConditionAgr.COMMAND_TEMP_CODE.data,temp);
   }

   public void setModel(AirConditionModel device ,String model){
      AirConditionAgr type = AirConditionAgr.parseWorkModel(model);
      controlDataCombination(device,AirConditionAgr.COMMAND_MODEL_CODE.data,type.data);
   }

   public void setWindSpeedLevl(AirConditionModel device ,String speed){
      AirConditionAgr speeds = AirConditionAgr.parseWindSpeed(speed);
      controlDataCombination(device,AirConditionAgr.COMMAND_WIND_SPEED_CODE.data,speeds.data);
   }

   @Override
   public void getMessage(String data) {
      String[] arrayData=data.split(" ");
      //判断是否离在线,同时判断是否有新增和删减
      if(arrayData[1].equals(AIR_CONDITION_QUERY_CODE.data)&&arrayData[2].equals(ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到空调数量
         TempAirConditionList.clear();
         /**
          * 1,找出所有拉取到的设备
          * 2,通过拉取到的设备地址判断是否存在这个设备
          * 3,判断地址是新的就要新增这个设备
          * 4,判断地址在所有拉取到的设备列表里面没有就列出需要删除的地址
          * 5,通过列出的需要删除的地址,删除对应地址设备
          * 6,判断在线状态是否有变更,如果有变更就要通知出去
          * */

         List<AirConditionModel>FindList=new ArrayList<>();//找到的设备列表
         List<String>FindAddressList=new ArrayList<>();//找到的设备地址列表
         List<String>HasAddressList=new ArrayList<>();//已经有的设备地址列表
         List<String>NeedAddressList=new ArrayList<>();//需要添加的设备地址列表
         List<String>NeedDeleteAddressList=new ArrayList<>();//需要删除的设备地址列表
         ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit=new ArrayList<>();

         //保存拉取到的设备以及设备地址到列表
         for (int i = 0; i <num ; i++) {
            AirConditionModel AirCondition=new AirConditionModel();
            AirCondition.setOutSideAddress(arrayData[4+(i*3)]);
            AirCondition.setInSideAddress(arrayData[5+(i*3)]);
            if(arrayData[6+(i*3)].equals(ON_LINE.data)){
               AirCondition.setOnlineState(ON_LINE.data);
            }else{
               AirCondition.setOnlineState(OFF_LINE.data);
            }
            FindAddressList.add(AirCondition.getOutSideAddress()+AirCondition.getInSideAddress());
            FindList.add(AirCondition);
         }

         //保存已经有的设备地址到列表
         for (int j = 0; j <AirConditionList.size() ; j++) {
            String address=AirConditionList.get(j).getOutSideAddress()+AirConditionList.get(j).getInSideAddress();
            HasAddressList.add(address);
         }

         //保存需要新增的设备地址到列表
         for (int i = 0; i <FindAddressList.size() ; i++) {
            if(!HasAddressList.contains(FindAddressList.get(i))){
               NeedAddressList.add(FindAddressList.get(i));
            }
         }

         //保存需要删除设备地址到列表
         for (int i = 0; i <HasAddressList.size() ; i++) {
            if(!FindAddressList.contains(HasAddressList.get(i))){
               NeedDeleteAddressList.add(HasAddressList.get(i));
            }
         }

         //通过需要新增地址列表,从拉取到的设备中添加需要添加的设备
         for (int i = 0; i <FindList.size() ; i++) {
            for (int j = 0; j <NeedAddressList.size() ; j++) {
               String address=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               if(NeedAddressList.get(j).equals(address)){
                  AirConditionList.add(FindList.get(i));
               }
            }
         }

         //通过需要删除的地址列表,从已经保存的设备列表中删除需要删除的设备
         for (int i = 0; i <NeedDeleteAddressList.size() ; i++) {
            deleteDevice(AirConditionList,NeedDeleteAddressList.get(i));
         }

         //判断离在线状态是否有变化
         for (int i = 0; i <FindList.size() ; i++) {
            for (int j = 0; j <AirConditionList.size() ; j++) {
               String findAddress=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               String address=AirConditionList.get(j).getOutSideAddress()+AirConditionList.get(j).getInSideAddress();
               if(address.equals(findAddress)){
                  if(!AirConditionList.get(j).getOnlineState().equals(FindList.get(i).getOnlineState())){
                  //在线状态不一致,就通知出去
                     OnlineState485Bean.PLC.OnlineState state=new OnlineState485Bean.PLC.OnlineState();
                     if(FindList.get(i).getOnlineState().equals(ON_LINE.data)){
                        state.setStatus(1);
                     }else{
                        state.setStatus(0);
                     }
                     state.setAddr(address);
                     state.setModelId("zhonghong.cac.002");
                     diffStatelsit.add(state);
                  }
               }
            }
         }
         if(diffStatelsit.size()>0){
            GateWayUtils.updateOnlineState485(diffStatelsit);
         }
         //将在线状态同步过来
         for (int i = 0; i <FindList.size() ; i++) {
            for (int j = 0; j <AirConditionList.size() ; j++) {
               String findAddress=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               String address=AirConditionList.get(j).getOutSideAddress()+AirConditionList.get(j).getInSideAddress();
               if(address.equals(findAddress)){
                  AirConditionList.get(j).setOnlineState(FindList.get(i).getOnlineState());
               }
            }
         }
         List<AirConditionModel> mAirConditionList = GsonUtils.fromJsonList((new Gson().toJson(AirConditionList)), AirConditionModel.class);
         TempAirConditionList.addAll(mAirConditionList);
         //判断属性变化
      }else if(arrayData[1].equals(AIR_CONDITION_QUERY_CODE.data)&&arrayData[2].equals(ALL_AIR_CONDITION_QUERY_PARELETE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到空调数量
         for (int i = 0; i <num ; i++) {
            for (int j = 0; j <TempAirConditionList.size() ; j++) {
               String querAddr=arrayData[4+(i*10)]+arrayData[5+(i*10)];
               String deviceAddr=TempAirConditionList.get(j).getOutSideAddress()+TempAirConditionList.get(j).getInSideAddress();
               if(querAddr.equals(deviceAddr)){
                  if(arrayData[6+(i*10)].equals(OPEN.data)){
                     TempAirConditionList.get(j).setOnOff(OPEN.data);
                  }else{
                     TempAirConditionList.get(j).setOnOff(CLOSE.data);
                  }
                  TempAirConditionList.get(j).setTemperature(arrayData[7+(i*10)]);
                  setWorkModel(TempAirConditionList.get(j),arrayData[8+(i*10)]);
                  setWindSpeed(TempAirConditionList.get(j),arrayData[9+(i*10)]);
                  TempAirConditionList.get(j).setCurrTemperature(arrayData[10+(i*10)]);
                  TempAirConditionList.get(j).setErrorCode(arrayData[11+(i*10)]);
               }
            }
         }
         //判断是否有数据变化,有数据变化就找出来
         for (int i = 0; i <TempAirConditionList.size() ; i++) {
            for (int j = 0; j <AirConditionList.size() ; j++) {
               String querAddr=TempAirConditionList.get(i).getOutSideAddress()+TempAirConditionList.get(i).getInSideAddress();
               String deviceAddr=AirConditionList.get(j).getOutSideAddress()+AirConditionList.get(j).getInSideAddress();
//               if(querAddr.equals("0101")){
//                  Log.e("sky","开关状态:"+TempAirConditionList.get(i).getOnOff());
//                  Log.e("sky","设定温度:"+Integer.parseInt(TempAirConditionList.get(i).getTemperature(),16));
//
//               }
               if(querAddr.equals(deviceAddr)){
                  String TempDeviceStr=new Gson().toJson(TempAirConditionList.get(i));
                  String DeviceStr=new Gson().toJson(AirConditionList.get(j));
                  if(!TempDeviceStr.equals(DeviceStr)){//json数据不相等说明数据有变化
                     if(arrayData[6+(i*10)].equals(OPEN.data)){
                        AirConditionList.get(j).setOnOff(OPEN.data);
                     }else{
                        AirConditionList.get(j).setOnOff(CLOSE.data);
                     }
                     AirConditionList.get(j).setTemperature(arrayData[7+(i*10)]);
                     setWorkModel(AirConditionList.get(j),arrayData[8+(i*10)]);
                     setWindSpeed(AirConditionList.get(j),arrayData[9+(i*10)]);
                     AirConditionList.get(j).setCurrTemperature(arrayData[10+(i*10)]);
                     AirConditionList.get(j).setErrorCode(arrayData[11+(i*10)]);
                     //有数据变化就发event
                     Log.e("sky","数据有变化");
                     RxBus.getInstance().post(new AirConditionChangeEvent().setAirConditionModel(AirConditionList.get(j)));
                     ArrayList<Update485DeviceBean.PLC.AttributeUpdate> deviceList=new ArrayList<>();
                     Update485DeviceBean.PLC.AttributeUpdate Attribute=new Update485DeviceBean.PLC.AttributeUpdate();
                     Update485DeviceBean.PLC.AttributeUpdate.Event event=new Update485DeviceBean.PLC.AttributeUpdate.Event();
                     event.setOnOff(Integer.parseInt(AirConditionList.get(j).getOnOff()));
                     event.setWindSpeed(Integer.parseInt(AirConditionList.get(j).getWindSpeed(),16));
                     event.setCurrTemp(Integer.parseInt(AirConditionList.get(j).getCurrTemperature(),16));
                     event.setTargetTemp(Integer.parseInt(AirConditionList.get(j).getTemperature(),16));
                     event.setOperationMode(Integer.parseInt(AirConditionList.get(j).getWorkModel(),16));
                     Attribute.setAddr(AirConditionList.get(j).getOutSideAddress()+AirConditionList.get(j).getInSideAddress());
                     Attribute.setModelId("zhonghong.cac.002");
                     Attribute.setEvent(event);
                     deviceList.add(Attribute);
                     GateWayUtils.update485Device(deviceList);

                  }
               }
            }
         }

      }
   }

   private void deleteDevice(List<AirConditionModel>AirConditionList,String deleteAddress){
      Iterator<AirConditionModel> iterator = AirConditionList.iterator();

      while (iterator.hasNext()) {
         AirConditionModel item = iterator.next();
         String address=item.getOutSideAddress()+item.getInSideAddress();
         if (address.equals(deleteAddress)) {
            iterator.remove();
         }
      }
   }

   private void setWindSpeed(AirConditionModel airConditionModel, String arrayDatum) {
      AirConditionAgr type = AirConditionAgr.parseWindSpeed(arrayDatum);
      airConditionModel.setWindSpeed(type.data);
   }

   private void setWorkModel(AirConditionModel airConditionModel, String arrayDatum) {
      AirConditionAgr type = AirConditionAgr.parseWorkModel(arrayDatum);
      airConditionModel.setWorkModel(type.data);
   }

   private void controlDataCombination(AirConditionModel device ,String commandCode,String data){
//      ControlManager.getInstance().stopFresh();
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
      sb.append(SumUtil.sum(sb.toString().toUpperCase()));
      ControlManager.getInstance().write(sb.toString());
//      ControlManager.getInstance().startFresh();

   }
}
