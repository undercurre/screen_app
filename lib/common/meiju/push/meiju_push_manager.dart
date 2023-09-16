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

import '../../../channel/models/net_state.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/util/net_utils.dart';
import '../../helper.dart';
import '../../logcat_helper.dart';
import '../../system.dart';
import '../api/meiju_api.dart';

/// 消息延长推送时间
const int delayPush = 10 * 1000;

class MeiJuPushManager {

  static IOWebSocketChannel? _channel;
  static int _isConnect = 0;

  static Timer? _globalTimer;
  static int? _sendHearTimerInterval;
  /// 记录设备ID、延迟通知时间
  static Map<String, Pair<int, void Function()>> pushRecord = {};

  static bool isConnect() {
    return _isConnect == 2;
  }

  static void _operateDevice(String deviceId) {
    if(pushRecord.containsKey(deviceId)) {
      var pair = pushRecord[deviceId]!;
      pushRecord[deviceId] = Pair.of(DateTime.now().millisecondsSinceEpoch + delayPush, pair.value2);
    }
  }

  static void _netConnectState(NetState? state) {
    if(state?.wifiState == 2 || state?.ethernetState == 2) {
      Log.file('meiju ws 检测到已连接网络');
      if(_isConnect == 0) {
        _startConnect('检测到网络已连接');
      }
    } else {
      _stopConnect('检测到未连接网络');
    }
  }

  static void stopConnect() {
    NetUtils.unregisterListenerNetState(_netConnectState);
    _stopConnect("切换平台，关闭连接");
  }

  static void startConnect() {
    NetUtils.registerListenerNetState(_netConnectState);
  }

  static void _stopConnect(String reason) {
    if(_isConnect == 2) {
      Log.file('meiju ws 关闭连接，原因：$reason');
      _isConnect = 0;
      _sendHearTimerInterval = null;

      if (_globalTimer?.isActive ?? false) {
        _globalTimer?.cancel();
        _globalTimer = null;
      }

      pushRecord.clear();

      _channel?.sink.close();

      _aliPushUnBind();

      bus.off('operateDevice');
    }
  }

  static void _startConnect(String reason) async {

    if (MeiJuGlobal.isLogin) {
      Log.file('meiju ws 即将建立连接, 原因$reason');

      _isConnect = 1;

      _sendHearTimerInterval = null;
      _globalTimer?.cancel();
      _globalTimer = null;
      pushRecord.clear();
      _channel?.sink.close();
      _aliPushUnBind();
      bus.off('operateDevice');

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

      _isConnect = 2;

      if(!(_globalTimer?.isActive ?? false)) {
        var lastSubscriptionTime = DateTime.now().millisecondsSinceEpoch;
        var lastBeatHearTime = DateTime.now().millisecondsSinceEpoch;

        _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if(_isConnect == 2) {
            if(MeiJuGlobal.isLogin) {

              /// 发送订阅任务
              var currTimer = DateTime.now();
              // 按云端要求，可以不用请求订阅接口
              // if(currTimer.millisecondsSinceEpoch - lastSubscriptionTime > 60 * 1000) {
              //   _subscriptionSet();
              //   lastSubscriptionTime = currTimer.millisecondsSinceEpoch;
              // }

              /// 发送心跳业务
              if(_sendHearTimerInterval != null &&
                  (currTimer.millisecondsSinceEpoch - lastBeatHearTime >= _sendHearTimerInterval!)) {
                _sendBeatHeart();
                lastBeatHearTime = currTimer.millisecondsSinceEpoch;
              }

              /// 执行延迟消息推送队列任务
              pushRecord.removeWhere((key, element) {
                int exeTime = element.value1;
                if(currTimer.millisecondsSinceEpoch >= exeTime) {
                  element.value2.call();
                }
                return currTimer.millisecondsSinceEpoch >= exeTime;
              });

            } else {
              _stopConnect('检测到退出登录，即将断开推送连接');
            }
          } else {
            timer.cancel();
          }
        });
      }

      bus.on('operateDevice', _operateDevice);
    }
  }

  static _sendBeatHeart() {
    Map<String,dynamic> map = <String,dynamic>{};
    map['id'] = Random().nextInt(1<<32);
    map['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    map['event_type'] = 5;
    map['sign'] = null;
    map['data'] = null;
    Log.i('send beat heart ${convert.jsonEncode(map)}');
    _channel?.sink.add(convert.jsonEncode(map));
  }

  static void _onData(event) {
    Map<String,dynamic> eventMap = json.decode(event);
    Log.file('meiju ws 接收到的Push消息: $eventMap');
    switch(eventMap['event_type']) {
      case 0:
        Log.file('meiju see recv beat heart');
        break;
      case 1:
        String data = eventMap['data'];
        Map<String,dynamic> dataMap = json.decode(data);
        _sendHearTimerInterval = dataMap['heatbeat_interval'];
        Log.i('meiju ws 接收到心跳发送间隔时间: $_sendHearTimerInterval');
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
                    if(!pushRecord.containsKey(nodeId)) {
                      pushRecord[nodeId] = Pair.of(DateTime.now().millisecondsSinceEpoch + delayPush,
                              () => bus.typeEmit(MeiJuSubDevicePropertyChangeEvent(nodeId)));
                    }
                  }
                } else { // wifi设备状态推送
                  if(!pushRecord.containsKey(deviceId)) {
                    pushRecord[deviceId] = Pair.of(DateTime.now().millisecondsSinceEpoch + delayPush,
                            () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId)));
                  }
                }
              }
            } else if (type == 'appliance/status/report') {
              if(msgMap.containsKey('applianceId')) {
                String deviceId = msgMap['applianceId'];
                if(!pushRecord.containsKey(deviceId)) {
                  pushRecord[deviceId] = Pair.of(DateTime.now().millisecondsSinceEpoch + delayPush,
                          () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId)));
                }
              }
            } else if(type == 'appliance/online/status/off') {
              // 设备离线通知
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                if(!pushRecord.containsKey(deviceId)) {
                  pushRecord[deviceId] = Pair.of(DateTime.now().millisecondsSinceEpoch + delayPush,
                          () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, false)));
                }
              }
            } else if(type == 'appliance/online/status/on') {
              // 设备在线通知
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                if(!pushRecord.containsKey(deviceId)) {
                  pushRecord[deviceId] = Pair.of(DateTime.now().millisecondsSinceEpoch + delayPush,
                          () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, true)));
                }
              }
            }
          }
        }
        break;
    }
  }
  // ALI 推送通知
  static notifyPushMessage(String title) {
    Log.file('meiju ws  ali推送 $title');
    if(title == '添加设备') {
      bus.typeEmit(MeiJuDeviceAddEvent());
    } else if(title == '删除设备') {
      bus.typeEmit(MeiJuDeviceDelEvent());
    } else if(title == '解绑设备') {
      bus.typeEmit(MeiJuDeviceUnbindEvent());
    }
  }

  static void _onError(err) {
    Log.file('meiju ws hjl $err');
  }

  static void _onDone() {
    if (MeiJuGlobal.isLogin) {
      var state = NetUtils.getNetState();
      if(state != null) {
        _startConnect('');
      } else {
        _stopConnect('接收到done事件，断开连接');
      }
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


