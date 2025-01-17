// Homlux接口模型
import '../generated/json/base/homlux_json_convert_content.dart';

class HomluxResponseEntity<T> {
  int code = -1;
  String msg = '未知错误';
  int timestamp = -1;
  T? result;
  bool _success = true;

  /// 增加别名
  T? get data {
    return result;
  }

  get isSuccess => code == 0 && _success;

  set success(bool result) => _success = result;

  HomluxResponseEntity();

  factory HomluxResponseEntity.fromJson(Map<String, dynamic>? json) =>
      $HomluxResponseEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $HomluxResponseEntityToJson(this);
}

$HomluxResponseEntityToJson(HomluxResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  if (entity.result is List) {
    data['result'] = entity.result?.map((e) => e.toJson()).toList();
  } else {
    data['result'] = entity.result?.toJson();
  }
  return data;
}

HomluxResponseEntity<T> $HomluxResponseEntityFromJson<T>(Map<String, dynamic>? json) {
  HomluxResponseEntity<T> entity = HomluxResponseEntity();
  entity.code = json?['code'] ?? -1;
  entity.msg = json?['msg'] ?? "网络错误";
  entity.timestamp = json?['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
  entity.result = HomluxJsonConvert.fromJsonAsT(json?['result']);
  entity._success = json?['success'] ?? true;
  return entity;
}