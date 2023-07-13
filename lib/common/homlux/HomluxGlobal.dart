import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';
import 'models/homlux_dui_token_entity.dart';
import 'models/homlux_family_entity.dart';
import 'models/homlux_qr_code_auth_entity.dart';
import 'models/homlux_room_list_entity.dart';
import 'generated/json/base/homlux_json_convert_content.dart' as json;

class HomluxGlobal {
  /// 是否为release版本
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  static late SharedPreferences _prefs;

  /// 家庭数据
  static const HOMLUX_FAMILY_INFO = 'homlux_family_info';

  /// 房间数据
  static const HOMLUX_ROOM_INFO = 'homlux_room_info';

  /// 登录令牌
  static const HOMLUX_TOKEN = 'homlux_token';

  /// 思必驰语音Token
  static const HOMLUX_AI_TOKEN = 'homlux_ai_token';

  static HomluxFamilyEntity? _homluxHomeInfo;
  static HomluxRoomInfo? _homluxRoomInfo;
  static HomluxQrCodeAuthEntity? _homluxQrCodeAuthEntity;
  static HomluxDuiTokenEntity? _aiToken;


  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();

    _homluxHomeInfo = _$parseToJsonByCache(_prefs, HOMLUX_FAMILY_INFO);
    _homluxRoomInfo = _$parseToJsonByCache(_prefs, HOMLUX_ROOM_INFO);
    _homluxQrCodeAuthEntity = _$parseToJsonByCache(_prefs, HOMLUX_TOKEN);
    _aiToken = _$parseToJsonByCache(_prefs, HOMLUX_AI_TOKEN);
  }

  static HomluxFamilyEntity? get homluxHomeInfo {
    return _homluxHomeInfo;
  }

  static set homluxHomeInfo(HomluxFamilyEntity? familyInfo) {
    _homluxHomeInfo = familyInfo;
    _prefs.setString(HOMLUX_FAMILY_INFO, familyInfo != null? jsonEncode(familyInfo.toJson() ) : '' );
  }

  static HomluxRoomInfo? get homluxRoomInfo {
    return _homluxRoomInfo;
  }

  static set homluxRoomInfo(HomluxRoomInfo? roomInfo) {
    _homluxRoomInfo = roomInfo;
    _prefs.setString(HOMLUX_ROOM_INFO, roomInfo != null ? jsonEncode(roomInfo.toJson()) : '');
  }

  static HomluxQrCodeAuthEntity? get homluxQrCodeAuthEntity {
    return _homluxQrCodeAuthEntity;
  }

  static set homluxQrCodeAuthEntity(HomluxQrCodeAuthEntity? qrCodeAuthEntity) {
    _homluxQrCodeAuthEntity = qrCodeAuthEntity;
    _prefs.setString(HOMLUX_TOKEN, qrCodeAuthEntity != null ? jsonEncode(qrCodeAuthEntity.toJson()) : '' );
  }

  static HomluxDuiTokenEntity? get aiToken {
    return _aiToken;
  }

  static set aiToken(HomluxDuiTokenEntity? aiToken) {
    _aiToken = aiToken;
    _prefs.setString(HOMLUX_AI_TOKEN, aiToken != null ? jsonEncode(aiToken.toJson()) : '' );
  }

  /// 是否已经登录
  static bool get isLogin => _homluxQrCodeAuthEntity != null;

  /// 设置退出登录
  static void setLogout() {
    homluxHomeInfo = null;
    homluxRoomInfo = null;
    homluxQrCodeAuthEntity = null;
    aiToken = null;
  }

}

/// 使用注意 ** 使用此方法解析的对象类型，一定是注册在homluxJsonConvert中，不然报错
T? _$parseToJsonByCache<T>(SharedPreferences preferences, String key) {
  String? jsonStr = preferences.getString(key);
  if (StrUtils.isNullOrEmpty(jsonStr)) return null;
  return json.homluxJsonConvert.convert(jsonDecode(jsonStr!));
}
