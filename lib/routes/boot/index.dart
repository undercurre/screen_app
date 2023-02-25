import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/event_bus.dart';
import '../../common/index.dart';

class _Boot extends State<Boot> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child:Center(child: Image.asset('assets/imgs/setting/ig_app_bg.png')),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 检查是否已经登录
  Future checkLogin() async {
    if (Global.isLogin) {
      await System.refreshToken();
    }

     Timer(const Duration(seconds: 2), () {
       bootFinish();
     });
  }

  /// 启动完成
  void bootFinish() {
    debugPrint('bootFinish trigger');
    var isFinishLogin = Global.isLogin &&
        Global.profile.homeInfo != null &&
        Global.profile.roomInfo != null;

    Navigator.pushNamed(
      context,
      isFinishLogin ? 'Home' : 'Login',
    );

    bus.on("logout",(arg) {
      System.loginOut();
      Navigator.popUntil(context, (route) => route.settings.name == "/");
      Navigator.pushNamed(context,'Login');
    });
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _Boot();
}
