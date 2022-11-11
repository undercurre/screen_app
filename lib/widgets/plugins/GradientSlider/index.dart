import 'package:flutter/material.dart';

class GradientSlider extends StatefulWidget {
  // 渐变色数组
  final List<Color> activeColors;

  // 滑动条宽高
  final double width;
  final double height;

  // 是否半圆
  final bool rounded;

  // 非半圆圆角大小
  final double radius;

  // 圆点半径
  final double ballRadius;

  // 数值
  final double max;
  final double value;
  final double min;

  // 滑动回调，传递出进度值和当前颜色
  final void Function(double value, Color activeColor)? onChanging;
  final void Function(double value, Color activeColor)? onChanged;

  // 插槽
  // final Widget child;

  // 动画时长，不传表示不执行动画
  final Duration? duration;

  const GradientSlider({
    super.key,
    required this.value,
    this.duration,
    this.onChanged,
    this.onChanging,
    this.activeColors = const [Color(0xFF267AFF), Color(0xFF267AFF)],
    this.max = 100,
    this.min = 0,
    this.width = 272,
    this.height = 20,
    this.rounded = true,
    this.radius = 10,
    this.ballRadius = 6,
  });

  @override
  State<GradientSlider> createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider>
    with TickerProviderStateMixin {
  // 动画控制器
  AnimationController? controller;
  // 当前滑动条的状态
  late double value;
  // 如果设置了动画，需要使用该变量设置动画最终值，并传递给父组件
  late double toValue;
  bool isPanUpdate = false;
  bool isPanning = false;

  @override
  void initState() {
    super.initState();
    value = widget.value < 0 ? 0 : widget.value > 100 ? 100 : widget.value;
  }

  @override
  void didUpdateWidget(GradientSlider oldWidget) {
    if (isPanning) return;
    if (controller != null && controller!.status == AnimationStatus.forward) {
      return;
    }
    var oldValue = value;
    var newValue = widget.value < 0
        ? 0.0
        : widget.value > 100
        ? 100.0
        : widget.value;
    super.didUpdateWidget(oldWidget);
    doAnimation(newValue, oldValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (e) => onPanDown(e),
      //手指滑动时会触发此回调
      onPanUpdate: (e) => onPanUpdate(e),
      onPanEnd: (e) => onPanUp(),
      onPanCancel: () => onPanUp(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: widget.height,
            width: widget.width,
          ),
          child: Stack(
            alignment: Alignment.centerLeft, //指定未定位或部分定位widget的对齐方式
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: widget.rounded
                      ? BorderRadius.circular(widget.height / 2)
                      : BorderRadius.circular(widget.radius),
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
                  gradient: LinearGradient(colors: getActiveColor()),
                  borderRadius: widget.rounded
                      ? BorderRadius.circular(widget.height / 2)
                      : BorderRadius.circular(widget.radius),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: widget.height,
                    width: getActiveBarWidth(),
                  ),
                ),
              ),
              Positioned(
                left: getBallLeft(),
                child: Container(
                  width: widget.ballRadius * 2,
                  height: widget.ballRadius * 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(widget.ballRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> getActiveColor({double? toValue}) {
    double value = toValue ?? this.value;
    Color leftColor = widget.activeColors[0];
    Color rightColor = widget.activeColors[1];
    int curRed = ((rightColor.red - leftColor.red) * value / 100 + leftColor.red).round();
    int curGreen = ((rightColor.green - leftColor.green) * value / 100 + leftColor.green).round();
    int curBlue = ((rightColor.blue - leftColor.blue) * value / 100 + leftColor.blue).round();
    int curAlpha = ((rightColor.alpha - leftColor.alpha) * value / 100 + leftColor.alpha).round();
    return [widget.activeColors[0], Color.fromARGB(curAlpha, curRed, curGreen, curBlue)];
  }

  // 获取白色圆点的left距离
  double getBallLeft() {
    return widget.height -
        ((widget.height - widget.ballRadius * 2) / 2 + widget.ballRadius * 2) +
        value / 100 * (widget.width - widget.height);
  }

  // 获取激活部分滑动条长度
  double getActiveBarWidth() {
    return widget.height + value / 100 * (widget.width - widget.height);
  }

  // 执行动画（如果不存在duration则没有动画过程）
  void doAnimation(double newValue, double oldValue) {
    if (widget.duration != null) {
      // 传入动画执行时间，需要执行动画
      // 如果当前动画还在执行，需要先停掉上一次动画
      if (controller?.status == AnimationStatus.forward) {
        controller!.stop();
      }
      // 执行本次动画
      controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      CurvedAnimation curve =
      CurvedAnimation(parent: controller!, curve: Curves.easeInOut);
      Animation<double> animation =
      Tween(begin: oldValue, end: newValue).animate(curve);
      animation.addListener(() {
        setState(() {
          value = animation.value;
        });
      });
      controller!.forward();
    } else {
      setState(() {
        value = newValue;
      });
    }
  }

  void onPanDown(DragDownDetails e) {
    isPanning = true;
    isPanUpdate = false;
    toValue = (e.localPosition.dx - 20 - 10) / (widget.width - 20) * 100;
    if (toValue > 100) {
      toValue = 100;
    } else if (toValue < 0) {
      toValue = 0;
    }
    doAnimation(toValue, value);
  }

  void onPanUpdate(DragUpdateDetails e) {
    isPanUpdate = true;
    //用户手指滑动时，更新偏移，重新构建
    double temp = (e.localPosition.dx - 20 - 10) / (widget.width - 20) * 100;
    if (temp > 100) {
      temp = 100;
    } else if (temp < 0) {
      temp = 0;
    }
    setState(() {
      value = temp;
      toValue = temp;
    });
    widget.onChanging?.call(value, getActiveColor()[1]);
  }

  void onPanUp() {
    isPanning = false;
    widget.onChanged?.call(toValue, getActiveColor(toValue: toValue)[1]);
  }
}
