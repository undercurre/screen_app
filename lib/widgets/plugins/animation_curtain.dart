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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        // 光线
        // Clip(widget.position),
        Positioned(
            left: 0,
            top: 300,
            child: ClipPath(
              clipper: Trapezoid(pos: widget.position),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 136,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Color(0x807D8D9B), Color(0x00D8D8D8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ))),
            )),
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
        Positioned(
            left: 0,
            top: 100,
            child: CustomAnimated(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(color: decorationColor),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    decorationColor = Colors.red;
                  });
                },
                child: const Text(
                  "AnimatedDecoratedBox",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )),
      ],
    );
  }
}

class Clip extends StatefulWidget {
  final num pos;

  const Clip(this.pos, {super.key});

  @override
  State<Clip> createState() => _ClipState();
}

class _ClipState extends State<Clip> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<num> _animation;
  final num startPos = 50;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 400));
    _animation =
        Tween<num>(begin: startPos, end: widget.pos).animate(_controller);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, child) {
        return ClipPath(
          clipper: Trapezoid(pos: _animation.value),
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
      animation: _animation,
    );
  }
}

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

    if (leftEnd < rightEnd) {
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

///////

class CustomAnimated extends StatefulWidget {
  const CustomAnimated({
    Key? key,
    required this.decoration,
    required this.child,
    this.curve = Curves.linear,
    required this.duration,
    this.reverseDuration,
  }) : super(key: key);

  final BoxDecoration decoration;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration? reverseDuration;

  @override
  State<CustomAnimated> createState() => _CustomAnimatedState();
}

class _CustomAnimatedState extends State<CustomAnimated>
    with SingleTickerProviderStateMixin {
  @protected
  AnimationController get controller => _controller;
  late AnimationController _controller;

  Animation<double> get animation => _animation;
  late Animation<double> _animation;

  late DecorationTween _tween;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return DecoratedBox(
          decoration: _tween.animate(_animation).value,
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      vsync: this,
    );
    _tween = DecorationTween(begin: widget.decoration);
    _updateCurve();
  }

  void _updateCurve() {
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(CustomAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.curve != oldWidget.curve) _updateCurve();
    _controller.duration = widget.duration;
    _controller.reverseDuration = widget.reverseDuration;
    //正在执行过渡动画
    if (widget.decoration != (_tween.end ?? _tween.begin)) {
      _tween
        ..begin = _tween.evaluate(_animation)
        ..end = widget.decoration;

      _controller
        ..value = 0.0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
