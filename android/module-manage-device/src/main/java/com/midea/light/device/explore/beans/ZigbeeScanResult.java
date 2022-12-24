package com.midea.light.device.explore.beans;

import android.os.Parcel;
import com.midea.light.device.explore.api.entity.SearchZigbeeDeviceResult;

import java.util.Objects;

/**
 * @author Janner
 * @ProjectName: SmartScreen
 * @Package: com.midea.light.explore.beans
 * @ClassName: ZigbeeScanResult
 * @CreateDate: 2022/9/19 10:47
 */
public class ZigbeeScanResult extends BaseScanResult {
   public SearchZigbeeDeviceResult.ZigbeeDevice device;

   public ZigbeeScanResult(Parcel in) {
      super(in);
      device = in.readParcelable(SearchZigbeeDeviceResult.ZigbeeDevice.class.getClassLoader());
   }


   public ZigbeeScanResult(SearchZigbeeDeviceResult.ZigbeeDevice deviceDTO, String icon, String name) {
      super(TYPE.zigbee.ordinal(), icon, name);
      device = deviceDTO;
   }

   public SearchZigbeeDeviceResult.ZigbeeDevice getDevice() {
      return device;
   }

   @Override
   public void writeToParcel(Parcel dest, int flags) {
      super.writeToParcel(dest, flags);
      dest.writeParcelable(device,0);
   }

   public static final Creator<ZigbeeScanResult> CREATOR = new Creator<ZigbeeScanResult>() {

      @Override
      public ZigbeeScanResult createFromParcel(Parcel in) {
         return new ZigbeeScanResult(in);
      }

      @Override
      public ZigbeeScanResult[] newArray(int size) {
         return new ZigbeeScanResult[size];
      }
   };

   @Override
   public int hashCode() {
      return Objects.hash(device.getSn());
   }

   @Override
   public boolean equals(Object o) {
      if (this == o)
         return true;
      if (o == null || getClass() != o.getClass())
         return false;
      if (!super.equals(o))
         return false;
      ZigbeeScanResult that = (ZigbeeScanResult) o;
      return Objects.equals(device.getSn(),that.device.getSn());
   }
}
