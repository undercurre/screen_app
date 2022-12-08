import 'package:screen_app/models/index.dart';

abstract class DeviceInterface {
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo);
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff);
}