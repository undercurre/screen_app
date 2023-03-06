

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

}