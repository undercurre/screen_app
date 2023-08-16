import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/homlux/push/homlux_push_message_model.dart';
import 'package:screen_app/common/logcat_helper.dart';

import '../../../widgets/event_bus.dart';
import '../../system.dart';
import 'event/homlux_push_event.dart';

const _connectTimeout = 5;
const _pingInterval = 30;

// //设备属性变化
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



// 1.定义消息类型
// 2.定义消息数据解析Bean
// 3.发送消息

class HomluxPushManager {

  static WebSocket? webSocket;
  static Timer? retryConnectTimer;
  static Timer? hearPacketTimeoutTimer;
  static bool _isConnect = false;
  static bool heartBeatReply = false;

  static bool isConnect() {
    return _isConnect;
  }

  static void stopConnect() async {
    // 1. 关闭旧连接, 定时器
    _isConnect = false;
    retryConnectTimer?.cancel();
    hearPacketTimeoutTimer?.cancel();
    await webSocket?.close();
    webSocket = null;
  }

  static startConnect(
      {required String token,
      required String houseId,
      int retrySeconds = 2}) async {

    _isConnect = false;



    // 重连函数
    void reconnectFunction() {
      retryConnectTimer = Timer(Duration(seconds: retrySeconds), () {
        startConnect(token: token, houseId: houseId, retrySeconds: retrySeconds * 2);
        retryConnectTimer = null;
      });
    }

    try {
      Log.file('homlux ws 重新建立连接中');
      // 1. 关闭旧连接, 定时器
      retryConnectTimer?.cancel();
      hearPacketTimeoutTimer?.cancel();
      await webSocket?.close();
      webSocket = null;

      // 1.1 判断是否能建立连接
      if(!System.isLogin() || !System.inHomluxPlatform()) {
        Log.file('homlux ws 状态不符合，无法建立连接');
        return;
      }

      // 2.建立新连接
      webSocket = await WebSocket.connect(dotenv.get('HOMLUX_PUSH_WSS') + houseId);
      webSocket?.pingInterval = const Duration(seconds: _pingInterval);
      webSocket?.timeout(const Duration(seconds: _connectTimeout));

      // 3.设置消息监听
      webSocket?.listen((event) => _message(event, reconnectFunction),
          onError: _error(reconnectFunction),
          onDone: _done(reconnectFunction));

      // 4.发送心跳包
      // TODO 临时去除心跳机制，后台还没上
      // _sendHearPacket(reconnectFunction);

      _isConnect = true;
    } catch(e) {
      Log.file('homlux ws 执行异常 $e');
    } finally {
      Log.file('执行异常，尝试重连');
      reconnectFunction();
    }

  }
  
  static _message(dynamic event, void Function() reconnectFunction) {
    Log.file('homlux ws message $event');
    try {
      // 1.取消心跳计时器
      hearPacketTimeoutTimer?.cancel();
      hearPacketTimeoutTimer = null;
      // 2.处理业务逻辑
      var jsonMap = jsonDecode(event) as Map<String, dynamic>;
      var eventType = jsonMap['result']?['eventType'];
      HomluxPushMessageEntity entity = HomluxPushMessageEntity.fromJson(jsonMap);
      if(entity.result?.eventType == TypeDeviceProperty) {
        bus.typeEmit(HomluxDevicePropertyChangeEvent.of(entity.result!));
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
        bus.typeEmit(HomluxScreenDelGatewayEvent.of(entity.result?.eventData?.sn ?? ""));
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
        bus.typeEmit(HomluxDeleteHouseUser());
      } else {
        if(entity.topic == 'heartbeatTopic') {
          /// 心跳包回复
          heartBeatReply = true;
        } else {
          Log.file('此消息类型无法处理：$event');
        }
      }

      // 3.重新启动心跳计时器
      // _sendHearPacket(reconnectFunction);
    } catch(e) {
      Log.file('homlux ws message error ->  $event $e');
    }
  }
  
  static _error(void Function() reconnectFunction) {
    Log.file('homlux ws error');
    try {

    } catch(e) {
      Log.file('homlux ws error error $e');
    }
  }
  
  static _done(void Function() reconnectFunction) {
    Log.file('homlux ws done');
    try {
      reconnectFunction();
    } catch(e) {
      Log.file('homlux ws done error $e');
    }
  }

  static _sendHearPacket(void Function() reconnectFunction) {
    hearPacketTimeoutTimer?.cancel();
    hearPacketTimeoutTimer = Timer(const Duration(seconds: _pingInterval), () {
      if(heartBeatReply) {
        _sendHearPacket(reconnectFunction);
      } else {
        reconnectFunction();
        hearPacketTimeoutTimer = null;
      }
    });
    // 发送心跳包
    webSocket?.add(jsonEncode({'topic': 'heartbeatTopic', 'message': 999}));
    heartBeatReply = false;
  }

}
