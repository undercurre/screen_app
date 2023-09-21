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
  // 灯组状态存储内存存储器
  static Map<String, HomluxGroupEntity> groups = {};

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

    Log.i('homlux 请求设备状态 deviceId=$deviceId forceRequestNetwork=$forceRequestNetwork');

    /// 从本地缓存中，还原设备状态
    if(!devices.containsKey(deviceId)) {
      String? devJson = await LocalStorage.getItem('homlux_lan_device_save_$deviceId');
      if(devJson != null) {
        HomluxDeviceEntity entity = HomluxDeviceEntity.fromJson(jsonDecode(devJson));
        devices[deviceId] = entity;
      }
    }

    if (!forceRequestNetwork && devices[deviceId] != null && lanManager.deviceMap.containsKey(deviceId)) {
      HomluxResponseEntity responseEntity = await lanManager.getDeviceStatus(deviceId);
      if(responseEntity.isSuccess) {
        HomluxDeviceEntity curEntity = devices[deviceId]!;
        /// [{
        //             "modelName": "wallSwicth2",
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
        }
        curEntity.mzgdPropertyDTOList = HomluxDeviceMzgdPropertyDTOList.fromJson(newStatus);
        LocalStorage.setItem('homlux_lan_device_save_$deviceId', jsonEncode(curEntity.toJson()));
        HomluxResponseEntity<HomluxDeviceEntity> response = HomluxResponseEntity()..code = 0..msg = '请求成功'..result = curEntity;
        Log.file('局域网 设备状态返回 ${response.toJson()}');
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

    Log.file('云端 设备状态返回 ${entity.toJson()}');
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
      {CancelToken? cancelToken}) async {

    var res = await HomluxApi.request<HomluxGroupEntity>(
        '/v1/mzgd/scene/queryGroupByGroupId',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'groupId': groupId});

    if(res.success && res.data != null) {
      groups['groupId'] = res.data!;
      LocalStorage.setItem('homlux_lan_group_save_$groupId', jsonEncode(res.data!.toJson()));
    }

    return res;
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
        'deviceProperty':{
          'power': onOff
        }
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
        'deviceProperty':{
          'power': onOff
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
        'deviceProperty':{
          'DelayClose': delayTime
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
        'deviceProperty':{
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
        'deviceProperty':{
          'colorTemperature': colorTemp
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
        'deviceProperty':{
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
        extraMap: {'deviceType': deviceType}
    );

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
      <String, dynamic>{'power': onOff == 1 ? 'on' : 'off'}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty':{
          'power': onOff == 1 ? 'on' : 'off'
        }
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
      <String, dynamic>{'brightness': '$brightness'}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty':{
          'brightness': '$brightness'
        }
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
      <String, dynamic>{'colorTemperature': '$colorTemp'}
    ];

    /// 局域网 设备执行的action
    var lanActions = [
      <String, dynamic>{
        'modelName': 'light',
        'deviceProperty':{
          'colorTemperature': '$colorTemp'
        }
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
        'deviceProperty':{
          'delay_light_off': '$delayTime'
        }
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
        'deviceProperty':{
          'scene_light': mode
        }
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
        'deviceProperty':{
          'curtain_status': onOff == 1 ? "open" : "close"
        }
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
        'deviceProperty': {
          'curtain_status': "stop"
        }
      }
    ];

    return _controlDevice(
        topic: '/subdevice/control',
        deviceId: deviceId,
        method: 'wifiCurtainControl',
        cloudInputData: cloudActions,
        lanInputData: lanActions,
        lanDeviceId: deviceId,
        extraMap: {'deviceType': deviceType}
    );
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
        'deviceProperty': {
          'curtain_status': "stop"
        }
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
    HomluxResponseEntity lanEntity = await lanManager.executeDevice(lanDeviceId, lanInputData);
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

    if(!groups.containsKey(groupId)) {
      var json = await LocalStorage.getItem('homlux_lan_group_save_$groupId');
      if(StrUtils.isNotNullAndEmpty(json)) {
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

}
