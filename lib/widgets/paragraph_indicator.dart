import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ParagraphIndicator extends StatefulWidget {
  final int itemCount;
  final int defaultPosition;

  const ParagraphIndicator(
      {super.key, required this.defaultPosition, required this.itemCount});

  @override
  State<ParagraphIndicator> createState() => ParagraphIndicatorState();
}

class ParagraphIndicatorState extends State<ParagraphIndicator> {
  late int position;

  @override
  void initState() {
    super.initState();
    position = widget.defaultPosition;
  }

  void updateIndicator(int position) {
    setState(() {
      this.position = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < widget.itemCount; i++)
            Container(
              width: i == position ? 22 : 14,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: i == position
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
            ),
        ],
      );
    });
  }
}
