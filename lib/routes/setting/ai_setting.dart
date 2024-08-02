import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/widgets/index.dart';

import '../../channel/index.dart';
import '../../common/adapter/ai_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/meiju/api/meiju_ai_author_api.dart';
import '../../common/setting.dart';
import '../../common/utils.dart';

class AiSettingPage extends StatefulWidget {
  const AiSettingPage({Key? key});

  @override
  _AiSettingPageState createState() => _AiSettingPageState();
}

class _AiSettingPageState extends State<AiSettingPage> {
  late double po;
  bool AiEnable = Setting.instant().aiEnable;
  bool AiCustomNameEnable = false;
  bool AiOnlyOneWakeup = false;

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("initState");
    getAiState();
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
                    const Text("小美语音",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.85),
                            fontSize: 28,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 432,
                        height: 72,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.05),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("语音控制",
                                style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 24.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                            MzSwitch(
                              value: AiEnable,
                              onTap: (bool value) {
                                Setting.instant().aiEnable = value;
                                aiMethodChannel.enableAi(value);
                                setState(() {
                                  AiEnable = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: 432,
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.05),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 432,
                                height: 72,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("唤醒词",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                    Text("小美小美",
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.60),
                                          fontSize: 20.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ],
                                ),
                              ),
                              if (MideaRuntimePlatform.platform.inMeiju())
                                Container(
                                  width: 392,
                                  height: 1,
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.05),
                                ),
                              SizedBox(
                                width: 432,
                                height: 72,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text("小美语音授权",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                    GestureDetector(
                                      onTap: () async => {AiAuthor()},
                                      child: Container(
                                        width: 88,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color(0x330092DC),
                                          border: Border.all(
                                              color: const Color(0xFF0092DC)),
                                        ),
                                        child: const Center(
                                          child: Text("授权",
                                              style: TextStyle(
                                                color: Color(0xFF0092DC),
                                                fontSize: 20.0,
                                                fontFamily: "MideaType",
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Container(
                          width: 432,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.05),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              // SizedBox(
                              //   width: 432,
                              //   height: 132,
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     crossAxisAlignment: CrossAxisAlignment.center,
                              //     children: [
                              //       const Column(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text("自定义设备名",
                              //               style: TextStyle(
                              //                 color: Color(0XFFFFFFFF),
                              //                 fontSize: 24.0,
                              //                 fontFamily: "MideaType",
                              //                 fontWeight: FontWeight.normal,
                              //                 decoration: TextDecoration.none,
                              //               )),
                              //           SizedBox(
                              //             width: 307,
                              //             child: Text(
                              //                 "唤醒小美后说：“打开自定义设备名”，即可按照设备自定义的名称进行语音控制",
                              //                 style: TextStyle(
                              //                   color: Color.fromRGBO(
                              //                       255, 255, 255, 0.60),
                              //                   fontSize: 16.0,
                              //                   fontFamily: "MideaType",
                              //                   fontWeight: FontWeight.normal,
                              //                   decoration: TextDecoration.none,
                              //                 )),
                              //           )
                              //         ],
                              //       ),
                              //       Padding(
                              //           padding: const EdgeInsets.fromLTRB(
                              //               0, 0, 0, 70),
                              //           child: MzSwitch(
                              //             value: AiCustomNameEnable,
                              //             onTap: (bool value) {
                              //               MeiJuAiAuthorApi.aiCustomDeviceName(
                              //                   value);
                              //               setState(() {
                              //                 AiCustomNameEnable = value;
                              //               });
                              //             },
                              //           )),
                              //     ],
                              //   ),
                              // ),
                              // Container(
                              //   width: 392,
                              //   height: 1,
                              //   color:
                              //       const Color.fromRGBO(255, 255, 255, 0.05),
                              // ),
                              SizedBox(
                                width: 432,
                                height: 132,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("唯一唤醒",
                                            style: TextStyle(
                                              color: Color(0XFFFFFFFF),
                                              fontSize: 24.0,
                                              fontFamily: "MideaType",
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                            )),
                                        SizedBox(
                                          width: 307,
                                          child: Text(
                                              "唤醒小美后说：“打开唯一唤醒”。即可体验1V1对话，拒绝一呼百应",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 0.60),
                                                fontSize: 16.0,
                                                fontFamily: "MideaType",
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              )),
                                        )
                                      ],
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 70),
                                        child: MzSwitch(
                                          value: AiOnlyOneWakeup,
                                          onTap: (bool value) {
                                            MeiJuAiAuthorApi.aiOnlyOneWakeup(
                                                value ? 1 : 0);
                                            setState(() {
                                              AiOnlyOneWakeup = value;
                                            });
                                          },
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )),
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

  Future<void> AiAuthor() async {
    var Res = await MeiJuAiAuthorApi.AiAuthor(
        deviceId: MeiJuGlobal.gatewayApplianceCode);
    if (Res.isSuccess) {
      TipsUtils.toast(content: "授权成功");
    }
  }

  @override
  void didUpdateWidget(AiSettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget ");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    print("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }

  Future<void> getAiState() async {
    // var res = await MeiJuAiAuthorApi.isAiCustomDeviceName();
    // if (res.data.toString().contains("true")) {
    //   AiCustomNameEnable = true;
    // } else {
    //   AiCustomNameEnable = false;
    // }
    var ress = await MeiJuAiAuthorApi.isAiOnlyOneWakeup();
    if (ress.data.toString().contains("1")) {
      AiOnlyOneWakeup = true;
    } else {
      AiOnlyOneWakeup = false;
    }
    setState(() {});
  }
}
