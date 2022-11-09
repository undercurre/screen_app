import 'package:flutter/material.dart';
import '../../common/index.dart';
import '../../models/index.dart';
import '../../states/index.dart';

class _SelectRoom extends State<SelectRoom> {
  bool wifi = true;

  @override
  Widget build(BuildContext context) {
    MzApi.authToken();
    IotApi.getWeather();
    debugPrint('Api: ${Global.user?.toJson()}');
    var wifiSwitch = Padding(
        padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('登录成功',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  fontSize: 18.0,
                  fontFamily: "PingFangSC-Regular",
                  decoration: TextDecoration.none,
                )),
          ],
        ));


    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wifiSwitch,
          ],
        );
  }
}

class SelectRoom extends StatefulWidget {
  const SelectRoom({super.key});

  @override
  State<SelectRoom> createState() => _SelectRoom();
}
