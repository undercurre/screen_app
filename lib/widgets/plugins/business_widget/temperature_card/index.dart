import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/base_widget/glass_card/index.dart';
import 'package:screen_app/widgets/plugins/base_widget/gradient_slider/index.dart';

class TemperatureCard extends StatefulWidget {
  final num minTemperature;
  final num maxTemperature;
  final num value;
  final num step;
  final void Function(num value)? onChanged;
  final Duration? duration;

  const TemperatureCard({
    super.key,
    this.value = 30,
    this.step = 1,
    this.maxTemperature = 60,
    this.minTemperature = 10,
    this.onChanged,
    this.duration
  });

  @override
  State<StatefulWidget> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<TemperatureCard> {
  late num value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      if (value - 1 > widget.minTemperature) {
                        value--;
                      } else {
                        value = widget.minTemperature;
                      }
                      widget.onChanged?.call(value);
                    });
                  },
                  elevation: 2.0,
                  fillColor: const Color(0xffd8d8d8),
                  padding: const EdgeInsets.all(4.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.remove_rounded,
                    size: 28.0,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontFamily: 'MideaType-Light',
                        fontSize: 54,
                        height: 1,
                        color: Color(0xffd8d8d8),
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontFamily: 'MideaType-Light',
                        fontSize: 18,
                        color: Color(0xff959595),
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      if (value + 1 < widget.maxTemperature) {
                        value++;
                      } else {
                        value = widget.maxTemperature;
                      }
                      widget.onChanged?.call(value);
                    });
                  },
                  elevation: 2.0,
                  fillColor: const Color(0xffd8d8d8),
                  padding: const EdgeInsets.all(4.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 28.0,
                  ),
                ),
              ],
            ),
          ),
          GradientSlider(
            value: value,
            max: widget.maxTemperature,
            min: widget.minTemperature,
            step: widget.step,
            duration: widget.duration ?? const Duration(milliseconds: 100),
            onChanging: (e, _) => setState(() {
              value = e;
            }),
            onChanged: (e, _) => setState(() {
              value = e;
              widget.onChanged?.call(value);
            }),
          )
        ],
      ),
    );
  }
}
