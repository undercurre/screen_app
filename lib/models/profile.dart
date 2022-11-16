import 'package:json_annotation/json_annotation.dart';
import "user.dart";
import "homeList.dart";
import "roomInfo.dart";
part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  User? user;
  HomeList? homeInfo;
  RoomInfo? romeInfoSelected;
  String? deviceId;
  
  factory Profile.fromJson(Map<String,dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
