import 'package:flutter/cupertino.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../widgets/mz_metal_card.dart';
import '../scene/scene.dart';

class QuickScene extends StatefulWidget {
  @override
  QuickSceneState createState() => QuickSceneState();
}

class QuickSceneState extends State<QuickScene> {

  List<Scene> sceneList = [];

  initPage() async {
    var sceneRes = await CenterControlService.initScene();
    setState(() {
      sceneList = sceneRes;
    });
  }

  @override
  void initState() {
    super.initState();
    // 加载场景信息
    initPage();
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      width: 440,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
                image: AssetImage('assets/imgs/center/changjing-BG.png'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '快捷场景',
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'MideaType-Regular',
                        letterSpacing: 1.0),
                  ),
                  Image.asset(
                    'assets/imgs/device/changjing.png',
                    alignment: Alignment.centerRight,
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 1; i <= sceneList.length; i++)
                    GestureDetector(
                      onTap: () => CenterControlService.selectScene(sceneList[i - 1]),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                            gradient: const RadialGradient(
                              colors: [Color(0xFF393E43), Color(0xFF333135)],
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(sceneList[i - 1].icon,
                                width: 42, height: 42),
                            Text(sceneList[i - 1].name)
                          ],
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
