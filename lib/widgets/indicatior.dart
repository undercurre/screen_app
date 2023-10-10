import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common/logcat_helper.dart';

class Indicator extends StatefulWidget {
  final PageController pageController;
  final int itemCount;

  const Indicator(
      {super.key, required this.pageController, required this.itemCount});

  @override
  State<Indicator> createState() => IndicatorState();
}

class IndicatorState extends State<Indicator> {
  void updateIndicator() {
    Log.i("update indicator ${widget.pageController.page}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Positioned(
          left: 215,
          bottom: 12,
          child: Stack(
            children: [
              Positioned(
                left: (widget.pageController.page?.round() ?? 0) /
                    (widget.itemCount - 1) *
                    25,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 背景颜色
                    borderRadius: BorderRadius.circular(10.0), // 圆角半径
                  ),
                ),
              ),
              Container(
                width: 51,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // 背景颜色
                  borderRadius: BorderRadius.circular(10.0), // 圆角半径
                ),
              ),
            ],
          ));
    });
  }
}
