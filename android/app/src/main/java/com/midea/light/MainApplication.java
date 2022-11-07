package com.midea.light;


import android.app.Application;
import android.content.Context;

import androidx.multidex.MultiDex;

public class MainApplication extends Application {

    private static Application application;

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        application = this;
        MultiDex.install(this);
    }

    public static Application getContext() {
        return application;
    }

}