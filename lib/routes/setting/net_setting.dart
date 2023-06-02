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
              image: DecorationImage(
                  image: ExactAssetImage('assets/newUI/bg.png'),
                  fit: BoxFit.cover
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
                      const Text("网络设置",
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
                  child: LinkNetwork(),
                ),
              ],
            ),
          )),
    );
  }

}
