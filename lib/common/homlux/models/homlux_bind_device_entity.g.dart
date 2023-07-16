import 'homlux_bind_device_entity.dart';

HomluxBindDeviceEntity $HomluxBindDeviceEntityFromJson(
    Map<String, dynamic> json) {
  HomluxBindDeviceEntity entity = HomluxBindDeviceEntity();
  entity.deviceId = json['deviceId'] ?? '';
  entity.isBind = json['isBind'] ?? false;
  entity.msg = json['msg'] ?? '';
  entity.houseId = json['houseId'] ?? '';
  entity.houseName = json['houseName'] ?? '';
  entity.userId = json['userId'] ?? '';
  entity.userName = json['userName'] ?? '';
  return entity;
}

Map<String, dynamic> $HomluxBindDeviceEntityToJson(
    HomluxBindDeviceEntity entity) {
  return {
    'deviceId': entity.deviceId,
    'isBind': entity.isBind,
    'msg': entity.msg,
    'houseId': entity.houseId,
    'houseName': entity.houseName,
    'userId': entity.userId,
    'userName': entity.userName,
    'userMobile': entity.userMobile
  };
}
