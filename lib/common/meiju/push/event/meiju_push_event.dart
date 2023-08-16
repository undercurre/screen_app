


/// 添加设备
class MeiJuDeviceAddEvent {}
/// 删除设备
class MeiJuDeviceDelEvent {}
/// 解绑设备
class MeiJuDeviceUnbindEvent {}
/// wifi设备状态发生变化
class MeiJuWifiDevicePropertyChangeEvent {
  final String deviceId;
  MeiJuWifiDevicePropertyChangeEvent(this.deviceId);
}
/// zigbee设备状态发生变化
class MeiJuSubDevicePropertyChangeEvent {
  final String nodeId;
  MeiJuSubDevicePropertyChangeEvent(this.nodeId);
}
/// 设备离线在线状态
/// 如果deviceId为网关[0x16、0x21]，则下面的子设备全部都应该离线，业务层需要额外处理
class MeiJuDeviceOnlineStatusChangeEvent {
  final String deviceId;
  final bool online;// false 离线 true 在线
  MeiJuDeviceOnlineStatusChangeEvent(this.deviceId, this.online);
}