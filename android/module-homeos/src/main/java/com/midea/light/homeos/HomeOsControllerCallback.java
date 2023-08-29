package com.midea.light.homeos;

public interface HomeOsControllerCallback {
    void msg(String topic, String msg);

    void log(String msg);
}
