
import 'package:screen_app/channel/models/wifi_scan_result.dart';

import '../../common/global.dart';

abstract class IFindDeviceResult {
  late String name;
  late String icon;
}

class FindZigbeeResult implements IFindDeviceResult {

  @override
  late String icon;
  @override
  late String name;
  late FindZigbeeResultInfo device;
  FindZigbeeResult();

  @override
  operator ==(Object other) {
    if(runtimeType != other.runtimeType) return false;
    return other is FindZigbeeResult
        && other.device.sn == device.sn;
  }

  @override
  int get hashCode => Object.hash(name, icon, device.sn);

  factory FindZigbeeResult.fromJson(Map<dynamic, dynamic> map) => FindZigbeeResult()
      ..icon = map["icon"]
      ..name = map["name"]
      ..device = FindZigbeeResultInfo.fromJson(map["device"]);

  static List<FindZigbeeResult>? fromArray(List<dynamic>? list) {
    if(list == null || list.isEmpty) {
      return null;
    }
    final result = <FindZigbeeResult>[];
    for (var value in list) {
      if(value is Map) {
        FindZigbeeResult findZigbeeResult = FindZigbeeResult.fromJson(value);
        result.add(findZigbeeResult);
      } else {
        throw Exception("请确保类型为Map");
      }
    }
    return result;
  }

}

class FindZigbeeResultInfo {
  FindZigbeeResultInfo();
   late String applianceCode;
   late String name;
   late String applianceType;
   late String modelNum;
   late String sn;
   late String desc;
   late String masterId;
   late String status;
   late String activeStatus;
   late String homegroupId;
   late String prop;
   late String lastActiveTime;
   late String version;

   factory FindZigbeeResultInfo.fromJson(Map<dynamic, dynamic> map) => FindZigbeeResultInfo()
       ..applianceCode = map["applianceCode"]
       ..name = map["name"]
       ..applianceType = map["applianceType"]
       ..modelNum = map["modelNum"]
       ..sn = map["sn"]
       ..desc = map["desc"]
       ..masterId = map["masterId"]
       ..status = map["status"]
       ..activeStatus = map["activeStatus"]
       ..homegroupId = map["homegroupId"]
       ..prop = map["prop"]
       ..lastActiveTime = map["lastActiveTime"]
       ..version = map["version"];

   Map<String, dynamic> toJson() => {
     'applianceCode': applianceCode,
     'name': name,
     'applianceType': applianceType,
     'modelNum': modelNum,
     'sn': sn,
     'desc': desc,
     'masterId': masterId,
     'status': status,
     'activeStatus': activeStatus,
     'prop': prop,
     'lastActiveTime': lastActiveTime,
     'version': version,
   };

}

// 如果类型为BindResult<FindZigbeeResult> 说明为zigbee绑定的结果
// 如果类型为BindResult<FindWiFiResult> 说明为wifi绑定的结果
class BindResult<T extends IFindDeviceResult> {
  late int code; // 0表示成功 -1表示失败
  late String message;// 如果失败会有失败的原因
  late int waitDeviceBind; //剩下多少设备需要绑定
  late T findResult; // 发现设备的详情
  ApplianceBean? bindResult; // 绑定的详情
  BindResult();

  // 转换为zigbee设备的绑定结果
  factory BindResult.convertZigbeeFromJson(Map<dynamic, dynamic> map) => BindResult()
  ..code = map['code']
  ..message = map['message']
  ..waitDeviceBind = map['waitDeviceBind']
  ..findResult = FindZigbeeResult.fromJson(map['findResult']) as T
  ..bindResult = ApplianceBean.parse(map['bindInfo']);

  // 转换为wifi设备的绑定结果
  factory BindResult.convertWiFiFromJson(Map<dynamic, dynamic> map) => BindResult()
    ..code = map['code']
    ..message = map['message']
    ..waitDeviceBind = map['waitDeviceBind']
    ..findResult = FindWiFiResult.fromJson(map['findResult']) as T
    ..bindResult = ApplianceBean.parse(map['bindInfo']);

  @override
  String toString() {
    return {
      'code': code,
      'message': message,
      'waitDeviceBind': waitDeviceBind,
      'findResult': findResult,
      'bindResult': bindResult
    }.toString();
  }

}

class ApplianceBean {
  late String applianceCode;// IOT平台的设备唯一标识
  late String onlineStatus; // 在线状态
  late String type; // 设备类型
  late String modelNumber; //
  late String name; // 设备名称
  late String des;
  late String activeStatus;
  late String homegroupId; // 绑定的家庭id
  late String roomId;// 绑定房间id
  late String roomName;// 绑定的房间名称
  late String rawSn; // 设备sn
  ApplianceBean();

  factory ApplianceBean.fromJson(Map<dynamic, dynamic> map) => ApplianceBean()
    ..applianceCode = map["applianceCode"]
    ..name = map["name"]
    ..type = map["type"]
    ..modelNumber = map["modelNumber"]
    ..des = map["des"]
    ..activeStatus = map["activeStatus"]
    ..homegroupId = map["homegroupId"]
    ..roomId = map["roomId"]
    ..rawSn = map["rawSn"]
    ..roomName = Global.profile.homeInfo?.roomList?.firstWhere((element) => element.id == map["roomId"]).name ?? ''
    ..onlineStatus = map["onlineStatus"];

  static ApplianceBean? parse(Map<dynamic, dynamic>? map) {
    if(map == null) {
      return null;
    } else {
      return ApplianceBean.fromJson(map);
    }
  }

  @override
  String toString() {
    return {
      'applianceCode': applianceCode,
      'onlineStatus': onlineStatus,
      'type': type,
      'homegroupId': homegroupId,
      'roomId': roomId
    }.toString();
  }

}


class ModifyDeviceResult {
  late int suc; // 0表示成功 -1表示失败
  late String homeGroupId; // 如果成功的话，这个值就是当前绑定的家庭id
  late String roomId; // 如果成功的话，这个值就是当前房间id
  late String applianceCode; // 设备的code
  ModifyDeviceResult();

  factory ModifyDeviceResult.fromJson(Map<dynamic, dynamic> json) => ModifyDeviceResult()
  ..suc = json['suc']
  ..homeGroupId = json['homeGroupId']
  ..roomId = json['roomId']
  ..applianceCode = json['applianceCode'];

}

class FindWiFiResult implements IFindDeviceResult {
  @override
  late String icon;
  @override
  late String name;
  late WiFiScanResult info;
  FindWiFiResult();

  @override
  operator ==(Object? other) {
    if(runtimeType != other.runtimeType) return false;
    return other is FindWiFiResult
        && other.info.ssid == info.ssid
        && other.info.bssid == info.bssid;
  }


  @override
  String toString() {
    return {
      'icon': icon,
      'name': name,
      'info': {
        'ssid': info.ssid,
        'bssid': info.bssid
      }
    }.toString();
  }

  factory FindWiFiResult.fromJson(Map<dynamic, dynamic> map) => FindWiFiResult()
      ..icon = map["icon"]
      ..name = map["name"]
      ..info = WiFiScanResult.fromJson(map["info"]);

  static List<FindWiFiResult>? fromArray(List<dynamic>? list) {
    if(list == null || list.isEmpty) {
      return null;
    }
    final result = <FindWiFiResult>[];
    for (var value in list) {
      if(value is Map) {
        FindWiFiResult findZigbeeResult = FindWiFiResult.fromJson(value);
        result.add(findZigbeeResult);
      } else {
        throw Exception("请确保类型为Map");
      }
    }
    return result;
  }

  @override
  int get hashCode => Object.hash(info.ssid, info.bssid);

}