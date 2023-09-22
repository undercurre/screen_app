import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/states/layout_notifier.dart';
import 'package:screen_app/states/weather_change_notifier.dart';
import '../../channel/index.dart';
import '../../common/gateway_platform.dart';
import '../../common/homlux/api/homlux_user_api.dart';
import '../../common/homlux/models/homlux_response_entity.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/api/meiju_device_api.dart';
import '../../common/meiju/models/meiju_delete_device_result_entity.dart';
import '../../common/meiju/models/meiju_response_entity.dart';
import '../../common/setting.dart';
import '../../common/system.dart';
import '../../common/utils.dart';
import '../../widgets/mz_cell.dart';
import '../../widgets/mz_dialog.dart';
import '../../widgets/util/net_utils.dart';

class AdvancedSettingPage extends StatefulWidget {
  const AdvancedSettingPage({super.key});

  @override
  AdvancedSettingPageState createState() => AdvancedSettingPageState();
}

class AdvancedSettingPageState extends State<AdvancedSettingPage> {

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
                    const Text("高级设置",
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        width: 432,
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        decoration: const BoxDecoration(
                            color: Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: Column(
                          children: [
                            if(!Setting.instant().engineeringModeEnable) settingCell("清除用户数据", null, true, false, null, clearButton()),

                            settingCell("重启系统", null, true, false, null, rebootButton()),

                            settingCell("当前平台", () {
                                if (Setting.instant().engineeringModeEnable) {
                                  return;
                                }
                                Navigator.pushNamed(context, 'CurrentPlatformPage');
                              },
                                false,
                                !Setting.instant().engineeringModeEnable,
                                MideaRuntimePlatform.platform == GatewayPlatform.MEIJU ? "美居" : "Homlux",
                                null
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                        width: 432,
                      )

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget clearButton() {
    return GestureDetector(
      onTap: () {
        showClearUserDataDialog(context);
      },
      child: Container(
        width: 97,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF3B30), width: 1),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Text("清除",
            style: TextStyle(
                color: Color(0XFFFF3B30),
                fontSize: 18,
                fontFamily: "MideaType",
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none)
        ),
      ),
    );
  }

  void showClearUserDataDialog(BuildContext context) async {
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
            context.read<WeatherModel>().clearData();
            // 此处执行清除数据的业务逻辑
            clearUserData().then((value) {
              /// 清除失败关闭弹窗
              /// 清除成功的话，程序会自动重启
              if (!value) {
                TipsUtils.hideLoading();
              }
            });
          }
        }).show(context);
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
      System.logout("清除缓存，导致退出登录");
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

    if(System.inHomluxPlatform()) {
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
    } else if(System.inMeiJuPlatform()) {
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

  Widget rebootButton() {
    return GestureDetector(
      onTap: () {
        showRebootDialog(context);
      },
      child: Container(
        width: 97,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0x19FFFFFF),
        ),
        child: const Text("重启",
            style: TextStyle(
                color: Color(0X99FFFFFF),
                fontSize: 18,
                fontFamily: "MideaType",
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none)
        ),
      ),
    );
  }

  void showRebootDialog(BuildContext context) async {
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
            aboutSystemChannel.reboot();
          }
        }).show(context);
  }

  Widget settingCell(String name, Function? callback, bool? haveLine, bool hasArrow, String? rightText, Widget? rightSlot) {
    return MzCell(
      title: name,
      titleSize: 24,
      hasArrow: hasArrow,
      bgColor: Colors.transparent,
      hasBottomBorder: haveLine?? false,
      onTap: callback,
      rightText: rightText,
      rightTextColor: const Color(0x7FFFFFFF),
      rightSlot: rightSlot,
    );
  }

  @override
  void didUpdateWidget(AdvancedSettingPage oldWidget) {
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
