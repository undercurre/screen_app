import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
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
  SelectRoomDataAdapter? roomDataAd;

  @override
  void initState() {
    super.initState();
    roomDataAd = SelectRoomDataAdapter(MideaRuntimePlatform.platform);
    roomDataAd?.bindDataUpdateFunction(() {
      setState(() {});
    });
    roomDataAd?.queryRoomList(System.familyInfo!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceneListModel = Provider.of<SceneListModel>(context);
    String sceneName = sceneListModel.getSceneName(widget.sceneId);
    String sceneRoomId = sceneListModel.getSceneRoomId(widget.sceneId);
    String sceneRoomName = roomDataAd?.familyListEntity?.familyList
            .firstWhere((element) => element.id == sceneRoomId, orElse: () {
          SelectRoomItem defaultRoom = SelectRoomItem();
          defaultRoom.name = '';
          return defaultRoom;
        }).name ??
        '';
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
      child: Container(
        width: 210,
        height: 196,
        padding:
            const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.discriminative
                        ? Colors.white.withOpacity(0.12)
                        : const Color(0x33616A76),
                    widget.discriminative
                        ? Colors.white.withOpacity(0.12)
                        : const Color(0x33434852),
                  ],
                  stops: const [0.06, 1.0],
                  transform: const GradientRotation(213 * (3.1415926 / 360.0)),
                ),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.6,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Image(
                  width: 40,
                  height: 40,
                  image: isNumeric(widget.icon)
                      ? AssetImage('assets/newUI/scene/${widget.icon}.png')
                      : const AssetImage('assets/newUI/scene/default.png'),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text(
                            NameFormatter.formLimitString(
                                sceneRoomName, 4, 1, 2),
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
