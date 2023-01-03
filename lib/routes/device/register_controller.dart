import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/routes/plugins/0x14/api.dart';
import 'package:screen_app/routes/plugins/0x16/api.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_light/api.dart';
import 'package:screen_app/routes/plugins/0x26/api.dart' as cate0x26;
import 'package:screen_app/routes/plugins/0x40/api.dart' as cate0x40;
import 'package:screen_app/routes/plugins/0xAC/api.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';
import 'package:screen_app/routes/plugins/lightGroup/api.dart';

import '../../models/device_entity.dart';
import '../plugins/0x21/0x21_panel/api.dart';

// 智慧屏实现线控器拆分和面板实现案件拆分通过定义屏端虚拟设备(既无法从接口获取到数据模型的设备)实现：
// 智慧屏线控器定义为：smartControl
// 面板按键定义为：singlePanel
// 例外：灯组（type为21，拥有数据接口，但是控制方式和其他zigbee灯不一样）：定义为lightGroup


Map<String, DeviceInterface> controllerList = {
  "0x13": WrapWIFILight(),
  "0x14": CurtainApi(),
  "lightGroup": WrapLightGroup(),
  "0x21_light_colorful": WrapZigbeeLight(),
  "0x21_light_noColor": WrapZigbeeLight(),
  "0x21_panel": WrapPanel(),
  "0x26": cate0x26.DeviceListApiImpl(),
  "0x40": cate0x40.DeviceListApiImpl(),
  "0x16": WrapGateway(),
  "0xAC": WrapAirCondition()
};

Map<String, String> zigbeeControllerList = {
  "31": "0x21_curtain_panel_one",
  "1108": "0x21_curtain_panel_one",
  "1107": "0x21_curtain_panel_one",
  "84": "0x21_curtain_panel_one",
  "85": "0x21_curtain_panel_one",
  "45": "0x21_curtain_panel_one",
  "39": "0x21_curtain_panel_one",
  "40": "0x21_curtain_panel_two",
  "1100": "0x21_curtain_panel_two",
  "1110": "0x21_curtain_panel_two",
  "86": "0x21_curtain_panel_two",
  "1109": "0x21_curtain_panel_two",
  "87": "0x21_curtain_panel_two",
  "32": "0x21_curtain_panel_two",
  "57": "0x21_light_colorful",
  "56": "0x21_light_colorful",
  "1262": "0x21_light_colorful",
  "1263": "0x21_light_colorful",
  "55": "0x21_light_noColor",
  "54": "0x21_light_noColor",
  "1254": "0x21_light_noColor",
  "51": "0x21_curtain",
  "47": "0x21_curtain",
  "1363": "0x21_panel",
  "1362": "0x21_panel",
  "1361": "0x21_panel",
  "1360": "0x21_panel",
  "1303": "0x21_panel",
  "1302": "0x21_panel",
  "1301": "0x21_panel",
  "1116": "0x21_panel",
  "1114": "0x21_panel",
  "1112": "0x21_panel",
  "1243": "0x21_panel",
  "1115": "0x21_panel",
  "1113": "0x21_panel",
  "1111": "0x21_panel",
  "1105": "0x21_panel",
  "1103": "0x21_panel",
  "1099": "0x21_panel",
  "77": "0x21_panel",
  "78": "0x21_panel",
  "80": "0x21_panel",
  "81": "0x21_panel",
  "82": "0x21_panel",
  "83": "0x21_panel",
  "44": "0x21_panel",
  "38": "0x21_panel",
  "20": "0x21_panel",
  "23": "0x21_panel",
  "22": "0x21_panel",
};

DeviceInterface? getController(DeviceEntity deviceInfo) {
  if (deviceInfo.type == '0x21') {
    return controllerList[zigbeeControllerList[deviceInfo.modelNumber] ?? '0x21'];
  } else {
    return controllerList[deviceInfo.type];
  }
}

String getControllerRoute(DeviceEntity deviceInfo) {
  if (deviceInfo.type == '0x21') {
    return zigbeeControllerList[deviceInfo.modelNumber] ?? '0x21';
  } else {
    return deviceInfo.type;
  }
}