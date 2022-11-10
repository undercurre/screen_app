import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/GlassCard/index.dart';
import 'package:screen_app/widgets/plugins/GradientSlider/index.dart';
import 'dart:math';

class ParamCard extends StatefulWidget {
  final String title;
  final double value;
  final String unit;

  const ParamCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = '%',
  });

  @override
  State<ParamCard> createState() => _ParamCardState();
}

class _ParamCardState extends State<ParamCard> {
  late double value;
  late String title;
  late String unit;

  @override
  void initState() {
    super.initState();
    value = widget.value;
    title = widget.title;
    unit = widget.unit;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '$title | ',
                    style: const TextStyle(
                      fontFamily: "MideaType",
                      fontSize: 18,
                      height: 1.2,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    '${value.toInt()}$unit',
                    style: const TextStyle(
                      fontFamily: "MideaType",
                      fontSize: 18,
                      height: 1.2,
                      color: Color(0x80FFFFFF),
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              GradientSlider(value: value)
            ],
          )),
    );
  }
}
