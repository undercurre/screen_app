
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/meiju/generated/json/base/meiju_json_convert_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';
import 'models/meiju_home_entity.dart';
import 'models/meiju_room_entity.dart';
import 'models/meiju_user_entity.dart';

class MeiJuGlobal {

  /// 是否为release版本
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  static late SharedPreferences _prefs;

  /// 家庭数据
  static const HOMLUX_FAMILY_INFO = 'meiju_family_info';

  /// 房间数据
  static const HOMLUX_ROOM_INFO = 'meiju_room_info';

  /// 用户数据
  static const HOMLUX_USER_INFO = 'meiju_user_info';

  /// 登录令牌
  static const HOMLUX_TOKEN = 'meiju_token';

  /// 思必驰语音Token
  static const HOMLUX_AI_TOKEN = 'meiju_ai_token';
  /// 网关设备id
  static const HOMLUX_GATEWAY_DEVICE_ID = 'meiju_gateway_device_id';
  /// 网关SN
  static const HOMLUX_GATEWAY_SN = 'meiju_gateway_sn';

  static MeiJuTokenEntity? _token;
  /// 登录的家庭
  static MeiJuHomeEntity? _homeEntity;
  /// 登录的房间
  static MeiJuRoomEntity? _roomEntity;
  /// 屏下网关的deviceId -- 登录之后才会返回
  static String? _gatewayApplianceCode;
  /// 屏下网关的sn
  static String? _gatewaySn;

  MeiJuGlobal._();


  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    _roomEntity = _$parseToJsonByCache(_prefs, HOMLUX_ROOM_INFO);
    _homeEntity = _$parseToJsonByCache(_prefs, HOMLUX_FAMILY_INFO);
    _token = _$parseToJsonByCache(_prefs, HOMLUX_USER_INFO);
    _gatewayApplianceCode = _prefs.getString(HOMLUX_GATEWAY_DEVICE_ID);
    _gatewaySn = _prefs.getString(HOMLUX_GATEWAY_SN);
  }

  static String? get gatewayApplianceCode =>  _gatewayApplianceCode;

  static set gatewayApplianceCode(String? applianceCode) {
    _gatewayApplianceCode = applianceCode;
    _prefs.setString(HOMLUX_GATEWAY_DEVICE_ID, _gatewayApplianceCode ?? '');
  }

  static Future<String?> get gatewaySn async {
    if(_gatewaySn != null) {
      // 获取Sn时更新
      aboutSystemChannel.getGatewaySn().then((value) {
        if(value != null) {
          _gatewaySn = value;
        }
      });
      return _gatewaySn;
    } else {
      return _gatewaySn = await aboutSystemChannel.getGatewaySn();
    }

  }

  static MeiJuHomeEntity? get homeInfo => _homeEntity;

  static set homeInfo(MeiJuHomeEntity? homeInfo) {
    _homeEntity = homeInfo;
    _prefs.setString(HOMLUX_FAMILY_INFO, _homeEntity == null ? '' : jsonEncode(_homeEntity!.toJson()));
  }

  static MeiJuRoomEntity? get roomInfo => _roomEntity;

  static set roomInfo(MeiJuRoomEntity? roomInfo) {
    _roomEntity = roomInfo;
    _prefs.setString(HOMLUX_TOKEN, _roomEntity == null ? '' : jsonEncode(_roomEntity!.toJson()));
  }

  static MeiJuTokenEntity? get token => _token;

  static set token(MeiJuTokenEntity? tokenEntity) {
    _token = tokenEntity;
    _prefs.setString(HOMLUX_TOKEN, tokenEntity == null ? '' : jsonEncode(tokenEntity.toJson()));
  }

  /// 是否登录
  static get isLogin => _token != null;

  /// 设置退出登录
  static void setLogout() {
    token = null;
    homeInfo = null;
    roomInfo = null;
    gatewayApplianceCode = null;
  }

}

/// 使用注意 ** 使用此方法解析的对象类型，一定是注册在homluxJsonConvert中，不然报错
T? _$parseToJsonByCache<T>(SharedPreferences preferences, String key) {
  String? jsonStr = preferences.getString(key);
  if (StrUtils.isNullOrEmpty(jsonStr)) return null;
  return meijuJsonConvert.convert(jsonDecode(jsonStr!));
}