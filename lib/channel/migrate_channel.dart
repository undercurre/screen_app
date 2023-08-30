

import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/common/global.dart';

class MigrateChannel extends AbstractChannel {

  MigrateChannel.fromName(super.channelName) : super.fromName();

  Future<List<Map<String, dynamic>>> syncWiFi() async {
    List<Map<String, dynamic>> wifis = await methodChannel.invokeMethod('syncWiFi') as List<Map<String, dynamic>>;
    logger.i(wifis);
    return wifis;
  }

  Future<Map<String, dynamic>?> syncToken() async {
    final res = await methodChannel.invokeMethod<Map<String, dynamic>>('syncToken');
    logger.i(res);
    return res;
  }

  Future<Map<String, dynamic>?> syncUserData() async {
    Map<String, dynamic>? user = await methodChannel.invokeMethod<Map<String, dynamic>>('syncUserData');
    logger.i(user);
    return user;
  }

  Future<Map<String, dynamic>?> syncHomluxToken() async {
    final res = await methodChannel.invokeMethod<Map<String, dynamic>>('syncHomluxToken');
    logger.i(res);
    return res;
  }

  Future<Map<String, dynamic>?> syncHomluxFamily() async {
    Map<String, dynamic>? res = await methodChannel.invokeMethod<Map<String, dynamic>>('syncHomluxFamily');
    logger.i(res);
    return res;
  }

    Future<Map<String, dynamic>?> syncHomluxRoom() async {
    Map<String, dynamic>? res = await methodChannel.invokeMethod<Map<String, dynamic>>('syncHomluxRoom');
    logger.i(res);
    return res;
  }

  Future<Map<String, dynamic>?> syncHomluxUserInfo() async {
    Map<String, dynamic>? res = await methodChannel.invokeMethod<Map<String, dynamic>>('syncHomluxUserData');
    logger.i(res);
    return res;
  }

  Future<Map<String, dynamic>?> syncGatewayApplianceCode() async {
    Map<String, dynamic>? res = await methodChannel.invokeMethod<Map<String, dynamic>>('syncGatewayApplianceCode');
    logger.i(res);
    return res;
  }

}