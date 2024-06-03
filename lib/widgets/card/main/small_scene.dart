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
import '../../../states/weather_change_notifier.dart';

class SmallSceneCardWidget extends StatefulWidget {
  bool onOff = false;
  final String name;
  final String icon;
  final String sceneId;
  final bool discriminative;
  final bool disabled;

  SmallSceneCardWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.sceneId,
    required this.disabled,
    bool onOff = false,
    this.discriminative = false,
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
    final weatherModel = Provider.of<WeatherModel>(context);
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
      child: Stack(children: [
        Positioned(
          child: Container(
            width: 210,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: widget.discriminative ? _getBgStop('null') : _getBgStop(widget.icon),
                colors: widget.discriminative ? _getBgColor('null') : _getBgColor(widget.icon),
              ),
            ),
          ),
        ),
        if (widget.onOff)
          Positioned(
            child: Container(
              width: 210,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.40),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        Container(
          width: 210,
          height: 88,
          padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
          child: Row(
            children: [
              widget.onOff
                  ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 40,
                      color: Colors.transparent,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 3.0,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 40,
                      child: Image(image: AssetImage('assets/newUI/scene/${widget.icon}.png')),
                    ),
              SizedBox(
                width: 100,
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        constraints: const BoxConstraints(
                          maxWidth: 98,
                          maxHeight: 56,
                        ),
                        child: Column(
                          mainAxisAlignment: System.inHomluxPlatform() ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NameFormatter.formLimitString(sceneName, 4, 1, 2),
                              style: const TextStyle(
                                height: 1.2,
                                color: Colors.white,
                                fontSize: 22,
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
                                  fontSize: 16,
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
      ]),
    );
  }

  List<Color> _getBgColor(String key) {
    List<Color> defaultBg = [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.12)];

    List<Color> all_on = [
      Color(0xFF305D78), // 新增过渡色
      Color(0xFF33617F), // 原始第三色
      Color(0xFF496A83), // 新增过渡色
      Color(0xFF576E87), // 原始第二色
      Color(0xFF596D81), // 新增过渡色
      Color(0xFF5C747B), // 原始第一色
    ];

    List<Color> all_off = [
      Color(0xFF7C6A6C), // 原始第一色
      Color(0xFF736A76), // 新增过渡色
      Color(0xFF636A85), // 原始第二色
      Color(0xFF5C6888), // 新增过渡色
      Color(0xFF57638C), // 原始第三色
      Color(0xFF506288), // 新增过渡色
    ];

    List<Color> bright = [
      Color(0xFF80736E), // 新增过渡色
      Color(0xFF7B746A), // 原始第三色
      Color(0xFF717570), // 新增过渡色
      Color(0xFF657581), // 原始第二色
      Color(0xFF5E7287), // 新增过渡色
      Color(0xFF586F8A), // 原始第一色
    ];

    List<Color> mild = [
      Color(0xFF5F5892), // 原始第一色
      Color(0xFF54608F), // 新增过渡色
      Color(0xFF48678E), // 原始第二色
      Color(0xFF4D6E8A), // 新增过渡色
      Color(0xFF5C7885), // 原始第三色
      Color(0xFF587785), // 新增过渡色
    ];

    final Map<String, List<Color>> codeToColor = {
      'null': defaultBg,
      'default': all_off,
      '1': all_on,
      '2': all_off,
      '3': bright,
      '4': mild,
      '5': all_on,
      '6': all_off,
      '7': all_off,
      '8': bright,
      '9': all_off,
      '10': all_off,
      '11': all_on,
      '12': mild,
      '13': all_off,
      '14': all_off,
      '15': all_off,
      '16': all_off,
      '17': mild,
      '18': mild,
      '19': bright,
      '20': all_off,
      '21': all_on,
      '22': all_off,
      '23': all_off,
      '24': bright,
      '25': all_off,
      'all-on': all_on,
      'all-off': all_off,
      'bright': bright,
      'catering': all_on,
      'general': all_off,
      'go-home': all_on,
      'leave-hoom': all_off,
      'leisure': bright,
      'mild': mild,
      'movie': all_on,
      'night': mild,
      'read': bright,
      'icon-1': bright,
      'icon-2': all_on,
      'icon-3': mild,
      'icon-4': all_off,
      'icon-5': all_on,
      'icon-6': bright,
      'icon-7': all_off,
      'icon-8': mild,
      'icon-9': mild,
      'icon-10': all_off,
      'icon-11': bright,
      'icon-12': all_on,
      'icon-13': all_off,
      'icon-14': all_on,
      'icon-15': mild,
      'icon-16': bright,
    };

    return codeToColor[key] ?? defaultBg;
  }

  List<double> _getBgStop(String key) {
    List<double> defaultStop = [0.06, 1.0];
    List<double> all_on = [0.0, 0.22, 0.44, 0.66, 0.88, 1.0];
    List<double> all_off = [0.0, 0.26, 0.52, 0.68, 0.84, 1.0];
    List<double> bright = [0.0, 0.18, 0.36, 0.53, 0.71, 1.0];
    List<double> mild = [0.0, 0.19, 0.38, 0.57, 0.76, 1.0];

    final Map<String, List<double>> codeToStop = {
      'null': defaultStop,
      'default': all_off,
      '1': all_on,
      '2': all_off,
      '3': bright,
      '4': mild,
      '5': all_on,
      '6': all_off,
      '7': all_off,
      '8': bright,
      '9': all_off,
      '10': all_off,
      '11': all_on,
      '12': mild,
      '13': all_off,
      '14': all_off,
      '15': all_off,
      '16': all_off,
      '17': mild,
      '18': mild,
      '19': bright,
      '20': all_off,
      '21': all_on,
      '22': all_off,
      '23': all_off,
      '24': bright,
      '25': all_off,
      'all-on': all_on,
      'all-off': all_off,
      'bright': bright,
      'catering': all_on,
      'general': all_off,
      'go-home': all_on,
      'leave-hoom': all_off,
      'leisure': bright,
      'mild': mild,
      'movie': all_on,
      'night': mild,
      'read': bright,
      'icon-1': bright,
      'icon-2': all_on,
      'icon-3': mild,
      'icon-4': all_off,
      'icon-5': all_on,
      'icon-6': bright,
      'icon-7': all_off,
      'icon-8': mild,
      'icon-9': mild,
      'icon-10': all_off,
      'icon-11': bright,
      'icon-12': all_on,
      'icon-13': all_off,
      'icon-14': all_on,
      'icon-15': mild,
      'icon-16': bright,
    };

    return codeToStop[key] ?? defaultStop;
  }
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  Log.i('homlux图标', str);
  final numericRegex = RegExp(r'^-?(\d+\.\d+|\d+)$');
  return numericRegex.hasMatch(str);
}
