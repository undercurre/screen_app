import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/widgets/card/method.dart';

import '../../../common/logcat_helper.dart';
import '../../../states/relay_change_notifier.dart';
import '../../util/nameFormatter.dart';

class LocalRelayWidget extends StatefulWidget {
  final int relayIndex;
  final bool disabled;
  final bool discriminative;

  const LocalRelayWidget({
    super.key,
    required this.relayIndex,
    required this.disabled,
    this.discriminative = false,
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
          if (widget.relayIndex == 1) {
            relayModel.toggleRelay1();
          } else {
            relayModel.toggleRelay2();
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
                      widget.relayIndex == 1 ? NameFormatter.formatName(relayModel.localRelay1Name, 4) : NameFormatter.formatName(relayModel.localRelay2Name, 4),
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
    if (widget.disabled) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled')
      );
    }
    return value
        ? BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: getBigCardColorBg('open'))
        : BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'),
    );
  }
}
