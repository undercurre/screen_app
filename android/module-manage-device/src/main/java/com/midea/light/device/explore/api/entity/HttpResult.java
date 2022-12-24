package com.midea.light.device.explore.api.entity;

import com.google.gson.annotations.SerializedName;

public class HttpResult<T> extends BaseBean {
    @SerializedName("data")
    T data;

    public boolean isSuc() {
        return errorCode == 0;
    }

    public T getData() {
        return data;
    }

    @Override
    public String toString() {
        return "{" +
                "data=" + data +
                ", errorCode=" + errorCode +
                ", errorMsg='" + errorMsg + '\'' +
                '}';
    }
}