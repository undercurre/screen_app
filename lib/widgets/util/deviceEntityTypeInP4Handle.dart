import '../../routes/home/device/card_type_config.dart';

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

  static DeviceEntityTypeInP4 getDeviceEntityType(String type, String? modelNum) {
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
      } else if (type == '3017') {
        return DeviceEntityTypeInP4.Zigbee_3017;
      }else if (type == '3018') {
        return DeviceEntityTypeInP4.Zigbee_3018;
      }else if (type == '3018') {
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
}
