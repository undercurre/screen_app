import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/index.dart';
import 'package:screen_app/common/global.dart';

import '../../models/index.dart';
import '../../routes/home/scene/scene.dart';
import 'api.dart';

class SceneSource {
  String name;
  num sceneId;
  num enable;

  SceneSource(this.name, this.sceneId, this.enable);
}

class SceneApi {
  /// 场景列表查询
  static Future<List<Scene>> getSceneList() async {
    var res =
        await Api.requestMzIot<SceneListEntity>("/v1/category/midea/scene/list",
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
    debugPrint('拿到场景响应$res');
    var modelRes = res.result;
    var filterList = modelRes.list.where((element) => element.sceneType == 2 && element.sceneStatus != 3).toList();
    debugPrint('过滤后的场景$filterList');
    var sceneList = filterList.map((e) => Scene(
          'assets/imgs/scene/${Random().nextInt(5) + 1}.png',
          e.name,
          'assets/imgs/scene/huijia.png',
          e.sceneId.toString())).toList();
    return sceneList;
  }

  /// 场景列表执行
  static Future<MzResponseEntity> execScene(String sceneId) async {
    var res = await Api.requestMzIot("/v1/category/midea/scene/execute",
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
