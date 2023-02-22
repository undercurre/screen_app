import 'package:flutter/material.dart';

import '../../widgets/business/net_connect.dart';

class NetSettingPage extends StatelessWidget {

  const NetSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
            width: 480,
            height: 480,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 480,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconSize: 60.0,
                        icon: Image.asset(
                          "assets/imgs/setting/fanhui.png",
                        ),
                      ),
                      const Text("网络设置",
                          style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 30.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          )),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            'Home',
                          );
                        },
                        iconSize: 60.0,
                        icon: Image.asset(
                          "assets/imgs/setting/zhuye.png",
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: LinkNetwork(),
                ),
              ],
            ),
          )),
    );
  }

}
