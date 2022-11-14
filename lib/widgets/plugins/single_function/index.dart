import 'dart:core';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/glass_card/index.dart';

import '../../../common/device_mode/mode.dart';

class SingleFunction extends StatefulWidget {
  final String title;
  final String desc;
  final Widget child;
  final bool power;

  const SingleFunction(
      {super.key,
      required this.title,
      required this.desc,
      required this.child,
      required this.power});

  @override
  State<SingleFunction> createState() => _SingleFunctionState();
}

class _SingleFunctionState extends State<SingleFunction> {
  late String title;
  late String desc;
  late Widget child;
  late bool power;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    desc = widget.desc;
    child = widget.child;
    power = widget.power;
  }

  void onClick() {
    setState(() {
      power = !power;
    });
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
                  '$title | ',
                  style: const TextStyle(
                      fontFamily: 'MEIDITYPE-REGULAR',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Color(0xFFFFFFFF),
                      decoration: TextDecoration.none),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                      fontFamily: 'MEIDITYPE-REGULAR',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0x7AFFFFFF),
                      decoration: TextDecoration.none),
                )
              ],
            ),
            child
          ],
        ),
      ),
    );

    throw UnimplementedError();
  }
}
