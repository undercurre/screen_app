import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';

import '../common/logcat_helper.dart';

/// # MzSliderMarkDecoration 配置
const _MARK_ACTIVE_COLOR = Color(0xFFFFFFFF);
const _MARK_DISABLE_COLOR = Color(0xFFFFFFFF);
const _MARK_WIDTH = 3.0;
const _MARK_HEIGHT = 3.0;
const _MARK_PADDING = EdgeInsets.fromLTRB(10, 0, 10, 0);

/// # MzSlider 配置
const _SLIDER_ACTIVE_COLOR = [Color(0xFF267AFF), Color(0xFF267AFF)];
const _SLIDER_MAX = 100;
const _SLIDER_MIN = 0;
const _SLIDER_WIDTH = 390.0;
const _SLIDER_HEIGHT = 16.0;
const _SLIDER_ROUNDED = false;
const _SLIDER_RADIUS = 10.0;
const _SLIDER_BALL_RADIUS = 6.0;
const _SLIDER_STEP = 1;
const _SLIDER_DISABLED = false;
const _SLIDER_PADDING = EdgeInsets.all(20);
const _SLIDER_IS_BAR_COLOR_KEEF_FULL = false;
const _SLIDER_SEEKBAR_BG_COLOR = Color(0xFF000000);

/// MzSlider的装饰类
/// 封装思想：  组合【复合】
///    效果：  为滑条底部增加虚点
class MzSliderMarkDecoration extends StatelessWidget {
  final MzSlider slider;

  final Color markActiveColor;

  final Color markDisableColor;

  final double markWidth;

  final double markHeight;

  final EdgeInsetsGeometry padding;

  const MzSliderMarkDecoration({
    super.key,
    required this.slider,
    this.markActiveColor = _MARK_ACTIVE_COLOR,
    this.markDisableColor = _MARK_DISABLE_COLOR,
    this.markWidth = _MARK_WIDTH,
    this.markHeight = _MARK_HEIGHT,
    this.padding = _MARK_PADDING,
  });

  @override
  Widget build(BuildContext context) {
    final markList = <Widget>[];
    for (num i = 0; i < slider.max - slider.min + 1; i += slider.step) {
      markList.add(
        Container(
          width: markWidth,
          height: markHeight,
          color: slider.disabled ? markDisableColor : markActiveColor,
        ),
      );
    }
    return Column(
      children: [
        slider,
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: slider.width,
            height: slider.height,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [...markList],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MzSlider extends StatefulWidget {
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

  // 滑动条底部颜色
  final Color seekbarBgColor;

  // 滑动回调，传递出进度值和当前颜色
  final void Function(num value, Color activeColor)? onChanging;
  final void Function(num value, Color activeColor)? onChanged;

  // 插槽
  // final Widget child;

  // 动画时长，不传表示不执行动画
  final Duration? duration;

  // 组件内边距，用于拓展手势区域，提高用户体验
  final EdgeInsetsGeometry padding;

  // 滑条颜色是否一直填满
  final bool isBarColorKeepFull;

  const MzSlider(
      {super.key,
      required this.value,
      this.duration,
      this.onChanged,
      this.onChanging,
      this.activeColors = _SLIDER_ACTIVE_COLOR,
      this.max = _SLIDER_MAX,
      this.min = _SLIDER_MIN,
      this.width = _SLIDER_WIDTH,
      this.height = _SLIDER_HEIGHT,
      this.rounded = _SLIDER_ROUNDED,
      this.radius = _SLIDER_RADIUS,
      this.ballRadius = _SLIDER_BALL_RADIUS,
      this.step = _SLIDER_STEP,
      this.disabled = _SLIDER_DISABLED,
      this.padding = _SLIDER_PADDING,
      this.isBarColorKeepFull = _SLIDER_IS_BAR_COLOR_KEEF_FULL,
      this.seekbarBgColor = _SLIDER_SEEKBAR_BG_COLOR});

  static MzSliderMarkDecoration createDottedLineSlider(
      {Key? key,
      required num value,
      Duration? duration,
      void Function(num, Color)? onChanged,
      void Function(num, Color)? onChanging,
      Color? seekbarBgColor,
      List<Color>? activeColors,
      bool? isBarColorKeepFull,
      EdgeInsetsGeometry? padding,
      bool? disabled,
      num? step,
      double? ballRadius,
      bool? rounded,
      double? radius,
      num? max,
      num? min,
      double? width,
      double? height,
      Color? markActiveColor,
      Color? markDisableColor,
      double? markWidth,
      double? markHeight}) {

    var slider = MzSlider(
      key: key,
      value: value,
      duration: duration,
      onChanged: onChanged,
      onChanging: onChanging,
      activeColors: activeColors ?? _SLIDER_ACTIVE_COLOR,
      max: max ?? _SLIDER_MAX,
      min: min ?? _SLIDER_MIN,
      width: width ?? _SLIDER_WIDTH,
      height: height ?? _SLIDER_HEIGHT,
      rounded: rounded ?? _SLIDER_ROUNDED,
      radius: radius ?? _SLIDER_RADIUS,
      ballRadius: ballRadius ?? _SLIDER_BALL_RADIUS,
      step: step ?? _SLIDER_STEP,
      disabled: disabled ?? _SLIDER_DISABLED,
      padding: padding ?? _SLIDER_PADDING,
      isBarColorKeepFull: isBarColorKeepFull ?? _SLIDER_IS_BAR_COLOR_KEEF_FULL,
      seekbarBgColor: seekbarBgColor ?? _SLIDER_SEEKBAR_BG_COLOR,
    );

    return MzSliderMarkDecoration(
      markActiveColor: markActiveColor ?? _MARK_ACTIVE_COLOR,
      markDisableColor: markDisableColor ?? _MARK_DISABLE_COLOR,
      markWidth: markWidth ?? _MARK_WIDTH,
      markHeight: markHeight ?? _MARK_HEIGHT,
      slider: slider,
    );

  }

  @override
  State<MzSlider> createState() => _MzSliderState();
}

class _MzSliderState extends State<MzSlider> with TickerProviderStateMixin {
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
  late Offset latestPosition;

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
  void didUpdateWidget(MzSlider oldWidget) {
    if (isPanning) return;
    if (controller != null && controller!.status == AnimationStatus.forward) {
      return;
    }

    if (oldWidget.value == widget.value) return;
    var oldValue = value;
    var newValue = clampValue(widget.value);
    super.didUpdateWidget(oldWidget);
    doAnimation(newValue, oldValue);
  }

  @override
  void dispose() {
    if (controller?.status == AnimationStatus.forward) {
      controller!.stop();
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (e) => onPanDown(e),
      //手指滑动时会触发此回调
      onHorizontalDragUpdate: (e) => onPanUpdate(e),
      onHorizontalDragEnd: (e) => onPanUp(),
      onHorizontalDragCancel: () => onPanUp(),
      onTap: () => onPanUp(),
      child: Container(
        padding: widget.padding,
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
                key: _railKey,
                decoration: BoxDecoration(
                  color: widget.seekbarBgColor,
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
                  gradient: LinearGradient(
                      colors: widget.disabled
                          ? disableColor
                          : widget.isBarColorKeepFull
                              ? widget.activeColors
                              : activeColor),
                  borderRadius: widget.rounded
                      ? BorderRadius.circular(widget.height / 2)
                      : BorderRadius.circular(widget.radius),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: widget.height,
                    width: widget.isBarColorKeepFull
                        ? widget.width
                        : activeRailWidth,
                  ),
                ),
              ),
              Positioned(
                left: ballLeft,
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
    Color leftColor = const Color(0xFF515151);
    Color rightColor = const Color(0xFF515151);
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
      const Color(0xFF515151),
      Color.fromARGB(curAlpha, curRed, curGreen, curBlue)
    ];
  }

  // 获取白色圆点的left距离
  double get ballLeft {
    return widget.height -
        ((widget.height - widget.ballRadius * 2) / 2 + widget.ballRadius * 2) +
        valueToPercentage(value) * (widget.width - widget.height);
  }

  // 获取激活部分滑动条长度
  double get activeRailWidth {
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
    return widget.height +
        valueToPercentage(value) * (widget.width - widget.height);
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
    RenderBox railRenderObject = _railKey.currentContext?.findRenderObject() as RenderBox;
    final percentage = (railRenderObject.globalToLocal(e.globalPosition).dx / railRenderObject.paintBounds.width);
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
    RenderBox railRenderObject = _railKey.currentContext?.findRenderObject() as RenderBox;
    final percentage = (railRenderObject.globalToLocal(latestPosition).dx / railRenderObject.paintBounds.width);
    final percentageValue = percentageToValue(percentage);
    final emitValue = clampValue(steppingValue(percentageValue));
    setState(() {
      value = clampValue(percentageValue);
      toValue = clampValue(percentageValue);
    });
    widget.onChanging?.call(emitValue, activeColor[1]);
    timeDrag = DateTime.now().millisecondsSinceEpoch;
    if (feedTimer?.isActive == false) {
      feedTimer?.cancel();
      feedTimer = null;
    }
    feedTimer ??= Timer(const Duration(milliseconds: 2000), () {
      Log.i("End Time");
      feedTimer?.cancel();
      feedTimer = null;
      RenderBox _railRenderObject = _railKey.currentContext?.findRenderObject() as RenderBox;
      final _percentage = (railRenderObject.globalToLocal(latestPosition).dx / _railRenderObject.paintBounds.width);
      final _temp = clampValue(steppingValue(percentageToValue(_percentage)));
      widget.onChanged?.call(_temp, activeColor[1]);
    });
  }

  void onPanUp() {
    if (widget.disabled) return;
    RenderBox railRenderObject = _railKey.currentContext?.findRenderObject() as RenderBox;
    final percentage = (railRenderObject.globalToLocal(latestPosition).dx / railRenderObject.paintBounds.width);
    final temp = clampValue(steppingValue(percentageToValue(percentage)));
    isPanning = false;
    feedTimer?.cancel();
    feedTimer = null;
    setState(() {
      value = temp;
      toValue = temp;
      widget.onChanged?.call(toValue, activeColor[1]);
    });
  }

}
