import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/global.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

typedef EventCallback = void Function(Map<String,dynamic> arg);

@Deprecated('此类已过期，请使用新方式对接')
class Push {
  static Timer? _timer;
  static Timer? _subscriptTimer;
  static IOWebSocketChannel? _channel;
  static Map<String,Timer?> delayMap = {};
  static final _emap = <String, List<EventCallback>>{};

  static Future<void> sseInit() async {
    if (Global.isLogin) {
      _aliPushBind();
      _updatePushToken();

      String host = 'wss://${dotenv.get('SSE_URL')}';
      String query = '/v1/ws/access?';
      query += 'src_token=1000&';
      query += 'req=${const Uuid().v4()}&';
      query += 'token=${Global.user?.accessToken}&';
      query += 'appid=${dotenv.get('IOT_APP_COUNT')}&';
      query += 'client_type=4&';
      query += 'reset=1&';
      query += 'offset=0&';
      query += 'version=${await aboutSystemChannel.getSystemVersion()}&';
      query += 'timestamp=${DateTime.now().millisecondsSinceEpoch}&';
      query += 'device_id=${Global.user?.deviceId}&';
      Digest sign = md5.convert(utf8.encode('$query${dotenv.get('SSE_SECRET')}'));
      query += 'sign=$sign';

      _channel = IOWebSocketChannel.connect(host + query,pingInterval:const Duration(seconds: 10),connectTimeout:const Duration(seconds: 8));
      _channel?.stream.listen(_onData,onError:_onError,onDone: _onDone);

      if (!(_subscriptTimer?.isActive ?? false)) {
        _subscriptTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
          _subscriptionSet();
        });
      }
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
        logger.i('send beat heart ${convert.jsonEncode(map)}');
        _channel?.sink.add(convert.jsonEncode(map));
      });
    }
  }

  static void _onData(event) {
    Map<String,dynamic> eventMap = json.decode(event);
    switch(eventMap['event_type']) {
      case 0:
        logger.i('see recv beat heart');
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
          if (Global.isLogin) {
            if (type == 'gemini/appliance/event') {
              if (msgMap.containsKey('applianceCode')){
                String deviceId = msgMap['applianceCode'];
                if (msgMap.containsKey('event')) {
                  String event = (msgMap['event'] as String).replaceAll("\\\"", "\"");
                  Map<String,dynamic> eventMap = json.decode(event);
                  if (eventMap.containsKey("nodeId")) {

                  }
                }

                _filterSameEvent(deviceId,type,msgMap);
              }
            } else if (type == 'appliance/status.report') {
              String deviceId = msgMap['applianceId'];
              _filterSameEvent(deviceId, type, msgMap);
            } else {
              _emap[type]?.forEach((element) {
                element(msgMap);
              });
            }
          }
        }
        break;
    }
  }

  static notifyPushMessage(String title) {
    _emap[title]?.forEach((element) {
      logger.i('hjl aliPushLog $title');
      element({});
    });
  }

  static listen(String type,EventCallback callback) {
    _emap[type] ??= <EventCallback>[];
    _emap[type]!.add(callback);
  }

  static dislisten(String type, [EventCallback? callback]) {
    var list = _emap[type];
    if (list == null) return;
    if (callback == null) {
      _emap.remove(type);
    }
    else {
      list.remove(callback);
    }
  }

  static _filterSameEvent(String deviceId,String pushType,Map<String, dynamic>? msg) {
    if (delayMap.containsKey(deviceId)) {
      if (delayMap[deviceId]?.isActive ?? false) {
        delayMap[deviceId]?.cancel();
      }
      delayMap.remove(deviceId);
    }

    Timer timer = Timer(const Duration(seconds: 4),(){
      _emap[pushType]?.forEach((element) {
        element(msg ?? {});
      });

      if (delayMap.containsKey(deviceId)) {
        delayMap.remove(deviceId);
      }
    });

    delayMap[deviceId] = timer;
  }

  static void _onError(err) {
    logger.i('hjl $err');
  }

  static void _onDone(){
    dispose();
    if (Global.isLogin &&
        Global.profile.homeInfo != null &&
        Global.profile.roomInfo != null) {
      sseInit();
    }
  }

  static void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    if (_subscriptTimer?.isActive ?? false) {
      _subscriptTimer?.cancel();
    }

    _channel?.sink.close();

    _aliPushUnBind();
  }

  static _subscriptionSet() {
    Api.requestMideaIot(
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
    await Api.requestMideaIot(
        "/push/bind",
        data: {
          'alias': Global.profile.user?.uid,
          'lang': 'zh_cn',
          'android': {
            'model' : 'ALIYUN',
            'bundle_id' : 'com.media.light',
            'token' : await aliPushChannel.getDeviceId(),
            'deviceId' : Global.user?.deviceId
          }
        },
        options: Options(
          method: 'POST',
          headers: {HttpHeaders.authorizationHeader : "Basic ${base64Encode(utf8.encode('${dotenv.get('ALI_PUSH_USER_NAME')}:${dotenv.get('ALI_PUSH_PASSWORD')}'))}"}
        ));
  }

  static _aliPushUnBind() async {
    await Api.requestMideaIot(
        "/push/bind",
        data: {
          'alias': Global.profile.user?.uid,
          'lang': 'zh_cn',
          'android': {
            'model' : 'ALIYUN',
            'token' : '',
            'cur_token' : await aliPushChannel.getDeviceId(),
            'deviceId' : Global.user?.deviceId
          }
        },
        options: Options(
            method: 'POST',
            headers: {HttpHeaders.authorizationHeader : "Basic ${base64Encode(utf8.encode('${dotenv.get('ALI_PUSH_USER_NAME')}:${dotenv.get('ALI_PUSH_PASSWORD')}'))}"}
        ));

  }

  static _updatePushToken() async {
    await Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/user/push/token/update",
        data: {
          'uid': Global.profile.user?.uid,
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

