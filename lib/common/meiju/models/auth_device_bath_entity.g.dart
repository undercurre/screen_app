part of 'auth_device_bath_entity.dart';

MeiJuAuthStatus _$StatusFromJson(Map<String, dynamic> json) {
  MeiJuAuthStatus bean = MeiJuAuthStatus();
  int applianceCode = meijuJsonConvert.convert(json["applianceCode"]);
  int status = meijuJsonConvert.convert(json["status"]);
  bean.applianceCode = applianceCode;
  bean.status = status;
  return bean;
}

Map<String, dynamic> _$StatusToJson(MeiJuAuthStatus status) {
  return <String, dynamic> {
    "applianceCode": status.applianceCode,
    "status": status.status
  };
}

MeiJuAuthDeviceBatchEntity _$AuthDeviceBatchEntityFromJson(Map<String, dynamic> json) {
  MeiJuAuthDeviceBatchEntity entity = MeiJuAuthDeviceBatchEntity();
  List<MeiJuAuthStatus>? status = meijuJsonConvert.convertListNotNull(json["applianceAuthList"]);
  entity.applianceAuthList = status;
  return entity;
}

Map<String, dynamic> _$AuthDeviceBatchEntityToJson(MeiJuAuthDeviceBatchEntity status) {
  return <String, dynamic> {
    "applianceAuthList": status.applianceAuthList?.map((e) => _$StatusToJson(e)).toList()
  };
}
