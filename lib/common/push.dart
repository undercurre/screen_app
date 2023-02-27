import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/setting/about_setting.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class Push {
  static Timer? _timer;
  static Timer? _subscriptTimer;
  static IOWebSocketChannel? _channel;

  static Future<void> sseInit() async {
    if (Global.isLogin) {
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

      logger.i("hjl url = ${host+query}");

      _channel = IOWebSocketChannel.connect(host + query,pingInterval:const Duration(seconds: 10),connectTimeout:const Duration(seconds: 8));
      _channel?.stream.listen(onData,onError:onError,onDone: onDone);

      if (!(_subscriptTimer?.isActive ?? false)) {
        _subscriptTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
          subscriptionSet();
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

  static void onData(event) {
    logger.i('hjl event $event');
    Map<String,dynamic> eventJson = json.decode(event);
    switch(eventJson['event_type']) {
      case 0:
        logger.i('see recv beat heart');
        break;
      case 1:
        String data = eventJson['data'];
        Map<String,dynamic> dataJson = json.decode(data);
        startBeatHeart(dataJson['heatbeat_interval']);
        break;
      case 2:
        String data = eventJson['data'];
        var splits = data.split(';');
        if (splits.length > 3) {
          String msg = doubleEscapeString(splits[2]);
        }
        break;
    }
  }

  static void onError(err) {
    logger.i('hjl $err');
  }

  static void onDone(){
    logger.i('hjl +++');
    dispose();
    sseInit();
  }

  static void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    if (_subscriptTimer?.isActive ?? false) {
      _subscriptTimer?.cancel();
    }

    _channel?.sink.close();
  }

  static subscriptionSet() {
    var res = Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/user/push/subscription/set",
        data: {
          'reqId': const Uuid().v4(),
          'stamp': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
        },
        options: Options(
          method: 'POST',
        ));
  }

  static updatePushToken(String deviceId) {
    var res = Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/user/push/token/update",
        data: {
          'uid': Global.profile.user?.uid,
          'pushToken': deviceId,
          'clientType': 1,
          'pushType': 5,
          'reqId': const Uuid().v4(),
          'stamp': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
        },
        options: Options(
          method: 'POST',
        ));
  }

  static String doubleEscapeString(String str) {
    return str.replaceAll("\\\\", "\\").replaceAll("\\\"", "\"");
  }
}

