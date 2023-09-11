import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/homlux/lan/homlux_lan_control_device_manager.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:uuid/uuid.dart';

import 'adapter/select_family_data_adapter.dart';
import 'adapter/select_room_data_adapter.dart';
import 'homlux/models/homlux_room_list_entity.dart';
import 'index.dart';
import 'logcat_helper.dart';
import 'meiju/models/meiju_room_entity.dart';

class System {
  /// 产品编码
  static const String PRODUCT = "D3ZZKP-Z";

  /// 设备Id 存储的key
  static const String DEVICE_ID = "device_id";
  static String? deviceId,macAddress;

  static List<MeiJuRoomEntity>? meijuRoomList;
  static List<HomluxRoomInfo>? homluxRoomList;

  System._();

  static bool inMeiJuPlatform() => MideaRuntimePlatform.platform == GatewayPlatform.MEIJU;

  static bool inHomluxPlatform() => MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX;

  static bool inNonePlatform() => MideaRuntimePlatform.platform == GatewayPlatform.NONE;

  /// 全局初始化
  static Future globalInit([String? deviceId]) async {
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
      Log.i('deviceId: $deviceId');

      if (StrUtils.isNullOrEmpty(deviceId)) {
        const uuid = Uuid();
        deviceId = uuid.v4();
      }
      System.deviceId = deviceId;
      LocalStorage.setItem(DEVICE_ID, deviceId);
    }

    initLoading();
  }

  /// 初始化全局loading配置
  static initLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 40.0
      ..progressColor = const Color.fromRGBO(255, 255, 255, 0.85)
      ..backgroundColor = const Color.fromRGBO(87, 87, 87, 1)
      ..indicatorColor = const Color.fromRGBO(255, 255, 255, 0.85)
      ..textColor = const Color.fromRGBO(255, 255, 255, 0.85)
      ..fontSize = 22
      ..contentPadding = const EdgeInsets.fromLTRB(32, 20, 32, 20)
      ..userInteractions = true
      ..dismissOnTap = false;

    EasyLoading.addStatusCallback((status) {
      Log.d('EasyLoading Status $status');
    });
  }

  /// 初始化美居平台数据
  static Future<void> initForMeiju() {
    Log.i('system init MeiJu');
    return MeiJuGlobal.init();
  }

  /// 初始化美的照明平台数据
  static Future<void> initForHomlux() {
    Log.i('system init Homlux');
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
     return null;
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
      MeiJuGlobal.roomInfo = roomItem?.meijuData;
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
      return false;
    }
  }

  static login() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      HomluxLanControlDeviceManager.getInstant().login();
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {

    } else {
      Log.file("No No No 运行环境为NONE 请勿调用此方法");
    }

  }

  /// 退出登录
  static logout() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      HomluxGlobal.setLogout();
      HomluxLanControlDeviceManager.getInstant().logout();
    } else if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      MeiJuGlobal.setLogout();
    } else {
      Log.file("No No No 运行环境为NONE 请勿调用此方法");
    }
  }


}
