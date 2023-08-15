
class HomluxPushMessageEntity {
  HomluxPushMessageEntity();
  int? code;
  int? msg;
  HomluxPushResultEntity? result;
  bool? success;
  int? timestamp;

  factory HomluxPushMessageEntity.fromJson(Map<String, dynamic> json) {
    HomluxPushMessageEntity model = HomluxPushMessageEntity();
    model.code = json['code'] as int?;
    model.msg = json['msg'] as int?;
    model.result = HomluxPushResultEntity.fromJson(json['result'] as Map<String, dynamic>);
    model.success = json['success'] as bool?;
    model.timestamp = json['timestamp'] as int?;
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'result': result?.toJson(),
      'success': success,
      'timestamp': timestamp,
    };
  }

}


class HomluxPushResultEntity {
  HomluxPushResultEntity();
  HomluxEventDataEntity? eventData;
  String? eventType;


  factory HomluxPushResultEntity.fromJson(Map<String, dynamic> json) {
    HomluxPushResultEntity bean = HomluxPushResultEntity();
    bean.eventType = json['eventType'] as String;
    bean.eventData = HomluxEventDataEntity.fromJson(json['eventData'] as Map<String, dynamic>);
    return bean;
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'eventData': eventData?.toJson()
    };
  }

}


class HomluxEventDataEntity {

  HomluxEventDataEntity();
  String? ep;
  // 目前存在下面的属性
  // {"level": 123, "colorTemp": 123,  “onOff”: 1, "brightness": 123, "color_temperature": 123}
  dynamic event;
  String? deviceId;
  String? sn;
  String? roomId;
  String? roomName;
  String? sceneId;
  String? groupId;
  int? status;

  factory HomluxEventDataEntity.fromJson(Map<String, dynamic> json) {
    HomluxEventDataEntity entity = HomluxEventDataEntity();
    entity.ep = json['ep'] as String?;
    entity.deviceId = json['deviceId'] as String?;
    entity.sn = json['sn'] as String?;
    entity.roomId = json['roomId'] as String?;
    entity.roomName = json['roomName'] as String?;
    entity.sceneId = json['sceneId'] as String?;
    entity.groupId = json['groupId'] as String?;
    entity.status = json['status'] as int?;
    entity.event = json['event'];

    return entity;
  }

  Map<String, dynamic> toJson() {
    return {
      'ep': ep,
      'event': event,
      'deviceId': deviceId,
      'sn': sn,
      'roomId': roomId,
      'roomName': roomName,
      'sceneId': sceneId,
      'groupId': groupId,
      'status': status,
    };
  }

}
