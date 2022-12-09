import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/routes/plugins/0x21_light/api.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

Map<String, DeviceInterface> controllerList = {
  "0x13": WrapWIFILight(),
  "0x21": WrapZigbeeLight()
};