import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/widgets/event_bus.dart';
import '../../common/gateway_platform.dart';
import '../../common/index.dart';
import '../../common/logcat_helper.dart';

class _Boot extends State<Boot> {
  @override
  void initState() {
    super.initState();

    bus.on("logout", (arg) {
      Push.dispose();
      System.loginOut();
      Navigator.pushNamedAndRemoveUntil(
          context, 'Login', (route) => route.settings.name == "/");
    });

    () async {
      var maxTryCount = 30;
      while (maxTryCount > 0) {
        // -1错误 0NONE 1MEIJU 2HOMLUX
        Log.file('启动查询网关环境次数${maxTryCount - 29}');
        try {
          var platform = await ChangePlatformHelper.checkGatewayPlatform();
          if (platform != -1) {
            if (platform == 1) {
              MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
            } else if (platform == 2) {
              MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
            } else {
              MideaRuntimePlatform.platform = GatewayPlatform.NONE;
            }
            break;
          }
        } catch (e) {
          Log.file('请求网关运行环境错误错误', e);
        }
        maxTryCount--;
      }
      checkLogin();
    }.call();

    // () async {
    //   /// 数据迁移逻辑
    //   String flavor = await aboutSystemChannel.queryFlavor();
    //   String version = await aboutSystemChannel.getAppVersion();
    //   if (flavor == 'LD' || flavor == 'JH') {
    //     if (version == '0120' &&
    //         !Setting.instant().checkVersionCompatibility(version)) {
    //       if (!System.isLogin()) {
    //         Future.delayed(Duration.zero).then((_) {
    //           Navigator.pushNamed(context, 'MigrationOldVersionDataPage');
    //         });
    //         return;
    //       }
    //     }
    //   }
    //
    //   /// 正常的跳转逻辑
    //   checkLogin();
    // }.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(child: Image.asset('assets/imgs/setting/ig_app_bg.png')),
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
    if (MideaRuntimePlatform.platform == GatewayPlatform.NONE) {
      Navigator.pushNamed(
        context,
        'Login',
      );
    } else {
      var isFinishLogin = System.isLogin() &&
          System.familyInfo != null &&
          System.roomInfo != null;

      Navigator.pushNamed(
        context,
        isFinishLogin ? 'Home' : 'Login',
      );

      if (isFinishLogin) {
        Push.sseInit();
      }
    }

  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _Boot();
}
