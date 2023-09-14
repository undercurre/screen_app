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
  static HomluxLanControlDeviceManager manager =
      HomluxLanControlDeviceManager.getInstant();

  // 场景存储内存存储器
  static Map<String, HomluxSceneEntity> _scenes = {};

  /// 查询家庭下的场景
  static Future<HomluxResponseEntity<List<HomluxSceneEntity>>>
      getSceneList() async {
    var res = await HomluxApi.request<List<HomluxSceneEntity>>(
        '/v1/mzgd/scene/querySceneListByHouseId',
        data: {"houseId": HomluxGlobal.homluxHomeInfo?.houseId});

    /// 移除无效场景
    if (res.isSuccess && (res.data?.isNotEmpty ?? false)) {
      List<HomluxSceneEntity> scenes = res.data!;
      scenes.removeWhere((element) => element.deviceActions?.isEmpty ?? true);
      /// 场景缓存到本地
      () async {
        if (scenes.isNotEmpty) {
          _scenes.clear();
          LocalStorage.setItem(
              'homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}',
              res.toString());
          for (var value in scenes) {
            if (value.sceneId != null) {
              _scenes[value.sceneId!] = value;
            }
          }
        } else {
          _scenes.clear();
          LocalStorage.removeItem(
              'homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}');
        }
      }();

    }
    return res;
  }

  /// 场景控制
  static Future<HomluxResponseEntity> execScene(String sceneId) async {
    /// 恢复缓存设置
    if(_scenes.isEmpty) {
      String? json = await LocalStorage.getItem('homlux_lan_scene_list_save_${HomluxGlobal.homluxHomeInfo?.houseId}');
      if(StrUtils.isNotNullAndEmpty(json)) {
        HomluxResponseEntity<List<HomluxSceneEntity>> entity = HomluxResponseEntity<List<HomluxSceneEntity>>.fromJson(jsonDecode(json!));
        entity.data?.forEach((element) {
          if(element.sceneId != null) {
            _scenes[element.sceneId!] = element;
          }
        });
      }
    }

    var updateStamp = _scenes[sceneId]?.updateStamp ?? 0;

    /// 局域网控制
    HomluxResponseEntity lanEntity = await manager.executeScene(sceneId, updateStamp);
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
    HomluxResponseEntity<List<HomluxPanelAssociateSceneEntity>> res =
        await HomluxApi.request<List<HomluxPanelAssociateSceneEntity>>(
            '/v1/mzgd/scene/querySceneListByPanel',
            data: {"deviceId": deviceId});
    return res;
  }
}
