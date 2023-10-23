package com.midea.light.device.explore.controller.control485.event;


import com.midea.light.device.explore.controller.control485.deviceModel.AirConditionModel;

public class AirConditionChangeEvent {

   private AirConditionModel mAirConditionModel;

    public AirConditionModel getAirConditionModel() {
        return mAirConditionModel;
    }

    public AirConditionChangeEvent setAirConditionModel(AirConditionModel airConditionModel) {
        mAirConditionModel = airConditionModel;
        return this;
    }
}
