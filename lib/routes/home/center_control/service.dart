import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_light/api.dart';
import 'package:screen_app/routes/plugins/0xAC/api.dart';
import 'package:screen_app/routes/plugins/lightGroup/api.dart';
import 'package:screen_app/routes/home/scene/scene.dart';

import '../../../common/api/device_api.dart';
import '../../../common/api/scene_api.dart';
import '../../../models/mz_response_entity.dart';
import '../../../states/device_change_notifier.dart';

class CenterControlService {
  /// 窗帘
  static bool isCurtainPower(BuildContext context) {
    var totalPower = false;
    var curtainList = context.read<DeviceListModel>().curtainList;
    for (var i = 1; i <= curtainList.length; i++) {
      var deviceInfo = curtainList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        totalPower = true;
      }
    }
    debugPrint('窗帘中控结果$totalPower');
    return totalPower;
  }

  static Future<void> curtainControl(BuildContext context, bool onOff) async {
    var curtainList = context.read<DeviceListModel>().curtainList;
    for (var i = 1; i <= curtainList.length; i++) {
      var deviceInfo = curtainList[i - 1];
      var res = await DeviceService.setPower(deviceInfo, onOff);
      if (res) {
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
      }
    }
  }

  /// 灯光
  static bool isLightPower(BuildContext context) {
    var totalPower = false;
    var lightList = context.read<DeviceListModel>().lightList;
    for (var i = 1; i <= lightList.length; i++) {
      var deviceInfo = lightList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        totalPower = true;
      }
    }
    debugPrint('灯光中控结果$totalPower');
    return totalPower;
  }

  static num lightTotalBrightness(BuildContext context) {
    late num totalBrightnessValue;
    List<num> totalBrightnessList = [];
    var lightList = context.read<DeviceListModel>().lightList;
    for (var i = 1; i <= lightList.length; i++) {
      var deviceInfo = lightList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        var res = context.read<DeviceListModel>().getDeviceDetail(deviceInfo.applianceCode);
        debugPrint('该设备detial${res["detail"]}');
        late num value;
        if (deviceInfo.type == '0x21') {
          if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_colorful') {
            value = res["detail"]["lightPanelDeviceList"][0]["brightness"] ?? 0;
          } else if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_noColor') {
            value = res["detail"]["lightPanelDeviceList"][0]["brightness"] ?? 0;
          }
        } else if (deviceInfo.type == 'lightGroup') {
          value = res["detail"]["brightness"] ?? 0;
        } else {
          value = (res["detail"]["brightValue"] / 255) * 100 ?? 0;
        }
        debugPrint('中控${deviceInfo.name}亮度$value');
        totalBrightnessList.add(value);
      }
    }
    if (totalBrightnessList.isNotEmpty) {
      var sum = totalBrightnessList.reduce((a, b) => a + b);
      totalBrightnessValue = sum / totalBrightnessList.length;
    } else {
      totalBrightnessValue = 0;
    }
    debugPrint('灯光中控亮度结果$totalBrightnessValue');
    return totalBrightnessValue.round();
  }

  static num lightTotalColorTemperature(BuildContext context) {
    late num totalColorTemperatureValue;
    List<num> totalColorTemperatureList = [];
    var lightList = context.read<DeviceListModel>().lightList;
    for (var i = 1; i <= lightList.length; i++) {
      var deviceInfo = lightList[i - 1];
      debugPrint(
          '中控${deviceInfo.name}开关:${DeviceService.isPower(deviceInfo)}在线情况:${DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        var res = context.read<DeviceListModel>().getDeviceDetail(deviceInfo.applianceCode);
        late num value;
        if (deviceInfo.type == '0x21') {
          if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_colorful') {
            value = res["detail"]["lightPanelDeviceList"][0]["colorTemperature"] ?? 0;
          } else if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_noColor') {
            value = res["detail"]["lightPanelDeviceList"][0]["colorTemperature"] ?? 0;
          }
        } else if (deviceInfo.type == '0x13') {
          value = (res["detail"]["colorTemperatureValue"] / 255) * 100 ?? 0;
        } else {
          value = res["detail"]["colorTemperature"] ?? 0;
        }
        debugPrint('中控${deviceInfo.name}色温$value');
        totalColorTemperatureList.add(value);
      }
    }
    if (totalColorTemperatureList.isNotEmpty) {
      var sum = totalColorTemperatureList.reduce((a, b) => a + b);
      totalColorTemperatureValue = sum / totalColorTemperatureList.length;
    } else {
      totalColorTemperatureValue = 0;
    }
    debugPrint('灯光中控色温结果$totalColorTemperatureValue');
    return totalColorTemperatureValue.round();
  }

  static Future<void> lightPowerControl(BuildContext context, bool onOff) async {
    debugPrint('发送中控指令: ${onOff ? '开灯' : '关灯'}');
    var lightList = context.read<DeviceListModel>().lightList;
    for (var i = 1; i <= lightList.length; i++) {
      var deviceInfo = lightList[i - 1];
      if (DeviceService.isOnline(deviceInfo)) {
        var res = await DeviceService.setPower(deviceInfo, onOff);
        debugPrint('${deviceInfo.name}${res ? '成功' : '失败'}');
        if (res) {
          Timer(const Duration(seconds: 1), () {
            context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
          });
        }
      }
    }
  }

  static Future<void> lightBrightnessControl(BuildContext context, num value) async {
    var lightList = context.read<DeviceListModel>().lightList;
    for (var i = 1; i <= lightList.length; i++) {
      var deviceInfo = lightList[i - 1];
      late MzResponseEntity<dynamic> res;
      if (deviceInfo.detail != null && deviceInfo.detail != {}) {
        if (deviceInfo.type == '0x13') {
          res = await WIFILightApi.brightnessPDM(deviceInfo.applianceCode, value);
        } else if (deviceInfo.type == '0x21') {
          MzResponseEntity<String> gatewayInfo =
              await DeviceApi.getGatewayInfo(deviceInfo.applianceCode, deviceInfo.masterId);
          Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
          var nodeId = infoMap["nodeid"];
          if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_colorful') {
            res = await ZigbeeLightApi.adjustPDM(deviceInfo.applianceCode, value,
                deviceInfo.detail!["lightPanelDeviceList"][0]["colorTemperature"], nodeId);
          }
          if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_noColor') {
            res = await ZigbeeLightApi.adjustPDM(deviceInfo.applianceCode, value,
                deviceInfo.detail!["lightPanelDeviceList"][0]["colorTemperature"], nodeId);
          }
        } else {
          // 灯组
          res = await LightGroupApi.brightnessPDM(deviceInfo, value);
        }
        if (res.isSuccess) {
          context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
        }
      }
    }
  }

  static Future<void> lightColorTemperatureControl(BuildContext context, num value) async {
    var lightList = context.read<DeviceListModel>().lightList;
    for (var i = 1; i <= lightList.length; i++) {
      var deviceInfo = lightList[i - 1];
      late MzResponseEntity<dynamic> res;
      if (deviceInfo.type == '0x13') {
        res = await WIFILightApi.colorTemperaturePDM(deviceInfo.applianceCode, value);
      } else if (deviceInfo.type == '0x21') {
        MzResponseEntity<String> gatewayInfo =
            await DeviceApi.getGatewayInfo(deviceInfo.applianceCode, deviceInfo.masterId);
        Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
        var nodeId = infoMap["nodeid"];
        if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_colorful') {
          res =
              await ZigbeeLightApi.adjustPDM(deviceInfo.applianceCode, deviceInfo.detail!["brightness"], value, nodeId);
        }
        if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_noColor') {
          res =
              await ZigbeeLightApi.adjustPDM(deviceInfo.applianceCode, deviceInfo.detail!["brightness"], value, nodeId);
        }
      } else {
        // 灯组
        res = await LightGroupApi.colorTemperaturePDM(deviceInfo, value);
      }
      if (res.isSuccess) {
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
      }
    }
  }

  /// 空调
  static bool isAirConditionPower(BuildContext context) {
    var totalPower = false;
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        totalPower = true;
      }
    }
    debugPrint('空调中控结果$totalPower');
    return totalPower;
  }

  static String airConditionMode(BuildContext context) {
    late String totalModeValue;
    List<String> totalModeList = [];
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        var res = context.read<DeviceListModel>().getDeviceDetail(deviceInfo.applianceCode);
        debugPrint('该设备detial${res["detail"]}');
        var value = res["detail"]["mode"] ?? 'auto';
        debugPrint('中控${deviceInfo.name}风速$value');
        totalModeList.add(value);
      }
    }
    Map frequency = {for (var e in totalModeList) e: totalModeList.where((i) => i == e).length};

    var maxFrequency = frequency.values.toList().isNotEmpty ? frequency.values.toList().reduce((value, element) => max) : 0;

    totalModeValue = frequency.keys.isNotEmpty ? frequency.keys.firstWhere((k) => frequency[k] == maxFrequency) : 'auto';

    debugPrint('空调中控模式$totalModeValue');
    return totalModeValue;
  }

  static num airConditionGear(BuildContext context) {
    late num totalGearValue;
    List<num> totalGearList = [];
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        var res = context.read<DeviceListModel>().getDeviceDetail(deviceInfo.applianceCode);
        debugPrint('该设备detial${res["detail"]}');
        var value = res["detail"]["wind_speed"] / 20 + 1;
        debugPrint('中控${deviceInfo.name}风速$value');
        totalGearList.add(value);
      }
    }
    if (totalGearList.isNotEmpty) {
      var sum = totalGearList.reduce((a, b) => a + b);
      totalGearValue = sum / totalGearList.length;
    } else {
      totalGearValue = 0;
    }
    debugPrint('空调中控风速$totalGearValue');
    return totalGearValue.round();
  }

  static num airConditionTemperature(BuildContext context) {
    late num totalTemperatureValue;
    List<num> totalTemperatureList = [];
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        var res = context.read<DeviceListModel>().getDeviceDetail(deviceInfo.applianceCode);
        debugPrint('该设备detial${res["detail"]}');
        var value = res["detail"]["temperature"];
        debugPrint('中控${deviceInfo.name}温度$value');
        totalTemperatureList.add(value);
      }
    }
    if (totalTemperatureList.isNotEmpty) {
      var sum = totalTemperatureList.reduce((a, b) => a + b);
      totalTemperatureValue = sum / totalTemperatureList.length;
    } else {
      totalTemperatureValue = 0;
    }
    debugPrint('空调中控温度$totalTemperatureValue');
    return totalTemperatureValue.round();
  }

  static Future<void> ACPowerControl(BuildContext context, bool onOff) async {
    debugPrint('发送中控指令: ${onOff ? '开' : '关'}');
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      if (DeviceService.isOnline(deviceInfo)) {
        var res = await DeviceService.setPower(deviceInfo, onOff);
        debugPrint('${deviceInfo.name}${res ? '成功' : '失败'}');
        if (res) {
          Timer(const Duration(seconds: 1), () {
            context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
          });
        }
      }
    }
  }

  static Future<void> ACTemperatureControl(BuildContext context, num value) async {
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      late MzResponseEntity<dynamic> res;
      res = await AirConditionApi.temperatureLua(deviceInfo.applianceCode, value);
      if (res.isSuccess) {
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
      }
    }
  }

  static Future<void> ACFengsuControl(BuildContext context, num value) async {
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      late MzResponseEntity<dynamic> res;
      res = await AirConditionApi.gearLua(deviceInfo.applianceCode, value * 20);
      if (res.isSuccess) {
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
      }
    }
  }

  static Future<void> ACModeControl(BuildContext context, String mode) async {
    var airConditionList = context.read<DeviceListModel>().airConditionList;
    for (var i = 1; i <= airConditionList.length; i++) {
      var deviceInfo = airConditionList[i - 1];
      late MzResponseEntity<dynamic> res;
      res = await AirConditionApi.modeLua(deviceInfo.applianceCode, mode);
      if (res.isSuccess) {
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
      }
    }
  }
  /// 场景
  static Future<List<Scene>> initScene() async {
    var sceneList = await SceneApi.getSceneList();
    debugPrint('场景列表:$sceneList');
    return sceneList.sublist(0, 4);
  }

  static selectScene(Scene scene) {
    SceneApi.execScene(scene.key);
  }
}
