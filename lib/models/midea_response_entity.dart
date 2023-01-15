import 'dart:convert';

import 'package:screen_app/generated/json/base/json_convert_content.dart';

/// 美的Iot中台接口模型
class MideaResponseEntity<T> {
  late int code;
  late String msg;
  late T data;

  get isSuccess => code == 0;

  MideaResponseEntity();

  factory MideaResponseEntity.fromJson(Map<String, dynamic> json) =>
      $MideaResponseEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $MideaResponseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

MideaResponseEntity<T> $MideaResponseEntityFromJson<T>(
    Map<String, dynamic> json) {
  final MideaResponseEntity<T> apiResponseEntityEntity = MideaResponseEntity();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    apiResponseEntityEntity.code = code;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    apiResponseEntityEntity.msg = msg;
  }
  final T? data = JsonConvert.fromJsonAsT<T>(json['data']);
  if (data != null) {
    apiResponseEntityEntity.data = data;
  }
  return apiResponseEntityEntity;
}

Map<String, dynamic> $MideaResponseEntityToJson(MideaResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['data'] = entity.data.toJson();
  return data;
}
