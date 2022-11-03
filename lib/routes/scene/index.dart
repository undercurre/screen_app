import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

// 获取当前时间
DateTime n = DateTime.now();
// 获取现在周几
String weekday = '星期${n.weekday}';
// 获取现在日期
String date = '${n.month}月${n.day}日';

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

  @override
  Widget build(BuildContext context) {
    const selected = false;
    List<Widget> _tiles = [
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: selected ? AssetImage("assets/imgs/scene/huijia.png") : AssetImage("assets/imgs/scene/choose.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
      Padding(padding: const EdgeInsets.all(10), child: Stack(
        children: const [
          Image(image: AssetImage("assets/imgs/scene/1.png"), width: 136.0),
          Positioned(
              top: 17,
              left: 46,
              child: Text("回家",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none))),
          Positioned(
              bottom: 4,
              left: 38,
              child: Image(
                  image: AssetImage("assets/imgs/scene/huijia.png"),
                  width: 60.0))
        ],
      ),),
    ];

    return DecoratedBox(
        decoration: const BoxDecoration(color: Colors.black),
        child: Column(children: [
          Container(
              padding: const EdgeInsets.only(
                  top: 26, left: 26.5, bottom: 10, right: 18),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('12月12日 周一 23:30',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontFamily: 'MideaType',
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                  Image.asset(
                    "assets/imgs/scene/room.png",
                    width: 40,
                  ),
                ],
              )),
          Container(
              padding: const EdgeInsets.only(left: 26.5, bottom: 30),
              child: Flex(
                direction: Axis.horizontal,
                children: const [
                  Text("手动场景",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.85),
                        fontSize: 30.0,
                        height: 1.2,
                        fontFamily: 'MideaType',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                ],
              )),
          Expanded(
              child: RawScrollbar(
                  thickness: 4,
                  thumbColor: const Color(0x4CD8D8D8),
                  radius: const Radius.circular(25),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: ReorderableWrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              padding: const EdgeInsets.all(8),
                              buildDraggableFeedback:
                                  (context, constraints, child) {
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
                                          child: child),
                                    ),
                                  ),
                                );
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  Widget row = _tiles.removeAt(oldIndex);
                                  _tiles.insert(newIndex, row);
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
                              children: _tiles)))))
        ]));
  }
}

class ScenePage extends StatefulWidget {
  const ScenePage({super.key});

  @override
  State<ScenePage> createState() => ScenePageState();
}
