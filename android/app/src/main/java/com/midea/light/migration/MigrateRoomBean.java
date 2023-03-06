package com.midea.light.migration;

import com.google.gson.annotations.SerializedName;
public class MigrateRoomBean {

    @SerializedName("des")
    private String des;
    @SerializedName("icon")
    private String icon;
    @SerializedName("isDefault")
    private String isDefault;
    @SerializedName("name")
    private String name;
    @SerializedName("roomId")
    private String roomId;

    public String getDes() {
        return des;
    }

    public void setDes(String des) {
        this.des = des;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getIsDefault() {
        return isDefault;
    }

    public void setIsDefault(String isDefault) {
        this.isDefault = isDefault;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }
}