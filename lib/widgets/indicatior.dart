import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Indicator extends StatefulWidget {
  final int itemCount;
  final int defaultPosition;

  const Indicator({super.key,
    required this.defaultPosition,
    required this.itemCount});

  @override
  State<Indicator> createState() => IndicatorState();
}

class IndicatorState extends State<Indicator> {

  late int position;


  @override
  void initState() {
    super.initState();
    position = widget.defaultPosition;
  }

  void updateIndicator(int position) {
    setState(() {
      this.position = position;
    });
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
                left: widget.itemCount == 0 ? 0 : (position ?? 0) / (widget.itemCount - 1) * 25,
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
