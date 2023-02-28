import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/event_bus.dart';
import '../../widgets/index.dart';

class SelectScenePage extends StatelessWidget {
  const SelectScenePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scene = context.read<SceneChangeNotifier>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          MzNavigationBar(
            title: '选择场景',
            onLeftBtnTap: () {
              Navigator.pop(context, 'back');
            },
          ),
          const Expanded(
            flex: 1,
            child: SelectSceneList(),
          ),
          if (scene.sceneList.isNotEmpty)
            RawMaterialButton(
              constraints: const BoxConstraints(minHeight: 64, maxHeight: 64, minWidth: double.infinity),
              onPressed: () {
                bus.emit('selectSceneConfirm');
              },
              elevation: 0,
              padding: EdgeInsets.zero,
              fillColor: const Color(0xff267aff),
              child: const Text(
                '确定',
                style: TextStyle(fontSize: 24, fontFamily: "MideaType", fontWeight: FontWeight.w400),
              ),
            )
        ],
      ),
    );
  }
}
