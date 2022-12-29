package com.midea.light.device.explore.api.entity;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SearchZigbeeDeviceResult {
   @SerializedName("list")
   private List<ZigbeeDevice> list;

   public List<ZigbeeDevice> getList() {
      return list;
   }

   public void setList(List<ZigbeeDevice> list) {
      this.list = list;
   }

   public static class ZigbeeDevice implements Parcelable {
      @SerializedName("applianceCode")
      private String applianceCode;

      @SerializedName("name")
      private String name;

      @SerializedName("applianceType")
      private String applianceType;

      @SerializedName("modelNum")
      private String modelNum;

      @SerializedName("sn")
      private String sn;

      @SerializedName("desc")
      private String desc;

      @SerializedName("masterId")
      private String masterId;

      @SerializedName("status")
      private String status;

      @SerializedName("activeStatus")
      private String activeStatus;

      @SerializedName("homegroupId")
      private String homegroupId;

      @SerializedName("prop")
      private String prop;

      @SerializedName("lastActiveTime")
      private String lastActiveTime;

      @SerializedName("version")
      private String version;

      protected ZigbeeDevice(Parcel in) {
         applianceCode = in.readString();
         name = in.readString();
         applianceType = in.readString();
         modelNum = in.readString();
         sn = in.readString();
         desc = in.readString();
         masterId = in.readString();
         status = in.readString();
         activeStatus = in.readString();
         homegroupId = in.readString();
         prop = in.readString();
         lastActiveTime = in.readString();
         version = in.readString();
      }

      public static final Creator<ZigbeeDevice> CREATOR = new Creator<ZigbeeDevice>() {
         @Override
         public ZigbeeDevice createFromParcel(Parcel in) {
            return new ZigbeeDevice(in);
         }

         @Override
         public ZigbeeDevice[] newArray(int size) {
            return new ZigbeeDevice[size];
         }
      };

      public String getApplianceCode() {
         return applianceCode;
      }

      public void setApplianceCode(String applianceCode) {
         this.applianceCode = applianceCode;
      }

      public String getName() {
         return name;
      }

      public void setName(String name) {
         this.name = name;
      }

      public String getApplianceType() {
         return applianceType;
      }

      public void setApplianceType(String applianceType) {
         this.applianceType = applianceType;
      }

      public String getModelNum() {
         return modelNum;
      }

      public void setModelNum(String modelNum) {
         this.modelNum = modelNum;
      }

      public String getSn() {
         return sn;
      }

      public void setSn(String sn) {
         this.sn = sn;
      }

      public String getDesc() {
         return desc;
      }

      public void setDesc(String desc) {
         this.desc = desc;
      }

      public String getMasterId() {
         return masterId;
      }

      public void setMasterId(String masterId) {
         this.masterId = masterId;
      }

      public String getStatus() {
         return status;
      }

      public void setStatus(String status) {
         this.status = status;
      }

      public String getActiveStatus() {
         return activeStatus;
      }

      public void setActiveStatus(String activeStatus) {
         this.activeStatus = activeStatus;
      }

      public String getHomegroupId() {
         return homegroupId;
      }

      public void setHomegroupId(String homegroupId) {
         this.homegroupId = homegroupId;
      }

      public String getProp() {
         return prop;
      }

      public void setProp(String prop) {
         this.prop = prop;
      }

      public String getLastActiveTime() {
         return lastActiveTime;
      }

      public void setLastActiveTime(String lastActiveTime) {
         this.lastActiveTime = lastActiveTime;
      }

      public String getVersion() {
         return version;
      }

      public void setVersion(String version) {
         this.version = version;
      }

      @Override
      public int describeContents() {
         return 0;
      }

      @Override
      public void writeToParcel(Parcel parcel, int i) {
         parcel.writeString(applianceCode);
         parcel.writeString(name);
         parcel.writeString(applianceType);
         parcel.writeString(modelNum);
         parcel.writeString(sn);
         parcel.writeString(desc);
         parcel.writeString(masterId);
         parcel.writeString(status);
         parcel.writeString(activeStatus);
         parcel.writeString(homegroupId);
         parcel.writeString(prop);
         parcel.writeString(lastActiveTime);
         parcel.writeString(version);
      }
   }
}