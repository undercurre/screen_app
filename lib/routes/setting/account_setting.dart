
import 'package:flutter/material.dart';

import '../../channel/index.dart';
import '../../common/global.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  _AccountSettingPageState createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  List<AccountDataItem> listData = [];

  @override
  void initState() {
    super.initState();

    testData();
  }

  /// 页面测试数据
  void testData() {
    listData.add(AccountDataItem("assets/imgs/weather/icon-rainy.png", "123456789012345678901234567890", "123456", "创建"));
    listData.add(AccountDataItem("assets/imgs/weather/icon-rainy.png", "12345678901234567890", "123456", "管理员"));
    listData.add(AccountDataItem("assets/imgs/weather/icon-rainy.png", "12345", "123456", "成员"));
    listData.add(AccountDataItem("assets/imgs/weather/icon-rainy.png", "坤坤坤坤坤", "123456", "成员"));
    listData.add(AccountDataItem("assets/imgs/weather/icon-rainy.png", "qwert", "123456", "成员"));
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
                child: ListView.builder(
                  itemCount: listData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        if(index == 0) myAccountCard("苏达仁的家", "房间 3 | 设备 3 | 成员 3"),
                        memberCard(
                            listData[index].avatar,
                            listData[index].name,
                            listData[index].role,
                            listData[index].accountNumber,
                            index == 0,
                            index == listData.length - 1
                        ),
                      ],
                    );
                  }
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myAccountCard(String homeName, String detailText) {
    return Container(
      width: 432,
      height: 94,
      decoration: const BoxDecoration(
        color: Color(0x19FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 17),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 20,
            child: Text(homeName,
              style: const TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 24,
                fontFamily: "MideaType",
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none)
            ),
          ),
          Positioned(
            bottom: 6,
            left: 20,
            child: Text(detailText,
              style: const TextStyle(
                color: Color(0X4BFFFFFF),
                fontSize: 18,
                fontFamily: "MideaType",
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none)
            ),
          ),
        ],
      ),
    );
  }

  Widget memberCard(String avatar, String name, String role, String number, bool isStart, bool isEnd) {
    return Container(
      width: 432,
      height: 95,
      decoration: BoxDecoration (
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isStart ? 16 : 0),
            topRight: Radius.circular(isStart ? 16 : 0),
            bottomLeft: Radius.circular(isEnd ? 16 : 0),
            bottomRight: Radius.circular(isEnd ? 16 : 0),
          )
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, isEnd ? 16 : 0),
      child: Stack(
        children: [
          if(!isStart) Positioned(
            top: 0,
            left: 20,
            child: Container(
              width: 392,
              height: 1,
              decoration: const BoxDecoration(
                  color: Color(0x19FFFFFF)
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 17,
            child: CircleAvatar(
              backgroundImage: AssetImage(avatar),
              backgroundColor: const Color(0x00FFFFFF),
              radius: 30,
            ),
          ),
          Positioned(
            left: 97,
            top: 9,
            child: Row (
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 210
                  ),
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 24,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)
                  ),
                ),
                Container(
                  width: (16 * role.length).toDouble() + 16,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Color(0X19FFFFFF),
                  ),
                  margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Text(role,
                    maxLines: 1,
                    style: const TextStyle(
                        height: 1.6,
                        color: Color(0X96FFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 97,
            top: 53,
            child: SizedBox(
              width: 280,
              child: Text(number ?? "--",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0X4BFFFFFF),
                      fontSize: 18,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)
              ),
            )
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

class AccountDataItem {
  late String avatar;
  late String name;
  late String accountNumber;
  late String role;
  AccountDataItem(this.avatar, this.name, this.accountNumber, this.role);
}

