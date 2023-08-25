import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/homlux/api/homlux_scene_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/models/meiju_scene_list_entity.dart';

import '../common/gateway_platform.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/homlux/models/homlux_scene_entity.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/api/meiju_scene_api.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/system.dart';
import '../models/scene_info_entity.dart';

class SceneListModel extends ChangeNotifier {
  MeiJuSceneListEntity sceneListMeiju = MeiJuSceneListEntity();
  List<HomluxSceneEntity> sceneListHomlux = [];

  SceneListModel() {
    logger.i('场景model加载');
    getSceneList();
  }

  List<SceneInfoEntity> getCacheSceneList() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      // Log.i('场景列表数据', sceneListMeiju.list?.length);
      if (sceneListMeiju.list != null) {
        return sceneListMeiju.list!.map((e) {
          SceneInfoEntity sceneObj = SceneInfoEntity();
          sceneObj.name = e.name;
          sceneObj.sceneId = e.sceneId;
          sceneObj.image = e.image;
          return sceneObj;
        }).toList();
      } else {
        return [];
      }
    } else {
      return sceneListHomlux.map((e) {
        SceneInfoEntity sceneObj = SceneInfoEntity();
        sceneObj.name = e.sceneName;
        sceneObj.sceneId = e.sceneId;
        sceneObj.image = e.sceneIcon;
        return sceneObj;
      }).toList();
    }
  }

  Future<List<SceneInfoEntity>> getSceneList() async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      final familyInfo = System.familyInfo;
      MeiJuResponseEntity<MeiJuSceneListEntity> MeijuRes = await MeiJuSceneApi.getSceneList(familyInfo!.familyId, MeiJuGlobal.token!.uid);
      if (MeijuRes.isSuccess) {
        sceneListMeiju = MeijuRes.data!;
        return sceneListMeiju.list!.map((e) {
            SceneInfoEntity sceneObj = SceneInfoEntity();
            sceneObj.name = e.name;
            sceneObj.sceneId = e.sceneId;
            sceneObj.image = e.image;
            return sceneObj;
        }).toList();
      }
    } else {
      HomluxResponseEntity<List<HomluxSceneEntity>> HomluxRes = await HomluxSceneApi.getSceneList();
      if (HomluxRes.isSuccess) {
        sceneListHomlux = HomluxRes.result!;
        return sceneListHomlux.map((e) {
          SceneInfoEntity sceneObj = SceneInfoEntity();
          sceneObj.name = e.sceneName;
          sceneObj.sceneId = e.sceneId;
          sceneObj.image = e.sceneIcon;
          return sceneObj;
        }).toList();
      }
    }
    return [];
  }

  Future<bool> sceneExec(String sceneId) async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      final familyInfo = System.familyInfo;
      MeiJuResponseEntity MeijuRes = await MeiJuSceneApi.execScene(familyInfo!.familyId, MeiJuGlobal.token!.uid, sceneId);
      return MeijuRes.isSuccess;
    } else {
      HomluxResponseEntity HomluxRes = await HomluxSceneApi.execScene(sceneId);
      return HomluxRes.code == 0;
    }
  }
}
