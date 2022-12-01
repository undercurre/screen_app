import 'package:screen_app/models/index.dart';

abstract class DeviceInterface {
  Map<String, dynamic> getDeviceDetail(String deviceId);
  MzResponseEntity setPower(String deviceId, bool onOff);
  bool isPower(Map<String, dynamic> status);
  num getAttr(Map<String, dynamic> status,String attrName);
}