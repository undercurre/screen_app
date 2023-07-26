package com.midea.light.device.explore.controller.control485.deviceModel;

public class AirConditionModel {

   private String inSideAddress;
   private String outSideAddress;
   private String temperature;
   private String windSpeed;
   private String workModel;
   private String CurrTemperature;
   private String errorCode;
   private String OnOff;
   private String onlineState;


   public String getOnOff() {
      return OnOff;
   }

   public void setOnOff(String onOff) {
      OnOff = onOff;
   }

   public String getErrorCode() {
      return errorCode;
   }

   public void setErrorCode(String errorCode) {
      this.errorCode = errorCode;
   }

   public String getInSideAddress() {
      return inSideAddress;
   }

   public void setInSideAddress(String inSideAddress) {
      this.inSideAddress = inSideAddress;
   }

   public String getOutSideAddress() {
      return outSideAddress;
   }

   public String getTemperature() {
      return temperature;
   }

   public void setTemperature(String temperature) {
      this.temperature = temperature;
   }

   public void setOutSideAddress(String outSideAddress) {
      this.outSideAddress = outSideAddress;
   }


   public String getWindSpeed() {
      return windSpeed;
   }

   public void setWindSpeed(String windSpeed) {
      this.windSpeed = windSpeed;
   }

   public String getWorkModel() {
      return workModel;
   }

   public void setWorkModel(String workModel) {
      this.workModel = workModel;
   }

   public String getCurrTemperature() {
      return CurrTemperature;
   }

   public void setCurrTemperature(String currTemperature) {
      CurrTemperature = currTemperature;
   }

   public String getOnlineState() {
      return onlineState;
   }

   public void setOnlineState(String onlineState) {
      this.onlineState = onlineState;
   }
}
