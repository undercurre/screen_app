import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/delete_device_result_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class DeleteDeviceResultEntity {

	late List<String> errorList;
  
  DeleteDeviceResultEntity();

  factory DeleteDeviceResultEntity.fromJson(Map<String, dynamic> json) => $DeleteDeviceResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $DeleteDeviceResultEntityToJson(this);

  DeleteDeviceResultEntity copyWith({List<String>? errorList}) {
      return DeleteDeviceResultEntity()..errorList= errorList ?? this.errorList;
  }
    
  @override
  String toString() {
    return jsonEncode(this);
  }
}