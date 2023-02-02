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
    sceneList.clear();
    var res = await SceneApi.getSceneList();
    sceneList = await reSort(res);
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
    logger.i('sceneSort缓存存储', sceneList.map((e) => e.name).toList());
    LocalStorage.setItem(
        'sceneSort', json.encode(sceneList.map((e) => e.key).toList()));
    notifyListeners();
  }

  Future<List<Scene>> reSort(List<Scene> newList) async {
    var res = await LocalStorage.getItem('sceneSort');
    logger.i('sceneSort缓存获取', res);
    if (res != null) {
      List<dynamic> sortKeyList = json.decode(res);
      List<Scene> sortList = [];
      List<Scene> noSortList = [];
      for (var newOne in newList) {
        if (sortKeyList.contains(newOne.key)) {
          sortList.add(newOne);
        } else {
          noSortList.add(newOne);
        }
      }
      for (int i = 0; i < sortKeyList.length; i ++) {
        var indexInList = sortList.indexWhere((element) => element.key == sortKeyList[i]);
        var element = sortList.removeAt(indexInList);
        sortList.insert(i, element);
      }
      sortList.addAll(noSortList);
      logger.i('重排', sortList.map((e) => e.name).toList());
      return sortList;
    } else {
      return newList;
    }
  }
}
