package com.midea.light.device.explore.controller.control485.controller;

import android.util.Log;

import com.google.gson.Gson;
import com.midea.light.RxBus;
import com.midea.light.bean.OnlineState485Bean;
import com.midea.light.bean.Update485DeviceBean;
import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.deviceModel.FreshAirModel;
import com.midea.light.device.explore.controller.control485.event.FreshAirChangeEvent;
import com.midea.light.device.explore.controller.control485.util.SumUtil;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.utils.GsonUtils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.CLOSE;
import static com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr.OPEN;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.ALL_FRESH_AIR_QUERY_PARELETE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.COMMAND_FRESH_AIR_ON_OFF_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.COMMAND_FRESH_AIR_WIND_SPEED_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_CLOSE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_OFF_LINE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_ON_LINE;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_OPEN;
import static com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr.FRESH_AIR_QUERY_CODE;


public class FreshAirController implements Data485Observer {

   public List<FreshAirModel>FreshAirList=new ArrayList<>();

   public List<FreshAirModel> TempFreshAirList=new ArrayList<>();

   public static FreshAirController Instance = new FreshAirController();

   public static FreshAirController getInstance() {
      return Instance;
   }

   public void open(FreshAirModel device){
      controlDataCombination(device,COMMAND_FRESH_AIR_ON_OFF_CODE.data,"01");
   }

   public void close(FreshAirModel device){
      controlDataCombination(device,COMMAND_FRESH_AIR_ON_OFF_CODE.data,"00");
   }

   public void setModel(FreshAirModel device ,String model){
      FreshAirAgr type = FreshAirAgr.parseWorkModel(model);
      controlDataCombination(device,FreshAirAgr.COMMAND_FRESH_AIR_MODEL_CODE.data,type.data);
   }

   public void setWindSpeedLevl(FreshAirModel device ,String speed){
      FreshAirAgr speeds = FreshAirAgr.parseWindSpeed(speed);
      controlDataCombination(device,COMMAND_FRESH_AIR_WIND_SPEED_CODE.data,speeds.data);
   }

   @Override
   public void getMessage(String data) {
      String[] arrayData=data.split(" ");
      //判断是否离在线,同时判断是否有新增和删减
      if(arrayData[1].equals(FRESH_AIR_QUERY_CODE.data)&&arrayData[2].equals(ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到新风数量
         TempFreshAirList.clear();
         /**
          * 1,找出所有拉取到的设备
          * 2,通过拉取到的设备地址判断是否存在这个设备
          * 3,判断地址是新的就要新增这个设备
          * 4,判断地址在所有拉取到的设备列表里面没有就列出需要删除的地址
          * 5,通过列出的需要删除的地址,删除对应地址设备
          * 6,判断在线状态是否有变更,如果有变更就要通知出去
          * */

         List<FreshAirModel>FindList=new ArrayList<>();//找到的设备列表
         List<String>FindAddressList=new ArrayList<>();//找到的设备地址列表
         List<String>HasAddressList=new ArrayList<>();//已经有的设备地址列表
         List<String>NeedAddressList=new ArrayList<>();//需要添加的设备地址列表
         List<String>NeedDeleteAddressList=new ArrayList<>();//需要删除的设备地址列表
         ArrayList<OnlineState485Bean.PLC.OnlineState> diffStatelsit=new ArrayList<>();

         //保存拉取到的设备以及设备地址到列表
         for (int i = 0; i <num ; i++) {
            FreshAirModel FreshAir=new FreshAirModel();
            FreshAir.setOutSideAddress(arrayData[4+(i*3)]);
            FreshAir.setInSideAddress(arrayData[5+(i*3)]);
            if(arrayData[6+(i*3)].equals(FRESH_AIR_ON_LINE.data)){
               FreshAir.setOnlineState(FRESH_AIR_ON_LINE.data);
            }else{
               FreshAir.setOnlineState(FRESH_AIR_OFF_LINE.data);
            }
            FindAddressList.add(FreshAir.getOutSideAddress()+FreshAir.getInSideAddress());
            FindList.add(FreshAir);
         }

         //保存已经有的设备地址到列表
         for (int j = 0; j <FreshAirList.size() ; j++) {
            String address=FreshAirList.get(j).getOutSideAddress()+FreshAirList.get(j).getInSideAddress();
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
                  FreshAirList.add(FindList.get(i));
               }
            }
         }

         //通过需要删除的地址列表,从已经保存的设备列表中删除需要删除的设备
         for (int i = 0; i <NeedDeleteAddressList.size() ; i++) {
            deleteDevice(FreshAirList,NeedDeleteAddressList.get(i));
         }

         //判断离在线状态是否有变化
         for (int i = 0; i <FindList.size() ; i++) {
            for (int j = 0; j <FreshAirList.size() ; j++) {
               String findAddress=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               String address=FreshAirList.get(j).getOutSideAddress()+FreshAirList.get(j).getInSideAddress();
               if(address.equals(findAddress)){
                  if(!FreshAirList.get(j).getOnlineState().equals(FindList.get(i).getOnlineState())){
                     //在线状态不一致,就通知出去
                     OnlineState485Bean.PLC.OnlineState state=new OnlineState485Bean.PLC.OnlineState();
                     if(FindList.get(i).getOnlineState().equals(FRESH_AIR_ON_LINE.data)){
                        state.setStatus(1);
                     }else{
                        state.setStatus(0);
                     }
                     state.setAddr(address);
                     state.setModelId("zhonghong.air.001");
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
            for (int j = 0; j <FreshAirList.size() ; j++) {
               String findAddress=FindList.get(i).getOutSideAddress()+FindList.get(i).getInSideAddress();
               String address=FreshAirList.get(j).getOutSideAddress()+FreshAirList.get(j).getInSideAddress();
               if(address.equals(findAddress)){
                  FreshAirList.get(j).setOnlineState(FindList.get(i).getOnlineState());
               }
            }
         }
         List<FreshAirModel> mFreshAirList = GsonUtils.fromJsonList((new Gson().toJson(FreshAirList)), FreshAirModel.class);
         TempFreshAirList.addAll(mFreshAirList);
         //判断属性变化
      }else if(arrayData[1].equals(FRESH_AIR_QUERY_CODE.data)&&arrayData[2].equals(ALL_FRESH_AIR_QUERY_PARELETE_CODE.data)){
         int num = Integer.parseInt(arrayData[3], 16);//num为拿到空调数量
         for (int i = 0; i <num ; i++) {
            for (int j = 0; j <TempFreshAirList.size() ; j++) {
               String querAddr=arrayData[4+(i*10)]+arrayData[5+(i*10)];
               String deviceAddr=TempFreshAirList.get(j).getOutSideAddress()+TempFreshAirList.get(j).getInSideAddress();
               if(querAddr.equals(deviceAddr)){
                  if(arrayData[6+(i*10)].equals(FRESH_AIR_OPEN.data)){
                     TempFreshAirList.get(j).setOnOff(FRESH_AIR_OPEN.data);
                  }else{
                     TempFreshAirList.get(j).setOnOff(FRESH_AIR_CLOSE.data);
                  }
                  setWorkModel(TempFreshAirList.get(j),arrayData[8+(i*10)]);
                  setWindSpeed(TempFreshAirList.get(j),arrayData[9+(i*10)]);
                  TempFreshAirList.get(j).setErrorCode(arrayData[11+(i*10)]);
               }
            }
         }
         //判断是否有数据变化,有数据变化就找出来
         for (int i = 0; i <TempFreshAirList.size() ; i++) {
            for (int j = 0; j <FreshAirList.size() ; j++) {
               String querAddr=TempFreshAirList.get(i).getOutSideAddress()+TempFreshAirList.get(i).getInSideAddress();
               String deviceAddr=FreshAirList.get(j).getOutSideAddress()+FreshAirList.get(j).getInSideAddress();
               if(querAddr.equals(deviceAddr)){
                  String TempDeviceStr=new Gson().toJson(TempFreshAirList.get(i));
                  String DeviceStr=new Gson().toJson(FreshAirList.get(j));
                  if(!TempDeviceStr.equals(DeviceStr)){//json数据不相等说明数据有变化
                     if(arrayData[6+(i*10)].equals(OPEN.data)){
                        FreshAirList.get(j).setOnOff(OPEN.data);
                     }else{
                        FreshAirList.get(j).setOnOff(CLOSE.data);
                     }
                     setWorkModel(FreshAirList.get(j),arrayData[8+(i*10)]);
                     setWindSpeed(FreshAirList.get(j),arrayData[9+(i*10)]);
                     FreshAirList.get(j).setErrorCode(arrayData[11+(i*10)]);
                     //有数据变化就发event
                     Log.e("sky","数据有变化");
                     RxBus.getInstance().post(new FreshAirChangeEvent().setFreshAirModel(FreshAirList.get(j)));
                     ArrayList<Update485DeviceBean.PLC.AttributeUpdate> deviceList=new ArrayList<>();
                     Update485DeviceBean.PLC.AttributeUpdate Attribute=new Update485DeviceBean.PLC.AttributeUpdate();
                     Update485DeviceBean.PLC.AttributeUpdate.Event event=new Update485DeviceBean.PLC.AttributeUpdate.Event();
                     event.setOnOff(Integer.parseInt(FreshAirList.get(j).getOnOff()));
                     event.setWindSpeed(Integer.parseInt(FreshAirList.get(j).getWindSpeed(),16));
                     event.setOperationMode(Integer.parseInt(FreshAirList.get(j).getWorkModel(),16));
                     Attribute.setAddr(FreshAirList.get(j).getOutSideAddress()+FreshAirList.get(j).getInSideAddress());
                     Attribute.setModelId("zhonghong.air.001");
                     Attribute.setEvent(event);
                     deviceList.add(Attribute);
                     GateWayUtils.update485Device(deviceList);

                  }
               }
            }
         }

      }
   }

   private void deleteDevice(List<FreshAirModel>FreshAirList,String deleteAddress){
      Iterator<FreshAirModel> iterator = FreshAirList.iterator();
      while (iterator.hasNext()) {
         FreshAirModel item = iterator.next();
         String address=item.getOutSideAddress()+item.getInSideAddress();
         if (address.equals(deleteAddress)) {
            iterator.remove();
         }
      }
   }

   private void setWindSpeed(FreshAirModel device, String arrayDatum) {
      FreshAirAgr type = FreshAirAgr.parseWindSpeed(arrayDatum);
      device.setWindSpeed(type.data);
   }

   private void setWorkModel(FreshAirModel device, String arrayDatum) {
      FreshAirAgr type = FreshAirAgr.parseWorkModel(arrayDatum);
      device.setWorkModel(type.data);
   }

   private void controlDataCombination(FreshAirModel device ,String commandCode,String data){
      ControlManager.getInstance().stopFresh();
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
      ControlManager.getInstance().startFresh();

   }
}
