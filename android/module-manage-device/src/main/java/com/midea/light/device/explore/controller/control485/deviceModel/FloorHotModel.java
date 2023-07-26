package com.midea.light.device.explore.controller.control485.deviceModel;

public class FloorHotModel {

   private String inSideAddress;
   private String outSideAddress;
   private String temperature;
   private String CurrTemperature;
   private String frostProtection;
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

   public String getFrostProtection() {
      return frostProtection;
   }

   public void setFrostProtection(String frostProtection) {
      this.frostProtection = frostProtection;
   }
}
