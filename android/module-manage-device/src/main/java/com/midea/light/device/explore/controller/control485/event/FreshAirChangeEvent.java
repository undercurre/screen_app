package com.midea.light.device.explore.controller.control485.event;


import com.midea.light.device.explore.controller.control485.deviceModel.FreshAirModel;

public class FreshAirChangeEvent {

   private FreshAirModel mFreshAirModel;

    public FreshAirModel getFreshAirModel() {
        return mFreshAirModel;
    }

    public FreshAirChangeEvent setFreshAirModel(FreshAirModel freshAirModel) {
        mFreshAirModel = freshAirModel;
        return this;
    }
}
