import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/channel/models/manager_devic.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/utils.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import '../home/device/register_controller.dart';
import '../home/device/service.dart';
import 'device_item.dart';

// 模拟数据 TODO 改为接口查询 @魏
var mockData = [
  {
    "type": "0x13",
    "name": '吸顶灯',
  },
  {
    "type": "0x13",
    "name": '吸顶灯',
  },
  {
    "type": "0x14",
    "name": '智能窗帘',
  },
  {
    "type": "0x26",
    "name": '浴霸',
  },
  {
    "type": "0x09",
    "name": '智能门锁',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  }
].map((d) => DeviceEntity.fromJson(d)).toList();

class Wifi {
  String name;
  int? strength; // WIFI信号强度

  Wifi({required this.name, this.strength});
}

class SnifferState extends State<SnifferPage> {
  late Timer _timer; // to be deleted
  double turns = 0; // 控制扫描动画圈数
  final int timeout = 30; // 设备查找时间
  final int timePerTurn = 3; // 转一圈所需时间
  List<Device> dList = []; // 格式化后的设备列表数据，带 selected 属性
  List<FindZigbeeResult> zigbeeList = <FindZigbeeResult>[];

  var wifiInfo = Wifi(name: "Midea", strength: 2); // WIFI 名称，强度 TODO

  bool hasSelected() {
    return dList.any((d) => d.selected);
  }

  void goBack() {
    stopSnifferZigbee(); // ! 页面离开前停止扫描
    Navigator.pop(context);
  }

  Widget selectWifi() {
    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, 'NetSettingPage'),
        child: Container(
            width: 356,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: const Color(0xff282828),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: Image.asset(
                        "assets/imgs/icon/wifi-${wifiInfo.strength}.png",
                        width: 24.0)),
                Text(
                  wifiInfo.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.w400),
                ),
                const Expanded(
                    child: Text(
                  '进入网络设置',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.w400,
                      color: Color(0xff267AFF)),
                ))
              ],
            )));
  }

  void showWifiDialog() async {
    MzDialog mzDialog = MzDialog(
        title: '连接家庭网络',
        desc: '请确认当前网络是2.4GHZ',
        btns: ['取消', '确认'],
        contentSlot: selectWifi(),
        maxWidth: 425,
        contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 50),
        onPressed: (String item, int index) {
          logger.i('$index: $item');
        });

    bool? result = await mzDialog.show(context);
    logger.i('mzDialog: $result');
  }

  void toDeviceConnect() {
    if (!hasSelected()) {
      TipsUtils.toast(content: '请选择要绑定的设备');
      return;
    }
    if (NetUtils.getNetState() == null) {
      showWifiDialog();
      return;
    }

    stopSnifferZigbee(); // ! 页面离开前停止扫描
    Navigator.pushNamed(context, 'DeviceConnectPage');
  }

  // TODO 初始化SDK的逻辑或将放到原生中
  void initSDK() {
    deviceManagerChannel.init(
        dotenv.get("IOT_URL"),
        Global.user?.accessToken ?? "",
        dotenv.get("HTTP_SIGN_SECRET"),
        Global.user?.seed ?? "",
        Global.user?.key ?? "",
        Global.profile.deviceId ?? "",
        Global.user?.uid ?? "",
        dotenv.get("IOT_APP_COUNT"),
        dotenv.get("IOT_SECRET"),
        dotenv.get("IOT_REQUEST_HEADER_DATA_KEY"));
    zigbeeList.clear();
  }

  void snifferZigbee() {
    debugPrint('NetUtils.getNetState(): ${NetUtils.getNetState()}');
    if (NetUtils.getNetState() == null) {
      showWifiDialog();
      return;
    }

    deviceManagerChannel.setFindZigbeeListener((result) {
      debugPrint('zigbeeList: $result');
      zigbeeList.addAll(result);
    });
    deviceManagerChannel.findZigbee(Global.profile.homeInfo?.homegroupId ?? "",
        Global.profile.applianceCode ?? "");
  }

  void stopSnifferZigbee() {
    deviceManagerChannel.stopFindZigbee(Global.profile.homeInfo?.homegroupId ?? "", Global.profile.applianceCode ?? "");
    deviceManagerChannel.setFindZigbeeListener(null);
  }

  // 生成设备列表
  List<Widget> _listView() {
    return dList
        .map((device) => DeviceItem(
            device: device,
            onTap: (d) {
              setState(() => d.selected = !d.selected);
            }))
        .toList();
  }

  // TODO 完善数据查询 @魏
  Future<void> initQuery() async {
    // ! 模拟发现设备过程
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      timer.cancel();

      // 格式化数据
      setState(() => dList = mockData.map((d) {
            var hasController = controllerList.keys.any((key) => key == d.type);
            var icon = hasController
                ? DeviceService.getOnIcon(d)
                : 'assets/imgs/device/phone_on.png'; // TODO 替换为无类型设备图标

            return Device(
                key: d.type, name: d.name, icon: icon, selected: false);
          }).toList());
    });
  }

  @override
  void initState() {
    super.initState();

    initQuery();
    // 页面加载完成，即开始执行扫描动画
    // HACK 0.5 使扫描光线图片恰好转到视图下方，无法看到
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSDK();
      snifferZigbee();

      setState(() => turns -= timeout / timePerTurn - 0.5);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    stopSnifferZigbee();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/imgs/device/sniffer_01.png")),
      ),
      child: Stack(
        children: [
          // 顶部导航
          MzNavigationBar(
            onLeftBtnTap: goBack,
            title: '发现设备',
          ),

          // 扫描动画
          Positioned(
              left: MediaQuery.of(context).size.width / 2,
              bottom: 0,
              child: AnimatedRotation(
                turns: turns,
                alignment: Alignment.bottomLeft,
                duration: Duration(seconds: timeout),
                child: const Image(
                  height: 296,
                  width: 349,
                  image: AssetImage("assets/imgs/device/sniffer_02.png"),
                ),
              )),

          // 设备阵列
          Positioned(
              top: 128,
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  runSpacing: 6,
                  children: _listView())),

          if (dList.isEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              left: 0,
              child: const Center(
                child: Text('正在搜索设备',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'MideaType')),
              ),
            ),

          if (dList.isNotEmpty)
            Positioned(
                left: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                        style: hasSelected() ? buttonStyleOn : buttonStyle,
                        onPressed: () => toDeviceConnect(),
                        child: Text(hasSelected() ? '添加设备' : '选择设备',
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: 'MideaType'))),
                  ),
                ])),
        ],
      ),
    );
  }
}

class SnifferPage extends StatefulWidget {
  const SnifferPage({super.key});

  @override
  SnifferState createState() => SnifferState();
}
