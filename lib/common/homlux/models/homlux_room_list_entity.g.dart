// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_room_list_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxRoomListEntity _$HomluxRoomListEntityFromJson(
        Map<String, dynamic> json) {
  HomluxRoomListEntity();
  var entity = HomluxRoomListEntity();
  entity.roomInfoWrap = homluxJsonConvert.convertListNotNull<HomluxRoomInfo>(json['roomInfoList']);
  return entity;
}


Map<String, dynamic> _$HomluxRoomListEntityToJson(
        HomluxRoomListEntity instance) =>
    <String, dynamic>{
      'roomInfoList': instance.roomInfoWrap?.map((e) => e.toJson()).toList(),
    };

HomluxRoomInfo _$RoomInfoFromJson(Map<String, dynamic> json) => HomluxRoomInfo(
      roomInfo: json['roomInfo'] == null
          ? null
          : RealHomluxRoomInfo.fromJson(json['roomInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomInfoToJson(HomluxRoomInfo instance) => <String, dynamic>{
      'roomInfo': instance.roomInfo,
    };

RealHomluxRoomInfo _$RealRoomInfoFromJson(Map<String, dynamic> json) => RealHomluxRoomInfo(
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      deviceLightOnNum: json['deviceLightOnNum'] as int?,
      deviceNum: json['deviceNum'] as int?,
    );

Map<String, dynamic> _$RealRoomInfoToJson(RealHomluxRoomInfo instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'deviceLightOnNum': instance.deviceLightOnNum,
      'deviceNum': instance.deviceNum,
    };
