import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 关于页的数据提供者
class AboutSettingProvider with ChangeNotifier {
  String deviceName;
  String familyName;
  String systemVersion;
  String macAddress;
  String ipAddress;
  String snCode;

  AboutSettingProvider() :
        deviceName = '', familyName = '', systemVersion = '',
        macAddress = '', ipAddress = '', snCode = ''
  {

  }

  void checkUpgrade() {}

  void reboot() {}

  void clearUserData() {}

}

class AboutSettingPage extends StatelessWidget {

    const AboutSettingPage({super.key});

    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider<AboutSettingProvider>(
        create: (context) => AboutSettingProvider(),
        child: Builder(
          builder: (context) {
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
                                        context.watch<AboutSettingProvider>().deviceName,
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
                                        context.watch<AboutSettingProvider>().familyName,
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
                                        context.watch<AboutSettingProvider>().systemVersion,
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
                                        context.watch<AboutSettingProvider>().macAddress,
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
                                        context.watch<AboutSettingProvider>().ipAddress,
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
                                        context.watch<AboutSettingProvider>().snCode,
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
                                    child: const Text("应用升级",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      context.read<AboutSettingProvider>().checkUpgrade()
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                      margin: const EdgeInsets.fromLTRB(0, 18, 20, 0),
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
                                    child: const Text("重启系统",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      context.read<AboutSettingProvider>().reboot()
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                      margin: const EdgeInsets.fromLTRB(0, 18, 20, 0),
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
                                    child: const Text("清除用户数据",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      context.read<AboutSettingProvider>().clearUserData()
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                                      margin: const EdgeInsets.fromLTRB(0, 18, 20, 0),
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
