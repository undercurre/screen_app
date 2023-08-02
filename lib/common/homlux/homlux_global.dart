import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../channel/index.dart';
import '../utils.dart';
import 'generated/json/base/homlux_json_convert_content.dart' as json;
import 'models/homlux_dui_token_entity.dart';
import 'models/homlux_family_entity.dart';
import 'models/homlux_qr_code_auth_entity.dart';
import 'models/homlux_room_list_entity.dart';

class HomluxGlobal {
  /// 是否为release版本
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  /// 家庭数据
  static const HOMLUX_FAMILY_INFO = 'homlux_family_info';

  /// 房间数据
  static const HOMLUX_ROOM_INFO = 'homlux_room_info';

  /// 登录令牌
  static const HOMLUX_TOKEN = 'homlux_token';

  /// 思必驰语音Token
  static const HOMLUX_AI_TOKEN = 'homlux_ai_token';

  /// 网关设备id
  static const HOMLUX_GATEWAY_DEVICE_ID = 'homlux_gateway_device_id';

  /// 网关SN
  static const HOMLUX_GATEWAY_SN = 'homlux_gateway_sn';

  static HomluxFamilyEntity? _homluxHomeInfo;
  static HomluxRoomInfo? _homluxRoomInfo;
  static HomluxQrCodeAuthEntity? _homluxQrCodeAuthEntity;
  static HomluxDuiTokenEntity? _aiToken;
  static String? _gatewaySn;  // 屏下网关的sn
  static String? _gatewayApplianceCode;// 屏下网关的deviceId -- 登录之后才会返回

  HomluxGlobal._();


  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    _homluxHomeInfo = await _$parseToJsonByCache(HOMLUX_FAMILY_INFO);
    _homluxRoomInfo = await _$parseToJsonByCache(HOMLUX_ROOM_INFO);
    _homluxQrCodeAuthEntity = await _$parseToJsonByCache(HOMLUX_TOKEN);
    _aiToken = await _$parseToJsonByCache(HOMLUX_AI_TOKEN);
    _gatewaySn = await LocalStorage.getItem(HOMLUX_GATEWAY_SN);
    _gatewayApplianceCode = await LocalStorage.getItem(HOMLUX_GATEWAY_DEVICE_ID);
  }


  static String? get gatewayApplianceCode =>  _gatewayApplianceCode;

  static set gatewayApplianceCode(String? applianceCode) {
    _gatewayApplianceCode = applianceCode;
    LocalStorage.setItem(HOMLUX_GATEWAY_DEVICE_ID, _gatewayApplianceCode ?? '');
  }

  static Future<String?> get gatewaySn async {
    if(StrUtils.isNotNullAndEmpty(_gatewaySn)) {
      // 获取Sn时更新
      aboutSystemChannel.getGatewaySn().then((value) {
        if(value != null) {
          _gatewaySn = value;
          LocalStorage.setItem(HOMLUX_GATEWAY_SN, value);
        }
      });
      return _gatewaySn;
    } else {
      _gatewaySn = await aboutSystemChannel.getGatewaySn();
      LocalStorage.setItem(HOMLUX_GATEWAY_SN, _gatewaySn ?? '');
      return _gatewaySn;
    }
  }

  static HomluxFamilyEntity? get homluxHomeInfo {
    return _homluxHomeInfo;
  }

  static set homluxHomeInfo(HomluxFamilyEntity? familyInfo) {
    _homluxHomeInfo = familyInfo;
    LocalStorage.setItem(HOMLUX_FAMILY_INFO, familyInfo != null? jsonEncode(familyInfo.toJson() ) : '');
  }

  static HomluxRoomInfo? get homluxRoomInfo {
    return _homluxRoomInfo;
  }

  static set homluxRoomInfo(HomluxRoomInfo? roomInfo) {
    _homluxRoomInfo = roomInfo;
    LocalStorage.setItem(HOMLUX_ROOM_INFO, roomInfo != null ? jsonEncode(roomInfo.toJson()) : '');
  }

  static HomluxQrCodeAuthEntity? get homluxQrCodeAuthEntity {
    return _homluxQrCodeAuthEntity;
  }

  static set homluxQrCodeAuthEntity(HomluxQrCodeAuthEntity? qrCodeAuthEntity) {
    _homluxQrCodeAuthEntity = qrCodeAuthEntity;
    LocalStorage.setItem(HOMLUX_TOKEN, qrCodeAuthEntity != null ? jsonEncode(qrCodeAuthEntity.toJson()) : '');
  }

  static HomluxDuiTokenEntity? get aiToken {
    return _aiToken;
  }

  static set aiToken(HomluxDuiTokenEntity? aiToken) {
    _aiToken = aiToken;
    LocalStorage.setItem(HOMLUX_AI_TOKEN, aiToken != null ? jsonEncode(aiToken.toJson()) : '');
  }


  /// 是否已经登录
  static bool get isLogin => _homluxQrCodeAuthEntity != null;

  /// 设置退出登录
  static void setLogout() {
    homluxHomeInfo = null;
    homluxRoomInfo = null;
    homluxQrCodeAuthEntity = null;
    aiToken = null;
    gatewayApplianceCode = null;
    LocalStorage.removeItem(HOMLUX_FAMILY_INFO);
    LocalStorage.removeItem(HOMLUX_ROOM_INFO);
    LocalStorage.removeItem(HOMLUX_TOKEN);
    LocalStorage.removeItem(HOMLUX_AI_TOKEN);
    LocalStorage.removeItem(HOMLUX_GATEWAY_DEVICE_ID);
    LocalStorage.removeItem(HOMLUX_GATEWAY_SN);
  }

}

/// 使用注意 ** 使用此方法解析的对象类型，一定是注册在homluxJsonConvert中，不然报错
Future<T?> _$parseToJsonByCache<T>(String key) async {
  String? jsonStr = await LocalStorage.getItem(key);
  if (StrUtils.isNullOrEmpty(jsonStr)) return null;
  return json.homluxJsonConvert.convert(jsonDecode(jsonStr!));
}
