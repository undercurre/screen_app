

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 圆形指示器
class MzCircleIndicator extends StatelessWidget {

  double circleWidth = 8;
  double circleHeight = 8;
  double spacing = 4.0;
  int pageCount;
  int selectPosition = 0;

  MzCircleIndicator({super.key, required this.pageCount , required this.selectPosition});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildIndicator(pageCount),
    );
  }

  List<Widget> _buildIndicator(int count) {
    return List<Widget>.generate(count, (index) {
      return Padding(
        padding: EdgeInsets.all(spacing),
        child: Container(
          width: circleWidth,
          height: circleHeight,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(circleWidth / 2)),
              color: index == selectPosition ? Colors.white : Colors.white30
          ),
        ),
      );
    });
  }

}