import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/push_data_adapter.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
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
      changePageToLogin();
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
      bootFinish();
    }.call();
  }

  // 防止Login页面重入
  void changePageToLogin() {
    bool isNewRouteSameAsCurrent = false;
    bool isNewRouteSameAsContain = false;
    Navigator.popUntil(context, (route) {
      if(route.isCurrent && route.settings.name == "Login") {
        isNewRouteSameAsCurrent = true;
      } else if(route.settings.name == "Login") {
        isNewRouteSameAsContain = true;
      }
      return true;
    });
    if(isNewRouteSameAsCurrent) {
      Log.i("当前页面为Login, 拦截重入跳入");
      return;
    } else if(isNewRouteSameAsContain) {
      Log.i("当前页面栈中包含Login");
    }
    Navigator.pushNamedAndRemoveUntil(
        context, "Login", (route) => route.settings.name == "/");
  }

  void checkGetWay() async {
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
            judgePage();
          } else if (platform == 2) {
            await ChangePlatformHelper.changeToHomlux(false);
            MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
            judgePage();
          } else {
            if(MeiJuGlobal.token != null && MeiJuGlobal.homeInfo != null && MeiJuGlobal.roomInfo != null && MeiJuGlobal.gatewayApplianceCode != null) {
              await ChangePlatformHelper.changeToMeiju(false);
              MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
              await gatewayChannel.setMeijuPlatFormFlag();
            } else if (HomluxGlobal.homluxQrCodeAuthEntity != null && HomluxGlobal.homluxUserInfo != null && HomluxGlobal.homluxRoomInfo != null && HomluxGlobal.gatewayApplianceCode != null && HomluxGlobal.homluxHomeInfo!=null) {
              await ChangePlatformHelper.changeToHomlux(false);
              MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
            } else {
              MideaRuntimePlatform.platform = GatewayPlatform.NONE;
            }
            judgePage();
          }
          break;
        }
      } catch (e) {
        Log.file('请求网关运行环境错误错误', e);
      }
      maxTryCount--;
    }
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

    const flavor = String.fromEnvironment('flavor', defaultValue: "JH");
    if(flavor == 'LD') {
      Future.microtask(() async {
        await ChangePlatformHelper.changeToMeiju(false);
        MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
        judgePage();
      });
      return;
    }

    /// 数据迁移逻辑
    () async {
        String? isMigrate = await migrateChannel.meiJuIsMigrate();
        if (isMigrate == "0" && !System.isLogin()) {
          // Log.file("进入迁移界面$isMigrate----${System.isLogin()}");
          Future.delayed(Duration.zero).then((_) {
            Navigator.pushNamed(context, 'MigrationOldVersionMeiJuDataPage').then((value) {
              Log.i('迁移返回');
              checkGetWay();
            });
          });
        } else {
          checkGetWay();
        }

      return;
    }.call();
  }

  void judgePage(){
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
      System.login(true);
    } else {
      System.logout("数据迁移失败", false);
    }
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _Boot();
}
