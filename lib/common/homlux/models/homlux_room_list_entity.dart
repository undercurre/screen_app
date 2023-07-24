import 'package:json_annotation/json_annotation.dart';
import 'package:screen_app/common/homlux/generated/json/base/homlux_json_convert_content.dart';

part 'homlux_room_list_entity.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.none)
class HomluxRoomListEntity {
  List<HomluxRoomInfo>? roomInfoWrap;

  HomluxRoomListEntity();

  factory HomluxRoomListEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxRoomListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxRoomListEntityToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.none)
class HomluxRoomInfo {

  RealHomluxRoomInfo? _roomInfo;

  get roomId => _roomInfo?.roomId;
  get roomName => _roomInfo?.roomName;
  get deviceLightOnNum => _roomInfo?.deviceLightOnNum;
  get deviceNum => _roomInfo?.deviceNum;

  get roomInfo => _roomInfo;

  HomluxRoomInfo({RealHomluxRoomInfo? roomInfo}) {
    _roomInfo = roomInfo;
  }

  factory HomluxRoomInfo.fromJson(Map<String, dynamic> json) =>
      _$RoomInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RoomInfoToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.none)
class RealHomluxRoomInfo {
  final String? roomId;
  final String? roomName;
  final int? deviceLightOnNum;
  final int? deviceNum;

  const RealHomluxRoomInfo({
    this.roomId,
    this.roomName,
    this.deviceLightOnNum,
    this.deviceNum,
  });

  factory RealHomluxRoomInfo.fromJson(Map<String, dynamic> json) =>
      _$RealRoomInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RealRoomInfoToJson(this);
}
