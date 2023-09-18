import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/models/homlux_device_entity.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/api/meiju_device_api.dart';
import 'package:screen_app/widgets/mz_buttion.dart';

import '../../common/adapter/bind_gateway_data_adapter.dart';
import '../../common/adapter/select_family_data_adapter.dart';
import '../../common/adapter/select_room_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/index.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/meiju_global.dart';
import '../../models/device_entity.dart';
import '../../states/device_list_notifier.dart';
import '../../states/layout_notifier.dart';
import '../../widgets/business/net_connect.dart';
import '../../widgets/business/select_home.dart';
import '../../widgets/business/select_room.dart';
import '../../widgets/mz_dialog.dart';
import '../../widgets/util/net_utils.dart';
import '../home/device/card_type_config.dart';
import '../home/device/layout_data.dart';
import 'chose_platform.dart';
import 'scan_code.dart';

class Step {
  String title;
  Widget view;

  Step(this.title, this.view);
}

class _LoginPage extends State<LoginPage> with WidgetNetState {
  /// 当前步骤，1-4
  var stepNum = 1;
  bool isNeedChoosePlatform = false;
  BindGatewayAdapter? bindGatewayAd;
  bool isNeedShowClearAlert = false;
  String routeFrom = "";
  GlobalKey<SelectHomeState> selectHomeKey = GlobalKey<SelectHomeState>();

  void showBindingDialog(bool show) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return const BindingDialog();
      },
    );
  }

  /// 上一步
  void prevStep() {
    if (stepNum == 1) {
      return;
    }
    if (stepNum == 3) {
      System.familyInfo = null;
    }
    if (stepNum == 4) {
      System.roomInfo = null;
    }
    setState(() {
      --stepNum;
    });
  }

  /// 下一步
  void nextStep() async {
    if (Platform.isAndroid && stepNum == 1 && !isConnected()) {
      TipsUtils.toast(content: '请连接网络');
      return;
    }

    if (stepNum == 3) {
      if (System.familyInfo == null) {
        // 必须选择家庭信息才能进行下一步
        // 检查家庭是否有权限
        selectHomeKey.currentState?.checkAndSelect();
        return;
      }
      if (isNeedShowClearAlert) {
        showClearAlert(context);
        return;
      }
    }

    if (stepNum == 4) {
      // 必须选择房间信息才能进行下一步
      if (System.roomInfo == null) {
        TipsUtils.toast(content: '请选择房间');
        return;
      }
      // todo: linux运行屏蔽，push前解放
      if (Platform.isLinux) {
        // 运行在 Linux 平台上
      } else {
        // 运行在其他平台上
        showBindingDialog(true);
        final deviceInfoListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
        final layoutModel = Provider.of<LayoutModel>(context, listen: false);
        await layoutModel.removeLayouts();
        if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
          var res = await HomluxDeviceApi.queryDeviceListByRoomId(System.roomInfo!.id!);
          List<HomluxDeviceEntity>? devices = res.data;
          if (devices != null) {
            List<DeviceEntity> devicesReal = [];

            devices.forEach((e) {
              DeviceEntity deviceObj = DeviceEntity();
              deviceObj.name = e.deviceName!;
              deviceObj.applianceCode = e.deviceId!;
              deviceObj.type = e.proType!;
              deviceObj.modelNumber = getModelNumber(e);
              deviceObj.roomName = e.roomName!;
              deviceObj.roomId = System.roomInfo?.id;
              deviceObj.masterId = e.gatewayId ?? '';
              deviceObj.onlineStatus = e.onLineStatus.toString();
              if (getDeviceEntityType(deviceObj.type, deviceObj.modelNumber) !=
                  DeviceEntityTypeInP4.Default) {
                devicesReal.add(deviceObj);
              }
            });
            if (devicesReal.isNotEmpty) {
              List<Layout> layoutData = deviceInfoListModel
                  .transformLayoutFromDeviceList(devicesReal);
              await layoutModel.setLayouts(layoutData);
            } else {
              await layoutModel.loadLayouts();
            }
          }
        } else {
          List<dynamic> devices = await MeiJuDeviceApi.queryDeviceListByRoomId(
              MeiJuGlobal.token!.uid, System.familyInfo!.familyId,
              System.roomInfo!.id!);
          List<DeviceEntity> devicesReal = [];

          devices.forEach((e) {
            DeviceEntity deviceObj = DeviceEntity();
            deviceObj.name = e["name"];
            deviceObj.applianceCode = e["applianceCode"];
            deviceObj.type = e["type"];
            deviceObj.modelNumber = e["modelNumber"];
            deviceObj.sn8 = e["sn8"];
            deviceObj.roomName = e["roomName"];
            deviceObj.masterId = e["masterId"];
            deviceObj.onlineStatus = e["onlineStatus"];
            if (getDeviceEntityType(e["type"], e["modelNumber"]) !=
                DeviceEntityTypeInP4.Default) {
              devicesReal.add(deviceObj);
            }
          });
          if (devicesReal.isNotEmpty) {
            List<Layout> layoutData = deviceInfoListModel
                .transformLayoutFromDeviceList(devicesReal);
            await layoutModel.setLayouts(layoutData);
          } else {
            await layoutModel.loadLayouts();
          }
        }
        // 判断是否绑定网关
        bindGatewayAd?.destroy();
        bindGatewayAd = BindGatewayAdapter(MideaRuntimePlatform.platform);
        bindGatewayAd?.checkGatewayBindState(System.familyInfo!, (isBind, deviceID) {
          if (!isBind) {
            // 绑定网关
            bindGatewayAd?.bindGateway(System.familyInfo!, System.roomInfo!).then((isSuccess) {
              if (isSuccess) {
                prepare2goHome();
              } else {
                TipsUtils.toast(content: '绑定家庭失败');
              }
            });
          } else {
            prepare2goHome();
          }
        }, () {
        });
      }
      return;
    }
    setState(() {
      ++stepNum;
    });
  }

  DeviceEntityTypeInP4 getDeviceEntityType(String value, String? modelNum) {
    for (var deviceType in DeviceEntityTypeInP4.values) {
      if (value == '0x21') {
        if (deviceType.toString() == 'DeviceEntityTypeInP4.Zigbee_$modelNum') {
          return deviceType;
        }
      } else if (value.contains('localPanel1')) {
        return DeviceEntityTypeInP4.LocalPanel1;
      } else if (value.contains('localPanel2')) {
        return DeviceEntityTypeInP4.LocalPanel2;
      } else if (value == '0x13' && modelNum == 'homluxZigbeeLight') {
        return DeviceEntityTypeInP4.Zigbee_homluxZigbeeLight;
      } else if (value == '0x13' && modelNum == 'homluxLightGroup') {
        return DeviceEntityTypeInP4.homlux_lightGroup;
      } else {
        if (deviceType.toString() == 'DeviceEntityTypeInP4.Device$value') {
          return deviceType;
        }
      }
    }
    return DeviceEntityTypeInP4.Default;
  }

  void prepare2goHome() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
      if (mounted) {
        setState(() {
          ++stepNum;
        });
      }
    });
    Timer(const Duration(seconds: 6), () {
      //导航到新路由
      if (mounted) {
        Navigator.popAndPushNamed(context, 'Home');
        System.login();
        stepNum = 2;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // 初始化
    if(!System.inNonePlatform()) {
      if (System.isLogin()) {
        stepNum = 3;
      } else if (Platform.isAndroid && isConnected()) {
        stepNum = 2;
      }
      isNeedShowClearAlert = System.familyInfo != null;
    }

    isNeedChoosePlatform = System.inNonePlatform();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        routeFrom = args["from"] ?? "";
        if (routeFrom == "changePlatform") {
          setState(() {
            isNeedChoosePlatform = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var stepList = [
      Step(
          '连接网络',
          Container(
            width: 480,
            height: 340,
            alignment: AlignmentDirectional.centerStart,
            child: const LinkNetwork(isNeedWifiSwitch: true),
          )
      ),
      Step(
          '扫码登录',
          Column(children: [
            Container(
                margin: const EdgeInsets.only(top: 5),
                child: ScanCode(onSuccess: nextStep)),
          ])
      ),
      Step(
          '选择家庭',
          SelectHome(
              key: selectHomeKey,
              onChange: (SelectFamilyItem? home) {
                debugPrint('Select: ${home?.toJson()}');
                System.familyInfo = home;
                nextStep();
              })
      ),
      Step(
          '选择房间',
          SelectRoom(
              onChange: (SelectRoomItem room) {
                debugPrint('SelectRoom: ${room.toJson()}');
                System.roomInfo = room;
              })
      ),
    ];

    var stepItem = stepNum > stepList.length ? null : stepList[stepNum - 1];

    return Stack(
      children: [
        if (isNeedChoosePlatform) ChosePlatform(
          isChose: routeFrom == "changePlatform",
          onFinished: () {
            setState(() {
              isNeedChoosePlatform = false;
            });
          },
        ),

        if (!isNeedChoosePlatform) DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF272F41), Color(0xFF080C14)],
              ),
            ),
            child: Center(
                child: stepNum == 5
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 96,
                            color: Colors.white,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Text(
                              '已成功绑定帐号',
                              style: TextStyle(fontSize: 24),
                            ),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LoginHeader(
                              stepSum: stepList.length,
                              stepNum: stepNum,
                              title: stepItem?.title ?? ''
                          ),

                          if(stepItem?.view != null) Container(
                            child: stepItem?.view,
                          ),
                        ],
                      ))),
        if (stepNum == 1 && !isNeedChoosePlatform)
          Positioned(
              bottom: 0,
              child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        width: MediaQuery.of(context).size.width,
                        height: 72,
                        child: Center(
                            child: MzButton(
                          width: 240,
                          height: 56,
                          borderRadius: 29,
                          backgroundColor: const Color(0xFF267AFF),
                          borderColor: Colors.transparent,
                          borderWidth: 1,
                          text: '下一步',
                          onPressed: () {
                            nextStep();
                          },
                        )),
                      ))))
        else if (stepNum == 2 && !isNeedChoosePlatform)
          Positioned(
              bottom: 0,
              child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        width: MediaQuery.of(context).size.width,
                        height: 72,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MzButton(
                              width: 168,
                              height: 56,
                              borderRadius: 29,
                              backgroundColor: const Color(0xFF949CA8),
                              borderColor: Colors.transparent,
                              borderWidth: 1,
                              text: '切换平台',
                              onPressed: () {
                                setState(() {
                                  isNeedChoosePlatform = true;
                                  routeFrom = "";
                                });
                              },
                            ),
                            MzButton(
                              width: 168,
                              height: 56,
                              borderRadius: 29,
                              backgroundColor: const Color(0xFF267AFF),
                              borderColor: Colors.transparent,
                              borderWidth: 1,
                              text: '上一步',
                              onPressed: () {
                                prevStep();
                              },
                            )
                          ],
                        ),
                      ))))
        else if (stepNum != 5 && !isNeedChoosePlatform)
          Positioned(
              bottom: 0,
              child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                          color: Colors.white.withOpacity(0.05),
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          width: MediaQuery.of(context).size.width,
                          height: 72,
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                MzButton(
                                  width: 168,
                                  height: 56,
                                  borderRadius: 29,
                                  backgroundColor: const Color(0xFF949CA8),
                                  borderColor: Colors.transparent,
                                  borderWidth: 1,
                                  text: '上一步',
                                  onPressed: () {
                                    prevStep();
                                  },
                                ),
                                MzButton(
                                  width: 168,
                                  height: 56,
                                  borderRadius: 29,
                                  backgroundColor: const Color(0xFF267AFF),
                                  borderColor: Colors.transparent,
                                  borderWidth: 1,
                                  text: stepNum == 4 ? '完成' : '下一步',
                                  onPressed: () {
                                    nextStep();
                                  },
                                )
                              ],
                            )
                          )
                      )
                  )
              )
          )
      ],
    );
  }

  void showClearAlert(BuildContext context) async {
    if (System.familyInfo == null) return;
    var name = System.familyInfo?.familyName ?? "";
    MzDialog(
        title: '绑定至新家庭',
        titleSize: 28,
        maxWidth: 432,
        backgroundColor: const Color(0xFF494E59),
        contentPadding: const EdgeInsets.fromLTRB(33, 24, 33, 0),
        contentSlot: Text("智慧屏已绑定在家庭“$name”，绑定至新家庭将清除所有本地数据，是否继续？",
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(
              color: Color(0xFFB6B8BC),
              fontSize: 24,
              height: 1.6,
              fontFamily: "MideaType",
              decoration: TextDecoration.none,
            )
        ),
        btns: ['取消', '确定'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            isNeedShowClearAlert = false;
            nextStep();
          }
        }).show(context);
  }

  @override
  void netChange(MZNetState? state) {
    debugPrint('netChange: $state');
  }

  @override
  void dispose() {
    super.dispose();
    bindGatewayAd?.destroy();
    bindGatewayAd = null;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class LoginHeader extends StatelessWidget {
  /// 当前索引
  final int stepNum;

  /// 步骤总数
  final int stepSum;

  /// 标题
  final String title;

  const LoginHeader(
      {super.key,
      required this.stepSum,
      required this.stepNum,
      required this.title});

  @override
  Widget build(BuildContext context) {

    var titleView = Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Text(title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            height: 1,
            fontFamily: "MideaType",
            decoration: TextDecoration.none,
          )),
    );

    const stepActiveImg =
        Image(image: AssetImage("assets/imgs/login/step-active.png"));
    const stepFinishedImg =
        Image(image: AssetImage("assets/imgs/login/step-finished.png"));
    const stepPassiveImg =
        Image(image: AssetImage("assets/imgs/login/step-passive.png"));
    const lineActiveImg =
        Image(image: AssetImage("assets/imgs/login/line-active.png"));
    const linePassiveImg =
        Image(image: AssetImage("assets/imgs/login/line-passive.png"));

    var stepList = <Widget>[];

    for (var i = 1; i <= stepSum; i++) {
      if (stepNum >= i && i > 1) {
        stepList.add(lineActiveImg);
      } else if (stepNum < i && i > 1) {
        stepList.add(linePassiveImg);
      } else {}

      if (stepNum > i) {
        stepList.add(stepFinishedImg);
      } else if (stepNum == i) {
        stepList.add(stepActiveImg);
      } else {
        stepList.add(stepPassiveImg);
      }
    }
    num index = min(4, stepNum);
    var stepBarView = Container(
        margin: const EdgeInsets.all(9.0),
        child: Image(image: AssetImage('assets/newUI/step_$index.png')));

    var headerView = Column(
      children: [titleView, stepBarView],
    );

    return Stack(
        alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
        children: [headerView]);
  }
}

class BindingDialog extends StatelessWidget {
  const BindingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 412,
        height: 270,
        padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 30),
        decoration: const BoxDecoration(
          color: Color(0xFF494E59),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoActivityIndicator(radius: 25),
                          Text(
                            '正在绑定中，请稍后',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.72),
                              fontSize: 24,
                            ),
                          ),
                        ]))),
          ],
        ),
      ),
    );
  }
}
