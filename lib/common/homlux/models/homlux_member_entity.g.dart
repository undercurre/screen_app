// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_member_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxMemberListEntity _$HomluxMemberEntityFromJson(Map<String, dynamic> json) =>
    HomluxMemberListEntity(
      totalElements: json['totalElements'] as int?,
      houseUserList: (json['houseUserList'] as List<dynamic>?)
          ?.map((e) => HouseUserList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomluxMemberEntityToJson(HomluxMemberListEntity instance) =>
    <String, dynamic>{
      'totalElements': instance.totalElements,
      'houseUserList': instance.houseUserList?.map((e) => e.toJson()).toList(),
    };

HouseUserList _$HouseUserListFromJson(Map<String, dynamic> json) =>
    HouseUserList(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userHouseAuth: json['userHouseAuth'] as int?,
      userHouseAuthName: json['userHouseAuthName'] as String?,
      headImageUrl: json['headImageUrl'] as String?,
    );

Map<String, dynamic> _$HouseUserListToJson(HouseUserList instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userHouseAuth': instance.userHouseAuth,
      'userHouseAuthName': instance.userHouseAuthName,
      'headImageUrl': instance.headImageUrl,
    };
