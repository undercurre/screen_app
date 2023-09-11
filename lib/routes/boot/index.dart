import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/push_data_adapter.dart';
import 'package:screen_app/widgets/event_bus.dart';
import '../../channel/index.dart';
import '../../common/gateway_platform.dart';
import '../../common/index.dart';
import '../../common/logcat_helper.dart';
import '../../common/setting.dart';

class _Boot extends State<Boot> {
  @override
  void initState() {
    super.initState();

    bus.on("logout", (arg) {
      PushDataAdapter(MideaRuntimePlatform.platform).stopConnect();
      System.logout();
      Navigator.pushNamedAndRemoveUntil(
          context, 'Login', (route) => route.settings.name == "/");
    });

    bus.on('change_platform', (arg) {
      if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
        ChangePlatformHelper.changeToHomlux();
      } else {
        ChangePlatformHelper.changeToMeiju();
      }
      Navigator.pushNamedAndRemoveUntil(
          context, "Login", (route) => route.settings.name == "/");
    });

    () async {
      var maxTryCount = 30;
      while (maxTryCount > 0) {
        // -1错误 0NONE 1MEIJU 2HOMLUX
        Log.file('启动查询网关环境次数${maxTryCount - 29}');
        try {
          var platform = await ChangePlatformHelper.checkGatewayPlatform();
          Log.file('查询到的运行平台为$platform');
          if (platform != -1) {
            if (platform == 1) {
              await ChangePlatformHelper.changeToMeiju(false);
              MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
            } else if (platform == 2) {
              await ChangePlatformHelper.changeToHomlux(false);
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
    //   String version = await aboutSystemChannel.getAppVersion();
    //   if (version == '0120' &&!Setting.instant().checkVersionCompatibility(version)) {
    //     if (!System.isLogin()) {
    //       if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
    //         Future.delayed(Duration.zero).then((_) {
    //           Navigator.pushNamed(context, 'MigrationOldVersionMeiJuDataPage');
    //         });
    //       } else if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
    //         Future.delayed(Duration.zero).then((_) {
    //           Navigator.pushNamed(context, 'MigrationOldVersionHomLuxDataPage');
    //         });
    //       }
    //       return;
    //     }
    //   }
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

    /// 数据迁移逻辑
    () async {
      if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
        String? isMigrate = await migrateChannel.meiJuIsMigrate();
        if (isMigrate == "0") {
          Future.delayed(Duration.zero).then((_) {
            Navigator.pushNamed(context, 'MigrationOldVersionMeiJuDataPage');
          });
        } else {
          bool isLogin = System.isLogin();
          bool familyInfo = System.familyInfo != null;
          bool roomInfo = System.roomInfo != null;
          Log.i('isLogin = $isLogin '
              'familyInfo = $familyInfo '
              'roomInfo = $roomInfo');
          var isFinishLogin = System.isLogin() &&
              System.familyInfo != null &&
              System.roomInfo != null;
          Navigator.pushNamed(
            context,
            isFinishLogin ? 'Home' : 'Login',
          );
          if (isFinishLogin) {
            System.login();
          } else {
            System.logout();
          }
        }
      } else if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
        String? isMigrate = await migrateChannel.homluxIsMigrate();
        if(isMigrate == "0"){
          Future.delayed(Duration.zero).then((_) {
            Navigator.pushNamed(context, 'MigrationOldVersionHomLuxDataPage');
          });
        }else{
          bool isLogin = System.isLogin();
          bool familyInfo = System.familyInfo != null;
          bool roomInfo = System.roomInfo != null;
          Log.i('isLogin = $isLogin '
              'familyInfo = $familyInfo '
              'roomInfo = $roomInfo');
          var isFinishLogin = System.isLogin() &&
              System.familyInfo != null &&
              System.roomInfo != null;
          Navigator.pushNamed(
            context,
            isFinishLogin ? 'Home' : 'Login',
          );
          if (isFinishLogin) {
            System.login();
          } else {
            System.logout();
          }
        }
      } else {
        Navigator.pushNamed(
          context,
          'Login',
        );
      }
      return;
    }.call();
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _Boot();
}
