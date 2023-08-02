package com.midea.light.device.explore.controller.control485.event;


import com.midea.light.device.explore.controller.control485.deviceModel.FloorHotModel;

public class FloorHotChangeEvent {

   private FloorHotModel mFloorHotModel;


    public FloorHotModel getFloorHotModel() {
        return mFloorHotModel;
    }

    public FloorHotChangeEvent setFloorHotModel(FloorHotModel floorHotModel) {
        mFloorHotModel = floorHotModel;
        return this;
    }
}
