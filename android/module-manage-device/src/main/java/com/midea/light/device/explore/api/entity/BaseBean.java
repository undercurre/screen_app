package com.midea.light.device.explore.api.entity;

import com.google.gson.annotations.SerializedName;

public class BaseBean {
    @SerializedName(value = "errorCode", alternate = "code")
    int errorCode;
    @SerializedName(value = "errorMsg", alternate = "msg")
    String errorMsg;

    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorMsg() {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }
}