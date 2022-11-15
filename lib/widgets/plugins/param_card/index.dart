import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/glass_card/index.dart';
import 'package:screen_app/widgets/plugins/gradient_slider/index.dart';

class ParamCard extends StatefulWidget {
  final List<Color> activeColors;
  final String title;
  final num value;
  final String unit;
  final void Function(num value, Color activeColor)? onChanging;
  final void Function(num value, Color activeColor)? onChanged;

  const ParamCard({
    super.key,
    required this.title,
    required this.value,
    this.activeColors = const [Color(0xFF267AFF), Color(0xFF267AFF)],
    this.unit = '%',
    this.onChanging,
    this.onChanged,
  });

  @override
  State<ParamCard> createState() => _ParamCardState();
}

class _ParamCardState extends State<ParamCard> {
  late num value;
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
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 23, 0),
                child: Row(
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
                        fontWeight: FontWeight.w100,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              GradientSlider(
                value: value,
                activeColors: widget.activeColors,
                duration: const Duration(milliseconds: 100),
                onChanged: widget.onChanged,
                onChanging: widget.onChanging
              ),
            ],
          ),
          const Positioned(
            left: 21,
            bottom: 11,
            child: Text(
              '0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(127, 255, 255, 255),
                fontFamily: "MideaType-Regular",
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const Positioned(
            right: 21,
            bottom: 11,
            child: Text(
              '100%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(127, 255, 255, 255),
                fontFamily: "MideaType-Regular",
                decoration: TextDecoration.none,
              ),
            ),
          )
        ],
      ),
    );
  }
}
