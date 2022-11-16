// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile()
  ..user = json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>)
  ..homeInfo = json['homeInfo'] == null
      ? null
      : HomeList.fromJson(json['homeInfo'] as Map<String, dynamic>)
  ..romeInfoSelected = json['romeInfoSelected'] == null
      ? null
      : RoomInfo.fromJson(json['romeInfoSelected'] as Map<String, dynamic>)
  ..deviceId = json['deviceId'] as String?;

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'user': instance.user,
      'homeInfo': instance.homeInfo,
      'romeInfoSelected': instance.romeInfoSelected,
      'deviceId': instance.deviceId,
    };
