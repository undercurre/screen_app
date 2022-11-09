import 'package:flutter/material.dart';

class GradientSlider extends StatefulWidget {
  // 渐变色数组
  final List<Color> activeColors;

  // 滑动条宽高
  final double width;
  final double height;
  final bool radius;

  // 数值
  final double max;
  final double value;
  final double min;

  // 滑动回调

  // 插槽
  // final Widget child;

  const GradientSlider({
    super.key,
    required this.value,
    this.activeColors = const [Color(0xFF267AFF), Color(0xFF267AFF)],
    this.max = 100,
    this.min = 0,
    this.width = 258,
    this.height = 20,
    this.radius = true,
  });

  @override
  State<GradientSlider> createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }
  
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onPanDown: (DragDownDetails e) {
        //打印手指按下的位置(相对于屏幕)
        setState(() {
          double temp =
              (e.localPosition.dx - 20 - 10) / (widget.width - 20) * 100;
          if (temp > 100) {
            temp = 100;
          } else if (temp < 0) {
            temp = 0;
          }
          setState(() {
            value = temp;
          });
        });
      },
      //手指滑动时会触发此回调
      onPanUpdate: (DragUpdateDetails e) {
        //用户手指滑动时，更新偏移，重新构建
        double temp =
            (e.localPosition.dx - 20 - 10) / (widget.width - 20) * 100;
        if (temp > 100) {
          temp = 100;
        } else if (temp < 0) {
          temp = 0;
        }
        setState(() {
          value = temp;
        });
      },
      onPanEnd: (DragEndDetails e) {
        //打印滑动结束时在x、y轴上的速度
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: widget.height,
            width: widget.width,
          ),
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
                    height: widget.height,
                    width: widget.width,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.activeColors),
                  borderRadius: widget.radius
                      ? BorderRadius.circular(10.0)
                      : BorderRadius.circular(0),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: widget.height,
                    width: 20 + value / 100 * (widget.width - 20),
                  ),
                ),
              ),
              Positioned(
                left: 20 - 16 + value / 100 * (widget.width - 20),
                top: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
