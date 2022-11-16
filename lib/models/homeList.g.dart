// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homeList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeList _$HomeListFromJson(Map<String, dynamic> json) => HomeList()
  ..homegroupId = json['homegroupId'] as String
  ..number = json['number'] as String
  ..roleId = json['roleId'] as String
  ..isDefault = json['isDefault'] as String
  ..name = json['name'] as String
  ..nickname = json['nickname'] as String
  ..des = json['des'] as String
  ..address = json['address'] as String
  ..profilePicUrl = json['profilePicUrl'] as String
  ..coordinate = json['coordinate'] as String
  ..areaid = json['areaid'] as String
  ..createTime = json['createTime'] as String
  ..createUserUid = json['createUserUid'] as String
  ..roomCount = json['roomCount'] as String?
  ..applianceCount = json['applianceCount'] as String?
  ..memberCount = json['memberCount'] as String?
  ..members = json['members'] as String?
  ..roomList = (json['roomList'] as List<dynamic>?)
      ?.map((e) => RoomInfo.fromJson(e as Map<String, dynamic>))
      .toList()
  ..unread = json['unread'] as num?;

Map<String, dynamic> _$HomeListToJson(HomeList instance) => <String, dynamic>{
      'homegroupId': instance.homegroupId,
      'number': instance.number,
      'roleId': instance.roleId,
      'isDefault': instance.isDefault,
      'name': instance.name,
      'nickname': instance.nickname,
      'des': instance.des,
      'address': instance.address,
      'profilePicUrl': instance.profilePicUrl,
      'coordinate': instance.coordinate,
      'areaid': instance.areaid,
      'createTime': instance.createTime,
      'createUserUid': instance.createUserUid,
      'roomCount': instance.roomCount,
      'applianceCount': instance.applianceCount,
      'memberCount': instance.memberCount,
      'members': instance.members,
      'roomList': instance.roomList,
      'unread': instance.unread,
    };
