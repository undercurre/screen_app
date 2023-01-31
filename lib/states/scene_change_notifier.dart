import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:screen_app/common/global.dart';

import '../common/api/scene_api.dart';
import '../common/utils.dart';
import '../routes/home/scene/scene.dart';
import '../routes/home/scene/scene_card.dart';

class SceneChangeNotifier extends ChangeNotifier {
  List<Scene> sceneList = [];
  List<String> selectList = [];

  initSceneList() async {
    sceneList = await SceneApi.getSceneList();
    logger.i('接口获取到的$sceneList');
    var quickString = await LocalStorage.getItem('quickScene');
    logger.i('LocalStorage$quickString');
    if (quickString != null) {
      selectList = List<String>.from(json.decode(quickString));
      logger.i('initSceneNotice$selectList');
    } else {
      logger.i('initSceneNotice${selectList.isEmpty}');
      if (selectList.isEmpty) {
        final sceneKeyList = sceneList.map((e) => e.key).toList();
        if (sceneList.length > 4) {
          selectList = sceneKeyList.sublist(0, 4);
        } else {
          selectList = sceneKeyList;
        }
      }
    }
    notifyListeners();
  }

  updateSceneList() async {
    sceneList = await SceneApi.getSceneList();
    // 去除一下之前选中但是场景列表中已经不存在的场景
    final sceneKeyList = sceneList.map((e) => e.key);
    selectList =
        selectList.where((element) => sceneKeyList.contains(element)).toList();
    logger.i('updateSceneNotice${selectSceneList.map((e) => e.name).toList()}');
    LocalStorage.setItem('quickScene', json.encode(selectList));
    notifyListeners();
  }

  List<Scene> get ableExecSceneList {
    return [];
  }

  List<Scene> get selectSceneList {
    return sceneList
        .where((element) => selectList.contains(element.key))
        .toList();
  }

  void shiftElement(int oldIndex, int newIndex) {
    logger.i('移动元素');
    var element = sceneList.removeAt(oldIndex);
    sceneList.insert(newIndex, element);
    notifyListeners();
  }
}
