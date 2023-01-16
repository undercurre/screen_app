import 'package:flutter/foundation.dart';

import '../common/api/scene_api.dart';
import '../routes/home/scene/scene.dart';

class SceneChangeNotifier extends ChangeNotifier {
  List<Scene> sceneList = [];
  List<String> selectList = [];

  updateSceneList() async {
    sceneList = await SceneApi.getSceneList();
    print(sceneList[0]);
    notifyListeners();
  }

  List<Scene> get ableExecSceneList {
    return [];
  }
}
