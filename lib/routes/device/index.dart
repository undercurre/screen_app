import 'package:flutter/material.dart';

class DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Scaffold(
        appBar: AppBar(
          title: const Text("子树中获取State对象"),
        ),
        body: Center(
          child: Column(
            children: [
              Builder(builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, '返回值');
                  },
                  child: const Text('返回'),
                );
              }),
            ],
          ),
        ),
        drawer: const Drawer(),
      )
    ]);
  }
}

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => DevicePageState();
}
