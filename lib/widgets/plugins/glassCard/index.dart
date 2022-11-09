import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {

  final double width;
  final double height;

  Widget child;

  GlassCard({
    this.width = 312,
    this.height = 112,
    required this.child
  });

  @override
  Widget build(BuildContext context) {

    return Container(
        width: width,
        height: height,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: const LinearGradient(
              begin: Alignment(-1, 1), //右上
              end: Alignment(0, 0.365), //左下
              stops: [0.0, 1.0], //[渐变起始点, 渐变结束点]
              colors: [Color(0xFF393E43), Color(0xFF333135)]),
        ),
        child: child);
  }
}