import 'package:json_annotation/json_annotation.dart';

part 'accessToken.g.dart';

@JsonSerializable()
class AccessToken {
  AccessToken();

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
  
  factory AccessToken.fromJson(Map<String,dynamic> json) => _$AccessTokenFromJson(json);
  Map<String, dynamic> toJson() => _$AccessTokenToJson(this);
}
