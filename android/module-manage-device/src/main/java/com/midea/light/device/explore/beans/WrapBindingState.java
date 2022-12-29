package com.midea.light.device.explore.beans;

import android.os.Parcelable;

import androidx.annotation.IntDef;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.Objects;

public class WrapBindingState {
    public final static int STATE_WAIT = 0;
    public final static int STATE_CONNECTING = 1;
    public final static int STATE_CONNECTED_SUC = 2;
    public final static int STATE_CONNECTED_ERR = 3;

    @IntDef({STATE_WAIT, STATE_CONNECTING, STATE_CONNECTED_SUC, STATE_CONNECTED_ERR})
    @Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.TYPE_USE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface State {
    }


    private Parcelable scanRequest;
    private Parcelable bindResult;
    @State
    private int state;
    private String errorMsg;
    private String homeGroupId;
    private String roomId;

    public static WrapBindingState wait(Parcelable object) {
        WrapBindingState wrapBean = new WrapBindingState();
        wrapBean.scanRequest = object;
        wrapBean.state = STATE_WAIT;
        return wrapBean;
    }

    public static WrapBindingState connecting(Parcelable object) {
        WrapBindingState wrapBean = new WrapBindingState();
        wrapBean.scanRequest = object;
        wrapBean.state = STATE_CONNECTING;
        return wrapBean;
    }

    public static WrapBindingState suc(Parcelable object) {
        WrapBindingState wrapBean = new WrapBindingState();
        wrapBean.scanRequest = object;
        wrapBean.state = STATE_CONNECTED_SUC;
        return wrapBean;
    }

    public static WrapBindingState error(Parcelable object) {
        WrapBindingState wrapBean = new WrapBindingState();
        wrapBean.scanRequest = object;
        wrapBean.state = STATE_CONNECTED_ERR;
        return wrapBean;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getHomeGroupId() {
        return homeGroupId;
    }

    public void setHomeGroupId(String homeGroupId) {
        this.homeGroupId = homeGroupId;
    }

    public Parcelable getScanResult() {
        return scanRequest;
    }

    public void setBindResult(Parcelable bindResult) {
        this.bindResult = bindResult;
    }

    public Parcelable getBindResult() {
        return bindResult;
    }


    public void setState(@State int state) {
        this.state = state;
    }

    public @State
    int getState() {
        return state;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }

    public String getErrorMsg() {
        return errorMsg;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        WrapBindingState wrapBean = (WrapBindingState) o;
        return Objects.equals(scanRequest, wrapBean.scanRequest);
    }

    @Override
    public int hashCode() {
        return Objects.hash(scanRequest);
    }

}