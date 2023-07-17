import 'dart:core';
import 'dart:math';

import '../../logcat_helper.dart';
import '../homlux_global.dart';
import '../models/homlux_scene_entity.dart';
import '../models/homlux_response_entity.dart';
import '../../../routes/home/scene/scene.dart';
import 'homlux_api.dart';

class HomluxSceneApi {
  /// 查询家庭下的场景
  static Future<List<Scene>> getSceneList() async {
    var res = await HomluxApi.request<List<HomluxSceneEntity>>('/v1/mzgd/scene/querySceneListByHouseId', data: {
      "houseId": HomluxGlobal.homluxHomeInfo?.houseId
    });
    Log.i('lmn>>>场景接口返回code=${res.code}');

    if (res.code != 0 || res.result == null || res.result!.isEmpty) {
      Log.i('lmn>>>无场景数据/解析失败');
      return [];
    }

    var list = res.result!;
    var previousBgIndex = 1;
    var sceneList = list.map((e) {
      var currentBgIndex = Random().nextInt(6) + 1;
      if (previousBgIndex == currentBgIndex) {
        currentBgIndex = (currentBgIndex % 6) + 1;
      }
      previousBgIndex = currentBgIndex;
      return Scene(
          'assets/imgs/scene/$currentBgIndex.png',
          e.sceneName ?? '未命名',
          'assets/imgs/scene/huijia.png', //暂时固定 //e.sceneIcon ?? 'assets/imgs/scene/huijia.png',
          e.sceneId!,
          '1'); // 暂无可匹配数据
    }).toList();
    return sceneList;
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
