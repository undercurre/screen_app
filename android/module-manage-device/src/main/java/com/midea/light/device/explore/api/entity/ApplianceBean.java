package com.midea.light.device.explore.api.entity;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.JsonAdapter;
import com.midea.light.device.explore.api.entity.adapter.ApplianceBeanAdapter;

/**
 * @ClassName ApplianceBean
 * @Description
 * @Author weinp1
 * @Date 2021/7/27 17:40
 * @Version 1.0
 */
@JsonAdapter(ApplianceBeanAdapter.class)
public class ApplianceBean implements Parcelable {
    private String applianceCode;
    private String onlineStatus;
    private String type;
    private String modelNumber;
    private String name;
    private String des;
    private String activeStatus;
    private String homegroupId;
    private String roomId;
    private String rawSn;

    public ApplianceBean() {
    }

    protected ApplianceBean(Parcel in) {
        applianceCode = in.readString();
        onlineStatus = in.readString();
        type = in.readString();
        modelNumber = in.readString();
        name = in.readString();
        des = in.readString();
        activeStatus = in.readString();
        homegroupId = in.readString();
        roomId = in.readString();
    }

    public String getRawSn() {
        return rawSn;
    }

    public void setRawSn(String rawSn) {
        this.rawSn = rawSn;
    }


    public String getApplianceCode() {
        return applianceCode;
    }

    public void setApplianceCode(String applianceCode) {
        this.applianceCode = applianceCode;
    }

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getModelNumber() {
        return modelNumber;
    }

    public void setModelNumber(String modelNumber) {
        this.modelNumber = modelNumber;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDes() {
        return des;
    }

    public void setDes(String des) {
        this.des = des;
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

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public static final Creator<ApplianceBean> CREATOR = new Creator<ApplianceBean>() {
        @Override
        public ApplianceBean createFromParcel(Parcel in) {
            return new ApplianceBean(in);
        }

        @Override
        public ApplianceBean[] newArray(int size) {
            return new ApplianceBean[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(applianceCode);
        dest.writeString(onlineStatus);
        dest.writeString(type);
        dest.writeString(modelNumber);
        dest.writeString(name);
        dest.writeString(des);
        dest.writeString(activeStatus);
        dest.writeString(homegroupId);
        dest.writeString(roomId);
    }


    @Override
    public String toString() {
        return "ApplianceBean{" +
                "applianceCode='" + applianceCode + '\'' +
                ", onlineStatus='" + onlineStatus + '\'' +
                ", type='" + type + '\'' +
                ", modelNumber='" + modelNumber + '\'' +
                ", name='" + name + '\'' +
                ", des='" + des + '\'' +
                ", activeStatus='" + activeStatus + '\'' +
                ", homegroupId='" + homegroupId + '\'' +
                ", roomId='" + roomId + '\'' +
                ", rawSn='" + rawSn + '\'' +
                '}';
    }
}
