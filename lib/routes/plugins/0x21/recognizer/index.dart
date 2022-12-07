import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_1254.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_1262.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_1263.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_54.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_55.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_56.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_57.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/zigbee_light_interface.dart';

Map<String, ZigbeeLightInterface> modelNumList = {
  "1254": ZigbeeLight1254(),
  "57": ZigbeeLight57(),
  "54": ZigbeeLight54(),
  "55": ZigbeeLight55(),
  "56": ZigbeeLight56(),
  "1262": ZigbeeLight1262(),
  "1263": ZigbeeLight1263()
};