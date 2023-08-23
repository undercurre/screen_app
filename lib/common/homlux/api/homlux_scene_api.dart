import 'dart:core';

import '../../logcat_helper.dart';
import '../homlux_global.dart';
import '../models/homlux_panel_associate_scene_entity.dart';
import '../models/homlux_scene_entity.dart';
import '../models/homlux_response_entity.dart';
import 'homlux_api.dart';

class HomluxSceneApi {
  /// 查询家庭下的场景
  static Future<HomluxResponseEntity<List<HomluxSceneEntity>>> getSceneList() async {
    var res = await HomluxApi.request<List<HomluxSceneEntity>>('/v1/mzgd/scene/querySceneListByHouseId', data: {
      "houseId": HomluxGlobal.homluxHomeInfo?.houseId
    });
    /// 移除无效场景
    if(res.isSuccess && (res.data?.isNotEmpty ?? false)) {
      List<HomluxSceneEntity> scenes = res.data!;
      scenes.removeWhere((element) => element.deviceActions?.isEmpty ?? true);
    }
    return res;
  }

  /// 场景控制
  static Future<HomluxResponseEntity> execScene(String sceneId) async {
    var res = await HomluxApi.request('/v1/mzgd/scene/sceneControl', data: {
      "sceneId": sceneId
    });
    if (res.code == 0) {
      Log.i('lmn>>>控制场景id=$sceneId成功');
    } else {
      Log.i('lmn>>>控制场景id=$sceneId失败');
    }
    return res;
  }

  /// 查询面关联的场景
  static Future<HomluxResponseEntity<HomluxPanelAssociateSceneEntity>> querySceneListByPanel(String deviceId) async {
    var res = await HomluxApi.request<HomluxPanelAssociateSceneEntity>('/v1/mzgd/scene/querySceneListByPanel', data: {
      "deviceId": deviceId
    });
    return res;
  }

}
