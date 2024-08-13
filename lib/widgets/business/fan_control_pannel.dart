import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/mz_buttion.dart';

import '../../common/logcat_helper.dart';

class FanControlPanel extends StatefulWidget {

  final num minGear;
  final num maxGear;
  final bool disable;
  final bool fanOnOff;
  final bool lightOnOff;
  final num gear;
  final void Function(num value) onGearChanged;
  final void Function(bool onOff) onFanOnOffChange;
  final void Function(bool onOff) onLightOnOffChange;

  const FanControlPanel({
    super.key,
    required this.minGear,
    required this.maxGear,
    required this.disable,
    required this.fanOnOff,
    required this.lightOnOff,
    required this.gear,
    required this.onGearChanged,
    required this.onFanOnOffChange,
    required this.onLightOnOffChange
  });

  @override
  State<FanControlPanel> createState() => _FanControlPanelState();


}

class _FanControlPanelState extends State<FanControlPanel> {

  late num gear;

  ValueNotifier<MaterialState> fanState = ValueNotifier(MaterialState.focused);

  ValueNotifier<MaterialState> lightState = ValueNotifier(MaterialState.focused);


  @override
  void initState() {
    super.initState();
    fanState.value = widget.fanOnOff ? MaterialState.selected : MaterialState.focused;
    lightState.value = widget.lightOnOff ? MaterialState.selected : MaterialState.focused;
    gear = widget.gear;
  }

  @override
  void didUpdateWidget(covariant FanControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i("fanOnOff = ${widget.fanOnOff} lightOnOff = ${widget.lightOnOff} gear = ${widget.gear}");
    if (oldWidget.lightOnOff != widget.lightOnOff ||
        oldWidget.fanOnOff != widget.fanOnOff ||
        oldWidget.gear != widget.gear) {
      setState(() {
        fanState.value = widget.fanOnOff ? MaterialState.selected : MaterialState.focused;
        lightState.value = widget.lightOnOff ? MaterialState.selected : MaterialState.focused;
        gear = widget.gear;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    gearTextWidget() {
      return RichText(text: TextSpan(
        children: [
          TextSpan(text: gear.toString(), style: TextStyle(
              height: 1.5,
              color: !widget.disable
                  ? const Color(0XFFFFFFFF)
                  : const Color(0XA3FFFFFF),
              letterSpacing: 0,
              fontSize: 60,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w100,
              decoration: TextDecoration.none)),
          TextSpan(text: "  挡", style: TextStyle(
              height: 1.5,
              color: !widget.disable
                  ? const Color(0XFFFFFFFF)
                  : const Color(0XA3FFFFFF),
              letterSpacing: 0,
              fontSize: 20,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w100,
              decoration: TextDecoration.none))
        ]
      ));
    }

    getRightButtonWidget() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MzButton.state(
              state: fanState,
              backgroundStateColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white: const Color(0xff202020).withOpacity(0.2)),
              textStateColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.black : Colors.white),
              width: 120,
              height: 56,
              isClickable: !widget.disable,
              borderColor: Colors.transparent,
              borderWidth: 0,
              isShowShadow: false,
              borderRadius: 15.0,
              text: '风扇',
              onPressed: () {
                if(fanState.value == MaterialState.selected) {
                  fanState.value = MaterialState.focused;
                  widget.onFanOnOffChange(false);
                } else {
                  fanState.value = MaterialState.selected;
                  widget.onFanOnOffChange(true);
                }
              }),

          MzButton.state(
              state: lightState,
              backgroundStateColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white: const Color(0xff202020).withOpacity(0.2)),
              textStateColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.black : Colors.white),
              width: 120,
              height: 56,
              isClickable: !widget.disable,
              borderColor: Colors.transparent,
              borderWidth: 0,
              isShowShadow: false,
              borderRadius: 15.0,
              text: '照明',
              onPressed: () {
                if(lightState.value == MaterialState.selected) {
                  lightState.value = MaterialState.focused;
                  widget.onLightOnOffChange(false);
                } else {
                  lightState.value = MaterialState.selected;
                  widget.onLightOnOffChange(true);
                }
              }),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: gearTextWidget()),
                Expanded(
                    flex: 2,
                    child: getRightButtonWidget()
                ),
              ],
            )
        ),
        MzSliderMarkDecoration(
            slider: MzSlider(
              value: gear,
              min: widget.minGear,
              max: widget.maxGear,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              step: 1,
              duration: const Duration(milliseconds: 100),
              activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
              width: 400,
              disabled: widget.disable || fanState.value != MaterialState.selected,
              onChanged: (value, _) {
                setState(() {
                  gear = value;
                  widget.onGearChanged(value);
                });
              },
            )
        )
      ],
    );

  }


  @override
  void dispose() {
    fanState.dispose();
    lightState.dispose();
    super.dispose();
  }

}

