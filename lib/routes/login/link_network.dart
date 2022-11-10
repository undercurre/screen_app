import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:platform_device_id/platform_device_id.dart';
import 'dart:developer' as developer;

import '../../common/index.dart';
import '../../models/index.dart';
import '../../states/index.dart';
import '../../widgets/index.dart';

class _LinkNetwork extends State<LinkNetwork> {
  bool wifi = true;

  void getDeviceInfo() async {
    // String? deviceId = await PlatformDeviceId.getDeviceId;

    // logger.i('AndroidDeviceInfo: \n '
    //     'deviceId: ${deviceId} \n ');

    final Connectivity _connectivity = Connectivity();

    ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();

    logger.i("Connectivity: ${connectivityResult}");
  }

  @override
  Widget build(BuildContext context) {
    getDeviceInfo();

    var wifiSwitch = Cell(
        title: '无线局域网',
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        titleSize: 24.0,

        hasTopBorder: true,
        hasSwitch: true,
        onSwitch: (bool value) {
          developer.log('onChanged: $value');
          setState(() {
            wifi = value;
          });
        });

    var wifiListTitle = DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: Color.fromRGBO(151, 151, 151, 0.3))),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 4, 36, 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text('其他网络',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.68),
                        fontSize: 13.0,
                        fontFamily: "PingFangSC-Regular",
                        decoration: TextDecoration.none,
                      )),
                ])));

    var list = <String>['loadingTag'];

    for (var i = 0; i < 20; i++) {
      list.insert(list.length - 1, 'test: $i');
    }

    var wifiList = ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          if (list[index] == "loadingTag") {
            //已经加载了100条数据，不再获取数据。
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "没有更多了",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Listener(
              onPointerDown: (event) {
                logger.i("item: $index  onPointerDown, $event");
                var userModel = context.read<UserModel>();

                userModel.user = User.fromJson({"name": "test $index"});
              },
              child: Cell(
                avatarIcon: const Icon(
                  Icons.wifi,
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  size: 24.0,
                ),
                rightIcon: const Icon(Icons.lock_outline_sharp, color: Color.fromRGBO(255, 255, 255, 0.85)),
                title: 'Midea-Smart: ${list[index]}',
                titleSize: 18.0,
                hasTopBorder: true,
                bgColor: const Color.fromRGBO(216, 216, 216, 0.1),
              ));
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wifiSwitch,
        wifiListTitle,
        Expanded(
          child: wifiList,
        ),
      ],
    );
  }
}

class LinkNetwork extends StatefulWidget {
  const LinkNetwork({super.key});

  @override
  State<LinkNetwork> createState() => _LinkNetwork();
}
