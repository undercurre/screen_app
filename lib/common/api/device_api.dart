import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'api.dart';
import '../../models/index.dart';

class DeviceApi {
  /// 获取设备详情（lua）
  static Future<MzResponseEntity> getDeviceDetail(
      String type, String applianceCode) async {
    var res = await Api.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/status/query",
        data: {
          "applianceCode": applianceCode,
          "categoryCode": type,
          "version": "1.0",
          "frontendType": "ANDROID",
          "systemSource": "SMART_SCREEN",
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

  /// 设备lua控制
  static Future<MzResponseEntity> sendLuaOrder(
      String categoryCode, String applianceCode, Object command) async {
    var res = await Api.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/wifiControl",
        data: {
          "deviceId": applianceCode,
          "userId": Global.user?.uid,
          "command": command,
          "categoryCode": categoryCode,
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDROID",
          "reqId": uuid.v4(),
          "version": "1.0",
          "timestamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

  /// 设备物模型控制
  static Future<MzResponseEntity> sendPDMOrder(
      String categoryCode, String uri, String applianceCode, Object command,
      {String? method = "PUT"}) async {
    var res = await Api.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/control",
        data: {
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDRIOD",
          "categoryCode": categoryCode,
          "reqId": uuid.v4(),
          "method": method,
          "command": command,
          "msgId": uuid.v4(),
          "uri": '/$uri/$applianceCode',
          "deviceId": applianceCode,
          "userId": Global.user?.uid,
          "timestamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

  /// 设备列表查询
  static Future<List<DeviceHomeListHomeListRoomListApplianceList>>
      getDeviceList() async {
    var res = await Api.requestMzIot<DeviceHomeListEntity>(
        "/v1/category/midea/device/list",
        data: {
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDROID",
          "reqId": uuid.v4(),
          "userId": Global.user?.uid,
          "homeGroupId": Global.profile.homeInfo?.homegroupId,
          "version": "1.0",
          "timestamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    var modelRes = res.result;
    var homeList = modelRes.homeList;
    var roomList = homeList![0].roomList;
    var curRoom = roomList
        ?.where((element) => element.id == Global.profile.roomInfo?.roomId)
        .toList()[0];

    return curRoom!.applianceList!;
  }

  static Future<MzResponseEntity<String>> getGatewayInfo(
      String deviceId, String masterId) async {
    var res =
        await Api.requestMzIot<String>("/v1/category/midea/getGatewayInfo",
            data: {
              "systemSource": "SMART_SCREEN",
              "frontendType": "ANDRIOD",
              "userId": Global.user?.uid,
              "applianceCode": masterId,
              "devId": deviceId,
              "reqId": uuid.v4(),
              "version": "1.0",
              "timestamp":
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
            },
            options: Options(
              method: 'POST',
              headers: {'accessToken': Global.user?.accessToken},
            ));

    return res;
  }

  // 灯组相关接口
  static Future<MzResponseEntity> groupRelated(
      String handleType, String commond) async {
    var res =
        await Api.requestMzIot<dynamic>("/v1/category/midea/light/groupRelated",
            data: {
              "systemSource": "SMART_SCREEN",
              "frontendType": "ANDRIOD",
              "userId": Global.user?.uid,
              "handleType": handleType,
              "data": commond,
              "reqId": uuid.v4(),
              "version": "1.0",
              "uid": Global.profile.user?.uid,
              "timestamp":
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
            },
            options: Options(
              method: 'POST',
              headers: {'accessToken': Global.user?.accessToken},
            ));

    return res;
  }

  // 灯组查询
  static Future<MideaResponseEntity<Map<String, dynamic>>> getGroupList() async {
    var res = await Api.requestMideaIot<Map<String, dynamic>>(
        "/mas/v5/app/proxy?alias=/mzgd/v2/appliance/group/list",
        data: {
          "homegroupId": Global.profile.homeInfo?.homegroupId,
          "reqId": uuid.v4(),
          "stamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          "uid": Global.profile.user?.uid
        },
        queryParameters: {
          "homegroupId": Global.profile.homeInfo?.homegroupId,
          "reqId": uuid.v4(),
          "stamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          "uid": Global.profile.user?.uid
        },
        options: Options(method: 'POST'));

    return res;
  }
}
