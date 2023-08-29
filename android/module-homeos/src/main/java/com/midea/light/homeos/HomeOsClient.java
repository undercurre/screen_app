package com.midea.light.homeos;

import androidx.annotation.Nullable;

/**
 * HomeOs 局域网控制客户端
 */
public class HomeOsClient {

    private static final HomeOsController OS_CONTROLLER = new HomeOsController();

    public static HomeOsController getOsController() {
        return OS_CONTROLLER;
    }

    public static void setCallback(@Nullable HomeOsControllerCallback callback) {
        OS_CONTROLLER.setCallback(callback);
    }

}
