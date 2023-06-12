import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/gateway_api.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/models/index.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/mz_buttion.dart';

import '../../common/index.dart';
import '../../widgets/business/net_connect.dart';
import '../../widgets/business/select_home.dart';
import '../../widgets/business/select_room.dart';
import '../../widgets/util/net_utils.dart';
import 'scan_code.dart';

class Step {
  String title;
  Widget view;

  Step(this.title, this.view);
}

class _LoginPage extends State<LoginPage> with WidgetNetState {
  /// 当前步骤，1-4
  var stepNum = 1;

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
      Global.profile.homeInfo = null;
    }
    if (stepNum == 4) {
      Global.profile.roomInfo = null;
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
      if (Global.profile.homeInfo == null) {
        // 必须选择家庭信息才能进行下一步
        TipsUtils.toast(content: '请选择家庭');
        return;
      }
    }

    if (stepNum == 4) {
      // 必须选择房间信息才能进行下一步
      if (Global.profile.roomInfo == null) {
        TipsUtils.toast(content: '请选择房间');
        return;
      }
      // todo: linux运行屏蔽，push前解放

      if (Platform.isLinux) {
        // 运行在 Linux 平台上
      } else {
        // 运行在其他平台上
        showBindingDialog(true);
        GatewayApi.check((bind, code) {
          if (!bind) {
            UserApi.bindHome(
                    sn: Global.profile.deviceSn ??
                        Global.profile.deviceId ??
                        '',
                    applianceType: '0x16')
                .then((bindRes) {
              logger.i('绑定成功', bindRes);
              if (!bindRes.isSuccess) {
                TipsUtils.toast(content: '绑定家庭失败');
              } else {
                Timer(const Duration(seconds: 3), () {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      ++stepNum;
                    });
                  }
                });
                Timer(const Duration(seconds: 6), () {
                  Global.saveProfile();
                  //导航到新路由
                  if (mounted) {
                    Navigator.popAndPushNamed(context, 'Home');
                    Push.sseInit();
                  }
                });
              }
            });
          } else {
            Timer(const Duration(seconds: 3), () {
              Navigator.pop(context);
              if (mounted) {
                setState(() {
                  ++stepNum;
                });
              }
            });
            Timer(const Duration(seconds: 6), () {
              Global.profile.applianceCode = code;
              Global.saveProfile();
              //导航到新路由
              if (mounted) {
                Navigator.popAndPushNamed(context, 'Home');
                Push.sseInit();
              }
            });
          }
        }, () {
          //接口请求报错
        });
      }
      return;
    }
    setState(() {
      ++stepNum;
    });
  }

  @override
  void initState() {
    super.initState();

    // 初始化
    if (Global.isLogin) {
      stepNum = 3;
    } else if (Platform.isAndroid && isConnected()) {
      stepNum = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    var stepList = [
      Step(
          '连接网络',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.fromLTRB(40, 16, 0, 13),
              child: const Text(
                '请选择链接网络',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  letterSpacing: 0,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const Expanded(child: LinkNetwork())
          ])),
      Step(
          '扫码登录',
          Column(children: [
            Container(
                margin: const EdgeInsets.only(top: 5),
                child: ScanCode(onSuccess: nextStep)),
          ])),
      Step(
          '选择家庭',
          SelectHome(
              value: Global.profile.homeInfo?.homegroupId ?? '',
              onChange: (HomeEntity home) {
                debugPrint('Select: ${home.toJson()}');
                Global.profile.homeInfo = home;
              })),
      Step(
          '选择房间',
          SelectRoom(
              value: Global.profile.roomInfo?.roomId ?? '',
              onChange: (RoomEntity room) {
                debugPrint('SelectRoom: ${room.toJson()}');
                Global.profile.roomInfo = room;
                context.read<RoomModel>().roomInfo = room;
              })),
    ];

    var stepItem = stepNum == 5 ? null : stepList[stepNum - 1];

    var buttonStyle = TextButton.styleFrom(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.all(20.0),
      textStyle: const TextStyle(
          fontSize: 17, color: Color.fromRGBO(1, 255, 255, 0.85)),
    );

    return Stack(
      children: [
        DecoratedBox(
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
                            margin: EdgeInsets.only(top: 50),
                            child: const Text(
                              '已成功绑定帐号',
                              style: TextStyle(fontSize: 24),
                            ),
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LoginHeader(
                              stepSum: stepList.length,
                              stepNum: stepNum,
                              title: stepItem!.title),
                          Expanded(flex: 1, child: stepItem!.view),
                          // Row(children: [
                          //   if (stepNum > 1)
                          //     Expanded(
                          //         child: TextButton(
                          //       style: buttonStyle,
                          //       onPressed: () async {
                          //         prevStep();
                          //       },
                          //       child: const Text('上一步',
                          //           style: TextStyle(
                          //             color: Color.fromRGBO(255, 255, 255, 0.85),
                          //           )),
                          //     )),
                          //   if (stepNum > 2)
                          //     const SizedBox(
                          //       width: 4,
                          //     ),
                          //   if (stepNum != 2)
                          //     Expanded(
                          //         child: TextButton(
                          //       style: buttonStyle,
                          //       onPressed: () async {
                          //         nextStep();
                          //       },
                          //       child: stepNum == 4
                          //           ? const Text('完成',
                          //               style: TextStyle(
                          //                 color: Color.fromRGBO(0, 145, 255, 1),
                          //               ))
                          //           : const Text('下一步',
                          //               style: TextStyle(
                          //                 color: Color.fromRGBO(255, 255, 255, 0.85),
                          //               )),
                          //     )),
                          // ])
                        ],
                      ))),
        if (stepNum == 1)
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
                          backgroundColor: const Color(0xFF818C98),
                          borderColor: Colors.transparent,
                          borderWidth: 1,
                          text: '下一步',
                          onPressed: () {
                            nextStep();
                          },
                        )),
                      ))))
        else if (stepNum == 2)
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
                          backgroundColor: const Color(0x19FFFFFF),
                          borderColor: Colors.transparent,
                          borderWidth: 1,
                          text: '上一步',
                          onPressed: () {
                            prevStep();
                          },
                        )),
                      ))))
        else if (stepNum != 5)
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
                                backgroundColor:
                                    const Color.fromRGBO(255, 255, 255, 0.10),
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
                                backgroundColor: const Color(0xFF818C98),
                                borderColor: Colors.transparent,
                                borderWidth: 1,
                                text: stepNum == 4 ? '完成' : '下一步',
                                onPressed: () {
                                  nextStep();
                                },
                              )
                            ],
                          ))))))
      ],
    );
  }

  @override
  void netChange(MZNetState? state) {
    debugPrint('netChange: $state');
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
    var stepNumView = Positioned(
      top: 10,
      left: -15,
      child: Text(
        stepNum.toString().padLeft(2, '0'),
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 60.0,
          height: 1,
          fontFamily: "MideaType",
          decoration: TextDecoration.none,
        ),
      ),
    );

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
    var stepBarView = Container(
        margin: const EdgeInsets.all(9.0),
        child: Image(image: AssetImage('assets/newUI/step_$stepNum.png')));

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image(image: AssetImage('assets/newUI/loading.png')),
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
