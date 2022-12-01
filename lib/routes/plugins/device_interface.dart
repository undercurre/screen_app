import 'package:screen_app/models/index.dart';

abstract class DeviceInterface {
  Future<Map<String, dynamic>> getDeviceDetail(String deviceId);
  Future<MzResponseEntity> setPower(String deviceId, bool onOff);
}