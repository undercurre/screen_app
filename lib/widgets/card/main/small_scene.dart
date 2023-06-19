import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class SmallSceneCardWidget extends StatefulWidget {
  final String name;
  final Widget icon;
  final bool onOff;
  final Function? onTap;

  const SmallSceneCardWidget(
      {super.key,
      required this.name,
      required this.icon,
      required this.onOff,
      this.onTap});

  @override
  _SmallSceneCardWidgetState createState() => _SmallSceneCardWidgetState();
}

class _SmallSceneCardWidgetState extends State<SmallSceneCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 210,
        height: 88,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: widget.onOff
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF767B86),
                    Color(0xFF88909F),
                    Color(0xFF516375),
                  ],
                  stops: [0, 0.24, 1],
                  transform: GradientRotation(194 * (3.1415926 / 360.0)),
                ),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x33616A76),
                    Color(0x33434852),
                  ],
                  stops: [0.06, 1.0],
                  transform: GradientRotation(213 * (3.1415926 / 360.0)),
                ),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.32),
                  width: 0.6,
                ),
              ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              child: widget.icon,
            ),
            Text(
              widget.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }
}
