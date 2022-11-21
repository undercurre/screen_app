import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/index.dart';
import '../../models/index.dart';
import '../../states/index.dart';
import '../../widgets/index.dart';

class _LinkNetwork extends State<LinkNetwork> {
  bool _isWifiOn = true;

  @override
  Widget build(BuildContext context) {
    debugPrint('link_network.dart-build: $_isWifiOn');
    var wifiSwitch = Cell(
        title: '无线局域网',
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        titleSize: 24.0,
        hasTopBorder: true,
        hasSwitch: true,
        initSwitchValue: _isWifiOn,
        onSwitch: changeWifiSwitch);

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
                rightIcon: const Icon(Icons.lock_outline_sharp,
                    color: Color.fromRGBO(255, 255, 255, 0.85)),
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
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(216, 216, 216, 0.1)),
            child: wifiList,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  void getWifiInfo() {}

  void changeWifiSwitch(bool value) async {
    debugPrint('onChanged: $value');
    setState(() {
      _isWifiOn = value;
    });
  }
}

class LinkNetwork extends StatefulWidget {
  const LinkNetwork({super.key});

  @override
  State<LinkNetwork> createState() => _LinkNetwork();
}
