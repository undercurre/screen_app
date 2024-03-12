import 'package:screen_app/common/homlux/generated/json/base/homlux_json_convert_content.dart';

part 'homlux_auth_entity.g.dart';

class HomluxAuthEntity {

  int? houseUserAuth;

  HomluxAuthEntity();

  factory HomluxAuthEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxAuthEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxAuthEntityToJson(this);

  bool isTourist() {
    return houseUserAuth != null && houseUserAuth == 3;
  }

  bool isNoRelationship() {
    return houseUserAuth == null;
  }

}
