import 'package:flutter/material.dart';

class MzSwitch extends StatefulWidget {
  final bool value; // 开关状态
  final bool disabled; // 是否禁止操作
  final Color activeColor; // 滑轨激活底色
  final Color inactiveColor; // 滑轨未激活底色
  final Color pointActiveColor; // 圆球激活底色
  final Color pointInactiveColor; // 圆圈未激活底色
  final Color borderActiveColor; // 边框激活底色
  final Color borderInactiveColor; // 边框未激活底色
  final Duration duration; // 状态切换动画时间
  final void Function(bool value)? onTap; // 点击开关回调

  const MzSwitch({
    super.key,
    this.value = false,
    this.disabled = false,
    this.activeColor = const Color(0x333C92D6),
    this.inactiveColor = const Color(0x003e3e3e),
    this.pointActiveColor = const Color(0xff3C92D6),
    this.pointInactiveColor = const Color(0xff868990),
    this.borderActiveColor = const Color(0xff3C92D6),
    this.borderInactiveColor = const Color(0xff868990),
    this.duration = const Duration(milliseconds: 100),
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _MzSwitchState();
}

class _MzSwitchState extends State<MzSwitch> with TickerProviderStateMixin {
  late bool value;
  late Color railBgc; // 轨道颜色
  late Color pointBgc; // 圆点颜色
  late Color borderBgc; // 边框颜色
  late double pointLeft; // 圆点left偏移值
  AnimationController? railController; // 轨道动画控制器
  AnimationController? pointColorController; // 圆点颜色动画控制器
  AnimationController? pointMoveController; // 圆点移动动画控制器

  @override
  void initState() {
    super.initState();
    value = widget.value;
    railBgc = widget.value ? widget.activeColor : widget.inactiveColor;
    pointBgc =
    widget.value ? widget.pointActiveColor : widget.pointInactiveColor;
    pointLeft = widget.value ? 29 : 3;
    borderBgc = widget.value ? widget.borderActiveColor : widget.borderInactiveColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.disabled) return;
        widget.onTap?.call(!value);
      },
      child: Stack(
        children: [
          Container(
            width: 54,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              color: railBgc,
              border: Border.all(color: borderBgc, width: 1),
            ),
          ),
          Positioned(
            top: 3,
            left: pointLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                color: pointBgc,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(MzSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 执行动画顺便设置值
    if (widget.value == value) return;
    // 如果上一个动画在执行就先停止上一个动画
    if (railController?.status == AnimationStatus.forward) {
      railController!.stop();
    }
    if (pointColorController?.status == AnimationStatus.forward) {
      pointColorController!.stop();
    }
    if (pointMoveController?.status == AnimationStatus.forward) {
      pointMoveController!.stop();
    }
    // 设置widget值
    value = widget.value;
    borderBgc = widget.value ? widget.borderActiveColor : widget.borderInactiveColor;
    // 轨道变色动画
    final railEndColor = value ? widget.activeColor : widget.inactiveColor;
    railController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    CurvedAnimation railCurve =
    CurvedAnimation(parent: railController!, curve: Curves.easeInOut);
    Animation<Color?> rainAnimation =
    ColorTween(begin: railBgc, end: railEndColor).animate(railCurve);
    rainAnimation.addListener(() {
      setState(() {
        if (rainAnimation.value != null) {
          railBgc = rainAnimation.value!;
        }
      });
    });
    railController!.forward();
    // 圆点变色动画
    final pointEndColor =
    value ? widget.pointActiveColor : widget.pointInactiveColor;
    pointColorController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    CurvedAnimation pointCurve =
    CurvedAnimation(parent: pointColorController!, curve: Curves.easeInOut);
    Animation<Color?> pointAnimation =
    ColorTween(begin: pointBgc, end: pointEndColor).animate(pointCurve);
    pointAnimation.addListener(() {
      setState(() {
        if (rainAnimation.value != null) {
          pointBgc = pointAnimation.value!;
        }
      });
    });
    pointColorController!.forward();
    // 圆点移动
    final pointEndLeft = value ? 29.0 : 3.0;
    pointMoveController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    CurvedAnimation curve =
    CurvedAnimation(parent: pointMoveController!, curve: Curves.easeInOut);
    Animation<double> pointMoveAnimation =
    Tween(begin: pointLeft, end: pointEndLeft).animate(curve);
    pointMoveAnimation.addListener(() {
      setState(() {
        pointLeft = pointMoveAnimation.value;
      });
    });
    pointMoveController!.forward();
  }
}
