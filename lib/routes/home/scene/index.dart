import 'dart:async';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/scene/scene.dart';
import 'package:screen_app/routes/home/scene/scene_card.dart';

import '../../../common/api/scene_api.dart';
import '../../../states/index.dart';
import 'config.dart';

class ScenePageState extends State<ScenePage> {
  double sceneTitleScale = 1;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  // 获取现在日期
  String time = '';

  // 定时器
  late Timer timeTimer = Timer(const Duration(seconds: 1), () {}); // 定义定时器

  void startTimer() {
    timeTimer.cancel(); // 取消定时器
    timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //TODO
      setState(() {
        time = DateFormat('MM月d日 E  kk:mm', 'zh_CN').format(DateTime.now());
      });
    });
  }

  // List<Scene> sceneList = [huijia, lijia, huike, jiucan, shuimian, chenqi, qiye, yuedu];

  // String selectedSceneKey = 'huijia';

  List<Map<String, String>> btnList = [
    {'title': '添加设备', 'route': 'SnifferPage'},
    {'title': '切换房间', 'route': 'SelectRoomPage'}
  ];

  // void selectScene(Scene scene) {
  //   setState(() {
  //     selectedSceneKey = scene.key;
  //     Timer(const Duration(seconds: 3), () {
  //       selectedSceneKey = '';
  //     });
  //   });
  //   SceneApi.execScene(scene.key);
  // }

  void initScene() async {
    var sceneChangeNotifier = context.read<SceneChangeNotifier>();
    sceneChangeNotifier.initSceneList();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final offset = min(_scrollController.offset, 150);
        setState(() {
          sceneTitleScale = min(1 - (offset / 150), 1);
        });
      }
    });
    await initializeDateFormatting('zh_CN', null);
    setState(() {
      time = DateFormat('MM月d日 E  kk:mm', 'zh_CN').format(DateTime.now());
      startTimer();
    });
  }

  void toConfigPage(String route) async {
    final res = await Navigator.pushNamed(context, route);
     // TODO: 点击确认场景返回 'confirm' 点击返回按钮返回 'back'
  }

  @override
  void initState() {
    super.initState();
    initScene();
  }

  @override
  Widget build(BuildContext context) {
    final sceneChangeNotifier = context.watch<SceneChangeNotifier>();
    var sceneWidgetList = sceneChangeNotifier.sceneList.map((scene) => SceneCard(scene: scene)).toList();
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 26, left: 26.5, bottom: 10, right: 18),
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
                PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      )),
                  offset: const Offset(0, 36.0),
                  itemBuilder: (context) {
                    return btnList.map((item) {
                      return PopupMenuItem<String>(
                          value: item['route'],
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(item['title']!,
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: "MideaType", fontWeight: FontWeight.w400)),
                          ));
                    }).toList();
                  },
                  onSelected: (String route) {
                    toConfigPage(route);
                  },
                  child: Image.asset(
                    "assets/imgs/icon/select_room.png",
                    width: 40,
                    height: 40,
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 26.5, bottom: 30 * sceneTitleScale),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Text(
                  "手动场景",
                  textAlign: TextAlign.end,
                  textScaleFactor: sceneTitleScale,
                  style: const TextStyle(
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
            child: EasyRefresh(
              header: const ClassicHeader(
                dragText: '下拉刷新',
                armedText: '释放执行刷新',
                readyText: '正在刷新...',
                processingText: '正在刷新...',
                processedText: '刷新完成',
                noMoreText: '没有更多信息',
                failedText: '失败',
                messageText: '上次更新 %T',
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              onRefresh: () {
                sceneChangeNotifier.updateSceneList();
              },
              child: ReorderableWrap(
                spacing: 8.0,
                runSpacing: 4.0,
                controller: _scrollController,
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
                  sceneChangeNotifier.shiftElement(oldIndex, newIndex);
                },
                onNoReorder: (int index) {
                  //this callback is optional
                  logger.i('结束移动');
                },
                onReorderStarted: (int index) {
                  //this callback is optional
                  logger.i('开始移动');
                },
                children: sceneWidgetList,
              ),
            ),
          )
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
