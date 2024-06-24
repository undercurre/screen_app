import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_slider.dart';

class Gear485Card extends StatefulWidget {
  final num minGear;
  final num maxGear;
  final num value;
  final String title;
  final bool disabled;
  final Duration? duration;
  final void Function(num value)? onChanged;

  const Gear485Card({
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

class _GearCardState extends State<Gear485Card> {
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
  void didUpdateWidget(covariant Gear485Card oldWidget) {
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
          width: 3,
          height: 3,
          color: const Color(0xFFFFFFFF),
        ),
      );
    }
    return Container(
      width: 400,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0x00FFFFFF)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => {
                    widget.onChanged?.call(value > widget.minGear
                        ? value - 1
                        : widget.minGear),
                  },
                  child: IgnorePointer(
                    ignoring: widget.disabled,
                    child: Image(
                        color: Color.fromRGBO(
                            255, 255, 255, widget.disabled ? 0.7 : 1),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/sub.png')),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$value",
                        style: TextStyle(
                            height: 1.5,
                            color: !widget.disabled
                                ? const Color(0XFFFFFFFF)
                                : const Color(0XA3FFFFFF),
                            fontSize: 60,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)),
                    Padding( padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child:Text("档",
                            style: TextStyle(
                                height: 1.5,
                                color: !widget.disabled
                                    ? const Color(0XFFFFFFFF)
                                    : const Color(0XA3FFFFFF),
                                fontSize: 20,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),

                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => {
                    widget.onChanged?.call(value < widget.maxGear
                        ? value + 1
                        : widget.maxGear),
                  },
                  child: IgnorePointer(
                    ignoring: widget.disabled,
                    child: Image(
                        color: Color.fromRGBO(
                            255, 255, 255, widget.disabled ? 0.7 : 1),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/add.png')),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              MzSlider(
                value: value,
                width: 400,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                max: widget.maxGear,
                min: widget.minGear,
                disabled: widget.disabled,
                step: 1,
                duration: widget.duration ?? const Duration(milliseconds: 100),
                activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
                onChanging: (e, _) => setState(() {
                  value = e;
                  // widget.onChanged?.call(value);
                }),
                onChanged: (e, _) => setState(() {
                  value = e;
                  widget.onChanged?.call(value);
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [...markList],
            ),
          )
        ],
      ),
    );
  }
}
