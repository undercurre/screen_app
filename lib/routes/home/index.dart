import 'package:flutter/material.dart';
import '../../widgets/AdvancedVerticalSeekBar.dart';
import '../dropdown/DropDownDialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.initValue = 0});

  final int initValue;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _counter = 0;
  late double po;
  double _sliderItemA = 0.0;

  @override
  void initState() {
    super.initState();
    //初始化状态
    _counter = widget.initValue;
    print("initState");
  }

  @override
  Widget build(BuildContext context) {
    print("build");
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
                        return DropDownDialog();
                      });
                }
              },
            ),
            Positioned(
              top: 20,
              left: 30,
              child: Wrap(
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, '返回值');
                    },
                    child: Text('返回'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(),
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

  void xx(double aa, bool) {}
}
