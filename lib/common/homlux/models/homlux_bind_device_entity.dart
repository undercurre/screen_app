
import 'dart:convert';

import 'homlux_bind_device_entity.g.dart';

class HomluxBindDeviceEntity {
  late String deviceId;
  late bool isBind;
  late String msg;

  late String houseId;
  late String houseName;
  late String userId;
  late String userName;

  String? userMobile;

  HomluxBindDeviceEntity();

  factory HomluxBindDeviceEntity.fromJson(Map<String, dynamic> json) => $HomluxBindDeviceEntityFromJson(json);

  Map<String,dynamic> toJson() => $HomluxBindDeviceEntityToJson(this);


  @override
  String toString() {
    return jsonEncode(toJson());
  }


}
