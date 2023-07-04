import 'package:flutter/material.dart';

class AnimationCurtain extends StatefulWidget {
  final num position;

  const AnimationCurtain({super.key, required this.position});

  @override
  State<AnimationCurtain> createState() => _AnimationCurtainState();
}

class _AnimationCurtainState extends State<AnimationCurtain> {
  Color decorationColor = Colors.blue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const curtainWidth = 80.0;

    return Stack(
      children: [
        SizedBox(
          width: 174,
          height: MediaQuery.of(context).size.height,
        ),

        // 光线
        Positioned(left: 0, top: 300, child: AnimatedClip(pos: widget.position)),

        // 窗
        const Positioned(
          left: 0,
          top: 98,
          child: Image(
            height: 205,
            width: 160,
            image: AssetImage("assets/imgs/plugins/0x14/c-01.png"),
          ),
        ),

        // 左窗帘
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          top: 96,
          left: -widget.position * 0.8,
          child: const Image(
            height: 218,
            width: curtainWidth,
            image: AssetImage("assets/imgs/plugins/0x14/c-02.png"),
          ),
        ),

        // 右窗帘
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          top: 96,
          left: 159 - curtainWidth + widget.position * 0.8, // 向左1像素
          child: const Image(
            height: 218,
            width: curtainWidth,
            image: AssetImage("assets/imgs/plugins/0x14/c-02.png"),
          ),
        ),

      ],
    );
  }
}

class AnimatedClip extends StatefulWidget {
  final num pos;
  final Duration duration;
  final Curve curve;

  const AnimatedClip(
      {super.key,
      this.pos = 0,
      this.duration = const Duration(milliseconds: 400),
      this.curve = Curves.linear});

  @override
  State<AnimatedClip> createState() => _AnimatedClipState();
}

class _AnimatedClipState extends State<AnimatedClip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Tween<double> _tween;

  void _updateCurve() {
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _tween = Tween(begin: widget.pos.toDouble());
    _updateCurve();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_animation.value: ${_animation.value}');

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipPath(
          clipper: Trapezoid(pos: _tween.animate(_animation).value),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 136,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                colors: [Color(0x807D8D9B), Color(0x00D8D8D8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ))),
        );
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedClip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.curve != oldWidget.curve) _updateCurve();

    _controller.duration = widget.duration;

    //正在执行过渡动画
    if (widget.pos != (_tween.end ?? _tween.begin)) {
      debugPrint('_tween.evaluate(_animation): ${_tween.evaluate(_animation)}');

      _tween
        ..begin = _tween.evaluate(_animation)
        ..end = widget.pos.toDouble();

      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 多边形路径
class Trapezoid extends CustomClipper<Path> {
  final num pos;

  Trapezoid({required this.pos});

  @override
  Path getClip(Size size) {
    const curtainWidth = 80.0;
    double wp = 0.8 * pos; // 光线单边变化

    var height = 136.0;
    var leftEnd = curtainWidth - wp;
    var rightEnd = curtainWidth + wp;
    var leftEnd2 = leftEnd + 140;
    var rightEnd2 = rightEnd + 400;
    Path path = Path();

    if (leftEnd < rightEnd - 3) {
      path.moveTo(leftEnd, 0); // 起点
      path.lineTo(rightEnd, 0);
      path.lineTo(rightEnd2, height);
      path.lineTo(leftEnd2, height);
    }

    path.close(); // 使这些点构成封闭的多边形
    return path;
  }

  @override
  bool shouldReclip(Trapezoid oldClipper) => pos != oldClipper.pos;
}

// 暂时不需要
class Square extends CustomClipper<Path> {
  final double width;
  final double height;

  Square({this.width = 80, this.height = 218});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // 起点
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close(); // 使这些点构成封闭的多边形
    return path;
  }

  @override
  bool shouldReclip(Trapezoid oldClipper) => false;
}
