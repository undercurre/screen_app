import 'dart:async';

import 'package:flutter/material.dart';

@immutable
class MzSettingButton extends StatelessWidget {
  String text;
  double fontSize;
  Color fontColor;
  Color backgroundColor;
  double borderRadius;
  Color borderColor;
  double borderWidth;
  GestureTapCallback? onTap;

  MzSettingButton({super.key,
    required this.text,
    this.fontSize = 18.0,
    this.fontColor = Colors.white54,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.1),
    this.onTap,
    this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minWidth: 100),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
        decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor),
        child: Text(
          text,
          style: TextStyle(
              fontSize: fontSize, color: fontColor, fontFamily: 'MideaType'),
        ),
      ),
    );
  }
}

@immutable
class MzSettingItem extends StatelessWidget {
  GestureTapCallback? onTap;
  String leftText;
  String? rightText;
  double rightTextSize;
  Widget? rightWidget;
  bool containBottomDivider;
  String? tipText;
  TextAlign rightTextAlign;
  int longTapSecond;
  GestureTapCallback? onLongTap;

  Timer? tapTimer;
  int timerCnt = 0;

  MzSettingItem({super.key,
    required this.leftText,
    this.rightText,
    this.rightTextSize = 20.0,
    this.onTap,
    this.tipText,
    this.rightTextAlign = TextAlign.end,
    this.containBottomDivider = true,
    this.rightWidget,
    this.onLongTap,
    this.longTapSecond = 10});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onTapDown: (e) {
        if (onLongTap == null) return;
        if (tapTimer != null) {
          tapTimer?.cancel();
          timerCnt = 0;
          tapTimer = null;
        }
        tapTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          timerCnt++;
          if (timerCnt >= longTapSecond) {
            tapTimer?.cancel();
            timerCnt = 0;
            tapTimer = null;
            onLongTap?.call();
          }
        });
      },
      onTapUp: (e) {
        if (onLongTap == null) return;
        tapTimer?.cancel();
        timerCnt = 0;
        tapTimer = null;
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      leftText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontFamily: 'MideaType',
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                    if (tipText != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          tipText!,
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                      )
                  ],
                ),
                if (rightWidget != null) rightWidget!,
                if (rightText != null)
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 240,
                          child: Text(rightText!,
                              textAlign: rightTextAlign,
                              style: TextStyle(
                                fontSize: rightTextSize,
                                color: Colors.white54,
                                fontFamily: 'MideaType',
                              )),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (containBottomDivider)
            const Divider(
              height: 1,
              color: Color.fromRGBO(255, 255, 255, 0.05),
            )
        ],
      ),
    );
  }

  Widget? getRightWidget() {
    if (rightText == null) return null;

    return Text(rightText!,
        style: TextStyle(
          fontSize: rightTextSize,
          color: Colors.white70,
          fontFamily: 'MideaType',
        ));
  }
}
