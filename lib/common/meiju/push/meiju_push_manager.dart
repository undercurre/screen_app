import 'dart:async';
import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/push/event/meiju_push_event.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

import '../../../widgets/event_bus.dart';
import '../../logcat_helper.dart';
import '../../system.dart';
import '../api/meiju_api.dart';

class MeiJuPushManager {

  static Timer? _timer;
  static Timer? _subscriptTimer;
  static IOWebSocketChannel? _channel;
  static bool _isConnect = false;

  static bool isConnect() {
    return _isConnect;
  }

  static void stopConnect() {
    if(_isConnect) {
      _isConnect = false;
      if (_timer?.isActive ?? false) {
        _timer?.cancel();
      }

      if (_subscriptTimer?.isActive ?? false) {
        _subscriptTimer?.cancel();
      }

      _channel?.sink.close();

      _aliPushUnBind();
    }
  }

  static Future<void> startConnect() async {
    _isConnect = false;
    if (MeiJuGlobal.isLogin) {
      _aliPushBind();
      _updatePushToken();

      String host = 'wss://${dotenv.get('SSE_URL')}';
      String query = '/v1/ws/access?';
      query += 'src_token=1000&';
      query += 'req=${const Uuid().v4()}&';
      query += 'token=${MeiJuGlobal.token?.accessToken}&';
      query += 'appid=${dotenv.get('IOT_APP_COUNT')}&';
      query += 'client_type=4&';
      query += 'reset=1&';
      query += 'offset=0&';
      query += 'version=${await aboutSystemChannel.getSystemVersion()}&';
      query += 'timestamp=${DateTime.now().millisecondsSinceEpoch}&';
      query += 'device_id=${System.deviceId}&';
      Digest sign = md5.convert(utf8.encode('$query${dotenv.get('SSE_SECRET')}'));
      query += 'sign=$sign';

      _channel = IOWebSocketChannel.connect(host + query,pingInterval:const Duration(seconds: 10),connectTimeout:const Duration(seconds: 8));
      _channel?.stream.listen(_onData,onError:_onError,onDone: _onDone);

      if (!(_subscriptTimer?.isActive ?? false)) {
        _subscriptTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
          _subscriptionSet();
        });
      }
      _isConnect = true;
    }
  }

  static startBeatHeart(int interval) {
    if (!(_timer?.isActive ?? false)){
      _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
        Map<String,dynamic> map = <String,dynamic>{};
        map['id'] = Random().nextInt(1<<32);
        map['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        map['event_type'] = 5;
        map['sign'] = null;
        map['data'] = null;
        Log.i('send beat heart ${convert.jsonEncode(map)}');
        _channel?.sink.add(convert.jsonEncode(map));
      });
    }
  }

  static void _onData(event) {
    Map<String,dynamic> eventMap = json.decode(event);
    Log.file('美居 接收到的Push消息: $eventMap');
    switch(eventMap['event_type']) {
      case 0:
        Log.file('meiju see recv beat heart');
        break;
      case 1:
        String data = eventMap['data'];
        Map<String,dynamic> dataMap = json.decode(data);
        startBeatHeart(dataMap['heatbeat_interval']);
        break;
      case 2:
        String data = eventMap['data'];
        var splits = data.split(';');
        if (splits.length > 3) {
          String msg = _doubleEscapeString(splits[2]);
          Map<String,dynamic> msgMap = json.decode(msg);
          String type = msgMap['pushType'];
          if (MeiJuGlobal.isLogin) {
            if (type == 'gemini/appliance/event') {
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                if (msgMap.containsKey('event')) { // 判定子设备推送
                  String event = (msgMap['event'] as String).replaceAll("\\\"", "\"");
                  Map<String,dynamic> eventMap = json.decode(event);
                  if (eventMap.containsKey("nodeId")) {
                    String nodeId = eventMap['nodeId'] as String;
                    bus.typeEmit(MeiJuSubDevicePropertyChangeEvent(nodeId));
                  }
                } else { // wifi设备状态推送
                  bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId));
                }
              }
            } else if (type == 'appliance/status/report') {
              if(msgMap.containsKey('applianceId')) {
                String deviceId = msgMap['applianceId'];
                bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId));
              }
            } else if(type == 'appliance/online/status/off') {
              // 设备离线通知
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, false));
              }
            } else if(type == 'appliance/online/status/on') {
              // 设备在线通知
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, true));
              }
            }
          }
        }
        break;
    }
  }
  // ALI 推送通知
  static notifyPushMessage(String title) {
    Log.file('美居 ali推送 $title');
    if(title == '添加设备') {
      bus.typeEmit(MeiJuDeviceAddEvent());
    } else if(title == '删除设备') {
      bus.typeEmit(MeiJuDeviceDelEvent());
    } else if(title == '解绑设备') {
      bus.typeEmit(MeiJuDeviceUnbindEvent());
    }
  }

  static void _onError(err) {
    Log.file('美居 push hjl $err');
  }

  static void _onDone() {
    stopConnect();
    if (MeiJuGlobal.isLogin &&
        MeiJuGlobal.homeInfo != null &&
        MeiJuGlobal.roomInfo != null) {
      startConnect();
    }
  }

  static _subscriptionSet() {
    MeiJuApi.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/push/subscription/set",
        data: {
          'reqId': const Uuid().v4(),
          'stamp': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
        },
        options: Options(
          method: 'POST',
        ));
  }

  static _aliPushBind() async {
    await MeiJuApi.requestMideaIot(
        "/push/bind",
        data: {
          'alias': MeiJuGlobal.token?.uid,
          'lang': 'zh_cn',
          'android': {
            'model' : 'ALIYUN',
            'bundle_id' : 'com.media.light',
            'token' : await aliPushChannel.getDeviceId(),
            'deviceId' : System.deviceId
          }
        },
        options: Options(
            method: 'POST',
            headers: {'Authorization' : "Basic ${base64Encode(utf8.encode('${dotenv.get('ALI_PUSH_USER_NAME')}:${dotenv.get('ALI_PUSH_PASSWORD')}'))}"}
        ));
  }

  static _aliPushUnBind() async {
    await MeiJuApi.requestMideaIot(
        "/push/bind",
        data: {
          'alias': MeiJuGlobal.token?.uid,
          'lang': 'zh_cn',
          'android': {
            'model' : 'ALIYUN',
            'token' : '',
            'cur_token' : await aliPushChannel.getDeviceId(),
            'deviceId' : System.deviceId
          }
        },
        options: Options(
            method: 'POST',
            headers: {'Authorization': "Basic ${base64Encode(utf8.encode('${dotenv.get('ALI_PUSH_USER_NAME')}:${dotenv.get('ALI_PUSH_PASSWORD')}'))}" }
        ));
  }

  static _updatePushToken() async {
    await MeiJuApi.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/user/push/token/update",
        data: {
          'uid': MeiJuGlobal.token?.uid,
          'pushToken': await aliPushChannel.getDeviceId(),
          'clientType': 1,
          'pushType': 5,
          'reqId': const Uuid().v4(),
          'stamp': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
        },
        options: Options(
          method: 'POST',
        ));
  }

  static String _doubleEscapeString(String str) {
    return str.replaceAll("\\\\", "\\").replaceAll("\\\"", "\"");
  }
}


