import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/homlux/push/homlux_push_message_model.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import 'package:web_socket_channel/io.dart';

import '../../../channel/models/net_state.dart';
import '../../../widgets/event_bus.dart';
import '../../helper.dart';
import '../../meiju/push/meiju_push_manager.dart';
import '../lan/homlux_lan_control_device_manager.dart';
import 'event/homlux_push_event.dart';

// //设备属性变化
const TypeConnectSuc = 'connect_success_status';
const TypeDeviceProperty = 'device_property';
const TypeScreenOnlineStatusSubDevice = 'screen_online_status_sub_device';
const TypeScreenOnlineStatusWifiDevice = 'screen_online_status_wifi_device';
const TypeScreenAddSubDevice = 'screen_add_sub_device';
const TypeScreenAddWiFiDevice = 'screen_add_wifi_device';
const TypeScreenEditSubDevice = 'screen_edit_sub_device';
const TypeScreenEditWiFiDevice = 'screen_edit_wifi_device';
const TypeScreenDelSubDevice = 'screen_del_sub_device';
const TypeScreenDelWiFiDevice = 'screen_del_wifi_device';
const TypeScreenMoveSubDevice = 'screen_move_sub_device';
const TypeScreenMoveWiFiDevice = 'screen_move_wifi_device';
const TypeSceneUpt = 'scene_upt';
const TypeSceneAdd = 'scene_add';
const TypeSceneDel = 'scene_del';
const TypeDelGateway = 'screen_del_gateway';
const TypeGroupUpt = 'group_upt';
const TypeGroupAdd = 'group_add';
const TypeGroupDel = 'group_del';
const TypeUpdateRoomName = 'update_room_name';
const TypeChangeHouse = 'change_house';
const TypeProjectChangeHouse = 'project_change_house';
const TypeDeleteHouseUser = 'del_house_user';
const TypeDeviceDel = 'device_del';
const TypeChangeUserAuth = 'change_house_user_auth';
const TypeQuitHouseUser = 'quit_house_user';
const TypeBindDevice = 'bind_device';



// 1.定义消息类型
// 2.定义消息数据解析Bean
// 3.发送消息

/// 心跳发送间隔
const _pingInterval = 30000;
/// 用户主动操作设备的消息延长推送时间
const int initiativeDelayPush = 20 * 1000;
/// 被动操作设备的消息延长推送时间
const int passivityDelayPush = 1 * 1500;
/// 最大连续重连次数
const int _maxRetryCount = 10;

class HomluxPushManager {

  static IOWebSocketChannel? _channel;
  static Timer? _globalTimer;
  static int _isConnect = 0;  // 0.未连接 1.连接中 2.已连接
  static int retryCount = 0;
  static int heartSendLastTime  = 0;

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


  static void deviceStatusChange(String deviceId, HomluxPushResultEntity entity) {
    if(!operatePushRecord.containsKey(deviceId)) {
      operatePushRecord[deviceId] = getOrGeneratePair2(
          DateTime.now().millisecondsSinceEpoch + passivityDelayPush,
          TypeDeviceProperty,
          () => bus.typeEmit(HomluxDevicePropertyChangeEvent.of(entity)));
    } else {
      var pair = operatePushRecord[deviceId]!;
      if(pair.value2?.id != TypeDeviceProperty) {
        operatePushRecord[deviceId] = getOrGeneratePair2(
            pair.value1,
            TypeDeviceProperty,
            () => bus.typeEmit(HomluxDevicePropertyChangeEvent.of(entity)));
      }
    }
  }

  static void _netConnectState(NetState? state) {
    if(state?.wifiState == 2 || state?.ethernetState == 2) {
      if(_isConnect == 0) {
        retryCount = 0;
        _startConnect('检测到已连接网络');
      }
    } else {
      _stopConnect('检测到未连接网络');
    }
  }

  static startConnect([int retrySeconds = 2]) async {
    NetUtils.registerListenerNetState(_netConnectState);
  }

  static bool isConnect() {
    return _isConnect == 2;
  }

  static void _operateDevice(String deviceId) {
    Log.file('操作设备 设备id $deviceId');
    if(operatePushRecord.containsKey(deviceId)) {
      var pair = operatePushRecord[deviceId]!;
      pair.value1 = DateTime.now().millisecondsSinceEpoch + initiativeDelayPush;
      operatePushRecord[deviceId] = pair;
    } else {
      operatePushRecord[deviceId] = getOrGeneratePair1(DateTime.now().millisecondsSinceEpoch + initiativeDelayPush);
    }
  }

  static void stopConnect() async {
    NetUtils.unregisterListenerNetState(_netConnectState);
    _stopConnect('切换平台断开连接');
  }

  static void init() {
    /// 消息处理全局定时器
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (HomluxGlobal.isLogin) {
          /// 发送订阅任务
          var currTimer = DateTime.now();

          try {
            if (_isConnect == 2) {
              // 检测心跳、发送心跳
              if (currTimer.millisecondsSinceEpoch - heartSendLastTime >= _pingInterval) {
                _channel?.sink.add(jsonEncode({'topic': 'heartbeatTopic', 'message': {"code": 999}}));
                heartSendLastTime = currTimer.millisecondsSinceEpoch;
              }
            }
          } catch (e) {
            Log.e("[WebSocket] 发送心跳失败",e );
          }

          /// 执行延迟消息推送队列任务
          operatePushRecord.removeWhere((key, element) {
            int exeTime = element.value1;
            if (currTimer.millisecondsSinceEpoch >= exeTime) {
              element.value2?.call();
              recyclePair(element);
            }
            return currTimer.millisecondsSinceEpoch >= exeTime;
          });

        } else {
          _stopConnect('检测到退出登录，即将断开推送连接');
        }
    });
    startConnect();
  }

  static void destroy() {
    _globalTimer?.cancel();
    stopConnect();
  }

  static Future _stopConnect(String reason) async {
    if(_isConnect > 0) {
      Log.file('[WebSocket]homlux ws 关闭连接, 关闭原因：$reason');
      // 1. 关闭旧连接, 定时器
      _isConnect = 0;
      _channel?.sink.close();
      _channel = null;
      bus.off('operateDevice');
    }
  }

  static _startConnect(String reason) async {
    Log.i('[WebSocket] 启动原因 $reason');

    // 延迟两秒连接
    await Future.delayed(const Duration(seconds: 2));

    if(retryCount >= _maxRetryCount) {
      _stopConnect('meiju ws 超过最大连接次数');
      return;
    }

    if(_isConnect == 0 && HomluxGlobal.isLogin) {

      _isConnect = 1;

      Log.file('[WebSocket]homlux ws 建立连接中 尝试次数$retryCount');
      // 1. 关闭旧连接, 定时器
      retryCount++;
      _channel?.sink.close();

      if (!HomluxGlobal.isLogin) {
        return;
      }

      // 1.1 判断是否能建立连接
      if(!System.isLogin() || !System.inHomluxPlatform()) {
        Log.file('[WebSocket]homlux ws 状态不符合，无法建立连接');
        return;
      }

      // 2.建立新连接
      try {
        bus.off('operateDevice');
        _channel = IOWebSocketChannel.connect(
            dotenv.get('HOMLUX_PUSH_WSS') + (HomluxGlobal.homluxHomeInfo?.houseId ?? ''),
            protocols: {
              HomluxGlobal.homluxQrCodeAuthEntity?.token ?? ''
            },
            // headers: {
            //   'Sec-WebSocket-Protocol': HomluxGlobal.homluxQrCodeAuthEntity?.token ?? ''
            // },
            pingInterval: const Duration(seconds: 10),
            connectTimeout: const Duration(seconds: 8));

        // 3.设置消息监听
        _channel?.stream.listen(_message, onError: _error, onDone: _done);

        _isConnect = 2;
        bus.on('operateDevice', _operateDevice);
      } catch (e) {
        _isConnect = 0;
        _startConnect('执行异常，尝试重连');
        return;
      }

    }
  }

  static _message(dynamic event) {
    Log.i('[WebSocket]homlux ws message $event');
    try {

      var jsonMap = jsonDecode(event) as Map<String, dynamic>;
      var eventType = jsonMap['result']?['eventType'] as String?;
      if (TypeConnectSuc == eventType) {
        Log.file('[WebSocket]websocket 建立连接成功');
        return;
      }

      var topic = jsonMap['result']?['topic'] as String?;
      if(topic == 'heartbeatTopic') {
        return;
      }
      retryCount = 0;
      // 重复消息过滤
      String? reqId = jsonMap['result']?['eventData']?['reqId'];
      if(HomluxLanControlDeviceManager.getInstant().handledMessageQueue.contains(reqId)) {
        Log.develop("[websocket] 重复消息去重 $reqId");
        return;
      } else if(reqId != null) {
        Log.develop("[websocket] 处理消息 $reqId");
        HomluxLanControlDeviceManager.getInstant().handledMessageQueue.add(reqId);
        if(HomluxLanControlDeviceManager.getInstant().handledMessageQueue.length >= 100) {
          HomluxLanControlDeviceManager.getInstant().handledMessageQueue.removeAt(0);
        }
      }
      _handleMessage(jsonMap);
    } catch(e) {
      Log.file('[WebSocket]homlux ws message error ->  $event $e');
    }
  }

  static _handleMessage(Map<String, dynamic> json) {
    var eventType = json['result']?['eventType'] as String?;
    HomluxPushMessageEntity entity = HomluxPushMessageEntity.fromJson(json);

    if(entity.result?.eventType == TypeDeviceProperty) {
      var deviceId = entity.result?.eventData?.deviceId;
      if(StrUtils.isNotNullAndEmpty(deviceId) && entity.result != null) {
        // var lanManager = HomluxLanControlDeviceManager.getInstant();
        // var lanContainer = lanManager.isEnable() && lanManager.deviceMap.containsKey(deviceId);
        // if(!lanContainer) { // 因局域网也会推送，则不再处理云端的推送
        //   deviceStatusChange(deviceId!, entity.result!);
        // }
        deviceStatusChange(deviceId!, entity.result!);
      }
    } else if(TypeDeviceDel == eventType) {
      bus.typeEmit(HomluxDeviceDelEvent.of(entity.result?.eventData?.deviceId ?? ""));
    } else if(TypeScreenOnlineStatusSubDevice == eventType|| TypeScreenOnlineStatusWifiDevice == eventType) {
      bus.typeEmit(HomluxDeviceOnlineStatusChangeEvent.of(entity.result!));
    } else if(TypeScreenAddSubDevice == eventType) {
      bus.typeEmit(HomluxAddSubEvent());
    } else if(TypeScreenAddWiFiDevice == eventType) {
      bus.typeEmit(HomluxAddWifiEvent());
    } else if(TypeScreenEditSubDevice == eventType) {
      bus.typeEmit(HomluxEditSubEvent());
    } else if(TypeScreenEditWiFiDevice == eventType) {
      bus.typeEmit(HomluxEditWifiEvent());
    } else if(TypeScreenDelSubDevice == eventType) {
      bus.typeEmit(HomluxDelSubDeviceEvent.of(entity.result!));
    } else if(TypeScreenDelWiFiDevice == eventType) {
      bus.typeEmit(HomluxDelWiFiDeviceEvent.of(entity.result!));
    } else if(TypeScreenMoveSubDevice == eventType) {
      bus.typeEmit(HomluxMovSubDeviceEvent.of(entity.result!));
    } else if(TypeScreenMoveWiFiDevice == eventType) {
      bus.typeEmit(HomluxMovWifiDeviceEvent.of(entity.result!));
    } else if(TypeSceneUpt == eventType) {
      bus.typeEmit(HomluxSceneUpdateEvent());
    } else if(TypeSceneAdd == eventType) {
      bus.typeEmit(HomluxSceneAddEvent());
    } else if(TypeSceneDel == eventType) {
      bus.typeEmit(HomluxSceneDelEvent());
    } else if(TypeDelGateway == eventType) {
      bus.typeEmit(HomluxScreenDelGatewayEvent.of(entity.result?.eventData?.sn ?? "", entity.result?.eventData?.deviceId ?? ""));
    } else if(TypeGroupUpt == eventType) {
      bus.typeEmit(HomluxGroupUptEvent());
    } else if(TypeGroupAdd == eventType) {
      bus.typeEmit(HomluxGroupAddEvent());
    } else if(TypeGroupDel == eventType) {
      bus.typeEmit(HomluxGroupDelEvent.of(entity.result?.eventData?.groupId ?? ""));
    } else if(TypeUpdateRoomName == eventType) {
      bus.typeEmit(HomluxChangeRoomNameEven.of(entity.result?.eventData?.roomId ?? ""
          , entity.result?.eventData?.roomName ?? ""));
    } else if(TypeChangeHouse == eventType) {
      bus.typeEmit(HomluxChangHouseEvent());
    } else if(TypeProjectChangeHouse == eventType) {
      bus.typeEmit(HomluxProjectChangeHouse());
    } else if(TypeDeleteHouseUser == eventType) {
      bus.typeEmit(HomluxDeleteHouseUser.of(entity.result?.eventData?.userId));
    } else if(TypeChangeUserAuth == eventType) {
      bus.typeEmit(HomluxChangeUserAuthEvent());
    } else if(TypeQuitHouseUser == eventType) {
      bus.typeEmit(HomluxUserCountChangeEvent());
    } else if(TypeBindDevice == eventType) {
      bus.typeEmit(HomluxBindDeviceEvent());
    } else {
      Log.file('[WebSocket]homlux 此消息类型无法处理：$json');
    }
  }

  static _error(dynamic error) {
    Log.file('[WebSocket] homlux ws error $error');
    try {

    } catch(e) {
      Log.file('[WebSocket]homlux ws error error $e');
    }
  }

  static _done() async {
    Log.file('[WebSocket]homlux ws done');
    try {
      await Future.delayed(const Duration(seconds: 2));
      var state = NetUtils.getNetState();
      if(state != null) {
        _stopConnect('[WebSocket]网络状态失效');
        _startConnect('接收到done事件重连');
      } else {
        _stopConnect('[WebSocket]网络状态失效');
      }
    } catch(e) {
      Log.file('[WebSocket]homlux ws done error $e');
    }
  }

}
