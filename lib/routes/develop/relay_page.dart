


import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/widgets/event_bus.dart';

class RelayPage extends StatefulWidget {
  const RelayPage({super.key});


  @override
  State<StatefulWidget> createState() => RelayPageState();

}

class RelayPageState extends State<RelayPage> {
  bool relay1 = false;
  bool relay2 = false;

  @override
  void initState() {
    gatewayChannel.relay2IsOpen()
        .then((value) => setState((){relay2 = value;}));
    gatewayChannel.relay1IsOpen()
        .then((value) => setState((){relay1 = value;}));
    bus.on("relay1StateChange", relay1StateChange);
    bus.on("relay2StateChange", relay2StateChange);
  }

  void relay1StateChange(dynamic open) {
    setState(() {
      relay1 = open as bool;
    });
  }

  void relay2StateChange(dynamic open) {
    setState(() {
      relay2 = open as bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zigbee设备测试页面"),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                gatewayChannel.controlRelay1Open(!relay1);
                setState(() {
                  relay1 = !relay1;
                });
              },
              child: Card(
                color: relay1 ? Colors.green : Colors.grey,
                child: const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: Text('继电器1'))
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                gatewayChannel.controlRelay2Open(!relay2);
                setState(() {
                  relay2 = !relay2;
                });
              },
              child: Card(
                color: relay2 ? Colors.green : Colors.grey,
                child:const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: Text('继电器2')),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}