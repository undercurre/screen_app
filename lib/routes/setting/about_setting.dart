import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/widgets/gesture/mutil_click.dart';

import '../../channel/index.dart';
import '../../common/global.dart';

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
    () async {
      deviceName = "智慧屏P4";
      familyName = Global.isLogin ? Global.profile.homeInfo?.nickname : "未登录";
      ipAddress = await aboutSystemChannel.getIpAddress();
      macAddress = await aboutSystemChannel.getMacAddress();
      systemVersion = await aboutSystemChannel.getSystemVersion();
      notifyListeners();
    }.call();
    () async {
      // 可能获取时间比较长
      snCode = await aboutSystemChannel.getGatewaySn();
      notifyListeners();
    }.call();
  }

  void checkDirectUpgrade() {
    TipsUtils.toast(content: '正在检查更新');
    if(otaChannel.isInit) {
      if(otaChannel.isDownloading) {
        TipsUtils.toast(content: "已经在下载中...");
      } else {
        otaChannel.checkDirect();
      }
    } else {
      TipsUtils.toast(content: "已经是最新版本");
    }
  }

  void checkUpgrade() {
    TipsUtils.toast(content: '正在检查更新');
    if(otaChannel.isInit) {
      if(otaChannel.isDownloading) {
        TipsUtils.toast(content: "已经在下载中...");
      } else {
        otaChannel.checkNormalAndRom(false);
      }
    } else {
      TipsUtils.toast(content: "已经是最新版本");
    }
  }

  void reboot() {
    aboutSystemChannel.reboot();
  }

  void clearUserData() {
    System.loginOut();

    Timer.periodic(const Duration(seconds: 10), (timer) {
      aboutSystemChannel.reboot();
    });
  }

}

class AboutSettingPage extends StatelessWidget {

    const AboutSettingPage({super.key});

    void showRebootDialog(BuildContext context, AboutSettingProvider provider) async {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (buildContext) {
            return RebootDialog(
              title: "重启设备",
              content: "此操作将使网关子设备暂时离线，是否确认重启？",
              confirmAction: () {
                provider.reboot();
              },
            );
          }
      );
    }

    void showClearUserDataDialog(BuildContext context, AboutSettingProvider provider) async {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (buildContext) {
            return RebootDialog(
              title: "清除用户数据",
              content: "此操作将退出当前账号，清除所有用户数据并重启，是否确认清除",
              confirmAction: () {
                TipsUtils.showLoading("正在清除中...");
                // 此处执行清除数据的业务逻辑
                provider.clearUserData();
              },
            );
          }
      );
    }

    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider<AboutSettingProvider>(
        create: (context) => AboutSettingProvider(),
        child: Builder(
          builder: (context) {
            print("about 构建第一次");
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
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    'Home',
                                  );
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
                        Expanded(child: SingleChildScrollView(
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
                                    child: Text(
                                        context.watch<AboutSettingProvider>().familyName ?? '',
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
                                      child: const Text("应用升级",
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
                                      child: const Text("检查更新",
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
                        ))
                      ],
                    ),
                  )),
            );
          }
        ));

    }
}

class RebootDialog extends StatelessWidget {
  final String title;
  final String content;
  final void Function() confirmAction;
  const RebootDialog({super.key, required this.title, required this.content, required this.confirmAction});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        color: const Color(0xff1b1b1b),
        width:423,
        height: 204,
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                )
            ),
            Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child:Padding(padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                  ),)
                )
            ),
            Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color(0xff282828)),
                            shape: MaterialStateProperty.all(const RoundedRectangleBorder())),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消', style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color(0xff267AFF)),
                            shape: MaterialStateProperty.all(const RoundedRectangleBorder())),
                        onPressed: () {
                          confirmAction.call();
                          Navigator.pop(context);
                        },
                        child: const Text('确定', style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),)
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
