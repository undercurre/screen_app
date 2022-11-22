import 'package:flutter/material.dart';

class MzMetalCard extends StatelessWidget {
  final double width;
  final Widget child;

  const MzMetalCard({super.key, this.width = 312, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(width: 0.2, color: const Color(0xff979797)),
        gradient: const LinearGradient(
          begin: Alignment(-1, 1), //右上
          end: Alignment(0, 0.365), //左下
          stops: [0.0, 1.0], //[渐变起始点, 渐变结束点]
          colors: [Color(0xFF393E43), Color(0xFF333135)],
        ),
      ),
      child: child,
    );
  }
}
