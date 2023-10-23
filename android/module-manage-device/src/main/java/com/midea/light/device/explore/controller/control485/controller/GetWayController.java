package com.midea.light.device.explore.controller.control485.controller;

import android.util.Log;

import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr;
import com.midea.light.device.explore.controller.control485.dataInterface.Data485Observer;
import com.midea.light.device.explore.controller.control485.util.SumUtil;

import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.COMMAND_CHANGE_AIR_CONDITION_TYPE_CODE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_AIR_CONDITION_ONLINE_STATE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_AIR_CONDITION_PARAMETE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FLOOR_HOT_ONLINE_STATE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FLOOR_HOT_PARAMETE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FRESH_AIR_ONLINE_STATE;
import static com.midea.light.device.explore.controller.control485.agreement.GetWayAgr.GET_ALL_FRESH_AIR_PARAMETE;


public class GetWayController implements Data485Observer {

   public static GetWayController Instance = new GetWayController();

   public static GetWayController getInstance() {
      return Instance;
   }

   public void findAllAirConditionOnlineState(){
      ControlManager.getInstance().write(GET_ALL_AIR_CONDITION_ONLINE_STATE.data);
   }

   public void getAllAirConditionParamete(){
      ControlManager.getInstance().write(GET_ALL_AIR_CONDITION_PARAMETE.data);
   }

   public void findAllFreshAirOnlineState(){
      ControlManager.getInstance().write(GET_ALL_FRESH_AIR_ONLINE_STATE.data);
   }

   public void getAllFreshAirParamete(){
      ControlManager.getInstance().write(GET_ALL_FRESH_AIR_PARAMETE.data);
   }

   public void findAllFloorHotOnlineState(){
      ControlManager.getInstance().write(GET_ALL_FLOOR_HOT_ONLINE_STATE.data);
   }

   public void getAllFloorHotParamete(){
      ControlManager.getInstance().write(GET_ALL_FLOOR_HOT_PARAMETE.data);
   }

   public void changeAirConditionType(String airType){
      AirConditionAgr type=AirConditionAgr.parseAirConditionType(airType);
      controlDataCombination(COMMAND_CHANGE_AIR_CONDITION_TYPE_CODE.data,type.data);
   }

   private void controlDataCombination(String commandCode, String data){
      StringBuffer sb = new StringBuffer();
      sb.append("01");
      sb.append(" ");
      sb.append(commandCode);
      sb.append(" ");
      sb.append(data);
      sb.append(" ");
      sb.append("FF");
      sb.append(" ");
      sb.append("FF");
      sb.append(" ");
      sb.append("FF");
      sb.append(" ");
      sb.append(SumUtil.sum(sb.toString()));
      ControlManager.getInstance().write(sb.toString());
   }


   @Override
   public void getMessage(String data) {
      String[] arrayData=data.split(" ");
      if(arrayData[1].equals(COMMAND_CHANGE_AIR_CONDITION_TYPE_CODE.data)){
         AirConditionAgr type=AirConditionAgr.parseAirConditionType(arrayData[2]);
         Log.e("sky","空调品牌切换为:"+type.signal());
      }

   }
}
