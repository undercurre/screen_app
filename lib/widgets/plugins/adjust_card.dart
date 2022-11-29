import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';
import 'package:screen_app/widgets/mz_slider.dart';
import 'package:screen_app/mixins/throttle.dart';

// 带+-调整的滑动条卡片
class AdjustCard extends StatefulWidget {
  final List<Color> activeColors;
  final num value;
  final String unit;
  final Duration throttle; // 节流控制onChanging触发
  final bool disabled;
  final Duration? duration;
  final void Function(num value, Color activeColor)? onChanging;
  final void Function(num value, Color activeColor)? onChanged;

  const AdjustCard({
    super.key,
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
  State<AdjustCard> createState() => _AdjustCardState();
}

class _AdjustCardState extends State<AdjustCard> with Throttle {
  late String unit;
  late num value;

  @override
  void initState() {
    super.initState();
    unit = widget.unit;
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    iconText: "-",
                    onTap: onTapMinus,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontFamily: "MideaType",
                            fontSize: 54,
                            height: 1,
                            color: Color(0x80FFFFFF),
                            fontWeight: FontWeight.w100,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontFamily: "MideaType",
                            fontSize: 14,
                            height: 1,
                            color: Color(0x80FFFFFF),
                            fontWeight: FontWeight.w100,
                            decoration: TextDecoration.none,
                          ),
                        )
                      ],
                    ),
                  ),
                  TextButton(
                    iconText: "+",
                    onTap: onTapAdd,
                  ),
                ],
              ),
            ),
            MzSlider(
              width: 270,
              value: value,
              activeColors: widget.activeColors,
              disabled: widget.disabled,
              duration: widget.duration,
              onChanged: widget.onChanged,
              onChanging: onChanging,
            ),
          ],
        ),
      ),
    );
  }

  // 点击按钮
  void onTapMinus() {
    setState(() {
      value = value <= 0 ? 0 : value - 1;
    });
  }
  void onTapAdd() {
    setState(() {
      value = value >= 100 ? 100 : value + 1;
    });
  }

  // 拖动滑动条
  void onChanging(num value, Color activeColor) {
    setState(() {
      this.value = value;
    });
    if (widget.onChanging != null) {
      throttle(() {
        widget.onChanging!(value, activeColor);
      }, durationTime: widget.throttle);
    }
  }
}

class TextButton extends StatelessWidget {
  final String iconText;
  final Function()? onTap;

  const TextButton({Key? key, this.iconText = '', this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xffd8d8d8),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          iconText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "MideaType",
            fontSize: 32,
            height: 1.2,
            color: Color(0xff000000),
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
