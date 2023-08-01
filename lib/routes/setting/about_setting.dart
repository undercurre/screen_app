import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/widgets/gesture/mutil_click.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../channel/index.dart';
import '../../common/gateway_platform.dart';
import '../../common/logcat_helper.dart';
import '../../common/setting.dart';
import '../../models/delete_device_result_entity.dart';
import '../../models/midea_response_entity.dart';
import '../../widgets/mz_setting_item.dart';

// 关于页的数据提供者
class AboutSettingProvider with ChangeNotifier {
  String? deviceName;
  String? familyName;
  String? systemVersion;
  String? macAddress;
  String? ipAddress;
  String? snCode;
  bool? isLogin;

  AboutSettingProvider() {
    // 初始化页面数据
    init();
  }

  void init() {
    Timer(const Duration(milliseconds: 250), () async {
      deviceName = "智慧屏P4";
      familyName = System.isLogin() ? System.familyInfo?.familyName : "未登录";
      ipAddress = await aboutSystemChannel.getIpAddress();
      macAddress = await aboutSystemChannel.getMacAddress();
      systemVersion = await aboutSystemChannel.getSystemVersion();
      // 可能获取时间比较长
      snCode = await aboutSystemChannel.getGatewaySn();
      isLogin = System.isLogin();
      notifyListeners();
    });
  }

  void checkDirectUpgrade() {
    TipsUtils.toast(
        content: '正在检查更新', position: EasyLoadingToastPosition.bottom);
    if (otaChannel.isDownloading) {
      TipsUtils.toast(
          content: "已经在下载中...", position: EasyLoadingToastPosition.bottom);
    } else {
      otaChannel.checkDirect();
    }
  }

  void checkUpgrade() {
    TipsUtils.toast(
        content: '正在检查更新', position: EasyLoadingToastPosition.bottom);
    if (otaChannel.isDownloading) {
      TipsUtils.toast(
          content: "已经在下载中...", position: EasyLoadingToastPosition.bottom);
    } else {
      otaChannel.checkNormalAndRom(false);
    }
  }

  void reboot() {
    aboutSystemChannel.reboot();
  }

  /// return
  ///  false 清除失败
  ///  true 清除成功
  Future<bool> clearUserData() async {
    // 删除网关设备，并且尝试五次删除
    // bool deleteResult = await deleteGateway(5);
    // if(deleteResult) {

    // 删除网关设备，并且尝试五次删除
    try {
      await deleteGateway(5);
    } finally {}
    // 重置网关设备
    gatewayChannel.resetGateway();
    // 删除所有的wifi记录
    netMethodChannel.removeAllWiFiRecord();
    // 删除本地所有缓存
    aboutSystemChannel.clearLocalCache();
    Timer(const Duration(seconds: 7), () {
      aboutSystemChannel
          .getAppVersion()
          .then((value) => Setting.instant().saveVersionCompatibility(value));
      System.loginOut();
    });
    // 定时十秒
    Timer(const Duration(seconds: 10), () {
      aboutSystemChannel.reboot();
    });
    return true;
  }

  /// return
  ///  false 删除失败
  ///  true 删除成功
  Future<bool> deleteGateway(int tryCount) async {
    if (NetUtils.getNetState() == null) {
      TipsUtils.toast(content: '请先连接网络');
      return false;
    }

    MideaResponseEntity<DeleteDeviceResultEntity>? result;

    try {
      result = await DeviceApi.deleteDevices(
          [Global.profile.applianceCode ?? ''],
          Global.profile.homeInfo?.homegroupId ?? '');
      if (result.isSuccess) {
        return true;
      }
    } catch (e) {
      Log.e("删除设备错误", e);
    }

    if ((result?.isSuccess != true) && tryCount > 0) {
      return deleteGateway(--tryCount);
    }

    return false;
  }
}

class AboutSettingPage extends StatelessWidget {
  const AboutSettingPage({super.key});

  void showInstallFail(
      BuildContext context, AboutSettingProvider provider) async {
    MzDialog(
        title: '安装失败',
        titleSize: 28,
        maxWidth: 432,
        btns: ['取消', '确定'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            // 此处执行清除数据的业务逻辑
            provider.reboot();
          }
        }).show(context);
  }

  void showUpdateGoing(
      BuildContext context, AboutSettingProvider provider) async {
    MzDialog(
        title: '正在安装更新',
        titleSize: 28,
        maxWidth: 432,
        contentSlot: const Column(
          children: [
            Text('更新中其他功能不可使用，期间会重启，请勿断电',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    color: Color.fromRGBO(255, 255, 255, 0.60),
                    fontFamily: 'MideaType',
                    fontWeight: FontWeight.w400,
                    height: 1.2)),
            MzSlider(width: 300, height: 4, value: 60),
            Text(
              '60%',
              style: TextStyle(fontSize: 60, color: Colors.white),
            )
          ],
        ),
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            // 此处执行清除数据的业务逻辑
            provider.reboot();
          }
        }).show(context);
  }

  void showUpdateVersion(
      BuildContext context, AboutSettingProvider provider) async {
    MzDialog(
        title: '有新版本可用',
        titleSize: 28,
        maxWidth: 432,
        contentSlot: const Text('此操作将使网关子设备暂时离线，是否确认重启？',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(255, 255, 255, 0.60),
                fontFamily: 'MideaType',
                fontWeight: FontWeight.w400,
                height: 1.2)),
        btns: ['取消', '更新'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            // 此处执行清除数据的业务逻辑
            provider.reboot();
          }
        }).show(context);
  }

  void showRebootDialog(
      BuildContext context, AboutSettingProvider provider) async {
    MzDialog(
        title: '重启设备',
        titleSize: 28,
        maxWidth: 432,
        contentSlot: const Text('此操作将使网关子设备暂时离线，是否确认重启？',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(255, 255, 255, 0.60),
                fontFamily: 'MideaType',
                fontWeight: FontWeight.w100,
                height: 1.2)),
        btns: ['取消', '确定'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            // 此处执行清除数据的业务逻辑
            provider.reboot();
          }
        }).show(context);
  }

  void showClearUserDataDialog(
      BuildContext context, AboutSettingProvider provider) async {
    MzDialog(
        title: '清除用户数据',
        titleSize: 28,
        maxWidth: 432,
        contentSlot: const Text('此操作将退出当前账号，清除所有用户数据并重启，是否确认清除?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(255, 255, 255, 0.60),
                fontFamily: 'MideaType',
                fontWeight: FontWeight.w100,
                height: 1.2)),
        btns: ['取消', '确定'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            TipsUtils.showLoading("正在清除中...");
            // 此处执行清除数据的业务逻辑
            provider.clearUserData().then((value) {
              /// 清除失败关闭弹窗
              /// 清除成功的话，程序会自动重启
              if (!value) {
                TipsUtils.hideLoading();
              }
            });
          }
        }).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        width: 480,
        height: 480,
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              height: 84,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTapDown: (e) {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/newUI/back.png",
                    ),
                  ),
                  const Text("关于本机",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.85),
                        fontSize: 28.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                  GestureDetector(
                    onTapDown: (e) {
                      Navigator.popUntil(
                          context, (route) => route.settings.name == 'Home');
                    },
                    child: Image.asset(
                      "assets/newUI/back_home.png",
                    ),
                  ),
                ],
              ),
            ),
            ChangeNotifierProvider<AboutSettingProvider>(
              create: (context) => AboutSettingProvider(),
              child: Builder(builder: (context) {
                return Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    width: 432,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.05),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        MzSettingItem(
                          leftText: '设备名称',
                          rightText: context
                                  .watch<AboutSettingProvider>()
                                  .deviceName ??
                              '',
                        ),
                        MzSettingItem(
                          leftText: '所在家庭',
                          rightWidget: Row(children: [
                            Text(
                                context
                                        .watch<AboutSettingProvider>()
                                        .familyName ??
                                    '',
                                style: const TextStyle(
                                  color: Color(0X7fFFFFFF),
                                  fontSize: 20.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                            const SizedBox(width: 10),
                            if (context.watch<AboutSettingProvider>().isLogin ?? false)
                              MzSettingButton(
                                onTap: () {
                                  MzDialog(
                                      contentSlot: const Text(
                                          '此操作将退出到扫码登录界面，是否继续?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'MideaType',
                                              fontWeight: FontWeight.w100,
                                              height: 1.2)),
                                      title: "登出",
                                      maxWidth: 400,
                                      btns: ['取消', '确定'],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 30, horizontal: 50),
                                      onPressed: (_, index, context) {
                                        if (index == 1) {
                                          Push.dispose();
                                          System.loginOut();
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              "Login",
                                              (route) =>
                                                  route.settings.name == "/");
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      }).show(context);
                                },
                                text: '登出',
                                borderColor: const Color(0xFF0092DC),
                                backgroundColor: const Color(0x330092DC),
                                fontColor: const Color(0xFF0092DC),
                              )
                          ]),
                        ),
                        MultiClick(
                          duration: 3000,
                          count: 5,
                          clickListener: () {
                            context
                                .read<AboutSettingProvider>()
                                .checkDirectUpgrade();
                          },
                          child: MzSettingItem(
                            leftText: '系统版本',
                            rightText: context
                                    .watch<AboutSettingProvider>()
                                    .systemVersion ??
                                '',
                          ),
                        ),
                        MultiClick(
                          count: 5,
                          duration: 3000,
                          clickListener: () =>
                              Navigator.of(context).pushNamed("developer"),
                          child: MzSettingItem(
                            leftText: 'MAC地址',
                            rightText: context
                                    .watch<AboutSettingProvider>()
                                    .macAddress ??
                                '',
                          ),
                        ),
                        MzSettingItem(
                          leftText: 'IP地址',
                          rightText:
                              context.watch<AboutSettingProvider>().ipAddress ??
                                  '',
                        ),
                        MzSettingItem(
                          leftText: 'SN码',
                          rightTextSize: 16.0,
                          rightTextAlign: TextAlign.left,
                          rightText:
                              context.watch<AboutSettingProvider>().snCode ??
                                  "获取失败",
                        ),
                        MzSettingItem(
                          onTap: () {
                            showUpdateGoing(
                                context, context.read<AboutSettingProvider>());
                            context.read<AboutSettingProvider>().checkUpgrade();
                          },
                          leftText: '应用升级',
                          rightWidget: MzSettingButton(
                            text: otaChannel.hasNewVersion ? "立即更新" : "检查更新",
                          ),
                          tipText: otaChannel.hasNewVersion ? 'New' : null,
                        ),
                        MzSettingItem(
                          onTap: () {
                            showRebootDialog(
                                context, context.read<AboutSettingProvider>());
                          },
                          leftText: '重启系统',
                          rightWidget: MzSettingButton(
                            text: '重启',
                          ),
                        ),
                        MzSettingItem(
                          onTap: () {
                            showClearUserDataDialog(
                                context, context.read<AboutSettingProvider>());
                          },
                          leftText: '清除用户数据',
                          rightWidget: MzSettingButton(
                            text: '清除',
                            backgroundColor: Colors.transparent,
                            borderColor: const Color.fromRGBO(255, 59, 48, 1),
                            fontColor: const Color.fromRGBO(255, 59, 48, 1),
                          ),
                        ),
                        MzSettingItem(
                          onTap: () {
                            MzDialog(
                                contentSlot: const Text('此操作将退出到选择平台界面，是否继续?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'MideaType',
                                        fontWeight: FontWeight.w100,
                                        height: 1.2)),
                                title: "切换平台",
                                maxWidth: 400,
                                btns: ['取消', '确定'],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 50),
                                onPressed: (_, index, context) {
                                  if (index == 1) {
                                    if (MideaRuntimePlatform.platform ==
                                        GatewayPlatform.MEIJU) {
                                      ChangePlatformHelper.changeToHomlux(
                                          context);
                                    } else {
                                      ChangePlatformHelper.changeToMeiju(
                                          context);
                                    }
                                    Push.dispose();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        "Login",
                                        (route) => route.settings.name == "/");
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }).show(context);
                          },
                          leftText: '切换平台',
                          containBottomDivider: false,
                          rightWidget: MzSettingButton(
                            text: '切换',
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
              }),
            )
          ],
        ),
      )),
    );
  }
}
