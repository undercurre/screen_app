package com.midea.light.device.explore.controller.control485.controller;

import com.google.gson.Gson;
import com.midea.light.RxBus;
import com.midea.light.bean.OnlineState485Bean;
import com.midea.light.bean.Update485DeviceBean;
import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.deviceModel.FloorHotModel;
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent;
import com.midea.light.device.explore.controller.control485.util.SumUtil;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.utils.GsonUtils;

import java.util.ArrayList;
import java.util.Iterator;
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
      //判断是否离在线,同时判断是否有新增和删减
      if(arrayData[1].equals(FLOOR_HOT_QUERY_CODE.data)&&arrayData[2].equals(ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到新风数量
         TempFloorHotList.clear();
         /**
          * 1,找出所有拉取到的设备
          * 2,通过拉取到的设备地址判断是否存在这个设备
          * 3,判断地址是新的就要新增这个设备
          * 4,判断地址在所有拉取到的设备列表里面没有就列出需要删除的地址
          * 5,通过列出的需要删除的地址,删除对应地址设备
          * 6,判断在线状态是否有变更,如果有变更就要通知出去
          * */

         List<FloorHotModel>FindList=new ArrayList<>();//找到的设备列表
         List<String>FindAddressList=new ArrayList<>();//找到的设备地址列表
         List<String>HasAddressList=new ArrayList<>();//已经有的设备地址列表
         List<String>NeedAddressList=new ArrayList<>();//需要添加的设备地址列表
         List<String>NeedDeleteAddressList=new ArrayList<>();//需要删除的设备地址列表
         ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit=new ArrayList<>();

         //保存拉取到的设备以及设备地址到列表
         for (int i = 0; i <num ; i++) {
            FloorHotModel FloorHot=new FloorHotModel();
            if(arrayData.length>(6+(i*3))){
               FloorHot.setOutSideAddress(arrayData[4+(i*3)]);
               FloorHot.setInSideAddress(arrayData[5+(i*3)]);
               if(arrayData[6+(i*3)].equals(FLOOR_HOT_ON_LINE.data)){
                  FloorHot.setOnlineState(FLOOR_HOT_ON_LINE.data);
               }else{
                  FloorHot.setOnlineState(FLOOR_HOT_OFF_LINE.data);
               }
               FindAddressList.add(FloorHot.getOutSideAddress()+FloorHot.getInSideAddress());
               FindList.add(FloorHot);
            }
         }

         //保存已经有的设备地址到列表
         for (int j = 0; j <FloorHotList.size() ; j++) {
            String address=FloorHotList.get(j).getOutSideAddress()+FloorHotList.get(j).getInSideAddress();
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
                  FloorHotList.add(FindList.get(i));
               }
            }
         }

         //通过需要删除的地址列表,从已经保存的设备列表中删除需要删除的设备
         for (int i = 0; i <NeedDeleteAddressList.size() ; i++) {
            deleteDevice(FloorHotList,NeedDeleteAddressList.get(i));
         }

         //判断离在线状态是否有变化
         for (int i = 0; i <FindList.size() ; i++) {
            for (int j = 0; j <FloorHotList.size() ; j++) {
               String findAddress=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               String address=FloorHotList.get(j).getOutSideAddress()+FloorHotList.get(j).getInSideAddress();
               if(address.equals(findAddress)){
                  if(!FloorHotList.get(j).getOnlineState().equals(FindList.get(i).getOnlineState())){
                     //在线状态不一致,就通知出去
                     OnlineState485Bean.PLC.OnlineState state=new OnlineState485Bean.PLC.OnlineState();
                     if(FindList.get(i).getOnlineState().equals(FLOOR_HOT_ON_LINE.data)){
                        state.setStatus(1);
                     }else{
                        state.setStatus(0);
                     }
                     state.setAddr(address);
                     state.setModelId("zhonghong.heat.001");
                     diffStatelsit.add(state);
                  }
               }
            }
         }
         if(diffStatelsit.size()>0){
            GateWayUtils.updateOnlineState485(diffStatelsit);
//            Log.e("sky","地暖在线状态上报:"+GsonUtils.stringify(diffStatelsit));
         }
         //将在线状态同步过来
         for (int i = 0; i <FindList.size() ; i++) {
            for (int j = 0; j <FloorHotList.size() ; j++) {
               String findAddress=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               String address=FloorHotList.get(j).getOutSideAddress()+FloorHotList.get(j).getInSideAddress();
               if(address.equals(findAddress)){
                  FloorHotList.get(j).setOnlineState(FindList.get(i).getOnlineState());
               }
            }
         }
         List<FloorHotModel> mFloorHotList = GsonUtils.fromJsonList((new Gson().toJson(FloorHotList)), FloorHotModel.class);
         TempFloorHotList.addAll(mFloorHotList);
         //判断属性变化
      }else if(arrayData[1].equals(FLOOR_HOT_QUERY_CODE.data)&&arrayData[2].equals(ALL_FLOOR_HOT_QUERY_PARELETE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到地暖数量
         for (int i = 0; i <num ; i++) {
            for (int j = 0; j <TempFloorHotList.size() ; j++) {
               String querAddr=arrayData[4+(i*10)]+arrayData[5+(i*10)];
               String deviceAddr=TempFloorHotList.get(j).getOutSideAddress()+TempFloorHotList.get(j).getInSideAddress();
               if(querAddr.equals(deviceAddr)){
                  if(arrayData.length>(12+(i*10))&&arrayData[6+(i*10)].equals(FLOOR_HOT_OPEN.data)){
                     TempFloorHotList.get(j).setOnOff(FLOOR_HOT_OPEN.data);
                  }else{
                     TempFloorHotList.get(j).setOnOff(FLOOR_HOT_CLOSE.data);
                  }
                  TempFloorHotList.get(j).setTemperature(arrayData[7+(i*10)]);
                  TempFloorHotList.get(j).setCurrTemperature(arrayData[10+(i*10)]);
                  TempFloorHotList.get(j).setErrorCode(arrayData[11+(i*10)]);
                  if(arrayData[12+(i*10)].equals(FLOOR_HOT_FANG_DONG_OPEN.data)){
                     TempFloorHotList.get(j).setFrostProtection(FLOOR_HOT_FANG_DONG_OPEN.data);
                  }else{
                     TempFloorHotList.get(j).setFrostProtection(FLOOR_HOT_FANG_DONG_CLOSE.data);
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
                  if(arrayData.length>(12+(i*10))&&!TempDeviceStr.equals(DeviceStr)){//json数据不相等说明数据有变化
                     if(arrayData.length>(6+(i*10))&&arrayData[6+(i*10)].equals(FLOOR_HOT_OPEN.data)){
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
//                     Log.e("sky","地暖数据有变化");
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

   private void deleteDevice(List<FloorHotModel>FreshAirList,String deleteAddress){
      Iterator<FloorHotModel> iterator = FreshAirList.iterator();
      while (iterator.hasNext()) {
         FloorHotModel item = iterator.next();
         String address=item.getOutSideAddress()+item.getInSideAddress();
         if (address.equals(deleteAddress)) {
            iterator.remove();
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
      sb.append(SumUtil.sum(sb.toString().toUpperCase()));
      ControlManager.getInstance().clearFlashCommand();
      ControlManager.getInstance().write(sb.toString());
   }
}
