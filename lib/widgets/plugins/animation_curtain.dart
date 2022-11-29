import 'package:flutter/material.dart';

class AnimationCurtain extends StatefulWidget {
  final num brightness;
  final num? colorTemperature;

  const AnimationCurtain({super.key, required this.brightness, this.colorTemperature});

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
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        const Positioned(
          left: -24,
          top: 98,
          child: Image(
            height: 208,
            width: 160,
            image: AssetImage("assets/imgs/plugins/0x14/c-01.png"),
          ),
        ),
        const Positioned(
          left: -24,
          top: 96,
          child: Image(
            height: 224,
            width: 48,
            image: AssetImage("assets/imgs/plugins/0x14/c-02.png"),
          ),
        ),
        const Positioned(
          left: 96,
          top: 96,
          child: Image(
            height: 224,
            width: 48,
            image: AssetImage("assets/imgs/plugins/0x14/c-02.png"),
          ),
        ),
      ],
    );
  }
}
