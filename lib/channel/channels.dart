import 'package:flutter/services.dart';
import 'package:screen_app/channel/net_method_channel.dart';

const String channelMethodNet = "com.midea.light/net";

// 网络channel
const _METHOD_CHANNEL_NET = "com.midea.light/net";

class Channels {

  static final Channels _INSTANT = Channels._privateConstruct();

  Channels._privateConstruct();

  factory Channels() => _INSTANT;

  late NetMethodChannel mNetMethodChannel = NetMethodChannel.fromName(_METHOD_CHANNEL_NET);

}