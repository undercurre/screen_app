import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/homlux/api/homlux_user_api.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/meiju/api/meiju_device_api.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:screen_app/widgets/gesture/mutil_click.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import 'package:flutter/foundation.dart';

import '../../channel/index.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/models/meiju_delete_device_result_entity.dart';
import '../../common/setting.dart';
import '../../widgets/event_bus.dart';
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
  bool? debug;
  bool? isEngineeringEnable;
  bool? hasNewVersion;

  AboutSettingProvider() {
    // 初始化页面数据
    init();
    debug = !kReleaseMode;
  }

  void init() {
    bus.on('ota-new-version-tip', (arg) {
      hasNewVersion = arg as bool;
      notifyListeners();
    });
    Timer(const Duration(milliseconds: 250), () async {
      deviceName = "智慧屏P4";
      familyName = System.familyInfo?.familyName ?? "未登录";
      ipAddress = await aboutSystemChannel.getIpAddress();
      macAddress = await aboutSystemChannel.getMacAddress();
      systemVersion = await aboutSystemChannel.getSystemVersion();
      // 可能获取时间比较长
      snCode = await aboutSystemChannel.getGatewaySn();
      isLogin = System.isLogin();
      isEngineeringEnable = Setting.instant().engineeringModeEnable;
      hasNewVersion = otaChannel.hasNewVersion;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    Log.i('执行了dispose');
    super.dispose();
    bus.off('ota-new-version-tip');
  }

  void updateEngineeringEnable() {
    isEngineeringEnable = Setting.instant().engineeringModeEnable;
    notifyListeners();
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
    if (NetUtils.getNetState() == null) {
      TipsUtils.toast(
          content: '请连接网络', position: EasyLoadingToastPosition.bottom);
      return;
    }
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
    LocalStorage.clearAllData();
    gatewayChannel.controlRelay1Open(false);
    gatewayChannel.controlRelay2Open(false);
    aboutSystemChannel.clearLocalCache();
    Timer(const Duration(seconds: 7), () {
      aboutSystemChannel
          .getAppVersion()
          .then((value) => Setting.instant().saveVersionCompatibility(value));
      System.logout("清除所有缓存，导致退出登录");
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

    if (System.inHomluxPlatform()) {
      HomluxResponseEntity? result;
      try {
        result = await HomluxUserApi.deleteDevices([
          {
            'deviceId': await System.gatewayApplianceCode ?? '',
            'deviceType': '1'
          }
        ]);
      } catch (e) {
        Log.e("删除设备错误", e);
      }
      if ((result?.isSuccess != true) && tryCount > 0) {
        return deleteGateway(--tryCount);
      }
    } else if (System.inMeiJuPlatform()) {
      MeiJuResponseEntity<MeiJuDeleteDeviceResultEntity>? result;

      try {
        result = await MeiJuDeviceApi.deleteDevices(
            [await System.gatewayApplianceCode ?? ''],
            System.familyInfo?.familyId ?? '');
        if (result.isSuccess) {
          return true;
        }
      } catch (e) {
        Log.e("删除设备错误", e);
      }

      if ((result?.isSuccess != true) && tryCount > 0) {
        return deleteGateway(--tryCount);
      }
    }

    return false;
  }
}

class AboutSettingPage extends StatefulWidget {
  const AboutSettingPage({super.key});

  @override
  State<AboutSettingPage> createState() => _AboutSettingPageState();
}

class _AboutSettingPageState extends State<AboutSettingPage> {
  AboutSettingProvider? provider;

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

  void showLogoutDialog(BuildContext context) {
    MzDialog(
        contentSlot: const Text('此操作将退出到扫码登录界面，是否继续?',
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
            const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        onPressed: (_, index, context) {
          if (index == 1) {
            System.logout("手动退出登录");
          } else {
            Navigator.pop(context);
          }
        }).show(context);
  }

  void showChangePlatformDialog(BuildContext context) {
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        onPressed: (_, index, context) {
          if (index == 1) {
            bus.emit('change_platform');
          } else {
            Navigator.pop(context);
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
                provider = context.read<AboutSettingProvider>();
                return Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        if(System.inHomluxPlatform()) Container(
                          margin: const EdgeInsets.only(bottom: 23),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: const Image(
                                image: AssetImage('assets/newUI/HomOS.png'),
                                fit: BoxFit.cover),
                          ),
                        ),
                        Container(
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
                                onLongTap: () {
                                  Navigator.pushNamed(
                                          context, 'EngineeringModePage')
                                      .then((value) {
                                    context
                                        .read<AboutSettingProvider>()
                                        .updateEngineeringEnable();
                                  });
                                },
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
                                ]),
                              ),
                              MultiClick(
                                duration: 3000,
                                count: 5,
                                clickListener: () {
                                  if (context
                                          .read<AboutSettingProvider>()
                                          .isEngineeringEnable ==
                                      true) {
                                    return;
                                  }
                                  context
                                      .read<AboutSettingProvider>()
                                      .checkDirectUpgrade();
                                },
                                child: MzSettingItem(
                                  gestureEnable: false,
                                  leftText: '系统版本',
                                  rightText: context
                                          .watch<AboutSettingProvider>()
                                          .systemVersion ??
                                      '',
                                ),
                              ),
                              MzSettingItem(
                                onLongTap: () {
                                  if (context
                                          .read<AboutSettingProvider>()
                                          .debug ==
                                      true) {
                                    Navigator.of(context)
                                        .pushNamed("developer");
                                  }
                                },
                                longTapSecond: 5,
                                leftText: 'MAC地址',
                                rightText: context
                                        .watch<AboutSettingProvider>()
                                        .macAddress ??
                                    '',
                              ),
                              MzSettingItem(
                                leftText: 'IP地址',
                                rightText: context
                                        .watch<AboutSettingProvider>()
                                        .ipAddress ??
                                    '',
                              ),
                              MzSettingItem(
                                leftText: 'SN码',
                                rightTextSize: 18,
                                rightTextAlign: TextAlign.right,
                                rightText: context
                                        .watch<AboutSettingProvider>()
                                        .snCode ??
                                    "获取失败",
                              ),
                              if (context
                                      .watch<AboutSettingProvider>()
                                      .isEngineeringEnable ==
                                  false)
                                MzSettingItem(
                                  leftText: '应用升级',
                                  rightWidget: MzSettingButton(
                                    onTap: () {
                                      context
                                          .read<AboutSettingProvider>()
                                          .checkUpgrade();
                                    },
                                    text: otaChannel.hasNewVersion
                                        ? "立即更新"
                                        : "检查更新",
                                  ),
                                  tipText:
                                      otaChannel.hasNewVersion ? 'New' : null,
                                ),
                              if (context.read<AboutSettingProvider>().debug ==
                                      true &&
                                  context
                                          .watch<AboutSettingProvider>()
                                          .isEngineeringEnable ==
                                      false)
                                MzSettingItem(
                                  onTap: () {
                                    showLogoutDialog(context);
                                  },
                                  leftText: '账号管理[Debug模式]',
                                  rightWidget: MzSettingButton(
                                    text: '退出登录',
                                    backgroundColor: Colors.transparent,
                                    borderColor:
                                        const Color.fromRGBO(255, 59, 48, 1),
                                    fontColor:
                                        const Color.fromRGBO(255, 59, 48, 1),
                                  ),
                                )
                              // MzSettingItem(
                              //   onTap: () {
                              //     showRebootDialog(
                              //         context, context.read<AboutSettingProvider>());
                              //   },
                              //   leftText: '重启系统',
                              //   rightWidget: MzSettingButton(
                              //     text: '重启',
                              //   ),
                              // ),
                              // MzSettingItem(
                              //   onTap: () {
                              //     showClearUserDataDialog(
                              //         context, context.read<AboutSettingProvider>());
                              //   },
                              //   leftText: '清除用户数据',
                              //   rightWidget: MzSettingButton(
                              //     text: '清除',
                              //     backgroundColor: Colors.transparent,
                              //     borderColor: const Color.fromRGBO(255, 59, 48, 1),
                              //     fontColor: const Color.fromRGBO(255, 59, 48, 1),
                              //   ),
                              // ),
                              // MzSettingItem(
                              //   onTap: () {
                              //     MzDialog(
                              //         contentSlot: const Text('此操作将退出到选择平台界面，是否继续?',
                              //             textAlign: TextAlign.center,
                              //             style: TextStyle(
                              //                 fontSize: 20,
                              //                 fontFamily: 'MideaType',
                              //                 fontWeight: FontWeight.w100,
                              //                 height: 1.2)),
                              //         title: "切换平台",
                              //         maxWidth: 400,
                              //         btns: ['取消', '确定'],
                              //         contentPadding: const EdgeInsets.symmetric(
                              //             vertical: 30, horizontal: 50),
                              //         onPressed: (_, index, context) {
                              //           if (index == 1) {
                              //             if (MideaRuntimePlatform.platform ==
                              //                 GatewayPlatform.MEIJU) {
                              //               ChangePlatformHelper.changeToHomlux();
                              //             } else {
                              //               ChangePlatformHelper.changeToMeiju();
                              //             }
                              //             Push.dispose();
                              //             Navigator.pushNamedAndRemoveUntil(
                              //                 context,
                              //                 "Login",
                              //                 (route) => route.settings.name == "/");
                              //           } else {
                              //             Navigator.pop(context);
                              //           }
                              //         }).show(context);
                              //   },
                              //   leftText: '切换平台',
                              //   containBottomDivider: false,
                              //   rightWidget: MzSettingButton(
                              //     text: '切换',
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            )
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
