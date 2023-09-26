import 'dart:convert';
import 'dart:core';

import 'package:screen_app/common/homlux/lan/homlux_lan_control_device_manager.dart';
import 'package:screen_app/common/index.dart';

import '../../logcat_helper.dart';
import '../homlux_global.dart';
import '../models/homlux_panel_associate_scene_entity.dart';
import '../models/homlux_scene_entity.dart';
import '../models/homlux_response_entity.dart';
import 'homlux_api.dart';

class HomluxSceneApi {
  /// 局域网控制器
  static HomluxLanControlDeviceManager manager = HomluxLanControlDeviceManager.getInstant();

  // 场景存储内存存储器
  static Map<String, HomluxSceneEntity> _scenes = {};
  // 场景列表
  static HomluxResponseEntity<List<HomluxSceneEntity>>? _cacheSceneList;
  // 面板关联的产经
  static Map<String, HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>>> _pannelScene = {};
  /// 清除内存缓存
  static void clearMemoryCache() {
    Log.file('清除数据');
    _scenes.clear();
    _cacheSceneList = null;
    _pannelScene.clear();
  }

  /// 查询家庭下的场景
  static Future<HomluxResponseEntity<List<HomluxSceneEntity>>>
      getSceneList() async {

    /// 缓存数据
    Future<HomluxResponseEntity<List<HomluxSceneEntity>>> getCacheData() async {

      if(_cacheSceneList != null) {
        return _cacheSceneList!;
      } else {
        var jsonStr = await LocalStorage.getItem('homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}');
        if(StrUtils.isNotNullAndEmpty(jsonStr)) {
          var entity = HomluxResponseEntity<List<HomluxSceneEntity>>.fromJson(jsonDecode(jsonStr!));
          _cacheSceneList = entity;
          _scenes.clear();
          var scenes = entity.result;
          if(scenes?.isNotEmpty ?? false) {
            for (var value in scenes!) {
              if (value.sceneId != null) {
                _scenes[value.sceneId!] = value;
              }
            }
          }
          return entity;
        }
      }

      return HomluxResponseEntity<List<HomluxSceneEntity>>()
        ..code = -1
        ..msg = '请求失败'
        ..success = false;

    }

    /// 保存本地缓存
    void saveCache(HomluxResponseEntity<List<HomluxSceneEntity>>? res, [bool clear = false]) {
      if(clear) {
        // 清空缓存
        _scenes.clear();
        LocalStorage.removeItem('homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}');
        _cacheSceneList = null;
      } else if(res != null) {
        _cacheSceneList = res;
        _scenes.clear();
        if(res.result?.isNotEmpty ?? false) {
          var scenes = res.result!;
          for (var value in scenes) {
            if (value.sceneId != null) {
              _scenes[value.sceneId!] = value;
            }
          }
        }
        LocalStorage.setItem('homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}', jsonEncode(res.toJson()));
      }
    }

    try {
      var res = await HomluxApi.request<List<HomluxSceneEntity>>(
          '/v1/mzgd/scene/querySceneListByHouseId',
          data: {"houseId": HomluxGlobal.homluxHomeInfo?.houseId});

      if (res.isSuccess) {

        if((res.data?.isNotEmpty ?? false)) {
          /// 移除无效场景
          List<HomluxSceneEntity> scenes = res.data!;
          scenes.removeWhere((element) =>
          element.deviceActions?.isEmpty ?? true);

          /// 场景缓存到本地
          saveCache(res, !scenes.isNotEmpty);
        }

        return res;
      }
    } catch (e) {
      Log.e("网络请求场景失败", e);
    }

    return getCacheData();
  }

  /// 场景控制
  static Future<HomluxResponseEntity> execScene(String sceneId) async {
    /// 恢复缓存设置
    if (_scenes.isEmpty) {
      String? json = await LocalStorage.getItem(
          'homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}');
      if (StrUtils.isNotNullAndEmpty(json)) {
        HomluxResponseEntity<List<HomluxSceneEntity>> entity =
            HomluxResponseEntity<List<HomluxSceneEntity>>.fromJson(
                jsonDecode(json!));
        entity.data?.forEach((element) {
          if (element.sceneId != null) {
            _scenes[element.sceneId!] = element;
          }
        });
      }
    }

    var updateStamp = _scenes[sceneId]?.updateStamp ?? 0;

    /// 局域网控制
    HomluxResponseEntity lanEntity =
        await manager.executeScene(sceneId, updateStamp);
    if (lanEntity.isSuccess) {
      return lanEntity;
    }

    /// 网络控制
    var res = await HomluxApi.request('/v1/mzgd/scene/sceneControl',
        data: {"sceneId": sceneId});
    if (res.code == 0) {
      Log.i('lmn>>>控制场景id=$sceneId成功');
    } else {
      Log.i('lmn>>>控制场景id=$sceneId失败');
    }
    return res;
  }

  /// 查询面关联的场景
  static Future<HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>>>
      querySceneListByPanel(String deviceId) async {

    /// 本地缓存数据
    Future<HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>>> getCacheData() async {
      if(_pannelScene.containsKey(deviceId)) {
        return _pannelScene[deviceId]!;
      } else {
        var jsonStr = await LocalStorage.getItem('homlux_query_scene_list_panel_$deviceId');
        if(StrUtils.isNotNullAndEmpty(jsonStr)) {
          var entity = HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>>.fromJson(jsonDecode(jsonStr!));
          _pannelScene[deviceId] = entity;
          return entity;
        }
      }

      return HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>>()
        ..code = -1
        ..msg = '请求失败'
        ..success = false;
    }

    /// 保存本地缓存数据
    void saveCache(HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>> res, [bool clear = false]) {
      if(clear) {
        _pannelScene.remove(deviceId);
        LocalStorage.removeItem('homlux_query_scene_list_panel_$deviceId');
      } else {
        _pannelScene[deviceId] = res;
        LocalStorage.setItem('homlux_query_scene_list_panel_$deviceId', jsonEncode(res.toJson()));
      }
    }

    try {
      var res = await HomluxApi.request<List<HomluxPanelAssociateSceneEntity>>(
          '/v1/mzgd/scene/querySceneListByPanel',
          data: {"deviceId": deviceId});

      if(res.isSuccess) {
        saveCache(res);
        return res;
      }

    } catch(e) {
      Log.i('查询面板关联的场景失败');
    }

    return getCacheData();

  }
}
