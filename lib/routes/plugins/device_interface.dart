import 'package:screen_app/models/index.dart';

abstract class DeviceInterface {
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo);
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff);
  bool isSupport(DeviceEntity deviceInfo);
  bool isPower(DeviceEntity deviceInfo);
  String getAttr(DeviceEntity deviceInfo);
  String getAttrUnit(DeviceEntity deviceInfo);
  String getOnIcon(DeviceEntity deviceInfo);
  String getOffIcon(DeviceEntity deviceInfo);
}