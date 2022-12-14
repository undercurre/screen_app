
import 'package:screen_app/channel/asb_channel.dart';

class ConfigChannel extends AbstractChannel {

  ConfigChannel.fromName(super.channelName) : super.fromName();

  // 目前env 值有 sit 与 prod
  void initNativeConfig(String? env) async {
    methodChannel.invokeMethod('initConfig', { 'env': env ??= "sit" });
  }

}