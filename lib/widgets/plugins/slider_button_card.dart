import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';
import 'package:screen_app/widgets/mz_slider.dart';

class SliderButtonCard extends StatefulWidget {
  final String? title;
  final String unit;
  final num min;
  final num max;
  final num value;
  final num step;
  final bool disabled;
  final Duration? duration;
  final void Function(num value)? onChanged;

  const SliderButtonCard({
    super.key,
    this.title,
    this.unit = '°C',
    this.value = 30,
    this.step = 1,
    this.max = 60,
    this.min = 10,
    this.disabled = false,
    this.duration,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _SliderButtonCardState();
}

class _SliderButtonCardState extends State<SliderButtonCard> {
  late num value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.title != null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 15),
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      fontFamily: "MideaType",
                      fontSize: 18,
                      height: 1.2,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.only(
                top: widget.title != null ? 5 : 30,
                bottom: widget.title != null ? 0 : 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      if (widget.disabled) return;
                      if (value - 1 > widget.min) {
                        value--;
                      } else {
                        value = widget.min;
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
                    const SizedBox(
                      width: 20,
                    ),
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
                    SizedBox(
                      width: 20,
                      child: Text(
                        widget.unit,
                        style: const TextStyle(
                          fontFamily: 'MideaType-Light',
                          fontSize: 18,
                          color: Color(0xff959595),
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                  ],
                ),
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      if (widget.disabled) return;
                      if (value + 1 < widget.max) {
                        value++;
                      } else {
                        value = widget.max;
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
          MzSlider(
            value: value,
            width: 270,
            max: widget.max,
            min: widget.min,
            step: widget.step,
            disabled: widget.disabled,
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
