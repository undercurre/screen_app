
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';

import 'models/manager_devic.dart';

abstract class IWiFiCallback{ }

typedef IFindZigbeeCallback = void Function(List<FindZigbeeResult> result);
typedef IBindZigbeeCallback = void Function(BindResult<FindZigbeeResult> result);
typedef IModifyDevicePositionCallback = void Function(ModifyDeviceResult result);

class DeviceManagerChannel extends AbstractChannel {

  DeviceManagerChannel.fromName(super.channelName) : super.fromName();

  IFindZigbeeCallback? findZigbeeCallback;
  IBindZigbeeCallback? bindZigbeeCallback;
  IModifyDevicePositionCallback? modifyDevicePositionCallback;

  void setFindZigbeeListener(IFindZigbeeCallback? findZigbeeCallback) {
    this.findZigbeeCallback = findZigbeeCallback;
  }

  void setBindZigbeeListener(IBindZigbeeCallback? bindZigbeeCallback) {
    this.bindZigbeeCallback = bindZigbeeCallback;
  }

  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    final method = call.method;
    switch(method) {
      case "findZigbeeResult":
        findZigbeeResultHandle(call.arguments);
        break;
      case "zigbeeBindResult":
        zigbeeBindResultHandle(call.arguments);
        break;
      case "modifyDeviceResult":
        modifyDeviceResultHandle(call.arguments);
        break;
    }
  }

  void modifyDeviceResultHandle(dynamic arguments) async {
    final result = ModifyDeviceResult.fromJson(arguments);
    modifyDevicePositionCallback?.call(result);
  }

  void zigbeeBindResultHandle(dynamic arguments) async {
    final result = BindResult<FindZigbeeResult>.convertZigbeeFromJson(arguments);
    bindZigbeeCallback?.call(result);
  }

  void findZigbeeResultHandle(dynamic arguments) async {
    List<FindZigbeeResult>? zigbeeDevices = FindZigbeeResult.fromArray(arguments);
    if(zigbeeDevices?.isNotEmpty == true) {
      findZigbeeCallback?.call(zigbeeDevices!);
    }
  }

  // 初始化
  void init(String host, String token, String httpSign, String seed, String key,
      String deviceId, String userId, String iotAppCount, String iotSecret, String httpHeaderDataKey) async {
    methodChannel.invokeMethod("init", {
      "host": host,
      "token": token,
      "httpSign": httpSign,
      "seed": seed,
      "key": key,
      "deviceId": deviceId,
      "userId": userId,
      "iotAppCount": iotAppCount,
      "iotSecret": iotSecret,
      "httpHeaderDataKey": httpHeaderDataKey,
    });
  }

  // 重置
  void reset() async {
    methodChannel.invokeMethod("reset");
  }
  // 发现zigbee设备
  void findZigbee(String homeGroupId, String gatewayApplianceCode) async {
    methodChannel.invokeMethod("findZigbee", {
      "homeGroupId": homeGroupId,
      "gatewayApplianceCode" : gatewayApplianceCode
    });
  }
  // 停止发现zigbee设备
  void stopFindZigbee(String homeGroupId, String gatewayApplianceCode) async {
    methodChannel.invokeMethod("stopFindZigbee", {
      "gatewayApplianceCode" : gatewayApplianceCode,
      "homeGroupId": homeGroupId
    });
  }
  // 绑定zigbee设备
  void bindZigbee(String homeGroupId, String roomId, List<String> applianceCodes) async {
    methodChannel.invokeMethod("bindZigbee", {
      "homeGroupId": homeGroupId,
      "roomId": roomId,
      "applianceCodes" : [...applianceCodes],
    });
  }
  // 停止绑定zigbee设备（移除剩下还未绑定的设备，正在绑定的设备阻止不了）
  void stopBindZigbee() async {
    methodChannel.invokeMethod("stopBindZigbee");
  }
  // 修改设备绑定的房间
  void modifyDevicePosition(String homeGroupId, String roomId, String applianceCode) async {
    methodChannel.invokeMethod("modifyDevicePosition", {
      "homeGroupId": homeGroupId,
      "roomId": roomId,
      "applianceCode": "applianceCode"
    });
  }

}