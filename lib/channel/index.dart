import 'package:flutter/services.dart';
import 'package:screen_app/channel/about_system_channel.dart';
import 'package:screen_app/channel/config_channel.dart';
import 'package:screen_app/channel/net_method_channel.dart';

const String channelMethodNet = "com.midea.light/net";
const String channelConfig = "com.midea.light/config";
const String channelAboutSystem = "com.midea.light/about";

// 网络channel
NetMethodChannel netMethodChannel = NetMethodChannel.fromName(channelMethodNet);
// 配置channel
ConfigChannel configChannel = ConfigChannel.fromName(channelConfig);
// 配置关于页的channel
AboutSystemChannel aboutSystemChannel = AboutSystemChannel.fromName(channelAboutSystem);
