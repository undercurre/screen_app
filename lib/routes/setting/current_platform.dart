
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../common/gateway_platform.dart';
import '../../common/utils.dart';
import '../../widgets/mz_dialog.dart';

class CurrentPlatformPage extends StatefulWidget {
  const CurrentPlatformPage({super.key});

  @override
  CurrentPlatformPageState createState() => CurrentPlatformPageState();
}

class CurrentPlatformPageState extends State<CurrentPlatformPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 480,
          height: 480,
          color: Colors.black,
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
                    const Text("当前平台",
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

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _card("美的美居",
                        "assets/newUI/login/meiju_logo.png",
                        MideaRuntimePlatform.platform == GatewayPlatform.MEIJU,
                        () {
                          if (MideaRuntimePlatform.platform != GatewayPlatform.MEIJU) {
                            showClearUserDataDialog(context, 0);
                          }
                        }
                    ),
                    _card("美的照明",
                        "assets/newUI/login/homlux_logo.png",
                        MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX,
                        () {
                          if (MideaRuntimePlatform.platform != GatewayPlatform.HOMLUX) {
                            showClearUserDataDialog(context, 1);
                          }
                        }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String name, String iconStr, bool isLogin, Function? onTap) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        height: 138,
        width: 400,
        margin: const EdgeInsets.only(top: 43),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        decoration: BoxDecoration(
            color: isLogin? const Color(0x510091FF) : const Color(0x28FFFFFF),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: isLogin ? const Color(0xFF0070C7) : Colors.transparent, width: 2)
        ),
        child: Row(
          children: [
            Image(
              height: 90,
              width: 90,
              image: AssetImage(iconStr),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 40),
                    child: Text(name,
                        style: const TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)
                    ),
                  ),
                  if (isLogin) const Text("已登入",
                      style: TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 20,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none)
                  ),
                  if (!isLogin) const Image(
                    height: 24,
                    width: 24,
                    image: AssetImage("assets/newUI/箭头@2x.png"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showClearUserDataDialog(BuildContext context, int index) async {
    MzDialog (
        title: '切换至${index == 0 ? "美的美居" : "美的照明"}平台',
        titleSize: 28,
        maxWidth: 432,
        contentSlot: const Text('此操作将会清除智慧屏上的所有\n数据',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(255, 255, 255, 0.60),
                fontFamily: 'MideaType',
                fontWeight: FontWeight.w400,
                height: 1.2)),
        btns: ['取消', '确定'],
        contentPadding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
        onPressed: (_, position, context) async {
          Navigator.pop(context);
          if (position == 1) {
            bool isSuccess = false;
            if (index == 0) {
              isSuccess = await ChangePlatformHelper.changeToMeiju();
            } else if (index == 1) {
              isSuccess = await ChangePlatformHelper.changeToHomlux();
            }
            if (!isSuccess) {
              TipsUtils.toast(content: '切换失败，请再次尝试', position: EasyLoadingToastPosition.bottom);
              return;
            }
            Navigator.pushNamedAndRemoveUntil(
                context,
                "Login",
                (route) => route.settings.name == "/",
                arguments: {"from": "changePlatform"});
          }
        }
    ).show(context);
  }

  @override
  void didUpdateWidget(CurrentPlatformPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}
