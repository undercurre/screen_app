import 'package:platform_device_id/platform_device_id.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:uuid/uuid.dart';

import 'adapter/select_family_data_adapter.dart';
import 'adapter/select_room_data_adapter.dart';
import 'index.dart';

class System {
  /// 产品编码
  static const String PRODUCT = "D3ZZKP-Z";

  /// 设备Id 存储的key
  static const String DEVICE_ID = "device_id";
  static String? deviceId;

  System._();

  /// 全局初始化
  static void globalInit([String? deviceId]) async {
    if (StrUtils.isNotNullAndEmpty(deviceId)) {
      System.deviceId = deviceId;
      LocalStorage.setItem(DEVICE_ID, deviceId!);
      return;
    }

    System.deviceId = await LocalStorage.getItem(DEVICE_ID);

    if (StrUtils.isNullOrEmpty(System.deviceId)) {
      String deviceId = await PlatformDeviceId.getDeviceId ?? '';
      // windows 下会获取到特殊字符，为了开发方便需要使用windows进行开发调试
      deviceId = deviceId
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '');
      logger.i('deviceId: $deviceId');

      if (StrUtils.isNullOrEmpty(deviceId)) {
        const uuid = Uuid();
        deviceId = uuid.v4();
      }
      System.deviceId = deviceId;
      LocalStorage.setItem(DEVICE_ID, deviceId);
    }
  }

  /// 初始化美居平台数据
  static Future<void> initForMeiju() {
    return MeiJuGlobal.init();
  }

  /// 初始化美的照明平台数据
  static Future<void> initForHomlux() {
    return HomluxGlobal.init();
  }

  /// 获取家庭信息
  static SelectFamilyItem? get familyInfo {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      return HomluxGlobal.homluxHomeInfo != null
          ? SelectFamilyItem.fromHomlux(HomluxGlobal.homluxHomeInfo!)
          : null;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return MeiJuGlobal.homeInfo != null
          ? SelectFamilyItem.fromMeiJu(MeiJuGlobal.homeInfo!)
          : null;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }

  /// 设置家庭信息
  static set familyInfo(SelectFamilyItem? item) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      HomluxGlobal.homluxHomeInfo = item?.homluxData;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      MeiJuGlobal.homeInfo = item?.meijuData;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }

  /// 获取房间信息
  static SelectRoomItem? get roomInfo {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      return HomluxGlobal.homluxRoomInfo != null
          ? SelectRoomItem.fromHomlux(HomluxGlobal.homluxRoomInfo!)
          : null;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return MeiJuGlobal.roomInfo != null
          ? SelectRoomItem.fromMeiJu(MeiJuGlobal.roomInfo!)
          : null;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }

  /// 设置房间信息
  static set roomInfo(SelectRoomItem? roomItem) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      HomluxGlobal.homluxRoomInfo = roomItem?.homluxData;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      MeiJuGlobal.roomInfo != roomItem?.meijuData;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }

  /// 获取屏下网关SN
  static Future<String?> get gatewaySn async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      return HomluxGlobal.gatewaySn;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return MeiJuGlobal.gatewaySn;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }

  /// 获取屏的云端id
  static Future<String?> get gatewayApplianceCode async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      return HomluxGlobal.gatewayApplianceCode;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return MeiJuGlobal.gatewayApplianceCode;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }


  /// 是否已经登录
  static bool isLogin() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      return HomluxGlobal.isLogin;
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return MeiJuGlobal.isLogin;
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }

  /// 退出登录
  static loginOut() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      HomluxGlobal.setLogout();
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      MeiJuGlobal.setLogout();
    } else {
      throw Exception("No No No 运行环境为NONE 请勿调用此方法");
    }
  }


}
