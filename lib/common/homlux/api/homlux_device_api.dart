import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:screen_app/common/exceptions/MideaException.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/homlux/lan/homlux_lan_control_device_manager.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';
import 'package:screen_app/common/index.dart';

import '../../logcat_helper.dart';
import '../models/homlux_device_auth_entity.dart';
import '../models/homlux_device_entity.dart';
import '../models/homlux_group_entity.dart';

/// 恢复[HomluxDeviceApi.devices]的单个设备缓存数据
Future<void> _recoverForDevices(String deviceId) async {
  var homeId = HomluxGlobal.homluxHomeInfo?.houseId ?? "xx";
  var devices = HomluxDeviceApi.devices;
  var homeDeviceList = HomluxDeviceApi.homeDeviceList;
  var lanManager = HomluxDeviceApi.lanManager;

  if (!devices.containsKey(deviceId)) {
    if (homeDeviceList.containsKey(homeId)) {
      homeDeviceList[homeId]!.result = homeDeviceList[homeId]!.result?.map((e) {
        e.onLineStatus = 0;
        if (lanManager.deviceMap.containsKey(e.deviceId)) {
          if (lanManager.deviceMap[e.deviceId]?['status'] != null &&
              lanManager.deviceMap[e.deviceId]?['status'].length > 0) {
            e.onLineStatus =
                lanManager.deviceMap[e.deviceId]?['status'][0]?['online'] == 1
                    ? 1
                    : 0;
            Log.file(
                '[device-api] 设备 ${e.deviceId} 局域网状态 ${lanManager.deviceMap[e.deviceId]}');
          }
        }
        return e;
      }).toList();
    } else {
      var jsonStr =
          await LocalStorage.getItem("homlux_device_list_by_home_id_$homeId");
      if (StrUtils.isNotNullAndEmpty(jsonStr)) {
        var entity = HomluxResponseEntity<List<HomluxDeviceEntity>>.fromJson(
            jsonDecode(jsonStr!));
        entity.result = entity.result?.map((e) {
          e.onLineStatus = 0;
          if (lanManager.deviceMap.containsKey(e.deviceId)) {
            if (lanManager.deviceMap[e.deviceId]?['status'] != null &&
                lanManager.deviceMap[e.deviceId]?['status'].length > 0) {
              e.onLineStatus =
                  lanManager.deviceMap[e.deviceId]?['status'][0]?['online'] == 1
                      ? 1
                      : 0;
              Log.file(
                  '[device-api] 设备 ${e.deviceId} 局域网检查状态 ${lanManager.deviceMap[e.deviceId]}');
            }
          }
          devices[e.deviceId!] = e;
          return e;
        }).toList();
        homeDeviceList[homeId] = entity;
      }
    }
  }

  return;
}

class HomluxDeviceApi {
  /// 局域网控制器
  static HomluxLanControlDeviceManager lanManager =
      HomluxLanControlDeviceManager.getInstant();

  // 设备状态存储内存存储器
  static Map<String, HomluxDeviceEntity> devices = {};

  // 灯组状态存储内存存储器
  static Map<String, HomluxGroupEntity> groups = {};

  // 房间设备列表
  static Map<String, HomluxResponseEntity<List<HomluxDeviceEntity>>>
      roomDeviceList = {};

  // 家庭设备列表
  static Map<String, HomluxResponseEntity<List<HomluxDeviceEntity>>>
      homeDeviceList = {};

  // 清除内存缓存
  static void clearMemoryCache() {
    Log.file('[device-api] 清除内存数据');
    devices.clear();
    groups.clear();
    roomDeviceList.clear();
    homeDeviceList.clear();
  }
  /// *****************
  /// *****************
  /// 设备确权接口（目前只有WIFI设备有）
  static Future<HomluxResponseEntity<HomluxDeviceAuthEntity>> getDeviceIsNeedCheck(String deviceId, String houseId, {CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxDeviceAuthEntity>(
        '/v1/thirdparty/midea/device/queryAuthGetStatus',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'deviceId': deviceId, 'houseId': houseId});
  }

  /// ******************
  /// 房间设备列表接口
  /// *******************
  static Future<HomluxResponseEntity<List<HomluxDeviceEntity>>>
      queryDeviceListByRoomId(String roomId, {CancelToken? cancelToken}) async {
    Future<HomluxResponseEntity<List<HomluxDeviceEntity>>>
        getCacheData() async {
      if (roomDeviceList[roomId] != null) {
        roomDeviceList[roomId]!.result =
            roomDeviceList[roomId]!.result?.map((e) {
          e.onLineStatus = 0;
          if (lanManager.deviceMap.containsKey(e.deviceId)) {
            if (lanManager.deviceMap[e.deviceId]?['status'] != null &&
                lanManager.deviceMap[e.deviceId]?['status'].length > 0) {
              e.onLineStatus =
                  lanManager.deviceMap[e.deviceId]?['status'][0]?['online'] == 1
                      ? 1
                      : 0;
              Log.file(
                  '[device-api] 设备 ${e.deviceId} 局域网状态 ${lanManager.deviceMap[e.deviceId]}');
            }
          }
          return e;
        }).toList();
        return roomDeviceList[roomId]!;
      } else {
        var jsonStr =
            await LocalStorage.getItem("homlux_device_list_by_room_id_$roomId");
        if (StrUtils.isNotNullAndEmpty(jsonStr)) {
          var entity = HomluxResponseEntity<List<HomluxDeviceEntity>>.fromJson(
              jsonDecode(jsonStr!));
          entity.result = entity.result?.map((e) {
            e.onLineStatus = 0;
            if (lanManager.deviceMap.containsKey(e.deviceId)) {
              if (lanManager.deviceMap[e.deviceId]?['status'] != null &&
                  lanManager.deviceMap[e.deviceId]?['status'].length > 0) {
                e.onLineStatus = lanManager.deviceMap[e.deviceId]?['status'][0]
                            ?['online'] ==
                        1
                    ? 1
                    : 0;
                Log.file(
                    '[device-api] 设备 ${e.deviceId} 局域网状态 ${lanManager.deviceMap[e.deviceId]}');
              }
            }
            Log.file(
                '[device-api] 设备 ${e.deviceId} 局域网状态 ${lanManager.deviceMap[e.deviceId]}');
            return e;
          }).toList();
          roomDeviceList[roomId] = entity;
          return entity;
        }
      }

      return HomluxResponseEntity<List<HomluxDeviceEntity>>()
        ..code = -1
        ..msg = '请求失败'
        ..success = false;
    }

    void saveCacheData(HomluxResponseEntity<List<HomluxDeviceEntity>>? res,
        [bool clear = false]) async {
      if (clear) {
        roomDeviceList.remove(roomId);
        LocalStorage.removeItem("homlux_device_list_by_room_id_$roomId");
      } else if (res != null) {
        roomDeviceList[roomId] = res;
        LocalStorage.setItem(
            "homlux_device_list_by_room_id_$roomId", jsonEncode(res.toJson()));
      }
    }

    try {
      var res = await HomluxApi.request<List<HomluxDeviceEntity>>(
          '/v1/device/queryDeviceInfoByRoomId',
          cancelToken: cancelToken,
          options: Options(method: 'POST'),
          data: {'roomId': roomId});

      if (res.isSuccess) {
        saveCacheData(res, res.result == null || res.result!.isEmpty);
        return res;
      }
    } catch (e) {
      Log.i('[device-api] 获取房间设备列表ID=$roomId 失败 ', e);
    }
    return getCacheData();
  }

  /// *****************
  /// 请求单个设备详情
  /// [deviceId] 设备id
  /// ****************
  static Future<HomluxResponseEntity<HomluxDeviceEntity>>
      queryDeviceStatusByDeviceId(String deviceId,
          {CancelToken? cancelToken}) async {
    Log.i('[device-api] 请求设备状态 deviceId=$deviceId');

    if (devices[deviceId] == null ||
        !lanManager.deviceMap.containsKey(deviceId)) {
      try {
        HomluxResponseEntity<HomluxDeviceEntity> entity =
            await HomluxApi.request<HomluxDeviceEntity>(
                '/v1/device/queryDeviceInfoByDeviceId',
                cancelToken: cancelToken,
                options: Options(method: 'POST'),
                data: {'deviceId': deviceId});

        /// 更新最新的数据到缓存中
        if (entity.isSuccess && entity.data != null) {
          devices[deviceId] = entity.data!;
          LocalStorage.setItem('homlux_lan_device_save_$deviceId',
              jsonEncode(entity.data!.toJson()));
        }

        Log.file('[device-api] 云端 设备状态返回 ${entity.toJson()}');
        /// 待确权设备统一处理方式。令到界面显示设备异常
        if(entity.isSuccess && entity.data != null) {
          entity.success = entity.data?.authStatus != 1 && entity.data?.authStatus != 2;
          entity.result = entity.isSuccess ? entity.result : null;
        }
        return entity;
      } catch (e) {
        /// 从本地缓存中，还原设备状态
        await _recoverForDevices(deviceId);
        if (devices[deviceId] != null) {
          HomluxResponseEntity<HomluxDeviceEntity> response =
              HomluxResponseEntity()
                ..code = 0
                ..msg = '请求成功'
                ..result = devices[deviceId];
          return response;
        }
      }
    } else {
      // 在局域网获取设备状态
      HomluxResponseEntity responseEntity =
          await lanManager.getDeviceStatus(deviceId);

      if (responseEntity.isSuccess) {
        HomluxDeviceEntity curEntity = devices[deviceId]!;

        /// [{
        //             "modelName": "wallSwicth2",
        //             "online": 1,
        //             "deviceProperty": {
        //                 "ccc": "7",
        //                 "ddd": "5"
        //             }
        //         }]
        var status = responseEntity.result as List<Map<String, dynamic>>;
        var newStatus = <String, dynamic>{};
        for (var statu in status) {
          var name = statu['modelName'] as String;
          var value = statu['deviceProperty'] as Map;
          newStatus[name] = value;
          curEntity.onLineStatus = statu['online'] ?? 0;
        }
        curEntity.mzgdPropertyDTOList =
            HomluxDeviceMzgdPropertyDTOList.fromJson(newStatus);
        HomluxResponseEntity<HomluxDeviceEntity> response =
            HomluxResponseEntity()
              ..code = 0
              ..msg = '请求成功'
              ..result = curEntity;
        Log.file('[device-api]设备状态返回 ${response.toJson()}');
        return response;
      } else {
        Log.file('[device-api] 获取局域网状态失败：$deviceId');
      }
    }

    throw MideaException("[device-api] 请求设备状态失败");
  }

  /// ******************
  /// 获取家庭设备列表
  /// *******************
  static Future<HomluxResponseEntity<List<HomluxDeviceEntity>>>
      queryDeviceListByHomeId(String homeId,
          {bool enableCache = true, CancelToken? cancelToken}) async {
    Future<HomluxResponseEntity<List<HomluxDeviceEntity>>>
        getCacheData() async {
      if (homeDeviceList[homeId] != null) {
        homeDeviceList[homeId]!.result =
            homeDeviceList[homeId]!.result?.map((e) {
          e.onLineStatus = 0;
          if (lanManager.deviceMap.containsKey(e.deviceId)) {
            if (lanManager.deviceMap[e.deviceId]?['status'] != null &&
                lanManager.deviceMap[e.deviceId]?['status'].length > 0) {
              e.onLineStatus =
                  lanManager.deviceMap[e.deviceId]?['status'][0]?['online'] == 1
                      ? 1
                      : 0;
            }
          }
          devices[e.deviceId!] = e;
          return e;
        }).toList();
        Log.file(
            '[device-api] 家庭设备列表 局域网状态 ${homeDeviceList[homeId]!.toJson()}');
        return homeDeviceList[homeId]!;
      } else {
        var jsonStr =
            await LocalStorage.getItem("homlux_device_list_by_home_id_$homeId");
        if (StrUtils.isNotNullAndEmpty(jsonStr)) {
          var entity = HomluxResponseEntity<List<HomluxDeviceEntity>>.fromJson(
              jsonDecode(jsonStr!));
          entity.result = entity.result?.map((e) {
            e.onLineStatus = 0;
            if (lanManager.deviceMap.containsKey(e.deviceId)) {
              if (lanManager.deviceMap[e.deviceId]?['status'] != null &&
                  lanManager.deviceMap[e.deviceId]?['status'].length > 0) {
                e.onLineStatus = lanManager.deviceMap[e.deviceId]?['status'][0]
                            ?['online'] ==
                        1
                    ? 1
                    : 0;
              }
            }
            devices[e.deviceId!] = e;
            return e;
          }).toList();
          homeDeviceList[homeId] = entity;
          Log.file('[device-api] 家庭设备列表 局域网状态 ${entity.toJson()}');
          return entity;
        }
      }
      return HomluxResponseEntity<List<HomluxDeviceEntity>>()
        ..code = -1
        ..msg = '请求失败'
        ..success = false;
    }

    void saveCache(HomluxResponseEntity<List<HomluxDeviceEntity>> res,
        [bool clear = false]) {
      if (clear) {
        homeDeviceList.remove(homeId);
        LocalStorage.removeItem("homlux_device_list_by_home_id_$homeId");
      } else {
        homeDeviceList[homeId] = res;
        LocalStorage.setItem(
            "homlux_device_list_by_home_id_$homeId", jsonEncode(res.toJson()));
      }
    }

    try {
      var res = await HomluxApi.request<List<HomluxDeviceEntity>>(
          '/v1/device/queryDeviceInfoByHouseId',
          cancelToken: cancelToken,
          options: Options(method: 'POST'),
          data: {'houseId': homeId});

      if (res.isSuccess) {
        saveCache(res, res.result == null || res.result!.isEmpty);
        return res;
      }
    } catch (e) {
      Log.file('[device-api] 获取家庭设备列表失败 $homeId', e);
    }

    if (enableCache) {
      return getCacheData();
    }

    throw MideaException("请求homlux设备列表失败");
  }

  /// *****************
  /// 根据分组id查设备详情
  /// [groupId] 分组id
  /// ****************
  static Future<HomluxResponseEntity<HomluxGroupEntity>> queryGroupByGroupId(
      String groupId,
      {CancelToken? cancelToken}) async {
    Future<HomluxResponseEntity<HomluxGroupEntity>> getCacheData() async {
      if (groups.containsKey(groupId)) {
        Log.file('[device-api] 获取灯组$groupId详情 ${groups[groupId]}');
        return HomluxResponseEntity()
          ..code = 0
          ..msg = "请求成功"
          ..result = groups[groupId];
      } else {
        var jsonStr =
            await LocalStorage.getItem('homlux_lan_group_save_$groupId');
        if (StrUtils.isNotNullAndEmpty(jsonStr)) {
          HomluxGroupEntity entity =
              HomluxGroupEntity.fromJson(jsonDecode(jsonStr!));
          groups[groupId] = entity;
          Log.file('[device-api] 获取灯组$groupId详情 $entity');
          return HomluxResponseEntity()
            ..code = 0
            ..msg = "请求成功"
            ..result = entity;
        }
      }
      return HomluxResponseEntity()
        ..code = -1
        ..msg = "请求失败";
    }

    try {
      var res = await HomluxApi.request<HomluxGroupEntity>(
          '/v1/mzgd/scene/queryGroupByGroupId',
          cancelToken: cancelToken,
          options: Options(method: 'POST'),
          data: {'groupId': groupId});

      if (res.isSuccess) {
        if (res.data != null) {
          groups['groupId'] = res.data!;
          LocalStorage.setItem(
              'homlux_lan_group_save_$groupId', jsonEncode(res.data!.toJson()));
        } else {
          groups.remove(groupId);
          LocalStorage.removeItem('homlux_lan_group_save_$groupId');
        }
      }

      return res;
    } catch (e) {
      Log.i('[device-api] 请求云端灯组列表失败');
    }

    return getCacheData();
  }

  /// ******************
  /// 控制面板的某一路开和关
  /// [panelId] 面板id
  /// [switchId] 某一路id
  /// [masterId] 面板的网关id
  /// [onOff] 0关 1开
  /// *******************
  static Future<HomluxResponseEntity> controlPanelOnOff(
      String panelId, String switchId, String masterId, int onOff) {
    /// 云端 设备执行的action
    var cloudActions = [
      <String, dynamic>{
        'devId': panelId,
        'modelName': 'wallSwitch$switchId',
        'power': onOff
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'wallSwitch$switchId',
        'deviceProperty': {'power': onOff}
      }
    ];

    return _controlDevice(
      topic: '/subdevice/control',
      deviceId: masterId,
      method: 'panelSingleControlNew',
      cloudInputData: cloudActions,
      lanInputData: lanActions,
      lanDeviceId: panelId,
    );
  }

  /// ******************
  /// 控制zigbee调光调色灯的开和关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [masterId] 面板的网关id
  /// [onOff] 0关 1开
  /// *******************
  static Future<HomluxResponseEntity> controlZigbeeLightOnOff(
      String deviceId, String deviceType, String masterId, int onOff) {
    var cloudActions = [
      <String, dynamic>{'devId': deviceId, 'modelName': "light", 'power': onOff}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'power': onOff}
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制zigbee调光调色灯的延时关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [masterId] 面板的网关id
  /// [delayTime] 延时分钟
  /// *******************
  static Future<HomluxResponseEntity> controlZigbeeLightDelayOff(
      String deviceId, String deviceType, String masterId, int delayTime) {
    var cloudActions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'DelayClose': delayTime
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'DelayClose': delayTime}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制zigbee调光调色灯的亮度
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [masterId] 面板的网关id
  /// [brightness] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlZigbeeBrightness(
      String deviceId, String deviceType, String masterId, int brightness) {
    var cloudActions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'brightness': brightness
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'brightness': brightness}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制zigbee调光调色灯的色温
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [masterId] 面板的网关id
  /// [colorTemp] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlZigbeeColorTemp(
      String deviceId, String deviceType, String masterId, int colorTemp) {
    var cloudActions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'colorTemperature': colorTemp
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'colorTemperature': colorTemp}
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制zigbee调光调色灯的亮度和色温
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [masterId] 面板的网关id
  /// [colorTemp] 0 - 100
  /// [brightness] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlZigbeeColorTempAndBrightness(
      String deviceId,
      String deviceType,
      String masterId,
      int colorTemp,
      int brightness) {
    var cloudActions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'colorTemperature': colorTemp,
        'brightness': brightness
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {
          'colorTemperature': colorTemp,
          'brightness': brightness
        }
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi调光调色灯的开和关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 0关 1开
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLightOnOff(
      String deviceId, String deviceType, int onOff) {
    var cloudActions = [
      <String, dynamic>{'power': onOff}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'power': onOff == 1 ? 1 : 0}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi调光调色灯的开和关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [brightness] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLightBrightness(
      String deviceId, String deviceType, int brightness) {
    var cloudActions = [
      <String, dynamic>{'brightness': brightness}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'brightness': '$brightness'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi调光调色灯的色温
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [colorTemp] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLightColorTemp(
      String deviceId, String deviceType, int colorTemp) {
    var cloudActions = [
      <String, dynamic>{'colorTemperature': colorTemp}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'colorTemperature': colorTemp}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi调光调色灯的延时关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [delayTime] 延时分钟
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLightDelayOff(
      String deviceId, String deviceType, int delayTime) {
    var cloudActions = [
      <String, dynamic>{'delay_light_off': '$delayTime'}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'delay_light_off': '$delayTime'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi调光调色灯的模式
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [delayTime] 延时分钟
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLightMode(
      String deviceId, String deviceType, String mode) {
    var cloudActions = [
      <String, dynamic>{'scene_light': mode}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'scene_light': mode}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi窗帘的全开和全关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 0关 1开
  /// *******************
  static Future<HomluxResponseEntity> controlWifiCurtainOnOff(
      String deviceId, String deviceType, int onOff) {
    var cloudActions = [
      <String, dynamic>{'curtain_status': onOff == 1 ? "open" : "close"}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'curtain',
        'deviceProperty': {'curtain_status': onOff == 1 ? "open" : "close"}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi窗帘位置百分比
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [position] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlWifiCurtainPosition(
      String deviceId, String deviceType, int position) {
    var cloudActions = [
      <String, dynamic>{'curtain_position': "$position"}
    ];

    var lanActions = [
      <String, dynamic>{
        'modelName': 'curtain',
        'deviceProperty': {'curtain_position': "$position"}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi窗帘暂停
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// *******************
  static Future<HomluxResponseEntity> controlWifiCurtainStop(
      String deviceId, String deviceType) {
    var cloudActions = [
      <String, dynamic>{'curtain_status': "stop"}
    ];

    var lanActions = [
      <String, dynamic>{
        'modelName': 'curtain',
        'deviceProperty': {'curtain_status': "stop"}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制灯组的开和关
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 0关 1开
  /// *******************
  static Future<HomluxResponseEntity> controlGroupLightOnOff(
      String groupId, int onOff) {
    var actions = [
      <String, dynamic>{'power': onOff}
    ];
    return _controlGroupLight(groupId: groupId, action: actions);
  }

  /// ******************
  /// 控制灯组的亮度
  /// [groupId] 分组id
  /// [brightness] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlGroupLightBrightness(
      String groupId, int brightness) {
    var actions = [
      <String, dynamic>{'brightness': brightness}
    ];
    return _controlGroupLight(groupId: groupId, action: actions);
  }

  /// ******************
  /// 控制灯组的色温
  /// [groupId] 分组id
  /// [colorTemp] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> controlGroupLightColorTemp(
      String groupId, int colorTemp) {
    var actions = [
      <String, dynamic>{'colorTemperature': colorTemp}
    ];
    return _controlGroupLight(groupId: groupId, action: actions);
  }

  /// *****************
  /// 控制设备
  /// ******************
  static Future<HomluxResponseEntity> _controlDevice(
      {required String topic,
      required String deviceId,
      required String method,
      required List<Map<String, dynamic>> cloudInputData,
      required List<Map<String, dynamic>> lanInputData,
      required String lanDeviceId,
      Map<String, dynamic>? extraMap}) async {
    /// 局域网控制设备
    HomluxResponseEntity lanEntity =
        await lanManager.executeDevice(lanDeviceId, lanInputData);
    if (lanEntity.isSuccess) {
      return lanEntity;
    }

    /// 云端控制设备
    return HomluxApi.request('/v1/device/down', data: {
      ...extraMap ?? {},
      'topic': topic,
      'deviceId': deviceId,
      'method': method,
      'inputData': cloudInputData
    });
  }

  /// *****************
  /// 控制灯组
  /// ******************
  static Future<HomluxResponseEntity> _controlGroupLight(
      {required String groupId,
      required List<Map<String, dynamic>> action}) async {
    if (!groups.containsKey(groupId)) {
      var json = await LocalStorage.getItem('homlux_lan_group_save_$groupId');
      if (StrUtils.isNotNullAndEmpty(json)) {
        groups[groupId] = HomluxGroupEntity.fromJson(jsonDecode(json!));
      }
    }

    int? updateStamp = groups[groupId]?.updateStamp;

    /// 局域网控制灯组
    HomluxResponseEntity lanEntity =
        await lanManager.executeGroup(groupId, updateStamp ?? 0, action);

    if (lanEntity.isSuccess) {
      return lanEntity;
    }

    /// 云端控制灯组
    return HomluxApi.request('/v1/mzgd/scene/groupControl',
        data: {'groupId': groupId, 'controlAction': action});
  }

  /// ******************
  /// 控制wifi浴霸的模式打开
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [mode] 打开的模式
  /// *******************
  static Future<HomluxResponseEntity> controlWifiYubaModeOn(
      String deviceId, String deviceType, String mode, String heating_temp) {
    var cloudActions = [
      <String, dynamic>{'mode_enable': mode}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'deviceProperty': {'mode_enable': mode}
      }
    ];

    if (mode == 'heating') {
      cloudActions = [
        <String, dynamic>{
          'mode_enable': mode,
          'heating_temperature': heating_temp
        }
      ];
      <String, dynamic>{
        'deviceProperty': {
          'mode_enable': mode,
          'heating_temperature': heating_temp
        }
      };
    }

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiBathHeatControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi浴霸的模式关闭
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [mode] 打开的模式
  /// *******************
  static Future<HomluxResponseEntity> controlWifiYubaModeOff(
      String deviceId, String deviceType, String mode) {
    var cloudActions = [
      <String, dynamic>{'mode_close': mode}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'deviceProperty': {'mode_close': mode}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiBathHeatControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi浴霸的灯光打开
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [mode] 打开的模式
  /// *******************
  static Future<HomluxResponseEntity> controlWifiYubaLightMode(
      String deviceId, String deviceType, String mode) {
    var cloudActions = [
      <String, dynamic>{'light_mode': mode}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'light_mode': mode}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiBathHeatControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi浴霸的延时打开
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 延迟开关
  /// [min] 延迟时间
  /// *******************
  static Future<HomluxResponseEntity> controlWifiYubaDelay(
      String deviceId, String deviceType, String onOff, String min) {
    var cloudActions = [
      <String, dynamic>{'delay_enable': onOff, 'delay_time': min}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'delay_enable': onOff, 'delay_time': min}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiBathHeatControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi晾衣架的灯光
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 灯光开关
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLiangyiLight(
      String deviceId, String onOff) {
    var cloudActions = [
      <String, dynamic>{'light': onOff}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'light': onOff}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiClothesDryingRackControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制wifi晾衣架的一键晾衣
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 灯光开关
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLiangyiLaundry(
      String deviceId, String onOff) {
    var cloudActions = [
      <String, dynamic>{'laundry': onOff}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'laundry': onOff}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiClothesDryingRackControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制wifi晾衣架的升降
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [updown] 升降状态
  /// *******************
  static Future<HomluxResponseEntity> controlWifiLiangyiUpdown(
      String deviceId, String updown) {
    var cloudActions = [
      <String, dynamic>{'updown': updown}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty': {'updown': updown}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiClothesDryingRackControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制wifi空调
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [onOff] 开关
  /// *******************
  static Future<HomluxResponseEntity> controlAirConditionerOnOff(
      String deviceId, int onOff) {
    var cloudActions = [
      <String, dynamic>{'power': onOff}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'power': onOff}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiAirControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制wifi空调
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [speed] 风速
  /// *******************
  static Future<HomluxResponseEntity> controlAirConditionerWindSpeed(
      String deviceId, int speed) {
    var cloudActions = [
      <String, dynamic>{'wind_speed': speed}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'wind_speed': speed}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiAirControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制wifi空调
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [temperature] 温度
  /// *******************
  static Future<HomluxResponseEntity> controlAirConditionerTemperature(
      String deviceId, int temperature, double smallTemperature) {
    var cloudActions = [
      <String, dynamic>{
        'temperature': temperature,
        'small_temperature': smallTemperature
      },
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {
          'temperature': temperature,
          "small_temperature": smallTemperature
        },
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiAirControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制wifi空调
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// [mode] 模式
  /// *******************
  static Future<HomluxResponseEntity> controlAirConditionerModel(
      String deviceId, String mode) {
    var cloudActions = [
      <String, dynamic>{'mode': mode},
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'mode': mode},
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiAirControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': '3'});
  }

  /// ******************
  /// 控制485地暖
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [power] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> control485HeatFloorPower(
      String gatewayId, String deviceId, int power) {
    var cloudActions = [
      <String, dynamic>{
        'power': power,
        'devId': deviceId,
        'modelName': 'floorHeating'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'floorHeating',
        'deviceProperty': {'power': '$power'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }



  /// ******************
  /// 控制485地暖 温度
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [targetTemperature] 5 - 90
  /// *******************
  static Future<HomluxResponseEntity> control485HeatFloorTemp(
      String gatewayId, String deviceId, int targetTemperature) {
    var cloudActions = [
      <String, dynamic>{
        'targetTemperature': targetTemperature,
        'devId': deviceId,
        'modelName': 'freshAir'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'floorHeating',
        'deviceProperty': {'targetTemperature': '$targetTemperature'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }

  /// ******************
  /// 控制485新风
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [power] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> control485FreshAirPower(
      String gatewayId, String deviceId, int power) {
    var cloudActions = [
      <String, dynamic>{
        'power': power,
        'devId': deviceId,
        'modelName': 'freshAir'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'freshAir',
        'deviceProperty': {'power': '$power'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }



  /// ******************
  /// 控制485新风 风速
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [windSpeed] 风速挡位 1 - 3
  /// *******************
  static Future<HomluxResponseEntity> control485FreshAirWindSpeed(
      String gatewayId, String deviceId, int windSpeed) {
    var cloudActions = [
      <String, dynamic>{
        'windSpeed': windSpeed,
        'devId': deviceId,
        'modelName': 'freshAir'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'freshAir',
        'deviceProperty': {'windSpeed': '$windSpeed'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }


  /// ******************
  /// 控制485空调
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [power] 0 - 100
  /// *******************
  static Future<HomluxResponseEntity> control485AirPower(
      String gatewayId, String deviceId, int power) {
    var cloudActions = [
      <String, dynamic>{
        'power': power,
        'devId': deviceId,
        'modelName': 'airConditioner'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'power': '$power'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }



  /// ******************
  /// 控制485空调 风速
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [targetTemperature] 温度 16 - 30
  /// *******************
  static Future<HomluxResponseEntity> control485AirTemp(
      String gatewayId, String deviceId, int targetTemperature) {
    var cloudActions = [
      <String, dynamic>{
        'targetTemperature': targetTemperature,
        'devId': deviceId,
        'modelName': 'airConditioner'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'targetTemperature': '$targetTemperature'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }

  /// ******************
  /// 控制485空调 模式
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [mode] 1 制冷 2 除湿 4 送风 8制热
  /// *******************
  static Future<HomluxResponseEntity> control485AirMode(
      String gatewayId, String deviceId, int mode) {
    var cloudActions = [
      <String, dynamic>{
        'mode': mode,
        'devId': deviceId,
        'modelName': 'airConditioner'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'mode': '$mode'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }


  /// ******************
  /// 控制485空调 风速
  /// [gatewayId] 网关Id
  /// [deviceId] 设备Id
  /// [windSpeed] 风速挡位 1 - 3
  /// *******************
  static Future<HomluxResponseEntity> control485AirWindSpeed(
      String gatewayId, String deviceId, int windSpeed) {
    var cloudActions = [
      <String, dynamic>{
        'windSpeed': windSpeed,
        'devId': deviceId,
        'modelName': 'airConditioner'
      }
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'airConditioner',
        'deviceProperty': {'windSpeed': '$windSpeed'}
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: gatewayId,
        method: 'airControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': "2"});
  }

}
