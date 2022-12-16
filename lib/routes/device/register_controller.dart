import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/routes/plugins/0x14/api.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_light/api.dart';
import 'package:screen_app/routes/plugins/0x26/api.dart' as cate0x26;
import 'package:screen_app/routes/plugins/0x40/api.dart' as cate0x40;
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../models/device_entity.dart';


Map<String, DeviceInterface> controllerList = {
  "0x13": WrapWIFILight(),
  "0x14": CurtainApi(),
  "0x21_light": WrapZigbeeLight(),
  "0x26": cate0x26.DeviceListApiImpl(),
  "0x40": cate0x40.DeviceListApiImpl()
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
  "57": "0x21_light",
  "56": "0x21_light",
  "1262": "0x21_light",
  "1263": "0x21_light",
  "55": "0x21_light",
  "54": "0x21_light",
  "51": "0x21_curtain",
  "47": "0x21_curtain",
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