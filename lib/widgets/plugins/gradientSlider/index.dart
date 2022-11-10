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
  final void Function(double value)? onChanging;
  final void Function(double value)? onChanged;

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
    this.width = 258,
    this.height = 20,
    this.radius = true,
  });

  @override
  State<GradientSlider> createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider>
    with TickerProviderStateMixin {
  late double value;
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
    var oldValue = oldWidget.value < 0 ? 0.0 : oldWidget.value > 100 ? 100.0 : oldWidget.value;
    var newValue = widget.value < 0 ? 0.0 : widget.value > 100 ? 100.0 : widget.value;
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
        padding: const EdgeInsets.all(20.0),
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

  // 执行动画（如果不存在duration则没有动画过程）
  void doAnimation(double newValue, double oldValue) {
    if (widget.duration != null) {
      // 传入动画执行时间，需要执行动画
      AnimationController controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      CurvedAnimation curve =
      CurvedAnimation(parent: controller, curve: Curves.easeInOut);
      Animation<double> animation =
      Tween(begin: oldValue, end: newValue).animate(curve);
      animation.addListener(() {
        setState(() {
          value = animation.value;
        });
      });
      controller.forward();
    } else {
      setState(() {
        value = newValue;
      });
    }
  }

  void onPanDown(DragDownDetails e) {
    isPanning = true;
    isPanUpdate = false;
    double temp = (e.localPosition.dx - 20 - 10) / (widget.width - 20) * 100;
    if (temp > 100) {
      temp = 100;
    } else if (temp < 0) {
      temp = 0;
    }
    doAnimation(temp, value);
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
    });
    widget.onChanging?.call(value);
  }

  void onPanUp() {
    isPanning = false;
    widget.onChanged?.call(value);
  }
}
