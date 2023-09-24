import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';

import '../common/logcat_helper.dart';

class MzVSlider extends StatefulWidget {
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
  final num max;
  final num min;
  final num step;
  final num value;

  // 是否禁用操作
  final bool disabled;

  // 滑动回调，传递出进度值和当前颜色
  final void Function(num value, Color activeColor)? onChanging;
  final void Function(num value, Color activeColor)? onChanged;

  // 插槽
  // final Widget child;

  // 动画时长，不传表示不执行动画
  final Duration? duration;

  // 组件内边距，用于拓展手势区域，提高用户体验
  final EdgeInsetsGeometry padding;

  const MzVSlider({
    super.key,
    required this.value,
    this.duration,
    this.onChanged,
    this.onChanging,
    this.activeColors = const [Color(0xFF267AFF), Color(0xFF267AFF)],
    this.max = 100,
    this.min = 0,
    this.width = 100,
    this.height = 20,
    this.rounded = false,
    this.radius = 10,
    this.ballRadius = 6,
    this.step = 1,
    this.disabled = false,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<MzVSlider> createState() => _MzSliderState();
}

class _MzSliderState extends State<MzVSlider> with TickerProviderStateMixin {
  // 轨道的key
  final GlobalKey _railKey = GlobalKey();

  // 动画控制器
  AnimationController? controller;

  // 当前滑动条的状态
  late num value;

  // 如果设置了动画，需要使用该变量设置动画最终值，并传递给父组件
  late num toValue;
  bool isPanUpdate = false;
  bool isPanning = false;
  late Offset latestPosition = Offset.zero;

  Timer? feedTimer;
  int timeDrag = 0;

  @override
  void initState() {
    super.initState();
    value = widget.value < widget.min
        ? widget.min
        : widget.value > widget.max
            ? widget.max
            : widget.value;
  }

  @override
  void didUpdateWidget(MzVSlider oldWidget) {
    if (isPanning) return;
    if (controller != null && controller!.status == AnimationStatus.forward) {
      return;
    }
    var oldValue = value;
    var newValue = clampValue(widget.value);
    super.didUpdateWidget(oldWidget);
    doAnimation(newValue, oldValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (e) => onPanDown(e),
      //手指滑动时会触发此回调
      onVerticalDragUpdate: (e) => onPanUpdate(e),
      onPanEnd: (e) => onPanUp(),
      onPanCancel: () => onPanUp(),
      child: Container(
        padding: widget.padding,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: widget.height,
            width: widget.width,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter, //指定未定位或部分定位widget的对齐方式
            children: <Widget>[
              DecoratedBox(
                key: _railKey,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.1),
                  borderRadius: widget.rounded
                      ? BorderRadius.circular(widget.width / 2)
                      : BorderRadius.circular(widget.radius),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: widget.height,
                    width: widget.width,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: widget.rounded
                    ? BorderRadius.circular(widget.width / 2)
                    : BorderRadius.circular(widget.radius),
                child: Container(
                  color: const Color.fromRGBO(255, 255, 255, 0.1),
                  height: widget.height,
                  width: widget.width,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: widget.disabled ? disableColor : activeColor),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                        height: activeRailHeight,
                        width: widget.width,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 值计算
  // 获取当前圆点的滑动条颜色
  List<Color> get activeColor {
    Color leftColor = widget.activeColors[0];
    Color rightColor = widget.activeColors[1];
    int curRed = ((rightColor.red - leftColor.red) * valueToPercentage(value) +
            leftColor.red)
        .round();
    int curGreen =
        ((rightColor.green - leftColor.green) * valueToPercentage(value) +
                leftColor.green)
            .round();
    int curBlue =
        ((rightColor.blue - leftColor.blue) * valueToPercentage(value) +
                leftColor.blue)
            .round();
    int curAlpha =
        ((rightColor.alpha - leftColor.alpha) * valueToPercentage(value) +
                leftColor.alpha)
            .round();
    return [
      widget.activeColors[0],
      Color.fromARGB(curAlpha, curRed, curGreen, curBlue)
    ];
  }

  // 获取当前圆点的滑动条颜色
  List<Color> get disableColor {
    Color leftColor = const Color(0xFF8F8F8F);
    Color rightColor = const Color(0xFF8F8F8F);
    int curRed = ((rightColor.red - leftColor.red) * valueToPercentage(value) +
            leftColor.red)
        .round();
    int curGreen =
        ((rightColor.green - leftColor.green) * valueToPercentage(value) +
                leftColor.green)
            .round();
    int curBlue =
        ((rightColor.blue - leftColor.blue) * valueToPercentage(value) +
                leftColor.blue)
            .round();
    int curAlpha =
        ((rightColor.alpha - leftColor.alpha) * valueToPercentage(value) +
                leftColor.alpha)
            .round();
    return [
      const Color(0xFF8F8F8F),
      Color.fromARGB(curAlpha, curRed, curGreen, curBlue)
    ];
  }

  // 获取激活部分滑动条高度
  double get activeRailHeight {
    if (widget.height +
            valueToPercentage(value) * (widget.width - widget.height) <
        0) {
      logger.i('错误原因', {
        widget.height,
        widget.width,
        value,
        widget.max,
        widget.min,
        valueToPercentage(value)
      });
    }
    return valueToPercentage(value) * (widget.height);
  }

  num clampValue(num value) {
    return min(widget.max, max(widget.min, value));
  }

  num valueToPercentage(num value) {
    if (value - widget.min < 0) {
      return 0;
    }
    return (value - widget.min) / (widget.max - widget.min);
  }

  num percentageToValue(num percentage) {
    return widget.min + (widget.max - widget.min) * percentage;
  }

  int get precision {
    var stepString = widget.step.toString();
    if (!stepString.contains('.')) {
      return 0;
    } else {
      return stepString.length - stepString.indexOf('.') - 1;
    }
  }

  num steppingValue(num nextValue) {
    if (widget.step <= 0) return nextValue;
    final currentStep =
        num.parse((nextValue / widget.step).toStringAsFixed(precision));
    final leftStep = num.parse(
        (currentStep.floor() * widget.step).toStringAsFixed(precision));
    final rightStep = num.parse(
        ((currentStep.floor() + 1) * widget.step).toStringAsFixed(precision));
    final closestStep =
        (nextValue - leftStep).abs() - (nextValue - rightStep).abs() > 0
            ? rightStep
            : leftStep;
    return closestStep;
  }

  // 执行动画（如果不存在duration则没有动画过程）
  void doAnimation(num newValue, num oldValue) {
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
      Animation<num> animation =
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

  /// 事件处理
  void onPanDown(DragDownDetails e) {
    if (widget.disabled) return;
    RenderBox railRenderObject =
        _railKey.currentContext?.findRenderObject() as RenderBox;
    final percentage = ((railRenderObject.paintBounds.height -
            railRenderObject.globalToLocal(latestPosition).dy) /
        railRenderObject.paintBounds.height);
    latestPosition = e.globalPosition;
    isPanning = true;
    isPanUpdate = false;
    toValue = clampValue(steppingValue(percentageToValue(percentage)));
    doAnimation(toValue, value);
  }

  void onPanUpdate(DragUpdateDetails e) {
    if (widget.disabled) return;
    isPanUpdate = true;
    latestPosition = e.globalPosition;
    //用户手指滑动时，更新偏移，重新构建
    RenderBox railRenderObject =
        _railKey.currentContext?.findRenderObject() as RenderBox;
    final percentage = ((railRenderObject.paintBounds.height -
            railRenderObject.globalToLocal(latestPosition).dy) /
        railRenderObject.paintBounds.height);
    final percentageValue = percentageToValue(percentage);
    final emitValue = clampValue(steppingValue(percentageValue));
    setState(() {
      value = clampValue(percentageValue);
      toValue = clampValue(percentageValue);
    });
    widget.onChanging?.call(emitValue, activeColor[1]);

    timeDrag = DateTime.now().millisecondsSinceEpoch;
    feedTimer ??= Timer.periodic(const Duration(milliseconds: 300), (timer) {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - timeDrag > 300) {
        feedTimer?.cancel();
        feedTimer = null;
        onPanUp();
      }
    });
  }

  void onPanUp() {
    if (widget.disabled) return;
    RenderBox railRenderObject =
        _railKey.currentContext?.findRenderObject() as RenderBox;
    final percentage = ((railRenderObject.paintBounds.height -
            railRenderObject.globalToLocal(latestPosition).dy) /
        railRenderObject.paintBounds.height);
    final temp = clampValue(steppingValue(percentageToValue(percentage)));
    isPanning = false;
    setState(() {
      value = temp;
      toValue = temp;
    });
    widget.onChanged?.call(toValue, activeColor[1]);

    feedTimer?.cancel();
    feedTimer = null;
  }
}
