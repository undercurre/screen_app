import 'dart:convert';
import '../generated/json/base/meiju_json_convert_content.dart';

/// 美居接口模型
class MeiJuResponseEntity<T> {
  late int code;
  late String msg;

  /// 以下为了兼容It中台与美智中台数据返回格式
  T? _data;
  T? _result;

  /// 以下为了兼容It中台与美智中台数据返回格式
  T? get data {
    if(_data != null) return _data;
    if(_result != null) return _result;
    return null;
  }

  get isSuccess => code == 0;

  MeiJuResponseEntity();

  factory MeiJuResponseEntity.fromJson(Map<String, dynamic> json) =>
      $MideaResponseEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $MideaResponseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

MeiJuResponseEntity<T> $MideaResponseEntityFromJson<T>(
    Map<String, dynamic> json) {
  final MeiJuResponseEntity<T> apiResponseEntityEntity = MeiJuResponseEntity();
  final int? code = meijuJsonConvert.convert<int>(json['code']);
  if (code != null) {
    apiResponseEntityEntity.code = code;
  }
  final String? msg = meijuJsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    apiResponseEntityEntity.msg = msg;
  }
  final T? data = meijuJsonConvert.fromJsonAsT<T>(json['data']);
  if (data != null) {
    apiResponseEntityEntity._data = data;
  }
  final T? result = meijuJsonConvert.fromJsonAsT<T>(json['result']);
  if (result != null) {
    apiResponseEntityEntity._result = result;
  }
  return apiResponseEntityEntity;
}

Map<String, dynamic> $MideaResponseEntityToJson(MeiJuResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['data'] = entity._data?.toJson();
  data['result'] = entity._result?.toJson();
  return data;
}
