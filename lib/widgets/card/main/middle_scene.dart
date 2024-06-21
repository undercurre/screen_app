import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/widgets/card/method.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';

import '../../../common/adapter/select_room_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/system.dart';
import '../../../states/scene_list_notifier.dart';

class MiddleSceneCardWidget extends StatefulWidget {
  bool onOff = false;
  final String name;
  final String icon;
  final String sceneId;
  final bool discriminative;
  final bool disabled;

  MiddleSceneCardWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.sceneId,
    required this.disabled,
    bool onOff = false,
    this.discriminative = false,
  });

  @override
  _MiddleSceneCardWidgetState createState() => _MiddleSceneCardWidgetState();
}

class _MiddleSceneCardWidgetState extends State<MiddleSceneCardWidget> {
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
    String sceneName = sceneListModel.getSceneName(widget.sceneId);
    String sceneRoomName = sceneListModel.getSceneRoomName(widget.sceneId);
    return GestureDetector(
        onTap: () {
          if (!widget.disabled) {
            sceneListModel.sceneExec(widget.sceneId);
            setState(() {
              widget.onOff = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  widget.onOff = false;
                });
              }
            });
          } else {
            return;
          }
        },
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: 210,
                height: 196,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: getSceneBgStop(widget.icon),
                    colors: getSceneBgColor(widget.icon),
                  ),
                ),
              ),
            ),
            if (widget.onOff)
              Positioned(
                child: Container(
                  width: 210,
                  height: 196,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.40),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            Container(
              width: 210,
              height: 196,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.6,
                    alignment: Alignment.topLeft,
                    child: widget.onOff
                        ? Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 30,
                            height: 30,
                            color: Colors.transparent,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 3.0,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 40,
                            height: 40,
                            child: Image(
                              width: 40,
                              height: 40,
                              image: AssetImage('assets/newUI/scene/${widget.icon}.png'),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 68,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            constraints: const BoxConstraints(
                              maxWidth: 98,
                              maxHeight: 68,
                            ),
                            child: Column(
                              mainAxisAlignment: System.inHomluxPlatform() ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NameFormatter.formLimitString(sceneName, 4, 1, 2),
                                  style: const TextStyle(
                                    height: 1.2,
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'MideaType',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (System.inHomluxPlatform())
                                  Text(
                                    widget.onOff ? '执行中...' : NameFormatter.formLimitString(sceneRoomName, 4, 1, 2),
                                    style: TextStyle(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.64),
                                      fontSize: 20,
                                      fontFamily: 'MideaType',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  final numericRegex = RegExp(r'^-?(\d+\.\d+|\d+)$');
  return numericRegex.hasMatch(str);
}
