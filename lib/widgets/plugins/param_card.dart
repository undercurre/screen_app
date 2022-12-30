import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';
import 'package:screen_app/widgets/mz_slider.dart';
import 'package:screen_app/mixins/throttle.dart';

// 普通的带滑动条卡片
class ParamCard extends StatefulWidget {
  final List<Color> activeColors;
  final String title;
  final num value;
  final String unit;
  final Duration throttle; // 节流控制onChanging触发
  final bool disabled;
  final Duration? duration;
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
    this.disabled = false,
    this.throttle = const Duration(seconds: 1),
    this.duration,
  });

  @override
  State<ParamCard> createState() => _ParamCardState();
}

class _ParamCardState extends State<ParamCard> with Throttle {
  late String title;
  late String unit;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    unit = widget.unit;
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
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
                        '${widget.value.toInt()}$unit',
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
                MzSlider(
                  width: 270,
                  value: widget.value,
                  activeColors: widget.activeColors,
                  disabled: widget.disabled,
                  duration: widget.duration,
                  onChanged: widget.onChanged,
                  onChanging: onChanging,
                ),
              ],
            ),
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

  // 使用节流
  void onChanging(num value, Color activeColor) {
    if (widget.onChanging != null) {
      throttle(() {
        widget.onChanging!(value, activeColor);
      }, durationTime: widget.throttle);
    }
  }
}
