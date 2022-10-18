import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../common/index.dart';
import '../../models/index.dart';
import '../../states/index.dart';

class _LinkNetwork extends State<LinkNetwork> {
  bool wifi = true;

  @override
  Widget build(BuildContext context) {
    const stepNum = Positioned(
      top: 10,
      left: -15,
      child: Text(
        '01',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.white24,
          fontSize: 60.0,
          height: 1,
          fontFamily: "MideaType-Bold",
          decoration: TextDecoration.none,
        ),
      ),
    );

    var title = Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 6),
      child: Text(
        '连接网络 ${context.watch<UserModel>().user?.name}',
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 26.0,
          height: 1,
          fontFamily: "MideaType-Bold",
          decoration: TextDecoration.none,
        ),
      )
    );

      var stepBar = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Image(
          image: AssetImage("assets/imgs/scanCode/step-active.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/line-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/step-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/line-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/step-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/line-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/step-passive.png"),
        ),
      ],
    );

    var header = DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imgs/scanCode/header-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [title, stepBar],
        ));

    var wifiSwitch = Padding(
        padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('无线局域网',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  fontSize: 18.0,
                  fontFamily: "PingFangSC-Regular",
                  decoration: TextDecoration.none,
                )),
            CupertinoSwitch(
              value: wifi,
              onChanged: (bool value) {
                developer.log('onChanged: $value');
                setState(() {
                  wifi = value;
                });
              },
            ),
          ],
        ));

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
          debugPrint('index: $index');

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

                userModel.user = User.fromJson({ "name": "test $index"});
              },
              child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromRGBO(151, 151, 151, 0.3))),
                    color: Color.fromRGBO(216, 216, 216, 0.1),
                  ),
                  padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.wifi,
                        color: Color.fromRGBO(255, 255, 255, 0.85),
                        size: 24.0,
                      ),
                      Text('Midea-Smart: ${list[index]}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.85),
                            fontSize: 17.0,
                            fontFamily: "PingFangSC-Regular",
                            decoration: TextDecoration.none,
                          )),
                    ],
                  )));
        });

    return Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 5,
              color: Colors.white,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
                  children: [header, stepNum]),
              wifiSwitch,
              wifiListTitle,
              Expanded(
                child: wifiList,
              ),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
                    padding: const EdgeInsets.all(20.0),
                    textStyle: const TextStyle(
                        fontSize: 17, color: Color.fromRGBO(1, 255, 255, 0.85)),
                  ),
                  onPressed: () async {
                    debugPrint('pressNextButton');
                    //导航到新路由
                    var result = await Navigator.pushNamed(
                      context,
                      'ScanCode',
                    );
                  },
                  child: const Text('下一步',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.85),
                      )),
                ),
              )
            ],
          ),
        ));
  }
}

class LinkNetwork extends StatefulWidget {
  const LinkNetwork({super.key});

  @override
  State<LinkNetwork> createState() => _LinkNetwork();
}
