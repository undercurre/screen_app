package com.midea.light;

import androidx.annotation.NonNull;

import com.midea.light.channel.Channels;

import android.Manifest;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    // 与Flutter通信通道
    Channels mChannels = new Channels();

    private final String[] permissions = new String[]{
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.CHANGE_WIFI_MULTICAST_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
    };


    public void onCreate(Bundle bundle) {
        requestPermissions(permissions, 0x18);
        super.onCreate(bundle);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 动态添加插件
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        // 初始化自定义的Channel
        mChannels.init(this, flutterEngine.getDartExecutor().getBinaryMessenger());
    }


}
