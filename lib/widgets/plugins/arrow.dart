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

    /// 不设置重复，使用代码控制进度，动画时间1秒
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
    return Stack(children: [
      const SizedBox(
        width: 100,
        height: 100,
      ),
      Positioned(
        top: -15,
        left: -15,
        child: RotationTransition(
          turns: _manualAnimation,
          child: CupertinoButton(
            onPressed: () {
              /// 获取动画当前的值
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
      )
    ]);
  }
}
