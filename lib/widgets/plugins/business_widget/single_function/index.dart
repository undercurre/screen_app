import 'dart:core';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/base_widget/glass_card/index.dart';

class SingleFunction extends StatefulWidget {
  final String title;
  final String desc;
  final Widget child;

  const SingleFunction({
    super.key,
    required this.title,
    required this.desc,
    required this.child,
  });

  @override
  State<SingleFunction> createState() => _SingleFunctionState();
}

class _SingleFunctionState extends State<SingleFunction> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GlassCard(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 19, 16),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${widget.title} | ',
                  style: const TextStyle(
                      fontFamily: 'MEIDITYPE-REGULAR',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Color(0xFFFFFFFF),
                      decoration: TextDecoration.none),
                ),
                Text(
                  widget.desc,
                  style: const TextStyle(
                      fontFamily: 'MEIDITYPE-REGULAR',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0x7AFFFFFF),
                      decoration: TextDecoration.none),
                )
              ],
            ),
            widget.child
          ],
        ),
      ),
    );
  }
}
