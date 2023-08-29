import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/lan/homlux_lan_control_device_manager.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';
import 'package:screen_app/common/index.dart';

import '../../logcat_helper.dart';
import '../models/homlux_device_entity.dart';
import '../models/homlux_group_entity.dart';

class HomluxDeviceApi {
  /// 局域网控制器
  static HomluxLanControlDeviceManager lanManager = HomluxLanControlDeviceManager.getInstant();
  // 设备状态存储内存存储器
  static Map<String, HomluxDeviceEntity> devices = {};

  /// ******************
  /// 房间设备列表接口
  /// *******************
  static Future<HomluxResponseEntity<List<HomluxDeviceEntity>>>
      queryDeviceListByRoomId(String roomId, {CancelToken? cancelToken}) {
    return HomluxApi.request<List<HomluxDeviceEntity>>(
        '/v1/device/queryDeviceInfoByRoomId',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'roomId': roomId});
  }

  /// *****************
  /// 请求单个设备详情
  /// [deviceId] 设备id
  /// ****************
  static Future<HomluxResponseEntity<HomluxDeviceEntity>>
      queryDeviceStatusByDeviceId(String deviceId,
          {CancelToken? cancelToken, bool forceRequestNetwork = false}) async {

    /// 从本地缓存中，还原设备状态
    if(!devices.containsKey(deviceId)) {
      String? devJson = await LocalStorage.getItem('homlux_lan_device_save_$deviceId');
      if(devJson != null) {
        HomluxDeviceEntity entity = HomluxDeviceEntity.fromJson(jsonDecode(devJson));
        devices[deviceId] = entity;
      }
    }

    if (!forceRequestNetwork && devices[deviceId] != null && lanManager.deviceMap.containsKey(deviceId)) {
      lanManager.getDeviceStatus(deviceId);
      HomluxDeviceEntity curEntity = devices[deviceId]!;
      var curDevice = lanManager.deviceMap[deviceId] as Map<String, dynamic>;
      var curVersion = curDevice['statusVersion'] as int;
      var curStatus = curDevice['status'] as Map<String, dynamic>;
      int time = DateTime.now().millisecondsSinceEpoch;
      bool lanHandlerResult = false;

      await Future.doWhile(() async {
        if (DateTime.now().millisecondsSinceEpoch - time >= 3000) {
          lanHandlerResult = false;
          return false;
        } else {
          var device = lanManager.deviceMap[deviceId];
          var status = device?['status'] as Map<String, dynamic>?;
          var version = device?['statusVersion'] as int?;
          if (status != null && version != null) {
            if (version > curVersion) {
              /// 请求成功
              Log.i('homlux 局域网 请求设备$deviceId状态成功');
              curDevice = device!;
              curVersion = version;
              curStatus = status;
              return false;
            }
          }
        }
        return true;
      });

      if (lanHandlerResult) {
        curEntity.mzgdPropertyDTOList = HomluxDeviceMzgdPropertyDTOList.fromJson(curStatus['deviceProperty']);
        LocalStorage.setItem('homlux_lan_device_save_$deviceId', jsonEncode(curEntity.toJson()));
        HomluxResponseEntity<HomluxDeviceEntity> response = HomluxResponseEntity()
        ..code = 0
        ..msg = '请求成功'
        ..result = curEntity;
        return response;
      }

    }

    HomluxResponseEntity<HomluxDeviceEntity> entity = await HomluxApi.request<HomluxDeviceEntity>(
        '/v1/device/queryDeviceInfoByDeviceId',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'deviceId': deviceId});

    /// 更新最新的数据到缓存中
    if(entity.isSuccess && entity.data != null) {
      devices[deviceId] = entity.data!;
      LocalStorage.setItem('homlux_lan_device_save_$deviceId', jsonEncode(entity.data!.toJson()));
    }

    return entity;
  }

  /// ******************
  /// 获取家庭设备列表
  /// *******************
  static Future<HomluxResponseEntity<List<HomluxDeviceEntity>>>
      queryDeviceListByHomeId(String homeId, {CancelToken? cancelToken}) {
    return HomluxApi.request('/v1/device/queryDeviceInfoByHouseId',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'houseId': homeId});
  }

  /// *****************
  /// 根据分组id查设备详情
  /// [groupId] 分组id
  /// ****************
  static Future<HomluxResponseEntity<HomluxGroupEntity>> queryGroupByGroupId(
      String groupId,
      {CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxGroupEntity>(
        '/v1/mzgd/scene/queryGroupByGroupId',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'groupId': groupId});
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
    var actions = [
      <String, dynamic>{
        'devId': panelId,
        'modelName': 'wallSwitch$switchId',
        'power': onOff
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'panelSingleControlNew',
        inputData: actions);
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
    var actions = [
      <String, dynamic>{'devId': deviceId, 'modelName': "light", 'power': onOff}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'DelayClose': delayTime
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'brightness': brightness
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'colorTemperature': colorTemp
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{
        'devId': deviceId,
        'modelName': "light",
        'colorTemperature': colorTemp,
        'brightness': brightness
      }
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: masterId,
        method: 'lightControlNew',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'power': onOff == 1 ? 'on' : 'off'}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'brightness': '$brightness'}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'colorTemperature': '$colorTemp'}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'delay_light_off': '$delayTime'}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'scene_light': mode}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiLampControl',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'curtain_status': onOff == 1 ? "open" : "close"}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        inputData: actions,
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
    var actions = [
      <String, dynamic>{'curtain_position': "$position"}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        inputData: actions,
        extraMap: {'deviceType': deviceType});
  }

  /// ******************
  /// 控制wifi窗帘暂停
  /// [deviceId] 设备Id
  /// [deviceType] 设备类型
  /// *******************
  static Future<HomluxResponseEntity> controlWifiCurtainStop(
      String deviceId, String deviceType) {
    var actions = [
      <String, dynamic>{'curtain_status': "stop"}
    ];
    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        inputData: actions,
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
      required List<Map<String, dynamic>> inputData,
      Map<String, dynamic>? extraMap}) async {
    /// 局域网控制设备
    HomluxResponseEntity lanEntity =
        await lanManager.executeDevice(deviceId, inputData);
    if (lanEntity.isSuccess) {
      return lanEntity;
    }

    /// 云端控制设备
    return HomluxApi.request('/v1/device/down', data: {
      ...extraMap ?? {},
      'topic': topic,
      'deviceId': deviceId,
      'method': method,
      'inputData': inputData
    });
  }

  /// *****************
  /// 控制灯组
  /// ******************
  static Future<HomluxResponseEntity> _controlGroupLight(
      {required String groupId,
      required List<Map<String, dynamic>> action}) async {
    /// 局域网控制灯组
    HomluxResponseEntity lanEntity =
        await lanManager.executeGroup(groupId, action);
    if (lanEntity.isSuccess) {
      return lanEntity;
    }

    /// 云端控制灯组
    return HomluxApi.request('/v1/mzgd/scene/groupControl',
        data: {'groupId': groupId, 'controlAction': action});
  }
}
