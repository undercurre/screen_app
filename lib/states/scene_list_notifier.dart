import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/homlux/api/homlux_scene_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/models/meiju_scene_list_entity.dart';

import '../common/adapter/select_room_data_adapter.dart';
import '../common/gateway_platform.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/homlux/models/homlux_scene_entity.dart';
import '../common/meiju/api/meiju_scene_api.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/system.dart';
import '../models/scene_info_entity.dart';

class SceneListModel extends ChangeNotifier {
  MeiJuSceneListEntity sceneListMeiju = MeiJuSceneListEntity();
  List<HomluxSceneEntity> sceneListHomlux = [];
  SelectRoomDataAdapter roomDataAd = SelectRoomDataAdapter(MideaRuntimePlatform.platform);

  SceneListModel() {
    getSceneList();
    roomDataAd.queryRoomList(System.familyInfo!);
    roomDataAd.bindDataUpdateFunction(() {
      getSceneList();
      notifyListeners();
    });
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
          sceneObj.roomId = e.roomId;
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
        sceneObj.roomId = e.roomId;
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
            sceneObj.roomId = e.roomId;
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
          sceneObj.roomId = e.roomId;
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

  String getSceneRoomName(String sceneId) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return '';
    } else {
      String sceneRoomId = sceneListHomlux.firstWhere((element) => element.sceneId == sceneId, orElse: () {
        HomluxSceneEntity defaultScene = HomluxSceneEntity();
        defaultScene.roomId = '';
        return defaultScene;
      }).roomId ?? '';
      return roomDataAd.roomListEntity?.roomList.firstWhere((element) => element.id == sceneRoomId, orElse: () {
        SelectRoomItem defaultRoom = SelectRoomItem();
        defaultRoom.name = '';
        return defaultRoom;
      }).name ?? '';
    }
  }

  String getSceneName(String sceneId) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return sceneListMeiju.list?.firstWhere((element) => element.sceneId == sceneId, orElse: () {
        MeiJuSceneEntity defaultScene = MeiJuSceneEntity(name: '');
        return defaultScene;
      }).name ?? '';
    } else {
      return sceneListHomlux.firstWhere((element) => element.sceneId == sceneId, orElse: () {
        HomluxSceneEntity defaultScene = HomluxSceneEntity();
        defaultScene.sceneName = '';
        return defaultScene;
      }).sceneName ?? '';
    }
  }

  String getSceneIcon(String sceneId) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return sceneListMeiju.list?.firstWhere((element) => element.sceneId == sceneId, orElse: () {
        MeiJuSceneEntity defaultScene = MeiJuSceneEntity(name: '');
        return defaultScene;
      }).image ?? '';
    } else {
      return sceneListHomlux.firstWhere((element) => element.sceneId == sceneId, orElse: () {
        HomluxSceneEntity defaultScene = HomluxSceneEntity();
        defaultScene.sceneName = '';
        return defaultScene;
      }).sceneIcon ?? '';
    }
  }
}
