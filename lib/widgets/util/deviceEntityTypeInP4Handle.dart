import '../../routes/home/device/card_type_config.dart';

// Adapter类型
enum AdapterType {
  unKnow,
  wifiLight,
  zigbeeLight,
  zigbeeLightSingle, //单调光灯
  lightGroup,
  wifiCurtain,
  air485,
  CRC485,
  floor485,
  panel,
  wifiAir,
  wifiYuba,
  wifiLiangyi,
  wifiDianre,
  wifiRanre,
  wifiLightFan
}

/// 添加需要确权的设备类型 （一般普通的wifi设备都需判断确权）
const NeedCheckWaitLockAuthTypes = [
  AdapterType.wifiLight,
  AdapterType.wifiCurtain,
  AdapterType.wifiAir,
  AdapterType.wifiYuba,
  AdapterType.wifiLiangyi,
  AdapterType.wifiDianre,
  AdapterType.wifiRanre,
  AdapterType.wifiLightFan
];

class DeviceEntityTypeInP4Handle {

  static String extractLowercaseEntityType(String inputString) {
    // 定义正则表达式模式，匹配DeviceEntityTypeInP4后面的单词
    final pattern = RegExp(r'DeviceEntityTypeInP4\.(\w+)');

    // 使用正则表达式查找匹配项
    final match = pattern.firstMatch(inputString);

    // 如果有匹配项，返回匹配的结果的小写形式，否则返回空字符串
    if (match != null) {
      return match.group(1)!.toLowerCase();
    } else {
      return '';
    }
  }

  static DeviceEntityTypeInP4 getDeviceEntityType(String type, String? modelNum,String? sn8) {
    for (var deviceType in DeviceEntityTypeInP4.values) {
      if (type == '0x21') {
        List<String> shuidianqi = ['1114', '1113', '82', '83', '23'];
        if (shuidianqi.contains(modelNum)) {
          return DeviceEntityTypeInP4.Default;
        }
        if (deviceType.toString() == 'DeviceEntityTypeInP4.Zigbee_$modelNum') {
          return deviceType;
        }
        if(deviceType.name == modelNum) {
          return deviceType;
        }
      } else if (type.contains('localPanel1')) {
        return DeviceEntityTypeInP4.LocalPanel1;
      } else if (type.contains('localPanel2')) {
        return DeviceEntityTypeInP4.LocalPanel2;
      } else if (type == '0x13' && modelNum == 'homluxZigbeeLight') {
        return DeviceEntityTypeInP4.Zigbee_homluxZigbeeLight;
      } else if (type == '0x13' && modelNum == 'homluxLightGroup') {
        return DeviceEntityTypeInP4.homlux_lightGroup;
      }  else if(type == '0x13' && typeOf0x13AndFan(sn8: sn8)) {
        return DeviceEntityTypeInP4.Device0x13_fan;
      } else if (type == "0xCC" && modelNum == '3017') {
        return DeviceEntityTypeInP4.Zigbee_3017;
      }else if (type == "0xCE" && modelNum == '3018') {
        return DeviceEntityTypeInP4.Zigbee_3018;
      }else if (type == "0xCF" && modelNum == '3019') {
        return DeviceEntityTypeInP4.Zigbee_3019;
      }else if (type == 'clock') {
        return DeviceEntityTypeInP4.Clock;
      } else if (type == 'weather') {
        return DeviceEntityTypeInP4.Weather;
      } else if (type == 'scene') {
        return DeviceEntityTypeInP4.Scene;
      } else {
        if (deviceType.toString() == 'DeviceEntityTypeInP4.Device$type') {
          return deviceType;
        }
      }
    }
    return DeviceEntityTypeInP4.Default;
  }

  /// 风扇灯配置
  static bool typeOf0x13AndFan({String? sn8}) {
    const List<String> funLight = ['M0200004', 'M0200005', '79010863'];
    if(sn8 != null) {
      return funLight.contains(sn8);
    }
    return false;
  }

}
