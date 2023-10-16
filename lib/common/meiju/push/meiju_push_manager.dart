import 'dart:async';
import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/index.dart';
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

/// 获取WebSocket连接的地址
Future<String> getWebSocketAddress() async {
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
  return host + query;
}

/// 用户主动操作设备的消息延长推送时间
const int initiativeDelayPush = 20 * 1000;
/// 被动操作设备的消息延长推送时间
const int passivityDelayPush = 3 * 1000;
/// 最大连续重连次数
const int _maxRetryCount = 20;

class PushEventFunction {
  String id;
  void Function() call;
  PushEventFunction.create(this.id, this.call);
}

class MeiJuPushManager {

  static IOWebSocketChannel? _channel;
  static int _isConnect = 0; // 0 未连接 1 连接中  2已连接
  static int retryCount = 0;

  static Timer? _globalTimer;
  static int _sendHearTimerInterval = 60000;
  static var lastBeatHearTime = DateTime.now().millisecondsSinceEpoch;
  /// 记录用户操作的设备
  /// 操作设备之后，设备的推送事件将延迟10s
  /// 被动接收云端推送的设备的推送事件延迟3s
  /// 记录用户操作的设备ID、延迟通知时间
  static Map<String, Pair<int, PushEventFunction?>> operatePushRecord = {};

  // 用途：内存缓存，避免重复构建
  static List<Pair<int, PushEventFunction?>> unoccupiedPair = [];

  /// 获取pair
  static Pair<int, PushEventFunction?> getOrGeneratePair1(int time) {
    if(unoccupiedPair.isNotEmpty) {
      var pair = unoccupiedPair.removeAt(0);
      pair.value1 = time;
      pair.value2 = null;
      return pair;
    } else {
      return Pair.of(time, null);
    }
  }

  static Pair<int, PushEventFunction?> getOrGeneratePair2(int time, String id, void Function() func) {
    if(unoccupiedPair.isNotEmpty) {
      var pair = unoccupiedPair.removeAt(0);
      pair.value1 = time;
      pair.value2 = pair.value2 ?? PushEventFunction.create(id, func);
      pair.value2!.id = id;
      pair.value2!.call = func;
      return pair;
    } else {
      return Pair.of(time, PushEventFunction.create(id, func));
    }
  }

  /// 回收pair
  static void recyclePair(Pair<int, PushEventFunction?> pair) {
    /// 支持20个设备的缓存
    if(unoccupiedPair.length <= 20) {
      unoccupiedPair.add(pair);
    }
  }


  static bool isConnect() {
    return _isConnect == 2;
  }

  static void _operateDevice(String deviceId) {
    Log.file('[ WebSocket ] 操作设备 设备id$deviceId');
    if(operatePushRecord.containsKey(deviceId)) {
      var pair = operatePushRecord[deviceId]!;
      pair.value1 = DateTime.now().millisecondsSinceEpoch + initiativeDelayPush;
      operatePushRecord[deviceId] = pair;
    } else {
      operatePushRecord[deviceId] = getOrGeneratePair1(DateTime.now().millisecondsSinceEpoch + initiativeDelayPush);
    }
  }

  static void _netConnectState(NetState? state) {
    if(state?.wifiState == 2 || state?.ethernetState == 2) {
      Log.file('[ WebSocket ] 检测到已连接网络');
      if(_isConnect == 0) {
        retryCount = 0;
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
      Log.file('[ WebSocket ] 关闭连接，原因：$reason');
      _isConnect = 0;

      _globalTimer?.cancel();
      _globalTimer = null;

      operatePushRecord.clear();

      _channel?.sink.close();

      _aliPushUnBind();

      bus.off('operateDevice');
    }
  }

  static void _startConnect(String reason) async {
    // 延迟两秒连接
    await Future.delayed(const Duration(seconds: 2));

    if(retryCount >= _maxRetryCount) {
      _stopConnect('[ WebSocket ]超过最大连接次数');
      return;
    }

    if (MeiJuGlobal.isLogin && _isConnect == 0) {
      Log.file('[ WebSocket ] 即将建立连接, 原因$reason 尝试次数$retryCount');
      retryCount++;
      _isConnect = 1;

      _globalTimer?.cancel();
      _globalTimer = null;
      operatePushRecord.clear();
      _channel?.sink.close();
      bus.off('operateDevice');

      try {
        _aliPushBind();
        _updatePushToken();
        _channel = IOWebSocketChannel.connect(await getWebSocketAddress(),
            pingInterval: const Duration(seconds: 10),
            connectTimeout: const Duration(seconds: 8));
        _channel?.stream.listen(_onData, onError: _onError, onDone: _onDone);
        _isConnect = 2;
        bus.on('operateDevice', _operateDevice);
      } catch (e) {
        Log.e("[ WebSocket ] 捕捉异常", e);
        _isConnect = 0;
        _startConnect("捕捉到异常，准备重新连接");
        return;
      }

      _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if(_isConnect == 2) {
          if(MeiJuGlobal.isLogin) {
            /// 发送订阅任务
            var currTimer = DateTime.now();
            /// 发送心跳业务
            if((currTimer.millisecondsSinceEpoch - lastBeatHearTime >= _sendHearTimerInterval)) {
              _sendBeatHeart();
              lastBeatHearTime = currTimer.millisecondsSinceEpoch;
            }
            /// 执行延迟消息推送队列任务
            operatePushRecord.removeWhere((key, element) {
              int exeTime = element.value1;
              if(currTimer.millisecondsSinceEpoch >= exeTime) {
                element.value2?.call();
                recyclePair(element);
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
  }

  static _sendBeatHeart() {
    Map<String,dynamic> map = <String,dynamic>{};
    map['id'] = Random().nextInt(1<<32);
    map['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    map['event_type'] = 5;
    map['sign'] = null;
    map['data'] = null;
    Log.i('[ WebSocket ] send beat heart ${convert.jsonEncode(map)}');
    _channel?.sink.add(convert.jsonEncode(map));
  }

  static void _onData(event) {
    retryCount = 0;
    Map<String,dynamic> eventMap = json.decode(event);
    Log.i('[ WebSocket ] 接收到的Push消息: $eventMap');
    switch(eventMap['event_type']) {
      case 0:
        Log.file('[ WebSocket ] recv beat heart');
        break;
      case 1:
        String data = eventMap['data'];
        Map<String,dynamic> dataMap = json.decode(data);
        _sendHearTimerInterval = dataMap['heatbeat_interval'];
        Log.i('[ WebSocket ] 接收到心跳发送间隔时间: $_sendHearTimerInterval');
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
                    if(!operatePushRecord.containsKey(nodeId)) {
                      operatePushRecord[nodeId] = getOrGeneratePair2(
                          DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
                          "gemini/appliance/event", () => bus.typeEmit(MeiJuSubDevicePropertyChangeEvent(nodeId))
                      );
                    } else {
                      var pair = operatePushRecord[nodeId]!;
                      if(pair.value2?.id != "gemini/appliance/event") {
                        pair.value2 = switch(pair.value2) {
                          null => PushEventFunction.create("gemini/appliance/event",
                                  () => bus.typeEmit(MeiJuSubDevicePropertyChangeEvent(nodeId))),
                          _ => pair.value2!
                            ..id = "gemini/appliance/event"
                            ..call = () => bus.typeEmit(MeiJuSubDevicePropertyChangeEvent(deviceId))
                        };
                        operatePushRecord[deviceId] = pair;
                      }
                    }
                  }
                } else { // wifi设备状态推送
                  if(!operatePushRecord.containsKey(deviceId)) {
                    operatePushRecord[deviceId] = getOrGeneratePair2(
                        DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
                        "gemini/appliance/event",
                        () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))
                    );
                  } else {
                    var pair = operatePushRecord[deviceId]!;
                    if(pair.value2?.id != "gemini/appliance/event") {
                      pair.value2 = switch(pair.value2) {
                        null => PushEventFunction.create("gemini/appliance/event",
                                () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))),
                        _ => pair.value2!
                          ..id = "gemini/appliance/event"
                          ..call = () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))
                      };
                      operatePushRecord[deviceId] = pair;
                    }
                  }
                }
              }
            } else if(type == "thing/properties/change") {
              String? deviceId = msgMap['applianceCode'];
              if(deviceId == null) return;
              if(!operatePushRecord.containsKey(deviceId)) {
                operatePushRecord[deviceId] = getOrGeneratePair2(
                    DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
                    "thing/properties/change",
                        () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))
                );
              } else {
                var pair = operatePushRecord[deviceId]!;
                if(pair.value2?.id != "thing/properties/change") {
                  pair.value2 = switch(pair.value2) {
                    null => PushEventFunction.create("thing/properties/change",
                            () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))),
                    _ => pair.value2!
                      ..id = "gemini/appliance/event"
                      ..call = () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))
                  };
                  operatePushRecord[deviceId] = pair;
                }
              }
            } else if (type == 'appliance/status/report') {
              if(msgMap.containsKey('applianceId')) {
                String deviceId = msgMap['applianceId'];
                if(!operatePushRecord.containsKey(deviceId)) {
                  operatePushRecord[deviceId] = getOrGeneratePair2(
                      DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
                      "appliance/status/report",
                      () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))
                  );
                } else {
                  var pair = operatePushRecord[deviceId]!;
                  if(pair.value2?.id != "appliance/status/report") {
                    pair.value2 = switch(pair.value2) {
                      null => PushEventFunction.create("appliance/status/report",
                              () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))),
                      _ => pair.value2!
                        ..id = "appliance/status/report"
                        ..call = () => bus.typeEmit(MeiJuWifiDevicePropertyChangeEvent(deviceId))
                    };
                    operatePushRecord[deviceId] = pair;
                  }
                }
              }
            } else if(type == 'appliance/online/status/off') {
              // 设备离线通知
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                if(!operatePushRecord.containsKey(deviceId)) {
                  operatePushRecord[deviceId] = getOrGeneratePair2(
                      DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
                      "appliance/online/status/off",
                      () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, false))
                  );
                } else {
                  var pair = operatePushRecord[deviceId]!;
                  if (pair.value2?.id != 'appliance/online/status/off') {
                    pair.value2 = switch(pair.value2) {
                      null => PushEventFunction.create("appliance/online/status/off",
                              () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, false))),
                      _ => pair.value2!
                        ..id = "appliance/online/status/on"
                        ..call = () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, false))
                    };
                    operatePushRecord[deviceId] = pair;
                  }
                }
              }
            } else if(type == 'appliance/online/status/on') {
              // 设备在线通知
              if (msgMap.containsKey('applianceCode')) {
                String deviceId = msgMap['applianceCode'];
                if(!operatePushRecord.containsKey(deviceId)) {
                  operatePushRecord[deviceId] = getOrGeneratePair2(
                      DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
                      "appliance/online/status/on",
                      () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, true)));
                } else {
                  var pair = operatePushRecord[deviceId]!;
                  if (pair.value2?.id != 'appliance/online/status/on') {
                    pair.value2 = switch(pair.value2) {
                      null => PushEventFunction.create("appliance/online/status/on", () =>
                            bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, true))),
                      _ => pair.value2!
                        ..id = "appliance/online/status/on"
                        ..call = () => bus.typeEmit(MeiJuDeviceOnlineStatusChangeEvent(deviceId, true))
                    };
                    operatePushRecord[deviceId] = pair;
                  }
                }
              }
            } else {
              Log.file('[WebSocket ] 该推送类型不进行处理 $type');
            }
          }
        }
        break;
    }
  }
  // ALI 推送通知
  static notifyPushMessage(String title) {
    Log.file('[ WebSocket ] 啊里推送 $title');
    if(title == '添加设备') {
      bus.typeEmit(MeiJuDeviceAddEvent());
    } else if(title == '删除设备') {
      bus.typeEmit(MeiJuDeviceDelEvent());
    } else if(title == '解绑设备') {
      bus.typeEmit(MeiJuDeviceUnbindEvent());
    }
  }

  static void _onError(err) {
    Log.file('[ WebSocket ] onError $err');
  }

  static void _onDone() async {
    if (MeiJuGlobal.isLogin) {
      await Future.delayed(const Duration(seconds: 2));
      var state = NetUtils.getNetState();
      if(state != null) {
        _stopConnect('接收到done事件，断开连接');
        _startConnect('接收到done事件，断开连接');
      } else {
        _stopConnect('接收到done事件，断开连接');
      }
    }
  }

  // 按云端要求，可以不用请求订阅接口
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
    String deviceId = await aliPushChannel.getDeviceId();
    if(StrUtils.isNullOrEmpty(deviceId)) {
      Log.file("[ WebSocket ] 绑定阿里推送失败 deviceId为空");
      return;
    }
    MeiJuApi.requestMideaIot(
        "/push/bind",
        data: {
          'alias': MeiJuGlobal.token?.uid,
          'lang': 'zh_cn',
          'android': {
            'model' : 'ALIYUN',
            'bundle_id' : 'com.media.light',
            'token' : deviceId,
            'deviceId' : System.deviceId
          }
        },
        options: Options(
            method: 'POST',
            headers: {'Authorization' : "Basic ${base64Encode(utf8.encode('${dotenv.get('ALI_PUSH_USER_NAME')}:${dotenv.get('ALI_PUSH_PASSWORD')}'))}"}
        )).then((value) {
          Log.file("[ WebSocket ] 绑定阿里推送成功");
        }, onError: (e) {
          Log.file("[ WebSocket ] 绑定阿里推送失败");
        });
  }

  static _aliPushUnBind() async {
    String deviceId = await aliPushChannel.getDeviceId();
    if(StrUtils.isNullOrEmpty(deviceId)) {
      Log.file("[ WebSocket ] 解绑阿里推送失败 deviceId为空");
      return;
    }
    MeiJuApi.requestMideaIot(
        "/push/bind",
        data: {
          'alias': MeiJuGlobal.token?.uid,
          'lang': 'zh_cn',
          'android': {
            'model' : 'ALIYUN',
            'token' : '',
            'cur_token' : deviceId,
            'deviceId' : System.deviceId
          }
        },
        options: Options(
            method: 'POST',
            headers: {'Authorization': "Basic ${base64Encode(utf8.encode('${dotenv.get('ALI_PUSH_USER_NAME')}:${dotenv.get('ALI_PUSH_PASSWORD')}'))}" }
        )).then((value) {
          Log.file("[ WebSocket ] 解绑阿里推送成功");
        }, onError: (e) {
          Log.file("[ WebSocket ] 解绑阿里推送失败");
        });
  }

  static _updatePushToken() async {
    String deviceId = await aliPushChannel.getDeviceId();
    if(StrUtils.isNullOrEmpty(deviceId)) {
      Log.file("[ WebSocket ] 绑定阿里推送失败 deviceId为空");
      return;
    }
    await MeiJuApi.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/user/push/token/update",
        data: {
          'uid': MeiJuGlobal.token?.uid,
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

  static String _doubleEscapeString(String str) {
    return str.replaceAll("\\\\", "\\").replaceAll("\\\"", "\"");
  }
}


