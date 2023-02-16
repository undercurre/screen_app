


import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';

class ScreenOnOffPage extends StatefulWidget {

  const ScreenOnOffPage({super.key});

  @override
  State<StatefulWidget> createState() => ScreenOnOffState();

}

class ScreenOnOffState extends State<ScreenOnOffPage> {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Icons.arrow_back)),
      title: const Text('测试屏幕两面'),
    ),
    body: Center(
      child: GestureDetector(
        onTap: () {
          print('点击屏幕');
          settingMethodChannel.getScreenOpenCloseState().then((value) => debugPrint('当前的状态为: $value'));
          //settingMethodChannel.setScreenClose(false);
        },
        child: Container(
          width: double.infinity,
          color: Colors.green,
          child: Column(
            children: [
              MaterialButton(
                  onPressed: () => settingMethodChannel.setScreenClose(true),
                  child: const Text('关闭屏幕')),
              MaterialButton(
                  onPressed: () => settingMethodChannel.setScreenClose(false),
                  child: const Text('打开屏幕'))
            ],
          ),
        ),
      ),
    ),
  );

}