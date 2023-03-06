import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';
import 'package:screen_app/widgets/mz_slider.dart';

class GearCard extends StatefulWidget {
  final num minGear;
  final num maxGear;
  final num value;
  final String title;
  final bool disabled;
  final Duration? duration;
  final void Function(num value)? onChanged;

  const GearCard({
    super.key,
    this.value = 3,
    this.maxGear = 6,
    this.minGear = 1,
    this.disabled = false,
    this.title = '风速',
    this.onChanged,
    this.duration,
  });

  @override
  State<StatefulWidget> createState() => _GearCardState();
}

class _GearCardState extends State<GearCard> {
  late num value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setState(() {
      value = widget.value;
    });
  }

  @override
  void didUpdateWidget(covariant GearCard oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    setState(() {
      value = widget.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final markList = <Widget>[];
    for (int i = 0; i < widget.maxGear - widget.minGear + 1; i++) {
      markList.add(
        Container(
          width: 2,
          height: 2,
          color: const Color(0x77d8d8d8),
        ),
      );
    }
    return MzMetalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'MideaType-Light',
                    fontWeight: FontWeight.w200,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '$value档',
                  style: const TextStyle(
                    color: Color(0x77ffffff),
                    fontSize: 18,
                    fontFamily: 'MideaType-Light',
                    fontWeight: FontWeight.w200,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              MzSlider(
                value: value,
                width: 270,
                max: widget.maxGear,
                min: widget.minGear,
                disabled: widget.disabled,
                step: 1,
                duration: widget.duration ?? const Duration(milliseconds: 100),
                onChanging: (e, _) => setState(() {
                  value = e;
                  // widget.onChanged?.call(value);
                }),
                onChanged: (e, _) => setState(() {
                  value = e;
                  widget.onChanged?.call(value);
                }),
              ),
              Positioned(
                left: 25,
                bottom: 10,
                right: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [...markList],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
