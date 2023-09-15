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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF272F41),
                  Color(0xFF080C14),
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 480,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconSize: 64,
                        icon: Image.asset(
                          "assets/newUI/back.png",
                        ),
                      ),
                      const Text("无线局域网",
                          style: TextStyle(
                              color: Color(0XD8FFFFFF),
                              fontSize: 28,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.settings.name == 'Home');
                        },
                        iconSize: 64,
                        icon: Image.asset(
                          "assets/newUI/back_home.png",
                        ),
                      ),
                    ],
                  ),
                ),

                const Expanded(
                  child: LinkNetwork(isNeedWifiSwitch: true),
                ),

              ],
            ),
          )),
    );
  }

}
