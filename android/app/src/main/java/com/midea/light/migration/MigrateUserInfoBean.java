package com.midea.light.migration;

public class MigrateUserInfoBean {
    /**
     * {
     * "uid":"73d29ca4312440c1a52e2a7a396ef84f",
     * "headImgUrl":"https://fcmms.midea.com/ccrm-beta/userHeadImg/defaultHeadImg.png",
     * "roleId":"1002",
     * "mobile":"18819462513",
     * "nickname":"\uD83D\uDE02",
     * "userId":"6876467463"
     * }
     */

    private String uid;
    private String mobile;
    private String nickName;
    private String headImageUrl;
    private String roledId;
    //当前的家庭
    private MigrateHomeBean.Home home;
    //当前的房前
    private MigrateRoomBean room;

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getHeadImageUrl() {
        return headImageUrl;
    }

    public void setHeadImageUrl(String headImageUrl) {
        this.headImageUrl = headImageUrl;
    }

    public String getRoledId() {
        return roledId;
    }

    public void setRoledId(String roledId) {
        this.roledId = roledId;
    }

    public MigrateHomeBean.Home getHome() {
        return home;
    }

    public void setHome(MigrateHomeBean.Home home) {
        this.home = home;
    }

    public MigrateRoomBean getRoom() {
        return room;
    }

    public void setRoom(MigrateRoomBean room) {
        this.room = room;
    }
}
