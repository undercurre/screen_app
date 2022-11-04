import 'package:flutter/material.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Text("${widget.text}",
            style: const TextStyle(
              color: Color(0XFFFFFFFF),
              fontSize: 30.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            )));
  }
}
