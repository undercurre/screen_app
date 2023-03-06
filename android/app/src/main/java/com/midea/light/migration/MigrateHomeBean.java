package com.midea.light.migration;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class MigrateHomeBean {
    @SerializedName("homeList")
    private List<Home> list;


    public List<Home> getList() {
        return list;
    }

    public void setList(List<Home> list) {
        this.list = list;
    }

    public static class Home {
        @SerializedName("homegroupId")
        private String homegroupId;
        @SerializedName("name")
        private String name;
        @SerializedName("des")
        private String des;
        @SerializedName("address")
        private String address;
        @SerializedName("profilePicUrl")
        private String profilePicUrl;
        @SerializedName("coordinate")
        private String coordinate;
        @SerializedName("createTime")
        private String createTime;
        @SerializedName("createUserUid")
        private String createUserUid;
        @SerializedName("roomCount")
        private int roomCount;
        @SerializedName("applianceCount")
        private int applianceCount;
        @SerializedName("memberCount")
        private int memberCount;

        public String getHomegroupId() {
            return homegroupId;
        }

        public void setHomegroupId(String homegroupId) {
            this.homegroupId = homegroupId;
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

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getProfilePicUrl() {
            return profilePicUrl;
        }

        public void setProfilePicUrl(String profilePicUrl) {
            this.profilePicUrl = profilePicUrl;
        }

        public String getCoordinate() {
            return coordinate;
        }

        public void setCoordinate(String coordinate) {
            this.coordinate = coordinate;
        }

        public String getCreateTime() {
            return createTime;
        }

        public void setCreateTime(String createTime) {
            this.createTime = createTime;
        }

        public String getCreateUserUid() {
            return createUserUid;
        }

        public void setCreateUserUid(String createUserUid) {
            this.createUserUid = createUserUid;
        }

        public int getRoomCount() {
            return roomCount;
        }

        public void setRoomCount(int roomCount) {
            this.roomCount = roomCount;
        }

        public int getApplianceCount() {
            return applianceCount;
        }

        public void setApplianceCount(int applianceCount) {
            this.applianceCount = applianceCount;
        }

        public int getMemberCount() {
            return memberCount;
        }

        public void setMemberCount(int memberCount) {
            this.memberCount = memberCount;
        }
    }

}
