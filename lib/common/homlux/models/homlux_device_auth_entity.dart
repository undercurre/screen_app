
import 'package:screen_app/common/homlux/generated/json/base/homlux_json_convert_content.dart';

part 'homlux_device_auth_entity.g.dart';

class HomluxDeviceAuthEntity {
  int? status;

  HomluxDeviceAuthEntity();

  factory HomluxDeviceAuthEntity.fromJson(Map<String, dynamic> jsonStr) => _$HomluxDeviceAuthEntityFromJson(jsonStr);

  Map<String, dynamic> toJson() => _$HomluxDeviceAuthEntityToJson(this);

}