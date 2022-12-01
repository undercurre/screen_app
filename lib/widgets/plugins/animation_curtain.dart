import 'package:flutter/material.dart';

class AnimationCurtain extends StatefulWidget {
  final num position;

  const AnimationCurtain({super.key, required this.position});

  @override
  State<AnimationCurtain> createState() => _AnimationCurtainState();
}

class _AnimationCurtainState extends State<AnimationCurtain> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const offsetX = -16.0;
    const curtainWidth = 40.0;
    double wp = 0.8 * widget.position; // 光线单边变化值
    double scaleX = 1.87 - widget.position / 100; // 1.87 = 80/48 + (48/40-1)

    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        // 光线
        Positioned(
            left: offsetX,
            top: 300,
            child: ClipPath(
              clipper: Trapezoid(leftEnd: 80 - wp, rightEnd: 80 + wp),
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
          left: offsetX,
          top: 98,
          child: Image(
            height: 208,
            width: 160,
            image: AssetImage("assets/imgs/plugins/0x14/c-01.png"),
          ),
        ),
        // 左窗帘
        Positioned(
            left: offsetX,
            top: 96,
            child: Transform.scale(
              scaleX: scaleX,
              alignment: Alignment.centerLeft,
              child: const Image(
                height: 224,
                width: curtainWidth,
                image: AssetImage("assets/imgs/plugins/0x14/c-02.png"),
              ),
            )),
        // 右窗帘
        Positioned(
          left: 160 + offsetX - curtainWidth,
          top: 96,
          child: Transform.scale(
            scaleX: scaleX,
            alignment: Alignment.centerRight,
            child: const Image(
              height: 224,
              width: curtainWidth,
              image: AssetImage("assets/imgs/plugins/0x14/c-02.png"),
            ),
          ),
        ),
      ],
    );
  }
}

class Trapezoid extends CustomClipper<Path> {
  final double leftEnd;
  final double rightEnd;

  Trapezoid({required this.leftEnd, required this.rightEnd});

  @override
  Path getClip(Size size) {
    var height = 136.0;
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
  bool shouldReclip(Trapezoid oldClipper) =>
      leftEnd != oldClipper.leftEnd || rightEnd != oldClipper.rightEnd;
}
