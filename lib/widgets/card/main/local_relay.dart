import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';

import '../../../common/logcat_helper.dart';
import '../../../states/relay_change_notifier.dart';

class LocalRelayWidget extends StatefulWidget {
  final int relayIndex;
  final bool disabled;

  const LocalRelayWidget({
    super.key,
    required this.relayIndex,
    required this.disabled,
  });

  @override
  _LocalRelayWidgetState createState() => _LocalRelayWidgetState();
}

class _LocalRelayWidgetState extends State<LocalRelayWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relayModel = Provider.of<RelayModel>(context);
    return GestureDetector(
      onTap: () {
        Log.i('点击', widget.disabled);
        if (!widget.disabled) {
          if (widget.relayIndex == 1) {
            relayModel.toggleRelay1();
          } else {
            relayModel.toggleRelay2();
          }
        }
      },
      child: Container(
        width: 210,
        height: 88,
        padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
        decoration: _getBoxDecoration(widget.relayIndex == 1 ? relayModel.localRelay1 : relayModel.localRelay2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              child: const Image(
                image: AssetImage('assets/newUI/device/localPanel.png'),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.relayIndex == 1 ? '灯1' : '灯2',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.2,
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(bool value) {
    return !value
        ? BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF767B86),
          Color(0xFF88909F),
          Color(0xFF516375),
        ],
        stops: [0, 0.24, 1],
        transform: GradientRotation(194 * (3.1415926 / 360.0)),
      ),
    )
        : BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x33616A76),
          Color(0x33434852),
        ],
        stops: [0.06, 1.0],
        transform: GradientRotation(213 * (3.1415926 / 360.0)),
      ),
    );
  }
}
