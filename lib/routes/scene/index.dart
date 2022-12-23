import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/routes/scene/scene.dart';
import 'package:screen_app/routes/scene/scene_card.dart';

import '../../common/api/scene_api.dart';
import 'config.dart';

class ScenePageState extends State<ScenePage> {
  double _alignmentY = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    setState(() {
      _alignmentY = -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
    });
    print('滚动组件最大滚动距离:${metrics.maxScrollExtent}');
    print('当前滚动位置:${metrics.pixels}');
    print('当前变量:$_alignmentY');
    return true;
  }

  // 获取现在日期
  String time = '';

  // 定时器
  late Timer timeTimer = Timer(const Duration(seconds: 1), () {}); // 定义定时器

  void startTimer() {
    timeTimer?.cancel(); // 取消定时器
    timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //TODO
      setState(() {
        time = DateFormat('MM月d日 E kk:mm', 'zh_CN').format(DateTime.now());
      });
    });
  }

  List<Scene> sceneList = [
    huijia,
    lijia,
    huike,
    jiucan,
    shuimian,
    chenqi,
    qiye,
    yuedu
  ];

  String selectedSceneKey = 'huijia';

  List<Widget> sceneWidgetList = [];

  void selectScene(Scene scene) {
    setState(() {
      selectedSceneKey = scene.key;
      sceneWidgetList = [
        ...sceneList.map((scene) => SceneCard(
            power: selectedSceneKey == scene.key,
            scene: scene,
            onClick: selectScene))
      ].toList();
    });
    SceneApi.execScene(scene.key);
  }

  void initScene() async {
    await initializeDateFormatting('zh_CN', null);
    sceneList = await SceneApi.getSceneList();
    debugPrint('场景列表:$sceneList');
    setState(() {
      time = DateFormat('MM月d日 E kk:mm', 'zh_CN').format(DateTime.now());
      startTimer();
      sceneWidgetList = [
        ...sceneList.map((scene) => SceneCard(
            power: selectedSceneKey == scene.key,
            scene: scene,
            onClick: selectScene))
      ].toList();
    });
  }

  void toSelectRoom() {
    Navigator.pushNamed(context, 'Room');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initScene();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 26, left: 26.5, bottom: 10, right: 18),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'MideaType',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
                Listener(
                  onPointerDown: (e) => toSelectRoom(),
                  child: Image.asset(
                    "assets/imgs/scene/room.png",
                    width: 40,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 26.5, bottom: 30),
            child: Flex(
              direction: Axis.horizontal,
              children: const [
                Text(
                  "手动场景",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.85),
                    fontSize: 30.0,
                    height: 1.2,
                    fontFamily: 'MideaType',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: RawScrollbar(
              thickness: 4,
              thumbColor: const Color(0x4CD8D8D8),
              radius: const Radius.circular(25),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ReorderableWrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    padding: const EdgeInsets.all(8),
                    buildDraggableFeedback: (context, constraints, child) {
                      return Transform(
                        transform: Matrix4.rotationZ(0),
                        alignment: FractionalOffset.topLeft,
                        child: Material(
                          elevation: 6.0,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.zero,
                          child: Card(
                            // 将默认白色设置成透明
                            color: Colors.transparent,
                            child: ConstrainedBox(
                              constraints: constraints,
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        Widget row = sceneWidgetList.removeAt(oldIndex);
                        Scene sceneRow = sceneList.removeAt(oldIndex);
                        sceneWidgetList.insert(newIndex, row);
                        sceneList.insert(newIndex, sceneRow);
                      });
                    },
                    onNoReorder: (int index) {
                      //this callback is optional
                      debugPrint(
                          '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                    },
                    onReorderStarted: (int index) {
                      //this callback is optional
                      debugPrint(
                          '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
                    },
                    children: sceneWidgetList,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class ScenePage extends StatefulWidget {
  const ScenePage({super.key, required String text});

  @override
  State<ScenePage> createState() => ScenePageState();
}
