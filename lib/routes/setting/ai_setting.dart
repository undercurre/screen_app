import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

import '../../channel/index.dart';
import '../../common/api/ai_author_api.dart';
import '../../common/global.dart';
import '../../common/utils.dart';

class AiSettingPage extends StatefulWidget {
  const AiSettingPage({Key? key});

  @override
  _AiSettingPageState createState() => _AiSettingPageState();
}

class _AiSettingPageState extends State<AiSettingPage> {
  late double po;
  bool AiEnable = Global.profile.aiEnable;

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("initState");
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
            image: DecorationImage(
                image: ExactAssetImage('assets/newUI/bg.png'),
                fit: BoxFit.cover),
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
                        Navigator.popUntil(context, (route) => route.settings.name == 'Home');
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
                                aiMethodChannel.enableAi(value);
                                Global.profile.aiEnable = value;
                                Global.saveProfile();
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
                          height: 145,
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
                          height: 265,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.05),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 432,
                                height: 132,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("自定义设备名",
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
                                              "唤醒小美后说：“打开自定义设备名”，即可按照设备自定义的名称进行语音控制",
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
                                    Image(
                                        image: AssetImage(
                                            'assets/newUI/arrow_right.png'))
                                  ],
                                ),
                              ),
                              Container(
                                width: 392,
                                height: 1,
                                color:
                                    const Color.fromRGBO(255, 255, 255, 0.05),
                              ),
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
                                    MzSwitch(
                                      value: AiEnable,
                                      onTap: (bool value) {
                                        aiMethodChannel.enableAi(value);
                                        Global.profile.aiEnable = value;
                                        Global.saveProfile();
                                        setState(() {
                                          AiEnable = value;
                                        });
                                      },
                                    ),
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
    var Res =
        await AiAuthorApi.AiAuthor(deviceId: Global.profile.applianceCode);
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
}
