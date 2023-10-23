import 'package:flutter/material.dart';

class MzMetalCard extends StatelessWidget {
  final double width;
  final Widget child;

  const MzMetalCard({super.key, this.width = 312, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0x19FFFFFF)
      ),
      child: child,
    );
  }
}
