import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedArrow extends StatefulWidget {
  const AnimatedArrow({super.key});

  @override
  State<AnimatedArrow> createState() => AnimatedArrowState();
}

class AnimatedArrowState extends State<AnimatedArrow>
    with TickerProviderStateMixin {
  /// 手动控制动画的控制器
  late final AnimationController _manualController;

  /// 手动控制
  late final Animation<double> _manualAnimation;

  @override
  void initState() {
    super.initState();

    /// 不设置重复，使用代码控制进度
    _manualController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 20),
    );
    _manualAnimation =
        Tween<double>(begin: 0, end: 1).animate(_manualController);
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(),
      Positioned(
        top: -16,
        left: -16,
        child: RotationTransition(
          turns: _manualAnimation,
          child: CupertinoButton(
            onPressed: () {
              var value = _manualController.value;

              /// 0.5代表 180弧度
              if (value == 0.5) {
                _manualController.animateTo(0);
              } else {
                _manualController.animateTo(0.5);
              }
            },
            child: const Image(
              image: AssetImage('assets/imgs/plugins/0xAC/arrow.png'),
            ),
          ),
        ),
      ),
    ]);
  }
}
