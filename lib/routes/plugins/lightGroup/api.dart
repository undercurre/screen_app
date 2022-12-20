// import 'package:screen_app/common/api/device_api.dart';
// import 'package:screen_app/models/device_entity.dart';
// import 'package:screen_app/routes/plugins/device_interface.dart';
//
// import '../../../models/mz_response_entity.dart';
//
// class WrapWIFILight implements DeviceInterface {
//   @override
//   Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
//     var res = await WIFILightApi.getLightDetail(deviceInfo.applianceCode);
//     if (res.code == 0) {
//       return res.result;
//     } else {
//       return {};
//     }
//   }
//
//   @override
//   Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
//     return await WIFILightApi.powerPDM(deviceInfo.applianceCode, onOff);
//   }
//
//   @override
//   bool isSupport (DeviceEntity deviceInfo) {
//     // 过滤sn8
//     if (deviceInfo.sn8 == '79009833') {
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   @override
//   bool isPower (DeviceEntity deviceInfo) {
//     return deviceInfo.detail != null ? deviceInfo.detail!["power"] : false;
//   }
//
//   @override
//   String getAttr (DeviceEntity deviceInfo) {
//     return deviceInfo.detail != null ? (deviceInfo.detail!["brightValue"] * 100 / 255).toStringAsFixed(0) : '';
//   }
//
//   @override
//   String getAttrUnit(DeviceEntity deviceInfo) {
//     return '%';
//   }
//
//   @override
//   String getOffIcon(DeviceEntity deviceInfo) {
//     return 'assets/imgs/device/dengguang_icon_off.png';
//   }
//
//   @override
//   String getOnIcon(DeviceEntity deviceInfo) {
//     return 'assets/imgs/device/dengguang_icon_on.png';
//   }
// }
//
// class WIFILightApi {
//   /// 查询设备状态（物模型）
//   static Future<MzResponseEntity> getLightDetail(String deviceId) async {
//     var res = await DeviceApi.sendPDMOrder('0x13', 'getAllStand', deviceId, {},
//         method: 'GET');
//     return res;
//   }
//
//   /// 设备控制（lua）
//   static Future<MzResponseEntity> powerLua(String deviceId, bool onOff) async {
//     var res = await DeviceApi.sendLuaOrder(
//         '0x13', deviceId, {"power": onOff ? 'on' : 'off'});
//
//     return res;
//   }
//
//   /// 设置延时关灯（物模型）
//   static Future<MzResponseEntity> delayPDM(String deviceId, bool onOff) async {
//     var res = await DeviceApi.sendPDMOrder(
//         '0x13', 'setTimeOff', deviceId, {"timeOff": onOff ? 3 : 0},
//         method: 'POST');
//
//     return res;
//   }
//
//   /// 开关控制（物模型）
//   static Future<MzResponseEntity> powerPDM(String deviceId, bool onOff) async {
//     var res = await DeviceApi.sendPDMOrder(
//         '0x13', 'switchLightWithTime', deviceId, {"dimTime": 0, "power": onOff},
//         method: 'POST');
//
//     return res;
//   }
//
//   /// 模式控制（物模型）
//   static Future<MzResponseEntity> modePDM(String deviceId, String mode) async {
//     var res = await DeviceApi.sendPDMOrder('0x13', 'controlScreenModel',
//         deviceId, {"dimTime": 0, "screenModel": mode},
//         method: 'POST');
//
//     return res;
//   }
//
//   /// 亮度控制（物模型）
//   static Future<MzResponseEntity> brightnessPDM(
//       String deviceId, num brightness) async {
//     var res = await DeviceApi.sendPDMOrder('0x13', 'controlBrightValue',
//         deviceId, {"dimTime": 0, "brightValue": brightness},
//         method: 'POST');
//
//     return res;
//   }
//
//   /// 色温控制（物模型）
//   static Future<MzResponseEntity> colorTemperaturePDM(
//       String deviceId, num colorTemperature) async {
//     var res = await DeviceApi.sendPDMOrder(
//         '0x13',
//         'controlColorTemperatureValue',
//         deviceId,
//         {"dimTime": 0, "colorTemperatureValue": colorTemperature},
//         method: 'POST');
//
//     return res;
//   }
// }
