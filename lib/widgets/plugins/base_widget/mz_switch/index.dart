import 'package:flutter/material.dart';

class MzSwitch extends StatefulWidget {
  final bool value; // 开关状态
  final bool disabled; // 是否允许操作
  final Color activeColor; // 滑轨未激活底色
  final Color inactiveColor; // 滑轨激活底色
  final Color pointActiveColor; // 圆球未激活底色
  final Color pointInactiveColor; // 圆圈激活底色
  final Duration duration; // 开关状态切换时间
  final void Function(bool value)? onTap; // 点击开关回调

  const MzSwitch({
    super.key,
    this.value = false,
    this.disabled = false,
    this.activeColor = const Color(0xff0091ff),
    this.inactiveColor = const Color(0xff3e3e3e),
    this.pointActiveColor = const Color(0xffffffff),
    this.pointInactiveColor = const Color(0xff949494),
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
  late double pointLeft; // 圆点left偏移值
  AnimationController? railController; // 轨道动画控制器
  AnimationController? pointController; // 圆点动画控制器

  @override
  void initState() {
    super.initState();
    value = widget.value;
    railBgc = widget.value ? widget.activeColor : widget.inactiveColor;
    pointBgc =
        widget.value ? widget.pointActiveColor : widget.pointInactiveColor;
    pointLeft = widget.value ? 2 : 29;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call(!value);
      },
      child: Stack(
        children: [
          Container(
            width: 54,
            height: 28,
            color: railBgc,
          ),
          Positioned(
            top: 3,
            left: pointLeft,
            child: Container(
              width: 22,
              height: 22,
              color: pointBgc,
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
    if (pointController?.status == AnimationStatus.forward) {
      pointController!.stop();
    }
    // 设置widget值
    value = widget.value;
    // 轨道变色动画
    final railEndColor = value ? widget.activeColor : widget.inactiveColor;
    railController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    CurvedAnimation railCurve =
    CurvedAnimation(parent: railController!, curve: Curves.easeInOut);
    Animation<Color> rainAnimation =
    Tween(begin: railBgc, end: railEndColor).animate(railCurve);
    rainAnimation.addListener(() {
      setState(() {
        railBgc = rainAnimation.value;
      });
    });
    railController!.forward();
    // 圆点变色动画
    final pointEndColor =
    value ? widget.pointActiveColor : widget.pointInactiveColor;
    pointController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    CurvedAnimation pointCurve =
    CurvedAnimation(parent: pointController!, curve: Curves.easeInOut);
    Animation<Color> pointAnimation =
    Tween(begin: pointBgc, end: pointEndColor).animate(pointCurve);
    pointAnimation.addListener(() {
      setState(() {
        railBgc = pointAnimation.value;
      });
    });
    pointController!.forward();
  }
}
