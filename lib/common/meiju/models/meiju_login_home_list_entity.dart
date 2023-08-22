import 'dart:convert';

import 'package:screen_app/common/meiju/generated/json/base/meiju_json_convert_content.dart';

import 'meiju_login_home_entity.dart';
part 'meiju_login_home_list_entity.g.dart';

class MeiJuLoginHomeListEntity {
  MeiJuLoginHomeListEntity();

  List<MeiJuLoginHomeEntity>? homeList;

  factory MeiJuLoginHomeListEntity.fromJson(Map<String, dynamic> json) =>
      _$MeiJuLoginHomeListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuLoginHomeListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
