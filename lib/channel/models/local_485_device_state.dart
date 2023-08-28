import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Local485DeviceState {
  Local485DeviceState();
  String modelId="";
  String address="";
  int mode=1;
  int speed=1;
  int temper=26;
  int onOff=1;
  int online=1;

  factory Local485DeviceState.fromJson(Map<dynamic, dynamic> map) => _$DeviceStateFromJson(map);

  Map<String, dynamic> toJson() => _$DeviceStateToJson(this);
}

_$DeviceStateToJson(Local485DeviceState instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'address': instance.address,
      'mode': instance.mode,
      'speed': instance.speed,
      'temper': instance.temper,
      'onOff': instance.onOff,
      'online': instance.online,

    };

_$DeviceStateFromJson(Map<dynamic, dynamic> map) {
  Local485DeviceState state = Local485DeviceState();
  state.modelId = map['modelId'] ?? "";
  state.address = map['address'] ?? "";
  state.mode = map['mode'] ?? 1;
  state.speed = map['speed'] ?? 1;
  state.temper = map['temper'] ?? 26;
  state.onOff = map['onOff'] ?? 1;
  state.online = map['online'] ?? 1;
  return state;
}

