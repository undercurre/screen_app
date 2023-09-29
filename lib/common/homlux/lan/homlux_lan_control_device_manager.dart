import 'dart:async';
import 'dart:convert';

import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/homlux/api/homlux_lan_device_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/homlux/lan/hang_up.dart';
import 'package:screen_app/common/homlux/lan/utils.dart';
import 'package:screen_app/common/index.dart';
import 'package:uuid/uuid.dart';

import '../../../channel/models/net_state.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/util/net_utils.dart';
import '../../logcat_helper.dart';
import '../api/homlux_device_api.dart';
import '../models/homlux_device_entity.dart';
import '../models/homlux_response_entity.dart';
import '../push/event/homlux_push_event.dart';
import '../push/homlu_push_manager.dart';
import '../push/homlux_push_message_model.dart';



/// 请求成功
final _successResponseEntity = HomluxResponseEntity()
  ..code = 0
  ..msg = '请求成功';

/// 请求失败
final _errorResponseEntity = HomluxResponseEntity()
  ..code = -1
  ..msg = '请求失败';

class HomluxLanControlDeviceManager {
  static final HomluxLanControlDeviceManager _instant = HomluxLanControlDeviceManager._();

  HomluxLanControlDeviceManager._();

  static HomluxLanControlDeviceManager getInstant() {
    return _instant;
  }

  final enable = true;

  final uuid = const Uuid();

  String? key;

  /// 是否成功订阅
  bool sucSubscribe = false;
  /// 是否连接
  bool connectOk = false;

  /// 初始化加锁
  Completer<void>? _lock;

  /// 用于存储本地设备
  /// key为设备ID
  /// value为设备局域网列表
  /// value中新增'status'字段，用于保存设备状态信息[Map<String, dynamic>]
  /// {
  ///               "roomId":"1",
  ///               "gatewayId":"11111",
  ///               "devId":"33333",
  ///               "deviceName":"测试设备1"
  ///               "status":[{
  ///                             "gatewayId": "1",
  ///                             "productId": "model.light.001.002",
  ///                             "devId": "123123",
  ///                             "modelName": "wallSwicth",
  ///                             "online": 1,
  ///                             "deviceProperty": {
  ///                                 "aaa": "2",
  ///                                 "bbb": "4"
  ///                             }
  ///                         }, {
  ///                             "deviceProperty": {
  ///                                 "ccc": "7",
  ///                                 "ddd": "5"
  ///                             },
  ///                             "online": 1,
  ///                             "modelName": "wallSwicth2",
  ///                             "devId": "3333",
  ///                             "gatewayId": "1",
  ///                             "productId": "model.light.001.003",
  ///                         }]
  ///  }
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


  bool isEnable() {
    return sucSubscribe && connectOk;
  }

  void _handleMqttMsg(String mTopic, String msg) {

    try {
      var curHouseId = HomluxGlobal.homluxHomeInfo!.houseId;

      var json = jsonDecode(msg);
      var reqId = json['reqId'] as String?;
      var ts = json['ts'] as String?;
      var topic = json['topic'] as String?;
      var data = json['data'];

      /// host被解绑
      if('/local/host/leave' == topic) {
        logout();
        Future.delayed(const Duration(seconds: 3), () {
          login();
        });
      }

      /// host通知control重新获取数据
      if('/local/synchronize' == topic) {
        Log.file('[homeos] getDeviceInfo()');
        lanDeviceControlChannel.getDeviceInfo(uuid.v4());
        Log.file('[homeos] getSceneInfo()');
        lanDeviceControlChannel.getSceneInfo(uuid.v4());
        Log.file('[homeos] getGroupInfo()');
        lanDeviceControlChannel.getGroupInfo(uuid.v4());

        Future.delayed(const Duration(seconds: 2), () {
          bus.typeEmit(HomluxLanDeviceChange(), 500);
        });
      }

      /// 设备列表
      if ('/local/getDeviceInfo/ack' == topic) {
        var houseId = data['houseId'] as String;
        var deviceList = data['deviceList'] as List<dynamic>;
        if (houseId == curHouseId) {
          deviceMap.clear();
          for (var device in deviceList) {
            var devId = device['devId'] as String;
            deviceMap[devId] = device;
          }
        }
        if(deviceMap.values.isNotEmpty) {
          Log.i('homlux 局域网 设备列表数据处理成功 第一个数据为 ${deviceMap.values.first}');
        } else {
          Log.i('homlux 局域网 设备列表数据处理成功 数据为空');
        }

        /// 获取设备列表中的设备状态
        lanDeviceControlChannel.getDeviceStatus(uuid.v4(), null);

        Future.delayed(const Duration(seconds: 2), () {
          bus.typeEmit(HomluxLanDeviceChange(), 500);
        });
      }

      /// 子设备删除通知
      if ('/local/subdevice/del/report' == topic) {
        var deviceList = data['deviceList'] as List<dynamic>;
        for (var device in deviceList) {
          var devId = device['devId'] as String;
          if (deviceMap.containsKey(devId)) {
            deviceMap.remove(devId);
          }
        }
      }

      /// 子设备增加
      if ('/local/subdevice/add/report' == topic) {
        var houseId = data['houseId'] as String;
        var deviceList = data['deviceList'] as List<dynamic>;
        for (var device in deviceList) {
          deviceMap[device['devId'] as String] = device;
        }
      }

      /// 设备状态信息
      if ('/local/getDeviceStatus/ack' == topic) {

        var houseId = data['houseId'] as String;
        var deviceStatusInfoList =
            data['deviceStatusInfoList'] as List<dynamic>;
        if (houseId == curHouseId) {

          for (var statu in deviceStatusInfoList) {
            var devId = statu['devId'];
            if (deviceMap.containsKey(devId)) {
              var device = deviceMap[devId] as Map<String, dynamic>;
              var status = device['status'] as List<Map<String, dynamic>>? ?? <Map<String, dynamic>>[];
              if (status.isEmpty) {
                status.add(statu);
              } else {
                status.removeWhere((element) => element['modelName'] == statu['modelName']);
                status.add(statu);
              }
              device['status'] = status;
            }
          }

          var hangUpTask = findTask(reqId!);
          if(hangUpTask != null) {
            var status = deviceMap[hangUpTask.handle.data as String]?['status'];
            if(status == null) {
              hangUpTask.handle.suc(_errorResponseEntity);
            } else {
              HomluxResponseEntity entity = HomluxResponseEntity();
              entity.code = 0;
              entity.msg = '请求成功';
              entity.result = status;
              hangUpTask.handle.suc(entity);
            }
          }
        }
      }

      /// 设备状态更新
      if ('/local/subDeviceStatus' == topic) {
        var houseId = data['houseId'] as String;
        if(houseId == curHouseId) {
          var deviceStatusInfoList =
          data['deviceStatusInfoList'] as List<dynamic>;
          bool needQueryDeviceList = false;
          for (var rStatu in deviceStatusInfoList) {
            var devId = rStatu['devId'] as String;

            if (deviceMap.containsKey(devId)) {
              if (deviceMap[devId]!.containsKey('status')) {
                var curStatus = deviceMap[devId]!['status'] as List<dynamic>;

                for (var i = 0; i < curStatus.length; i++) {
                  var cStatu = curStatus[i];
                  if(cStatu['modelName'] == rStatu['modelName']) {
                    curStatus[i] = LanUtils.mapDeepMerge(cStatu, rStatu) as Map<String, dynamic>;
                  }
                }

                deviceMap[devId]!['status'] = curStatus;
                Log.i('本地设备数量 ${HomluxDeviceApi.devices.values.length}');
                HomluxDeviceEntity? entity = HomluxDeviceApi.devices[devId];
                if (entity != null) {
                  HomluxPushResultEntity pushResult = HomluxPushResultEntity();
                  HomluxEventDataEntity eventData = HomluxEventDataEntity();
                  eventData.modelName = rStatu['modelName'];
                  eventData.deviceId = rStatu['devId'];
                  eventData.event = rStatu['deviceProperty'];
                  pushResult.eventType = TypeDeviceProperty;
                  pushResult.eventData = eventData;
                  HomluxPushManager.deviceStatusChange(rStatu['devId'], pushResult);
                  Log.file('homlux 局域网 设备$devId状态发生变化 ${rStatu['deviceProperty']}');
                }

              } else {
                lanDeviceControlChannel.getDeviceStatus(uuid.v4(), devId);
              }
            } else {
              needQueryDeviceList = true;
            }
          }

          if (needQueryDeviceList) {
            lanDeviceControlChannel.getDeviceInfo(uuid.v4());
          }

        }

      }

      /// 场景列表
      /// {
      //     "data":{
      //         "houseId":"5beb2c644c854a18a1cd87664e4b4d35",
      //         "sceneList":[
      //             {
      //                 "sceneId":"df3d96cd0b25450c962a3a0c199ffa57",
      //                 "sceneName":"全开",
      //                 "sceneType":1
      //             }
      //         ]
      //     }
      // }
      if ('/local/getSceneInfo/ack' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<dynamic>;
        if (houseId == curHouseId) {
          sceneMap.clear();
          for (var scene in scenes) {
            var sceneId = scene['sceneId'] as String;
            sceneMap[sceneId] = scene;
          }
          if(sceneMap.values.isNotEmpty) {
            Log.i('[homeos] 场景列表数据处理成功 第一个数据为 ${sceneMap.values.first}');
          } else {
            Log.i('[homeos] 场景列表数据处理成功 数据为空');
          }
        }
      }

      /// 场景删除
      /// {
      //     "data":{
      //         "houseId":"5beb2c644c854a18a1cd87664e4b4d35",
      //         "sceneList":[
      //             {
      //                 "sceneId":"893dca7961804487ac96606bd1b72b55"
      //             }
      //         ]
      //     },
      //     "topic":"/local/scene/del/report",
      //     "reqId":"b9c69f9ef34648fc80e58ef1b6b1fec0",
      //     "ts":"1693376544074"
      // }
      if ('/local/scene/del/report' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<dynamic>;
        if (houseId == curHouseId) {
          var sceneIds = scenes.map((e) => e['sceneId'] as String).toList();
          sceneMap.removeWhere((key, value) => sceneIds.contains(key));
        }
      }

      /// 场景新增
      /// {
      //     "data":{
      //         "houseId":"5beb2c644c854a18a1cd87664e4b4d35",
      //         "sceneList":[
      //             {
      //                 "sceneId":"2e4c476b7e634f91a51ba40f99d317fa",
      //                 "sceneName":"止不住",
      //                 "sceneType":3,
      //                 "updateStamp":"1111111111"
      //             }
      //         ]
      //     },
      //     "topic":"/local/scene/add/report",
      //     "reqId":"b9c69f9ef34648fc80e58ef1b6b1fec0",
      //     "ts":"1693383181289"
      // }
      if ('/local/scene/add/report' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<dynamic>;
        if (houseId == curHouseId) {
          for (var scene in scenes) {
            var sceneId = scene['sceneId'] as String;
            sceneMap[sceneId] = scene;
          }
        }
      }

      /// 场景时间搓发生变化
      /// "data":{
      //         "houseId":"111111",
      //         "sceneList":[
      //            {
      //               "sceneId":"1",
      //               "updateStamp":"1111111111"    hjl更新2023/9/11
      //
      //            },
      //            {
      //               "sceneId":"2",
      //               "updateStamp":"1111111111"    hjl更新2023/9/11
      //            }
      //         ]
      //     }
      if('/local/scene/update/stamp' == topic) {
        var houseId = data['houseId'] as String;
        var scenes = data['sceneList'] as List<dynamic>;
        if(houseId == curHouseId) {
          for(var scene in scenes) {
            var sceneId = scene['sceneId'] as String;
            sceneMap[sceneId] = scene;
          }
        }
      }
      /// 场景执行
      /// {
      //     "data":{
      //         "sceneId":"df3d96cd0b25450c962a3a0c199ffa57",
      //         "errorCode":"success"
      //     },
      //     "topic":"/local/sceneExcute/ack",
      //     "reqId":"a2d6787d325941e8bee20ca10264da4a",
      //     "ts":"1693377362930"
      // }
      if ('/local/sceneExcute/ack' == topic) {
        var task = findTask(reqId!);
        task?.handle.suc(_successResponseEntity);
      }

      /// 灯组列表
      /// {
      //     "reqId":"随机数",
      //     "ts":"时间戳",
      //     "topic":"/local/getGroupInfo/ack",
      //     "data":{
      //         "houseId":"111111",
      //         "groupList":[
      //            {
      //               "webGroupId":"11111",
      //                "updateStamp":"1111111111"
      //            },
      //            {
      //               "webGroupId":"11111",
      //               "groupStatus":2
      //            }
      //         ]
      //     }
      // }
      if ('/local/getGroupInfo/ack' == topic) {
        var houseId = data['houseId'] as String;
        var groupList = data['groupList'] as List<dynamic>;
        if (houseId == curHouseId) {
          groupMap.clear();
          for (var group in groupList) {
            var groupId = group['webGroupId'] as String;
            groupMap[groupId] = group;
          }
          Log.i('局域网 灯组列表数据处理成功 第一个数据为 ${groupMap.values.first}');
        }
      }

      /// 灯组状态更新
      if('/local/group/update/stamp' == topic) {
        var houseId = data['houseId'] as String;
        if(houseId == curHouseId) {
          var groupList = data['groupList'] as List<dynamic>;
          for(var group in groupList) {
            var groupId = group['webGroupId'] as String;
            groupMap[groupId] = group;
          }
        }
      }

      /// 灯组删除
      if ('/local/group/del/report' == topic) {
        var groupList = data['groupList'] as List<dynamic>;
        bool needRefreshGroupList = false;
        for (var groupID in groupList) {
          if (groupMap.containsKey(groupID)) {
            groupMap.remove(groupID);
          } else {
            needRefreshGroupList = true;
          }
        }
        if (needRefreshGroupList) {
          lanDeviceControlChannel.getGroupInfo(uuid.v4());
        }
      }

      /// 灯组增加
      if ('/local/group/add/report' == topic) {
        var groupList = data['groupList'] as List<dynamic>;
        bool needRefreshGroupList = false;
        for (var group in groupList) {
          String groupId = group['webGroupId'] as String;
          if (!groupMap.containsKey(groupId)) {
            groupMap[groupId] = group;
          } else {
            needRefreshGroupList = true;
          }
        }
        if (needRefreshGroupList) {
          lanDeviceControlChannel.getGroupInfo(uuid.v4());
        }
      }
    } catch (e, stack) {
      Log.file('解析错误', e, stack);
    }
  }

  void init() {
    Log.file('[homeos] init()');
    lanDeviceControlChannel.init();
  }

  void logout() {
    Log.file('[homeos] logout()');
    NetUtils.unregisterListenerNetState(listenerNetState);
    lanDeviceControlChannel.logout();
    sucSubscribe = false;
    key = null;
    lanDeviceControlChannel.logCallback = null;
    lanDeviceControlChannel.mqttCallback = null;
    deviceMap.clear();
    sceneMap.clear();
    groupMap.clear();
    HomluxDeviceApi.devices.clear();
    bus.off("eventStandbyActive", listenerEventStandbyActive);
  }

  listenerEventStandbyActive(result) {
    if(result) {
      lanDeviceControlChannel.adjustSpeedToLow();
    } else {
      lanDeviceControlChannel.adjustSpeedToNormal();
    }
  }

  listenerNetState(NetState? state) {
    if (System.inHomluxPlatform() &&
        System.isLogin() &&
        (state?.wifiState == 2 || state?.ethernetState == 2)) {
      Log.file('订阅网络已经连接');
      login();
    }
  }

  void login() async {
    if(!enable) return;

    if (_lock != null && !_lock!.isCompleted) {
      _lock!.future.then((value) => login());
      return;
    }
    try {
      if (sucSubscribe) {
        Log.file('已经订阅成功，无须再login');
        return;
      }
      _lock = Completer();
      NetUtils.registerListenerNetState(listenerNetState);
      String? houseId = HomluxGlobal.homluxHomeInfo?.houseId;
      if (houseId == null) {
        Log.e('houseId 为空，请确保已经登录');
        sucSubscribe = false;
        return;
      }

      String? _key;
      try {
         _key = (await HomluxLanDeviceApi.queryLocalKey(houseId)).result;
      } catch(e) {
        Log.file(e);
      }
      if (_key == null) {
        _key = await LocalStorage.getItem('homlux_lan_control_key');
        if(_key == null) {
          Log.e('请求到的key为空');
          sucSubscribe = false;
          return;
        }
      }
      if (_key != key) {
        key = _key;
        LocalStorage.setItem('homlux_lan_control_key', key!);
        Log.file('[homeos] login(houseId=$houseId, key=$key)');
        sucSubscribe = true;
        lanDeviceControlChannel.login(houseId, key!);
        bus.on("eventStandbyActive", listenerEventStandbyActive);
      }
      lanDeviceControlChannel.logCallback = (args) async {
        Log.file('[homeos] log $args');
        if (args == 'aesKeyMayBeExpire') {
          /// key过期
          if (System.inHomluxPlatform() && System.isLogin()) {
            sucSubscribe = false;
            String? _newKey = (await HomluxLanDeviceApi.queryLocalKey(houseId)).result;
            if(_newKey != key) {
              login();
            }
          }
        } else if (args == 'connectOk') {
          connectOk = true;
          Log.file('[homeos] getDeviceInfo()');
          lanDeviceControlChannel.getDeviceInfo(uuid.v4());
          Log.file('[homeos] getSceneInfo()');
          lanDeviceControlChannel.getSceneInfo(uuid.v4());
          Log.file('[homeos] getGroupInfo()');
          lanDeviceControlChannel.getGroupInfo(uuid.v4());
        } else if(args == 'connectLost') {
          connectOk = false;
        }
      };
      lanDeviceControlChannel.mqttCallback = (topic, msg) {
        if (sucSubscribe && System.inHomluxPlatform() && System.isLogin()) {
          Log.file('[homeos] message $msg');
          _handleMqttMsg(topic, msg);
        }
      };
    } finally {
      _lock?.complete();
      _lock = null;
    }
  }

  Future<HomluxResponseEntity> executeDevice(
      String deviceID, List<Map<String, dynamic>> actions) async {
    if (sucSubscribe && connectOk) {
      if (deviceMap.containsKey(deviceID)) {
        Log.file('homlux 局域网控制 设备 \n ${deviceMap[deviceID]}');
        lanDeviceControlChannel.deviceControl(uuid.v4(), deviceID, actions);
        return _successResponseEntity;
      } else {
        Log.file('homlux 局域网控制 本地设备列表不包含此设备 $deviceID');
      }
    } else {
      login();
      Log.file('homlux 局域网控制 设备 \n 异常 连接还未订阅成功');
    }
    return _errorResponseEntity;
  }

  Future<HomluxResponseEntity> executeScene(String sceneID, int updateStamp) async {
    if (sucSubscribe && connectOk) {
      if (sceneMap.containsKey(sceneID)) {
        // 1. 查询本地场景能否控制
        dynamic scene = sceneMap[sceneID];
        if(scene['updateStamp'] == null || int.parse(scene['updateStamp']) < updateStamp) {
          Log.i('homlux 局域网控制 \n 场景 ${scene['updateStamp']} 太小，跳出局域网控制');
          return _errorResponseEntity; // 局域网能控制的设备
        }
        // 2.去执行本地场景
        Log.file('[homeos] sceneExcute(scene = ${sceneMap[sceneID]})');
        final requestId = uuid.v4();
        lanDeviceControlChannel.sceneExcute(requestId, sceneID);
        // 3.等待执行结果并返回
        HomluxResponseEntity entity =  await hangUp(HangUpTask<HomluxResponseEntity>.create(
            id: requestId,
            handle: HangUpHandle(),
            timeoutComputation: () => _errorResponseEntity));
        Log.file('homlux 局域网控制 场景 \n ${sceneMap[sceneID]} ${entity.isSuccess? '控制成功': '控制失败'}');
        return entity;
      }
    } else {
      login();
      Log.file('homlux 局域网控制 场景 \n 异常 订阅：$sucSubscribe 连接：$connectOk');
    }
    return _errorResponseEntity;
  }

  Future<HomluxResponseEntity> executeGroup(
      String groupID, int updateStamp, List<Map<String, dynamic>> actions) async {
    if (sucSubscribe && connectOk) {
      if (groupMap.containsKey(groupID)) {
        // 1. 查询本地灯组能否控制
        dynamic group = groupMap[groupID];
        if(group['updateStamp'] == null || int.parse(group['updateStamp']) < updateStamp) {
          Log.file('homlux 局域网控制 \n 灯组 ${group['updateStamp']} 太小，跳出局域网控制');
          return _errorResponseEntity; // 局域网能控制的设备
        }

        // 2. 控制灯组状态
        for (var action in actions) {
          Log.file('[homeos] groupControl(groupID=$groupID)');
          lanDeviceControlChannel.groupControl(uuid.v4(), groupID, action);
        }

        // 3.返回控制结果
        Log.file('homlux 局域网控制 灯组 \n ${groupMap[groupID]}');
        return _successResponseEntity;
      } else {
        Log.file('homlux 局域网控制 灯组 \n 异常 不存在此设备');
      }
    } else {
      login();
      Log.file('homlux 局域网控制 灯组 \n 异常 订阅：$sucSubscribe 连接：$connectOk');
    }
    return _errorResponseEntity;
  }

  Future<HomluxResponseEntity> getDeviceStatus(String devId) async {
    Log.file('局域网 getDeviceStatus(devId=$devId)');
    if (sucSubscribe && connectOk) {

      // 1.查询设备是否存在本地
      if(!deviceMap.containsKey(devId)) {
        return _errorResponseEntity;
      }

      // 2.去获取状态
      final requestId = uuid.v4();
      lanDeviceControlChannel.getDeviceStatus(requestId, devId);

      // 3.等待执行结果并返回
      HomluxResponseEntity entity =  await hangUp(HangUpTask<HomluxResponseEntity>.create(
          id: requestId,
          handle: HangUpHandle(devId),
          timeoutComputation: () => _errorResponseEntity));
      return entity;

    } else {
      login();
      Log.file('homlux 局域网控制 场景 \n 异常 订阅：$sucSubscribe 连接：$connectOk');
    }
    return _errorResponseEntity;
  }

}
