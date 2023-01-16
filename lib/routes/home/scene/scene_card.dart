import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/scene/scene.dart';

class SceneCard extends StatefulWidget {
  final Scene scene;
  final bool power;
  final Function(Scene scene)? onClick;

  const SceneCard(
      {super.key, required this.scene, required this.power, this.onClick});

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard> {
  late Scene scene;

  @override
  void initState() {
    super.initState();
    scene = widget.scene;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) =>
          widget.onClick != null ? widget.onClick!(scene) : print('点击了'),
      child: Padding(
        padding: const EdgeInsets.all(6),
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
                      image: AssetImage(widget.power
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
