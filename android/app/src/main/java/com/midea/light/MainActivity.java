package com.midea.light;

import androidx.annotation.NonNull;

import com.midea.light.channel.Channels;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    // 与Flutter通信通道
    Channels mChannels = new Channels();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 动态添加插件
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        // 初始化自定义的Channel
        mChannels.init(this, flutterEngine.getDartExecutor().getBinaryMessenger());
    }


}
