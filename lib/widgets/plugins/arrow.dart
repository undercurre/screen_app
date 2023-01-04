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
    return Stack(children: const [
      SizedBox(
        width: 100,
        height: 100,
      ),
      Positioned(
        width: 100,
        height: 100,
        top: -5,
        left: -15,
          child: Image(
            image: AssetImage('assets/imgs/plugins/0xAC/arrow.png'),
          ),
        ),
    ]);
  }
}
