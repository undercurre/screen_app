import 'dart:convert';

import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/homlux/api/homlux_lan_device_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/index.dart';

import '../../../widgets/event_bus.dart';
import '../../logcat_helper.dart';
import '../api/homlux_device_api.dart';
import '../models/homlux_device_entity.dart';
import '../models/homlux_response_entity.dart';
import '../push/event/homlux_push_event.dart';
import '../push/homlu_push_manager.dart';
import '../push/homlux_push_message_model.dart';

//  print(equal(['1','2','2'], ['1','2','3']));
//   print(equal(['1','3','2'], ['1','2','3']));
//   print(equal(['1','3','2'], ['1','2']));
//   print(equal({
//     '1': ['1','2','3'],
//     '2':123,
//     '3':{
//       '1': 1,
//       '2': 2,
//       '3':['1','2','3'],
//       '4': {
//         '1': 1,
//         '2': 2,
//         '3':['1','2','2']
//       }
//     }
//   }, {
//     '1': ['1','2','3'],
//     '2': 123,
//     '3':{
//       '1': 1,
//       '2': 2,
//       '3':['1','3','2'],
//       '4': {
//         '1': 1,
//         '2': 2,
//         '3':['1','2','3']
//       }
//     }
//   }));
bool _equal(dynamic value1, dynamic value2, [int deep = 9223372036854775807]) {

  if(value1 is Map && value2 is Map) {
    if(deep == 0) {
      return true;
    }
    if(value1.keys.length != value2.keys.length) {
      return false;
    }
    bool equals = true;
    value1.forEach((key, elementValue) {
      equals &= _equal(elementValue, value2[key], deep - 1);
    });
    return equals;
  } else if(value1 is List && value2 is List) {
    if(deep == 0) {
      return true;
    }
    bool result = true;
    for(var item1 in value1) {
      bool equals = false;
      for(var item2 in value2) {
        equals |= _equal(item1, item2, deep - 1);
      }
      result &= equals;
    }
    if(!result) return false;

    result = true;
    for(var item1 in value2) {
      bool equals = false;
      for(var item2 in value1) {
        equals |= _equal(item1, item2, deep - 1);
      }
      result &= equals;
    }
    return result;
  } else {
    return value1 == value2;
  }

}
// value2 contain in value1
// 数值2 被 数值1 包含
bool _mapContain(Map<String, dynamic> value1, Map<String, dynamic> value2) {
  bool equals = true;
  value2.forEach((key, elementValue) {
    equals &= _equal(elementValue, value1[key]);
  });
  return equals;
}
// 将collection2 融合到 collection1 上
Map<dynamic, dynamic> _mapDeepMerge(Map<dynamic, dynamic> collection1, Map<dynamic, dynamic> collection2) {
  collection2.forEach((key2, value2) {
    if(collection1.containsKey(key2)) {
      var value1 = collection1[key2];
      if(value2 is Map && value1 is Map) {
        collection1[key2] = _mapDeepMerge(value1, value2);
      } else {
        collection1[key2] = value2;
      }
    } else {
      collection1[key2] = value2;
    }
  });
  return collection1;
}

/// 请求成功
HomluxResponseEntity _successResponseEntity = HomluxResponseEntity()
  ..code = 0
  ..msg = '请求成功';

/// 请求失败
HomluxResponseEntity _errorResponseEntity = HomluxResponseEntity()
  ..code = -1
  ..msg = '请求失败';

/// 1.初始化
/// 2.登录与登出
/// 3.增加是否连接Host成功的标识
///
class HomluxLanControlDeviceManager {
  static final HomluxLanControlDeviceManager _instant =
      HomluxLanControlDeviceManager._();

  HomluxLanControlDeviceManager._();

  static HomluxLanControlDeviceManager getInstant() {
    return _instant;
  }

  String? key;

  /// 是否成功订阅
  bool sucSubscribe = false;

  /// 用于存储本地设备
  /// key为设备ID
  /// value为设备局域网列表
  /// value中新增'status'字段，用于保存设备状态信息[Map<String, dynamic>]
  /// value中新增 ‘status_version’字段用于标识设备状态信息的版本[int]
  Map<String, Map<String, dynamic>> deviceMap = {};

  /// 用于存储本地场景
  /// key为场景ID
  /// value为场景信息
  /// {
  //               "sceneId":"1",
  //               "sceneName":"场景1",
  //               "sceneType":1 //0：自动化场景 1：手动场景 2：定时场景
  //  }
  Map<String, Map<String, dynamic>> sceneMap = {};

  /// 用于存储本地灯组
  /// key为灯组ID
  /// value为灯组信息
  Map<String, Map<String, dynamic>> groupMap = {};

  void _handleMqttMsg(String topic, String msg) {
    try {
      var curHouseId = HomluxGlobal.homluxHomeInfo!.houseId;

      var json = jsonDecode(msg);
      var reqId = json['reqId'] as String?;
      var ts = json['ts'] as String?;
      var topic = json['topic'] as String?;
      var data = json['data'];

      /// 设备列表
      if('/local/getDeviceInfo/ack' == topic) {
        var houseId = data['houseId'] as String;
        var deviceList = data['deviceList'] as List<Map<String, dynamic>>;
        if(houseId == curHouseId) {
          deviceMap.clear();
          for (var device in deviceList) {
            var devId = device['devId'] as String;
            deviceMap[devId] = device;
          }
          /// 获取全设备列表状态
          lanDeviceControlChannel.getDeviceStatus(null);
        }
      }

      /// 子设备删除通知
      if('/local/subdevice/del/report' == topic) {
        var deviceList = data['deviceList'] as List<Map<String, dynamic>>;
        for (var device in deviceList) {
          var devId = device['devId'] as String;
          if(deviceMap.containsKey(devId)) {
            deviceMap.remove(devId);
          }
        }
      }

      /// 子设备增加
      if('/local/subdevice/add/report' == topic) {
        var houseId = data['houseId'] as String;
        var deviceList = data['deviceList'] as List<Map<String, dynamic>>;
        for (var device in deviceList) {
          deviceMap[device['devId'] as String] = device;
        }
      }
      /// 设备状态信息
      if('/local/getDeviceStatus' == topic) {
        var houseId = data['houseId'] as String;
        var deviceStatusInfoList = data['deviceStatusInfoList'] as List<Map<String, dynamic>>;
        if(houseId == curHouseId) {
          for (var status in deviceStatusInfoList) {
            var devId = status['devId'];
            bool contained = deviceMap.containsKey(devId);
            bool containedStatus = deviceMap.containsKey('status');
            if(contained) {
              // if(containedStatus) {
              //   Map<String, dynamic> oldStatus = deviceMap['devId']!['status'];
              //   int version = deviceMap['devId']!['statusVersion'];
              //   bool equalResult = _equal(oldStatus, status);
              //   if(equalResult) continue;
              //   deviceMap['devId']!['status'] = status;
              //   deviceMap['devId']!['statusVersion'] = version++;
              // } else {
              //   deviceMap['devId']!['status'] = status;
              //   deviceMap['devId']!['statusVersion'] = 1;
              // }

              if(containedStatus) {
                int version = deviceMap['devId']!['statusVersion'];
                deviceMap['devId']!['status'] = status;
                deviceMap['devId']!['statusVersion'] = version++;
              } else {
                deviceMap['devId']!['status'] = status;
                deviceMap['devId']!['statusVersion'] = 1;
              }
            }
          }
        }
      }

      /// 设备状态更新
      if('/local/deviceStatusUpdate/report' == topic) {
        var houseId = data['houseId'] as String;
        var deviceStatusInfoList = data['deviceStatusInfoList'] as List<Map<String, dynamic>>;
        bool needQueryDeviceList = false;
        for (var status in deviceStatusInfoList) {
          var devId = status['devId'] as String;
          if(deviceMap.containsKey(devId)) {
            if(deviceMap['devId']!.containsKey('status')) {
              var curStatus = deviceMap[devId]!['status'] as Map<String, dynamic>;
              var curVersion = deviceMap[devId]!['statusVersion'] as int;
              deviceMap[devId]!['status'] = _mapDeepMerge(curStatus, status);
              deviceMap[devId]!['statusVersion'] = curVersion;

              HomluxDeviceEntity? entity = HomluxDeviceApi.devices[devId];
              if(entity != null) {
                HomluxPushResultEntity pushResult = HomluxPushResultEntity();
                HomluxEventDataEntity eventData = HomluxEventDataEntity();
                eventData.modelName = status['modelName'];
                eventData.deviceId = status['devId'];
                eventData.event = status['deviceProperty'];
                pushResult.eventType = TypeDeviceProperty;
                pushResult.eventData = eventData;
                bus.typeEmit(HomluxDevicePropertyChangeEvent.of(pushResult));
                Log.file('homlux 局域网 设备$devId状态发生变化 ${status['deviceProperty']}');
              }
            } else {
              lanDeviceControlChannel.getDeviceStatus(devId);
            }
          } else {
            needQueryDeviceList = true;
          }
        }
        if(needQueryDeviceList) {
          lanDeviceControlChannel.getDeviceInfo();
        }
      }

      /// 场景列表
      if('/local/getSceneInfo/ack' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<Map<String, dynamic>>;
        if(houseId == curHouseId) {
          sceneMap.clear();
          for (var scene in scenes) {
            var sceneId = scene['sceneId'] as String;
            sceneMap[sceneId] = scene;
          }
        }
      }
      
      /// 场景删除
      if('/local/scene/del/report' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<Map<String, dynamic>>;
        if(houseId == curHouseId) {
          var sceneIds = scenes.map((e) => e['sceneId'] as String).toList();
          sceneMap.removeWhere((key, value) => sceneIds.contains(key));
        }
      }

      /// 场景新增
      if('/local/scene/add/report' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<Map<String, dynamic>>;
        if(houseId == curHouseId) {
          for (var scene in scenes) {
            var sceneId = scene['sceneId'] as String;
            sceneMap[sceneId] = scene;
          }
        }
      }

      /// 灯组列表
      if('/local/getGroupInfo/ack' == topic) {
        var houseId = data['houseId'] as String;
        var groupList = data['groupList'] as List<Map<String, dynamic>>;
        if(houseId == curHouseId) {
          groupMap.clear();
          for (var group in groupList) {
            var groupId = group['webGroupId'] as String;
            groupMap[groupId] = group;
          }
        }
      }

      /// 灯组删除
      if('/local/group/del/report' == topic) {
        var houseId = data['houseId'] as String;
        var groupList = data['groupList'] as List<Map<String, dynamic>>;
        bool needRefreshGroupList = false;
        for(var group in groupList) {
          String groupId = group['webGroupId'] as String;
          List<String> devIds = group['devIds'] as List<String>;
          if(groupMap.containsKey(groupId)) {
            (groupMap[groupId]![devIds] as List<String>).removeWhere((element) =>
                devIds.contains(element));
            if((groupMap[groupId]![devIds] as List<String>).isEmpty) {
              groupMap.remove(groupId);
            }
          } else {
            needRefreshGroupList = true;
          }
        }
        if(needRefreshGroupList) {
          lanDeviceControlChannel.getGroupInfo();
        }
      }

      /// 灯组增加
      if('/local/group/add/report' == topic) {
        var houseId = data['houseId'] as String;
        var groupList = data['groupList'] as List<Map<String, dynamic>>;
        for(var group in groupList) {
          String groupId = group['webGroupId'] as String;
          List<String> devIds = group['devIds'] as List<String>;
          if(groupMap.containsKey(groupId)) {
            Set<String> idsSet = (groupMap[groupId]!['devIds'] as List<String>).toSet();
            idsSet.addAll(devIds);
            groupMap[groupId]!['devIds'] = idsSet.toList();
          } else {
            groupMap[groupId] = group;
          }
        }
      }

    } catch (e, stack) {
      Log.file('解析错误', e, stack);
    }
  }

  void init() {
    lanDeviceControlChannel.init();
  }

  void logout() {
    lanDeviceControlChannel.logout();
    sucSubscribe = false;
    lanDeviceControlChannel.logCallback = null;
    lanDeviceControlChannel.mqttCallback = null;
    deviceMap.clear();
    sceneMap.clear();
    groupMap.clear();
    HomluxDeviceApi.devices.clear();
  }

  void login() async {
    String? houseId = HomluxGlobal.homluxHomeInfo?.houseId;
    if (houseId == null) {
      Log.e('houseId 为空，请确保已经登录');
      sucSubscribe = false;
      return;
    }
    String? _key = (await HomluxLanDeviceApi.queryLocalKey(houseId)).result;
    if (_key == null) {
      Log.e('请求到的key为空');
      sucSubscribe = false;
      return;
    }
    if (_key != key) {
      key = _key;
      lanDeviceControlChannel.login(houseId, key!);
      sucSubscribe = true;
    }

    lanDeviceControlChannel.logCallback = (args) {
      if (args == 'aesKeyMayBeExpire') {
        /// key过期
        if (System.inHomluxPlatform() && System.isLogin()) {
          login();
        }
      }
    };
    lanDeviceControlChannel.mqttCallback = (topic, msg) {
      if (sucSubscribe && System.inHomluxPlatform() && System.isLogin()) {
        _handleMqttMsg(topic, msg);
      }
    };

    lanDeviceControlChannel.getDeviceInfo();
    lanDeviceControlChannel.getSceneInfo();
    lanDeviceControlChannel.getGroupInfo();
  }

  Future<HomluxResponseEntity> executeDevice(
      String deviceID, List<Map<String, dynamic>> actions) async {
    if (sucSubscribe) {
      if (deviceMap.containsKey(deviceID)) {
        for (var action in actions) {
          lanDeviceControlChannel.deviceControl(deviceID, action);
        }
        Log.file('homlux 局域网控制 设备 \n ${deviceMap[deviceID]}');
        return _successResponseEntity;
      }
    } else {
      Log.file('homlux 局域网控制 设备 \n 异常 连接还未订阅成功');
    }
    return _errorResponseEntity;
  }

  Future<HomluxResponseEntity> executeScene(String sceneID) async {
    if (sucSubscribe) {
      if (sceneMap.containsKey(sceneID)) {
        lanDeviceControlChannel.sceneExcute(sceneID);
        Log.file('homlux 局域网控制 场景 \n ${sceneMap[sceneID]}');
        return _successResponseEntity;
      }
    } else {
      Log.file('homlux 局域网控制 场景 \n 异常 连接还未订阅成功');
    }
    return _errorResponseEntity;
  }

  Future<HomluxResponseEntity> executeGroup(
      String groupID, List<Map<String, dynamic>> actions) async {
    if (sucSubscribe) {
      if (groupMap.containsKey(groupID)) {
        for (var action in actions) {
          lanDeviceControlChannel.groupControl(int.parse(groupID), action);
        }
        Log.file('homlux 局域网控制 灯组 \n ${groupMap[groupID]}');
        return _successResponseEntity;
      }
    } else {
      Log.file('homlux 局域网控制 灯组 \n 异常 连接还未订阅成功');
    }
    return _errorResponseEntity;
  }

  void getDeviceStatus(String devId) {
    lanDeviceControlChannel.getDeviceStatus(devId);
  }

}
