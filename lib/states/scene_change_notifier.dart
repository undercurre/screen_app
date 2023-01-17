import 'package:flutter/foundation.dart';

import '../common/api/scene_api.dart';
import '../routes/home/scene/scene.dart';

class SceneChangeNotifier extends ChangeNotifier {
  List<Scene> sceneList = [];
  List<String> selectList = [];

  updateSceneList() async {
    sceneList = await SceneApi.getSceneList();
    // 去除一下之前选中但是场景列表中已经不存在的场景
    final sceneKeyList = sceneList.map((e) => e.key);
    selectList = selectList.where((element) => sceneKeyList.contains(element)).toList();
    print(sceneList[0]);
    notifyListeners();
  }

  List<Scene> get ableExecSceneList {
    return [];
  }
}
