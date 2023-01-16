import 'package:flutter/material.dart';
import 'package:screen_app/widgets/event_bus.dart';
import '../../widgets/index.dart';

class SelectScenePage extends StatelessWidget {
  const SelectScenePage({super.key});

  @override
  Widget build(BuildContext context) {
    SelectSceneList list = const SelectSceneList();
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
          Expanded(
            flex: 1,
            child: list,
          ),
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
