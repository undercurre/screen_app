import 'package:flutter/material.dart';
import '../device/index.dart';
import '../dropdown/DropDownDialog.dart';
import '../scene/index.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.initValue = 0});

  final int initValue;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double po;
  var children = <Widget>[];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    //初始化状态
    _pageController = PageController(initialPage: 1);
    children.add(const ScenePage(text: "场景页"));
    children.add(const DevicePage(text: "设备页"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
              onVerticalDragDown: (details) {
                print("竖直方向拖动按下onVerticalDragDown:" + details.globalPosition.toString());
                po = details.globalPosition.dy;
              },
              onVerticalDragUpdate: (details) {
                print("onVerticalDragUpdate---${details.globalPosition}---${details.localPosition}---${details.delta}");
                if (po <= 14) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const DropDownDialog();
                      });
                }
              },
              child: PageView(
                controller: _pageController,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget ");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    print("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }
}
