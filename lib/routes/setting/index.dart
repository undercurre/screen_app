import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import '../../common/gateway_platform.dart';
import '../../common/homlux/api/homlux_user_config_api.dart';
import '../../common/setting.dart';
import '../../widgets/mz_cell.dart';

export 'about_setting.dart';
export 'ai_setting.dart';
export 'display_setting.dart';
export 'net_setting.dart';
export 'sound_setting.dart';
export 'standby_time_choice.dart';
export 'advanced_setting.dart';
export 'current_platform.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  void initState() {
    super.initState();
    //初始化状态
    getEngineeringModeEnable();
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
              /// 标题栏
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
                    const Text("系统设置",
                        style: TextStyle(
                          color: Color(0XD8FFFFFF),
                          fontSize: 28,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)
                    ),
                    const SizedBox(
                      width: 64,
                      height: 64,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      /// 用户信息栏
                      GestureDetector(
                        onTap: () => {
                          Navigator.pushNamed(
                            context,
                            'AccountSettingPage',
                          )
                        },
                        child: Container(
                          width: 432,
                          height: 96,
                          decoration: const BoxDecoration(
                              color: Color(0x33FFFFFF),
                              borderRadius: BorderRadius.all(Radius.circular(16))
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Positioned(
                                left: 20,
                                top: 17,
                                child: CircleAvatar(
                                  backgroundImage: AssetImage("assets/newUI/default_account.png"),
                                  backgroundColor: Color(0x00FFFFFF),
                                  radius: 30,
                                ),
                              ),
                              Positioned(
                                left: 97,
                                top: 9,
                                child: Text(System.familyInfo?.familyName ?? '--',
                                    style: const TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 24,
                                        height: 1.8,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none)
                                ),
                              ),
                              const Positioned(
                                left: 97,
                                top: 53,
                                child: Text("家庭、账号、成员",
                                    style: TextStyle(
                                        color: Color(0X99FFFFFF),
                                        fontSize: 18,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none)
                                ),
                              ),
                              const Positioned(
                                right: 20,
                                top: 36,
                                child: Image(
                                  width: 24,
                                  height: 24,
                                  image: AssetImage("assets/newUI/arrow_right.png"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 432,
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        decoration: const BoxDecoration(
                            color: Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: Column(
                          children: [
                            settingCell("assets/newUI/WiFi_setting.png", "无线局域网", () => {
                              Navigator.pushNamed(
                                context,
                                'NetSettingPage',
                              )
                            }, true),
                            if (MideaRuntimePlatform.platform.inMeiju())
                              settingCell("assets/newUI/add_device.png", "发现设备", () => {
                                if(MeiJuGlobal.isLogin) {
                                  Navigator.pushNamed(
                                    context,
                                    'SnifferPage',
                                  )
                                } else {
                                  TipsUtils.toast(content: '请先登录')
                                }
                            }, true),
                            settingCell("assets/newUI/display_setting.png", "显示设置", () => {
                              Navigator.pushNamed(
                                context,
                                'DisplaySettingPage',
                              )
                            }, true),
                            settingCell("assets/newUI/volume_setting.png", "音量设置", () => {
                              Navigator.pushNamed(
                                context,
                                'SoundSettingPage',
                              )
                            }, true),
                            settingCell("assets/newUI/sound.png", "小美语音", () => {
                              if(System.inMeiJuPlatform()){
                                Navigator.pushNamed(
                                  context,
                                  'AiSettingPage',
                                )
                              }else{
                                Navigator.pushNamed(
                                  context,
                                  'HomluxAiSettingPage',
                                )
                              }

                            }, false),
                          ],
                        ),
                      ),

                      Container(
                        width: 432,
                        height: 144,
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        decoration: const BoxDecoration(
                            color: Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: Column(
                          children: [
                            settingCell("assets/newUI/about.png", "关于本机", () => {
                              Navigator.pushNamed(
                                context,
                                'AboutSettingPage',
                              )
                            }, true),
                            settingCell("assets/newUI/shezhi.png", "高级设置", () => {
                              Navigator.pushNamed(
                                context,
                                'AdvancedSettingPage',
                              )
                            }, false),
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

  Widget settingCell(String icon, String name, Function callback, bool? isLast) {
    return MzCell(
      avatarIcon: Image(
        width: 36,
        height: 36,
        image: AssetImage(icon),
      ),
      title: name,
      titleSize: 24,
      hasArrow: true,
      bgColor: Colors.transparent,
      hasBottomBorder: isLast?? false,
      onTap: callback,
    );
  }

  Future<void> getEngineeringModeEnable() async {
    if (MideaRuntimePlatform.platform.inHomlux()) {
      var res = await HomluxUserConfigApi.queryEngineeringMode();
      if(res.isSuccess) {
        if (res.data?.businessValue == "0") {
          Setting.instant().engineeringModeEnable = false;
        } else if(res.data?.businessValue == "1") {
          Setting.instant().engineeringModeEnable = true;
        }
        setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(SettingPage oldWidget) {
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
