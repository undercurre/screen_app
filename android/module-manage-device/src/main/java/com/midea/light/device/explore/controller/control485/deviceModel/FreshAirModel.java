package com.midea.light.device.explore.controller.control485.deviceModel;

public class FreshAirModel {

   private String inSideAddress;
   private String outSideAddress;
   private String workModel;
   private String windSpeed;
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

   public void setOutSideAddress(String outSideAddress) {
      this.outSideAddress = outSideAddress;
   }

   public String getWindSpeed() {
      return windSpeed;
   }

   public void setWindSpeed(String windSpeed) {
      this.windSpeed = windSpeed;
   }

   public String getOnlineState() {
      return onlineState;
   }

   public void setOnlineState(String onlineState) {
      this.onlineState = onlineState;
   }

   public String getWorkModel() {
      return workModel;
   }

   public void setWorkModel(String workModel) {
      this.workModel = workModel;
   }
}
