

import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/common/index.dart';

class AboutSystemChannel extends AbstractChannel {
  
  AboutSystemChannel.fromName(super.channelName) : super.fromName();

  Future<String> getAppVersion() async {
    return await methodChannel.invokeMethod('getAppVersion');
  }

  Future<String> getGatewayVersion() async {
    return await methodChannel.invokeMethod('getGatewayVersion');
  }
  
  Future<String> getSystemVersion() async {
    return await methodChannel.invokeMethod("getSystemVersion");
  }

  Future<String> getIpAddress() async {
    return await methodChannel.invokeMethod("getIpAddress");
  }

  Future<String> getMacAddress() async {
    return await methodChannel.invokeMethod("getMacAddress");
  }

  Future<bool> clearLocalCache() async {
    return await methodChannel.invokeMethod('clearLocalCache') as bool;
  }

  /// return
  /// LD 
  /// JH
  Future<String> queryFlavor() async {
    return await methodChannel.invokeMethod('queryFlavor') as String;
  }

  // isEncrypt 是否加密
  Future<String?> getGatewaySn([bool isEncrypt = false, String? secretKey]) async {
    try {
      assert(isEncrypt && StrUtils.isNotNullAndEmpty(secretKey) || !isEncrypt);
      String sn = await methodChannel.invokeMethod("getGatewaySn", {'isEncrypt': isEncrypt, 'secretKey': secretKey ?? ''});
      return sn;
    } on PlatformException catch(e) {
      print(e);
    }
    return null;
  }

  Future<bool> reboot() async {
    return await methodChannel.invokeMethod("reboot");
  }
  
}