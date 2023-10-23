import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/common/index.dart';

import '../common/logcat_helper.dart';

class AboutSystemChannel extends AbstractChannel {
  Map<String, String> encryptSnMap = {};
  String? decryptSn;
  
  AboutSystemChannel.fromName(super.channelName) : super.fromName();

  Future<String> getAppVersion() async {
    return await methodChannel.invokeMethod('getAppVersion');
  }

  void translateToProductionTestPage() {
    methodChannel.invokeMethod('translateToProductionTestPage');
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
    if(isEncrypt && (encryptSnMap[secretKey]?.isNotEmpty ?? false)) {
      Log.i('获取到加密的SN = ${encryptSnMap[secretKey]}');
      return encryptSnMap[secretKey];
    } else if(!isEncrypt && decryptSn != null) {
      Log.i('获取到非加密的SN = $decryptSn');
      return decryptSn;
    } else {
      try {
        assert(isEncrypt && StrUtils.isNotNullAndEmpty(secretKey) || !isEncrypt);
        String sn = await methodChannel.invokeMethod("getGatewaySn", {'isEncrypt': isEncrypt, 'secretKey': secretKey ?? ''});
        if(isEncrypt && sn.isNotEmpty) {
          Log.i('保存加密的SN = $sn');
          encryptSnMap[secretKey!] = sn;
        } else if(!isEncrypt && sn.isNotEmpty) {
          Log.i('保存非加密的SN = $sn');
          decryptSn = sn;
        }
        return sn;
      } on PlatformException catch(e) {
        Log.file(e.toString());
      }
    }
    return null;
  }

  Future<bool> reboot() async {
    return await methodChannel.invokeMethod("reboot");
  }
  
}