import 'package:flutter/material.dart';

// 获取当前时间
DateTime n = DateTime.now();
// 获取现在周几
String weekday = '星期${n.weekday}';
// 获取现在日期
String date = '${n.month}月${n.day}日';

class ScenePageState extends State<ScenePage> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: const BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 38, left: 26.5, bottom: 16, right: 18),
              child: Flex(
              direction: Axis.horizontal,
              children: const [
                Text('12月12日 周一 23:30',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'MideaType',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ],
            )),
            Flex(
              direction: Axis.horizontal,
              children: const [
                Text("手动场景",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.85),
                      fontSize: 30.0,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              textDirection: TextDirection.ltr,
              children: const <Widget>[
                Icon(Icons.help, color: Color.fromRGBO(216, 216, 216, 1))
              ],
            ),
            Expanded(
                child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, //横轴三个子widget
                            childAspectRatio: 1.0 //宽高比为1时，子widget
                            ),
                    children: <Widget>[
                  Container(
                    color: Colors.yellow,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.red,
                    width: 100,
                    height: 180,
                  ),
                  Container(
                    color: Colors.white,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.green,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.green,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.green,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.green,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.green,
                    width: 60,
                    height: 80,
                  ),
                  Container(
                    color: Colors.green,
                    width: 60,
                    height: 80,
                  ),
                ]))
          ],
        ));
  }
}

class ScenePage extends StatefulWidget {
  const ScenePage({super.key});

  @override
  State<ScenePage> createState() => ScenePageState();
}
