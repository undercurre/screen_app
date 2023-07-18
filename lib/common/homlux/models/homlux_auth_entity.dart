part 'homlux_auth_entity.g.dart';

class HomluxAuthEntity {

  final int? houseUserAuth;

  const HomluxAuthEntity({
    this.houseUserAuth,
  });

  factory HomluxAuthEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxAuthEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxAuthEntityToJson(this);

  bool isTourist() {
    return houseUserAuth != null && houseUserAuth == 3;
  }

}
