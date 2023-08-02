import 'package:dio/dio.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import '../../logcat_helper.dart';
import '../models/meiju_scene_list_entity.dart';
import 'meiju_api.dart';

class MeiJuSceneApi {

  /// 场景列表查询
  static Future<MeiJuResponseEntity<MeiJuSceneListEntity>> getSceneList(String homegroupId, String uid) async {
    var res = await MeiJuApi.requestMideaIot<MeiJuSceneListEntity>("/mas/v5/app/proxy?alias=/v2/scene/brief/list",
        options: Options(method: 'POST', headers: {
          'uid':uid,
          'version': '8.0'
        }),
        data: {
          'uid': uid,
          "homegroupId": homegroupId
        });
    /// 去除非主动场景数据
    if(res.isSuccess && res.data != null && (res.data?.list?.isNotEmpty ?? false)) {
      List<MeiJuSceneEntity> scenes = res.data!.list!;
      scenes.removeWhere((element) => element.sceneType != 2);
    }
    return res;
  }

  /// 场景列表执行
  static Future<MeiJuResponseEntity> execScene(String homegroupId, String uid, String sceneId) async {
    var res = await MeiJuApi.requestMideaIot("/mas/v5/app/proxy?alias=/v2/scene/execute",
        data: {
          "sceneId": sceneId,
          "homegroupId": homegroupId,
          "uid": uid
        },
        options: Options(method: 'POST', headers: {
            'uid':uid,
            'version': '8.0'
          },
        ));

    if(res.isSuccess) {
      Log.i('场景执行成功');
    } else {
      Log.i("场景执行失败");
    }

    return res;
  }


}