import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/scene/scene.dart';

import '../../../common/api/scene_api.dart';
import '../../../common/utils.dart';

class SceneCard extends StatefulWidget {
  final Scene scene;
  final bool? power;
  final Function(Scene scene)? onClick;

  const SceneCard({super.key, required this.scene, this.power, this.onClick});

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard> {
  late Scene scene;
  bool selfPower = false;

  @override
  void initState() {
    super.initState();
    scene = widget.scene;
  }

  execScene() async {
    setState(() {
      selfPower = true;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        selfPower = false;
      });
    });
    var res = await SceneApi.execScene(scene.key);
    if (res.success) {
      TipsUtils.toast(content: '执行成功');
    } else {
      TipsUtils.toast(content: '执行失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTapUp: (e) {
          if (widget.onClick != null) {
            widget.onClick!(scene);
          } else {
            execScene();
          }
        },
        child: Stack(
          children: [
            Positioned(
              child: Image(image: AssetImage(scene.bg), width: 136.0),
            ),
            SizedBox(
              width: 136,
              height: 179,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      scene.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontFamily: 'MideaType',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Image(
                      image: AssetImage(
                          (widget.power != null ? widget.power! : selfPower)
                              ? 'assets/imgs/scene/choose.png'
                              : scene.icon),
                      width: 60.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
