


import 'dart:convert';

import '../homlux_push_message_model.dart';
// 更改家庭
class HomluxChangHouseEvent{}
// 转让家庭
class HomluxProjectChangeHouse{}
// 删除家庭用户
class HomluxDeleteHouseUser{}
// 更新房间名
class HomluxChangeRoomNameEven{
  late final String roomId;
  late final String roomName;
  HomluxChangeRoomNameEven.of(this.roomId, this.roomName);
  @override
  String toString() {
    return jsonEncode({
      'roomId': roomId,
      'roomName': roomName
    });
  }
}
// 灯组增加
class HomluxGroupAddEvent{}
// 灯组更新
class HomluxGroupUptEvent {}
// 灯组删除
class HomluxGroupDelEvent {
  late final String groupId;
  HomluxGroupDelEvent.of(this.groupId);
  @override
  String toString() {
    return jsonEncode({
      'groupId': groupId
    });
  }
}
// 场景发生更新
class HomluxSceneUpdateEvent {}
// 场景添加
class HomluxSceneAddEvent {}
// 场景删除
class HomluxSceneDelEvent {}
// 网关被删除
class HomluxScreenDelGatewayEvent {
  late final String sn;

  HomluxScreenDelGatewayEvent.of(this.sn);

  @override
  String toString() {
    return jsonEncode({
      'sn': sn
    });
  }
}
// 设备属性发生变化
class HomluxDevicePropertyChangeEvent {

  late final HomluxPushResultEntity deviceInfo;

  HomluxDevicePropertyChangeEvent.of(HomluxPushResultEntity entity) {
    deviceInfo = entity;
  }

  @override
  String toString() {
    return jsonEncode(deviceInfo.toJson());
  }

}
// 删除子设备事件
class HomluxDelSubDeviceEvent {
  late final HomluxPushResultEntity deviceInfo;

  HomluxDelSubDeviceEvent.of(HomluxPushResultEntity entity) {
    deviceInfo = entity;
  }

  @override
  String toString() {
    return jsonEncode(deviceInfo.toJson());
  }
}
// 删除Wifi设备事件
class HomluxDelWiFiDeviceEvent {
  late final HomluxPushResultEntity deviceInfo;

  HomluxDelWiFiDeviceEvent.of(HomluxPushResultEntity entity) {
    deviceInfo = entity;
  }

  @override
  String toString() {
    return jsonEncode(deviceInfo.toJson());
  }
}
// 移动子设备事件
class HomluxMovSubDeviceEvent {
  late final HomluxPushResultEntity deviceInfo;

  HomluxMovSubDeviceEvent.of(HomluxPushResultEntity entity) {
    deviceInfo = entity;
  }

  @override
  String toString() {
    return jsonEncode(deviceInfo.toJson());
  }
}
// 移动wifi设备事件
class HomluxMovWifiDeviceEvent {
  late final HomluxPushResultEntity deviceInfo;

  HomluxMovWifiDeviceEvent.of(HomluxPushResultEntity entity) {
    deviceInfo = entity;
  }

  @override
  String toString() {
    return jsonEncode(deviceInfo.toJson());
  }
}
// 设备在线状态更改
class HomluxDeviceOnlineStatusChangeEvent {
  late final HomluxPushResultEntity deviceInfo;

  HomluxDeviceOnlineStatusChangeEvent.of(HomluxPushResultEntity entity) {
    deviceInfo = entity;
  }

  @override
  String toString() {
    return jsonEncode(deviceInfo.toJson());
  }

}
// 编辑子设备事件
class HomluxEditSubEvent{}
// 编辑wifi设备
class HomluxEditWifiEvent{}
// 添加子设备事件
class HomluxAddSubEvent{}
// 添加wifi设备事件
class HomluxAddWifiEvent{}