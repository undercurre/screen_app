import 'dart:convert';

import 'package:screen_app/generated/json/base/json_convert_content.dart';

import '../generated/json/base/json_field.dart';

/// 美智光电Iot中台接口模型
@JsonSerializable()
class MzResponseEntity<T> {
  late int code;
  late String msg;
  late T result;
  late bool success;
  // 源数据存储
  Map<String, dynamic>? rawData;

  get isSuccess => success;

  MzResponseEntity();

  factory MzResponseEntity.fromJson(Map<String, dynamic> json) =>
      $MzResponseEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $MzResponseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

MzResponseEntity<T> $MzResponseEntityFromJson<T>(Map<String, dynamic> json) {
  final MzResponseEntity<T> mzResponseEntity = MzResponseEntity();
  mzResponseEntity.rawData = json;
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    mzResponseEntity.code = code;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    mzResponseEntity.msg = msg;
  }
  final T? result = JsonConvert.fromJsonAsT<T>(json['result']);
  if (result != null) {
    mzResponseEntity.result = result;
  }
  final bool? success = jsonConvert.convert<bool>(json['success']);
  if (success != null) {
    mzResponseEntity.success = success;
  }
  return mzResponseEntity;
}

Map<String, dynamic> $MzResponseEntityToJson(MzResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['result'] = entity.result.toJson();
  data['success'] = entity.success;
  data['isSuccess'] = entity.isSuccess;
  return data;
}
