

import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';

class AboutSystemChannel extends AbstractChannel {
  
  AboutSystemChannel.fromName(super.channelName) : super.fromName();
  
  Future<String> getSystemVersion() async {
    return await methodChannel.invokeMethod("getSystemVersion");
  }

  Future<String> getIpAddress() async {
    return await methodChannel.invokeMethod("getIpAddress");
  }

  Future<String> getMacAddress() async {
    return await methodChannel.invokeMethod("getMacAddress");
  }

  Future<String?> getGatewaySn() async {
    try {
      String sn = await methodChannel.invokeMethod("getGatewaySn");
      return sn;
    } on PlatformException catch(e) {
      print(e);
    }
    return null;
  }

  Future<String> reboot() async {
    return await methodChannel.invokeMethod("reboot");
  }
  
}