
import 'package:flutter/material.dart';

import '../../common/adapter/select_family_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/setting.dart';
import '../../common/system.dart';
import '../../widgets/mz_dialog.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  _AccountSettingPageState createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  SelectFamilyDataAdapter? familyDataAd;

  @override
  void initState() {
    super.initState();

    familyDataAd = SelectFamilyDataAdapter(MideaRuntimePlatform.platform);
    familyDataAd?.bindDataUpdateFunction(() {
      setState(() {
        var len = familyDataAd?.familyListEntity?.familyList.length ?? 0;
        for (var i = 0; i < len; i++) {
          var item = familyDataAd?.familyListEntity?.familyList[i];
          if(System.familyInfo?.familyId == item?.familyId) {
            System.familyInfo = item;
            Setting.instant().lastBindHomeName = System.familyInfo?.familyName ?? "";
            Setting.instant().lastBindHomeId = System.familyInfo?.familyId ?? "";
            return;
          }
        }
      });
    });
    familyDataAd?.queryFamilyList();
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
                    const Text("账号管理",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 52,
                    ),
                    const Image(
                      height: 143,
                      width: 143,
                      image: AssetImage("assets/newUI/default_account.png"),
                    ),
                    Text(System.familyInfo?.familyName ?? '--',
                        style: const TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 24,
                            height: 2.6,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none)
                    ),
                    Text("房间 ${System.familyInfo?.roomNum} | 设备 ${System.familyInfo?.deviceNum} | 成员 ${System.familyInfo?.userNum}",
                        style: const TextStyle(
                            color: Color(0X7FFFFFFF),
                            fontSize: 18,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none)
                    )
                  ],
                ),
              ),

              if(!Setting.instant().engineeringModeEnable) GestureDetector(
                onTap: () {
                  MzDialog(
                      contentSlot: const Text(
                          '确定退出账号吗',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'MideaType',
                              fontWeight: FontWeight.w400,
                              height: 1.2)),
                      maxWidth: 400,
                      btns: ['取消', '确定'],
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 50),
                      onPressed: (_, index, context) {
                        if (index == 1) {
                          System.logout("账号管理，手动退出登录");
                        } else {
                          Navigator.pop(context);
                        }
                      }).show(context);
                },
                child: Container(
                  height: 88,
                  width: 480,
                  color: const Color(0x19FFFFFF),
                  alignment: Alignment.center,
                  child: Container(
                    height: 55,
                    width: 240,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: const Color(0xFF267AFF),
                        borderRadius: BorderRadius.circular(29)
                    ),
                    child: const Text("退出账号",
                        style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none)
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(AccountSettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    familyDataAd?.destroy();
    familyDataAd = null;
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

