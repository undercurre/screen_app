part of 'homlux_device_auth_entity.dart';

HomluxDeviceAuthEntity _$HomluxDeviceAuthEntityFromJson(
    Map<String, dynamic> json) {
  HomluxDeviceAuthEntity entity = HomluxDeviceAuthEntity();
  final status = homluxJsonConvert.convert<int>(json['status']);
  if(status != null) {
    entity.status = status;
  }
  return entity;
}

Map<String, dynamic> _$HomluxDeviceAuthEntityToJson(
    HomluxDeviceAuthEntity entity) {
  return <String, dynamic>{'status': entity.status};
}
