package com.midea.light.device.explore.beans;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * @ClassName BindResult
 * @Description 设配配网结果Bean
 * @Author weinp1
 * @Date 2021/7/23 14:31
 * @Version 1.0
 */
public class BindResult implements Parcelable {
    public final static String TYPE_WIFI = "result_wifi";
    public final static String TYPE_ZIGBEE = "result_zigbee";

    Parcelable deviceInfo;
    Parcelable bindResult;
    String bindType;
    int code; //code == 0 说明绑定成功了。其他的结果，需要根据结合相对的场景做判断
    String message;
    //还剩下多少台设备需要绑定。注意：这里不区分类型，统计所有类型的数据
    int waitDeviceBind;

    public void setBindResult(Parcelable bindResult) {
        this.bindResult = bindResult;
    }

    public Parcelable getBindResult() {
        return bindResult;
    }

    public int getWaitDeviceBind() {
        return waitDeviceBind;
    }

    public void setWaitDeviceBind(int waitDeviceBind) {
        this.waitDeviceBind = waitDeviceBind;
    }

    public Parcelable getDeviceInfo() {
        return deviceInfo;
    }

    public void setDeviceInfo(Parcelable deviceInfo) {
        this.deviceInfo = deviceInfo;
    }

    public String getBindType() {
        return bindType;
    }

    public void setBindType(String bindType) {
        this.bindType = bindType;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public BindResult() {

    }

    protected BindResult(Parcel in) {
        bindType = in.readString();
        if (TYPE_WIFI.equals(bindType)) {
            deviceInfo = in.readParcelable(WiFiScanResult.class.getClassLoader());
        } else if (TYPE_ZIGBEE.equals(bindType)) {
            // todo
        }
        code = in.readInt();
        message = in.readString();
    }

    public static final Creator<BindResult> CREATOR = new Creator<BindResult>() {
        @Override
        public BindResult createFromParcel(Parcel in) {
            return new BindResult(in);
        }

        @Override
        public BindResult[] newArray(int size) {
            return new BindResult[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(bindType);
        dest.writeParcelable(deviceInfo, 0);
        dest.writeInt(code);
        dest.writeString(message);
    }

}
