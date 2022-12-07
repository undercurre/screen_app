import 'package:flutter/services.dart';
import 'package:screen_app/channel/net_method_channel.dart';

const String channelMethodNet = "com.midea.light/net";

// 网络channel
NetMethodChannel netMethodChannel = NetMethodChannel.fromName("com.midea.light/net");
