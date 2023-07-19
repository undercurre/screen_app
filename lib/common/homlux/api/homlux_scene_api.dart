import 'dart:core';

import '../../logcat_helper.dart';
import '../homlux_global.dart';
import '../models/homlux_scene_entity.dart';
import '../models/homlux_response_entity.dart';
import 'homlux_api.dart';

class HomluxSceneApi {
  /// 查询家庭下的场景
  static Future<HomluxResponseEntity<List<HomluxSceneEntity>>> getSceneList() async {
    var res = await HomluxApi.request<List<HomluxSceneEntity>>('/v1/mzgd/scene/querySceneListByHouseId', data: {
      "houseId": HomluxGlobal.homluxHomeInfo?.houseId
    });
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
}
