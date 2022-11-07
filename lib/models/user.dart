import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User();

  late String accessToken;
  late String deviceId;
  late String iotUserId;
  late String key;
  late String openId;
  late String seed;
  late String sessionId;
  late String tokenPwd;
  late String uid;
  num? expired;
  
  factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
