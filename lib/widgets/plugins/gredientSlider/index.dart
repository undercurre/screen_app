import 'package:flutter/material.dart';
import 'dart:math';

class GredientSlider extends StatefulWidget {
  // 渐变色数组
  final List<Color> activeColors;

  // 滑动条宽高
  final double width;
  final double height;
  final bool radius;

  // 数值
  final double max;
  double value;
  final double min;

  // 滑动回调

  // 插槽
  // final Widget child;

  GredientSlider({super.key,
    required this.value,
    this.activeColors = const [Color(0xFF267AFF), Color(0xFF267AFF)],
    this.max = 100,
    this.min = 0,
    this.width = 258,
    this.height = 20,
    this.radius = true,
  });

  @override
  State<GredientSlider> createState() => _GredientSliderState(value);
}

class _GredientSliderState extends State<GredientSlider> {

  _GredientSliderState(double value);

  @override
  Widget build(BuildContext context) {
    double leftValue = widget.value / 100 * 258;

    return ConstrainedBox(
      constraints:
          BoxConstraints.tightFor(height: widget.height, width: widget.width),
      child: Stack(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: widget.radius
                  ? BorderRadius.circular(10.0)
                  : BorderRadius.circular(0),
            ),
            child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    height: widget.height, width: widget.width)),
          ),
          GestureDetector(
              onPanDown: (DragDownDetails e) {
                //打印手指按下的位置(相对于屏幕)
                print("用户手指按下：${e.localPosition}");
              },
              //手指滑动时会触发此回调
              onPanUpdate: (DragUpdateDetails e) {
                //用户手指滑动时，更新偏移，重新构建
                setState(() {
                  double dir = e.delta.dx > 0 ? 1 : -1;
                  double dan = ((e.delta.dx / widget.width).abs() > 1 ? (e.delta.dx / widget.width) : 2);
                  if (widget.value + dir * dan > 100) {
                    widget.value = 100;
                  } else if (widget.value + dir * dan < 0) {
                    widget.value = 0;
                  } else {
                    widget.value += dir * dan;
                  }});
                print("用户手指滑动：${e.delta.dx}");
              },
              onPanEnd: (DragEndDetails e) {
                //打印滑动结束时在x、y轴上的速度
                print(e.velocity);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.activeColors),
                  borderRadius: widget.radius
                      ? BorderRadius.circular(10.0)
                      : BorderRadius.circular(0),
                ),
                child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        height: widget.height, width: widget.width)),
              )),
          Positioned(
              left: widget.value / 100 * 258,
              top: 4,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10.0)),
              )),
        ],
      ),
    );
  }
}
