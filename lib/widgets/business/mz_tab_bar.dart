import 'package:flutter/material.dart';

import '../../common/logcat_helper.dart';

class MzTabBar extends StatefulWidget {
  final List<Tab> tabs;

  final ValueChanged<int> tap;

  const MzTabBar({super.key, required this.tabs, required this.tap});

  @override
  State<MzTabBar> createState() => _MzTabBarState();
}

class _MzTabBarState extends State<MzTabBar> with TickerProviderStateMixin {
  late double height;
  int selectIndex = 0;

  double selectBallLeft = 0;

  AnimationController? railController; // 轨道动画控制器

  @override
  void initState() {
    super.initState();
    Tab max = widget.tabs.reduce((value, element) =>
        (value.height ?? 0) > (element.height ?? 0) ? value : element);
    height = max.height ?? ((max.icon != null && max.text != null) ? 72 : 46);
    selectBallLeft =  5;
  }

  @override
  void didUpdateWidget(covariant MzTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    railController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.all(Radius.circular(height / 2))),
          child: Stack(
            children: [
              Positioned(
                  left: selectBallLeft,
                  top: 5,
                  child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFF267AFF),
                          borderRadius: BorderRadius.all(Radius.circular(height / 2))),
                      width: maxWidth / widget.tabs.length - 10,
                      height: height - 10)),
              Row(
                children: [
                  ...widget.tabs
                      .map((e) => Expanded(
                          child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                var index = widget.tabs.indexOf(e);
                                double begin = selectBallLeft;
                                double end = index * (maxWidth / widget.tabs.length) + 5;

                                if(begin == end || index == selectIndex) return;

                                if(railController?.status == AnimationStatus.forward) {
                                  railController!.stop();
                                }
                                railController = AnimationController(
                                  vsync: this,
                                  duration: const Duration(milliseconds: 500),
                                );
                                CurvedAnimation railCurve = CurvedAnimation(parent: railController!, curve: Curves.easeInOut);
                                Animation<double> animation = Tween(begin: begin, end: end).animate(railCurve);
                                animation.addListener(() {
                                  setState(() {
                                    selectBallLeft = animation.value;
                                  });
                                });
                                railController?.forward();
                                if (index != selectIndex) {
                                  selectIndex = widget.tabs.indexOf(e);
                                  widget.tap(selectIndex);
                                  Log.i("选择中：$selectIndex");
                                }
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [e]))))
                      .toList()
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
