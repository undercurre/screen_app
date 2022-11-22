import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:screen_app/common/api/index.dart';
import 'package:screen_app/common/global.dart';

import '../../routes/scene/config.dart';
import '../../routes/scene/scene.dart';
import 'api.dart';
import '../../models/index.dart';

class SceneSource {
  String name;
  num sceneId;
  num enable;

  SceneSource(this.name, this.sceneId, this.enable);
}

class SceneApi {
  /// 场景列表查询
  static  Future<List<Scene>> getSceneList() async {
    var res = await Api.requestMzIot<QrCode>(
        "/v1/category/midea/scene/list",
        data: {
          "systemSource": "SMART_SCREEN",
          "homegroupId": Global.profile.homeInfo?.homegroupId,
          "frontendType": "ANDRIOD",
          "version": "1.0",
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));
    var modelRes = SceneList.fromJson(res.result);
    var filterList = modelRes.list.where((element) => element.sceneType == 1);
    var sceneList = [...filterList.map((e) =>
        Scene('assets/imgs/scene/${Random().nextInt(5) + 1}.png', e.name, 'assets/imgs/scene/huijia.png', e.sceneId.toString())
    )].toList();
    return sceneList;
  }

  /// 场景列表执行
  static Future<MzIotResult> execScene(String sceneId) async {
    var res = await Api.requestMzIot<QrCode>(
        "/v1/category/midea/scene/execute",
        data: {
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDRIOD",
          "sceneId": sceneId,
          "homegroupId": Global.profile.homeInfo?.homegroupId,
          "version": "1.0",
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }
}