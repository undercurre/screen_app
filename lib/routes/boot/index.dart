import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/common/setting.dart';
import 'package:screen_app/widgets/event_bus.dart';
import '../../common/index.dart';

class _Boot extends State<Boot> {

  @override
  void initState() {
    super.initState();

    bus.on("logout",(arg) {
      Push.dispose();
      System.loginOut();
      Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => route.settings.name == "/");
    });
    
    () async {
      /// 数据迁移逻辑
      String flavor = await aboutSystemChannel.queryFlavor();
      String version = await aboutSystemChannel.getAppVersion();
      if(flavor == 'LD') {
        if(version == '0117' && !Setting.instant().checkVersionCompatibility(version)) {
          if(!Global.isLogin) {
            Future.delayed(Duration.zero).then((_) {
              Navigator.pushNamed(context, 'MigrationOldVersionDataPage');
            });
            return;
          }
        }
      } else if(flavor == 'JH') {
        if(version == '0120' && !Setting.instant().checkVersionCompatibility(version)) {
          if(!Global.isLogin) {
            Future.delayed(Duration.zero).then((_) {
              Navigator.pushNamed(context, 'MigrationOldVersionDataPage');
            });
            return;
          }
        }
      }
      /// 正常的跳转逻辑
      checkLogin();
    }.call();

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

    if (isFinishLogin) {
      Push.sseInit();
    }
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _Boot();
}
