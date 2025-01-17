import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';
import 'package:screen_app/widgets/mz_slider.dart';

// 普通的带滑动条卡片
class ParamCard extends StatefulWidget {
  final maxValue;
  final minValue;
  final List<Color> activeColors;
  final String title;
  final num value;
  final String unit;
  final Duration throttle; // 节流控制onChanging触发
  final bool disabled;
  final Duration? duration;
  final num customMin;
  final num customMax;
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
    this.maxValue = 100,
    this.minValue = 0,
    this.throttle = const Duration(milliseconds: 800),
    this.duration,
    this.customMin = 0,
    this.customMax = 0,
  });

  @override
  State<ParamCard> createState() => _ParamCardState();
}

class _ParamCardState extends State<ParamCard> with Throttle {
  late String title;
  late String unit;
  late num localValue;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    unit = widget.unit;
    localValue = widget.value;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setState(() {
      localValue = widget.value;
    });
  }

  @override
  void didUpdateWidget(covariant ParamCard oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      logger.i('widget更新', widget.value);
      setState(() {
        localValue = widget.value;
      });
    }
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
                        '${customValue(localValue)}$unit',
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
                ),
                MzSlider(
                  min: widget.minValue,
                  max: widget.maxValue,
                  width: 270,
                  value: localValue,
                  activeColors: widget.activeColors,
                  disabled: widget.disabled,
                  duration: widget.duration,
                  onChanged: onChanged,
                  onChanging: onChanging,
                ),
              ],
            ),
          ),
          Positioned(
            left: 21,
            bottom: 11,
            child: Text(
              '${widget.customMin < widget.customMax ? widget.customMin : widget.minValue}$unit',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(127, 255, 255, 255),
                fontFamily: "MideaType-Regular",
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Positioned(
            right: 21,
            bottom: 11,
            child: Text(
              '${widget.customMin < widget.customMax ? widget.customMax : widget.maxValue}$unit',
              style: const TextStyle(
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

  int customValue(num val) {
    if(widget.customMin < widget.customMax) {
      num diff = widget.customMax - widget.customMin;
      return (diff * (val / 100) + widget.customMin).toInt();
    }
    return val.toInt();
  }

  void onChanged(num value, Color activeColor) {
    setState(() {
      localValue = value;
    });
    widget.onChanged!(localValue, activeColor);
  }

  // 使用节流
  void onChanging(num value, Color activeColor) {
    setState(() {
      localValue = value;
    });
    // if (widget.onChanging != null) {
    //   throttle(() {
    //     widget.onChanging!(localValue, activeColor);
    //   }, durationTime: widget.throttle);
    // }
  }
}
