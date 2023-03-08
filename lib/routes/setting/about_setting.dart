import 'dart:async';

import 'package:catcher/core/catcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/widgets/gesture/mutil_click.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../channel/index.dart';
import '../../common/global.dart';
import '../../models/delete_device_result_entity.dart';
import '../../models/midea_response_entity.dart';

// 关于页的数据提供者
class AboutSettingProvider with ChangeNotifier {
  String? deviceName;
  String? familyName;
  String? systemVersion;
  String? macAddress;
  String? ipAddress;
  String? snCode;

  AboutSettingProvider() {
    // 初始化页面数据
    init();
  }

  void init() {
    Timer(const Duration(milliseconds: 250), () async {
      deviceName = "智慧屏P4";
      familyName = Global.isLogin ? Global.profile.homeInfo?.nickname : "未登录";
      ipAddress = await aboutSystemChannel.getIpAddress();
      macAddress = await aboutSystemChannel.getMacAddress();
      systemVersion = await aboutSystemChannel.getSystemVersion();
      // 可能获取时间比较长
      snCode = await aboutSystemChannel.getGatewaySn();
      notifyListeners();
    });
  }

  void checkDirectUpgrade() {
    TipsUtils.toast(content: '正在检查更新', position: EasyLoadingToastPosition.bottom);
    if(otaChannel.isDownloading) {
      TipsUtils.toast(content: "已经在下载中...", position: EasyLoadingToastPosition.bottom);
    } else {
      otaChannel.checkDirect();
    }
  }

  void checkUpgrade() {
    TipsUtils.toast(content: '正在检查更新', position: EasyLoadingToastPosition.bottom);
    if(otaChannel.isDownloading) {
      TipsUtils.toast(content: "已经在下载中...", position: EasyLoadingToastPosition.bottom);
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
      // 定时十秒
      Timer(const Duration(seconds: 8), () {
        //System.loginOut();
        Timer(const Duration(seconds: 2), () {
          aboutSystemChannel.reboot();
        });
      });
      return true;

    // } else {
    //   TipsUtils.toast(content: '删除网关失败，请重试');
    //   return false;
    // }
  }

  /// return 
  ///  false 删除失败
  ///  true 删除成功
  Future<bool> deleteGateway(int tryCount) async {

    if(NetUtils.getNetState() == null) {
      TipsUtils.toast(content: '请先连接网络');
      return false;
    }

    MideaResponseEntity<DeleteDeviceResultEntity>? result;

    try {
      result = await DeviceApi.deleteDevices([Global.profile.applianceCode ?? ''], Global.profile.homeInfo?.homegroupId ?? '');
      if(result.isSuccess) {
        return true;
      }
    } catch(e) {
      logger.e(e);
    }

    if((result?.isSuccess != true) && tryCount > 0) {
      return deleteGateway(--tryCount);
    }

    return false;
  }

}

class AboutSettingPage extends StatelessWidget {

    const AboutSettingPage({super.key});

    void showRebootDialog(BuildContext context, AboutSettingProvider provider) async {
      MzDialog(
          title: '重启设备',
          maxWidth: 400,
          contentSlot: const Text(
              '此操作将使网关子设备暂时离线，是否确认重启？',
              textAlign: TextAlign.center,
              style: TextStyle(
              fontSize: 20,
              fontFamily: 'MideaType',
              fontWeight: FontWeight.w100,
              height: 1.2)
          ),
          btns: ['取消','确定'],
          onPressed: (_, position, context) {
            Navigator.pop(context);
            if(position == 1) {
              // 此处执行清除数据的业务逻辑
              provider.reboot();
            }
          }
      ).show(context);
    }

    void showClearUserDataDialog(BuildContext context, AboutSettingProvider provider) async {
      MzDialog(
        title: '清除用户数据',
        maxWidth: 400,
        contentSlot: const Text(
            '此操作将退出当前账号，清除所有用户数据并重启，是否确认清除?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'MideaType',
                fontWeight: FontWeight.w100,
                height: 1.2)
        ),
        btns: ['取消','确定'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if(position == 1) {
            TipsUtils.showLoading("正在清除中...");
            // 此处执行清除数据的业务逻辑
            provider.clearUserData().then((value) {
              /// 清除失败关闭弹窗
              /// 清除成功的话，程序会自动重启
              if(!value) {
                TipsUtils.hideLoading();
              }
            });
          }
        }
      ).show(context);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
            child: Container(
              width: 480,
              height: 480,
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 480,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconSize: 60.0,
                          icon: Image.asset(
                            "assets/imgs/setting/fanhui.png",
                          ),
                        ),
                        const Text("关于本机",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 30.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                        IconButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.settings.name == 'Home');
                          },
                          iconSize: 60.0,
                          icon: Image.asset(
                            "assets/imgs/setting/zhuye.png",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 480,
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                  ChangeNotifierProvider<AboutSettingProvider>(
                    create: (context) => AboutSettingProvider(),
                    child: Builder(builder: (context) {
                      return Expanded(child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                                  child: const Text("设备名称",
                                      style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 24.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                                  child: Text(
                                      context.watch<AboutSettingProvider>().deviceName ?? '',
                                      style: const TextStyle(
                                        color: Color(0X7fFFFFFF),
                                        fontSize: 18.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                              ],
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                                  child: const Text("所在家庭",
                                      style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 24.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                          context.watch<AboutSettingProvider>().familyName ?? '',
                                          style: const TextStyle(
                                            color: Color(0X7fFFFFFF),
                                            fontSize: 18.0,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none,
                                          )),
                                      GestureDetector(
                                        onTap: () {
                                          MzDialog(
                                              contentSlot: const Text(
                                                  '此操作将退出到扫码登录界面，是否继续?',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: 'MideaType',
                                                      fontWeight: FontWeight.w100,
                                                      height: 1.2)
                                              ),
                                              title: "登出",
                                              maxWidth: 400,
                                              btns: ['取消','确定'],
                                              contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                                              onPressed:(_, index, context) {
                                                if(index == 1) {
                                                  Push.dispose();
                                                  System.loginOut();
                                                  Navigator.pushNamedAndRemoveUntil(context, "Login", (route) => route.settings.name == "/");
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              }
                                          ).show(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(80),
                                            color: const Color(0x2f0091FF),
                                            border: const Border(
                                              top: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                              left: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                              right: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                              bottom: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                            ),
                                          ),
                                          child: const Text("登出",
                                              style: TextStyle(
                                                color: Color(0XFFFFFFFF),
                                                fontSize: 22.0,
                                                fontFamily: "MideaType",
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            MultiClick(
                              duration: 3000,
                              count: 5,
                              clickListener: () {
                                context.read<AboutSettingProvider>().checkDirectUpgrade();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                                    child: const Text(
                                        "系统版本",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                                    child: Text(
                                        context.watch<AboutSettingProvider>().systemVersion ?? '',
                                        style:const TextStyle(
                                          color: Color(0X7fFFFFFF),
                                          fontSize: 18.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            MultiClick(
                              count: 5,
                              duration: 3000,
                              clickListener: () => Navigator.of(context).pushNamed("developer"),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                                    child: const Text("MAC地址",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                                    child: Text(
                                        context.watch<AboutSettingProvider>().macAddress ?? '',
                                        style: const TextStyle(
                                          color: Color(0X7fFFFFFF),
                                          fontSize: 18.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                                  child: const Text("IP地址",
                                      style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 24.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                                  child: Text(
                                      context.watch<AboutSettingProvider>().ipAddress ?? '',
                                      style: const TextStyle(
                                        color: Color(0X7fFFFFFF),
                                        fontSize: 18.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                              ],
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                                  child: const Text("SN码",
                                      style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 24.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                                  child: Text(
                                      context.watch<AboutSettingProvider>().snCode ?? "获取失败",
                                      style: const TextStyle(
                                        color: Color(0X7fFFFFFF),
                                        fontSize: 16.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                              ],
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => {
                                context.read<AboutSettingProvider>().checkUpgrade()
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 0, 18),
                                    child: Row(
                                      children: [
                                        const Text("应用升级",
                                            style: TextStyle(
                                              color: Color(0XFFFFFFFF),
                                              fontSize: 24.0,
                                              fontFamily: "MideaType",
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                            )),
                                        if(otaChannel.hasNewVersion)
                                          const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Text('New',
                                                style: TextStyle(
                                                  color: Colors.blueAccent
                                                ),
                                              ),
                                            )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                    margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      color: const Color(0x2f0091FF),
                                      border: const Border(
                                        top: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                        left: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                        right: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                        bottom: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                      ),
                                    ),
                                    child: Text(otaChannel.hasNewVersion ? "立即更新":"检查更新",
                                        style: const TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 22.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => showRebootDialog(context, context.read<AboutSettingProvider>()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 0, 18),
                                    child: const Text("重启系统",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                    margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      color: const Color(0x2f0091FF),
                                      border: const Border(
                                        top: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                        left: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                        right: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                        bottom: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                                      ),
                                    ),
                                    child: const Text("重启",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 22.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 464,
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Color(0xff232323),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => showClearUserDataDialog(context, context.read<AboutSettingProvider>()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(28, 18, 0, 18),
                                    child: const Text("清除用户数据",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                    margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      color: const Color(0x2fFF1B12),
                                      border: const Border(
                                        top: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                                        left: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                                        right: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                                        bottom: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                                      ),
                                    ),
                                    child: const Text("清除",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 22.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
