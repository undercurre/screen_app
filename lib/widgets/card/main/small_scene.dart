import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';

import '../../../common/logcat_helper.dart';
import '../../../states/scene_list_notifier.dart';

class SmallSceneCardWidget extends StatefulWidget {
  bool onOff = false;
  final String name;
  final String icon;
  final String sceneId;
  final bool disabled;

  SmallSceneCardWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.sceneId,
    required this.disabled,
    bool onOff = false,
  });

  @override
  _SmallSceneCardWidgetState createState() => _SmallSceneCardWidgetState();
}

class _SmallSceneCardWidgetState extends State<SmallSceneCardWidget> {
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
    final sceneListModel = Provider.of<SceneListModel>(context);
    return GestureDetector(
      onTap: () {
        Log.i('disabled', widget.disabled);
        if (!widget.disabled) {
          sceneListModel.sceneExec(widget.sceneId);
          setState(() {
            widget.onOff = true;
          });
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              widget.onOff = false;
            });
          });
        } else {
          return;
        }
      },
      child: Container(
        width: 210,
        height: 88,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: widget.onOff
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
              ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              child: Image(
                image: isNumeric(widget.icon) ? AssetImage('assets/newUI/scene/${widget.icon}.png') : AssetImage('assets/newUI/scene/default.png'),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  final numericRegex = RegExp(r'^-?(\d+\.\d+|\d+)$');
  return numericRegex.hasMatch(str);
}