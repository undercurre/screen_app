package com.midea.light.device.explore.beans;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Objects;

/**
 * @author Janner
 * @ProjectName: SmartScreen
 * @Package: com.midea.light.explore.beans
 * @ClassName: BaseScanResult
 * @CreateDate: 2022/9/19 11:22
 */
public class BaseScanResult implements Parcelable {
   public int deviceType;
   public String icon;
   public String name;

   public enum TYPE{
      zigbee,
      wifi
   }

   public int getDeviceType() {
      return deviceType;
   }

   public String getIcon() {
      return icon;
   }

   public void setIcon(String icon) {
      this.icon = icon;
   }

   public String getName() {
      return name;
   }

   public void setName(String name) {
      this.name = name;
   }

   public BaseScanResult(int deviceType, String icon, String name) {
      this.deviceType = deviceType;
      this.icon = icon;
      this.name = name;
   }

   protected BaseScanResult(Parcel in) {
      deviceType = in.readInt();
      icon = in.readString();
      name = in.readString();
   }

   @Override
   public void writeToParcel(Parcel dest, int flags) {
      dest.writeInt(deviceType);
      dest.writeString(icon);
      dest.writeString(name);
   }

   @Override
   public int describeContents() {
      return 0;
   }

   public static final Creator<BaseScanResult> CREATOR = new Creator<BaseScanResult>() {
      @Override
      public BaseScanResult createFromParcel(Parcel in) {
         return new BaseScanResult(in);
      }

      @Override
      public BaseScanResult[] newArray(int size) {
         return new BaseScanResult[size];
      }
   };

   @Override
   public boolean equals(Object o) {
      if (this == o)
         return true;
      if (o == null || getClass() != o.getClass())
         return false;
      BaseScanResult that = (BaseScanResult) o;
      return Objects.equals(icon, that.icon) && Objects.equals(name, that.name) && deviceType == that.deviceType;
   }

   @Override
   public int hashCode() {
      return Objects.hash(icon, name,deviceType);
   }
}
