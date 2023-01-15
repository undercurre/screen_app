import 'package:date_format/date_format.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/mixins/auto_sniffer.dart';
import 'package:screen_app/routes/home/center_control/service.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../states/device_change_notifier.dart';
import '../../../states/room_change_notifier.dart';
import '../../../widgets/plugins/slider_button_content.dart';
import '../device/register_controller.dart';
import '../device/service.dart';

var time = DateTime.now();
var weekday = [" ", "周一", "周二", "周三", "周四", "周五", "周六", "周日"];

List<Map<String, String>> btnList = [
  {'title': '添加设备', 'route': 'SnifferPage'},
  {'title': '切换房间', 'route': 'Room'}
];

class CenterControlPage extends StatefulWidget {
  const CenterControlPage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _CenterControlPageState();
}

class _CenterControlPageState extends State<CenterControlPage>
    with AutoSniffer {
  double roomTitleScale = 1;

  bool menuVisible = false;

  // true为温度盘 false为风速盘
  bool airConditionPanel = true;

  List<Map<String, String>> btnList = [
    {
      'icon': 'assets/imgs/plugins/0xAC/zidong_icon.png',
      'text': '自动',
      'key': 'auto'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhileng_icon.png',
      'text': '制冷',
      'key': 'cool'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhire_icon.png',
      'text': '制热',
      'key': 'heat'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/songfeng_icon.png',
      'text': '送风',
      'key': 'fan'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/chushi_icon.png',
      'text': '除湿',
      'key': 'dry'
    },
  ];

  @override
  initState() {
    super.initState();
    initPage();
  }

  void toConfigPage(String route) {
    Navigator.pushNamed(context, route);
  }

  void switchACPanel(bool onOff) {
    setState(() {
      airConditionPanel = onOff;
    });
  }

  Map<String, String> getCurACMode() {
    return btnList.where((element) => element["key"] == CenterControlService.airConditionMode(context)).toList()[0];
  }

  void curtainHandle(bool onOff) {
    CenterControlService.curtainControl(context, onOff);
  }

  void lightPowerHandle(bool onOff) {
    CenterControlService.lightPowerControl(context, onOff);
  }

  void lightBrightHandle(num value, Color color) {
    CenterControlService.lightBrightnessControl(context, value);
  }

  void lightColorHandle(num value, Color color) {
    CenterControlService.lightColorTemperatureControl(context, value);
  }

  void airConditionPowerHandle(bool onOff) {
    CenterControlService.ACPowerControl(context, onOff);
  }

  void airConditionValueHandle(num value) {
    if (airConditionPanel) {
      CenterControlService.ACTemperatureControl(context, value);
    } else {
      CenterControlService.ACFengsuControl(context, value);
    }
  }

  void airConditionModeHandle(String mode) {
    CenterControlService.ACModeControl(context, mode);
  }

  Future<void> updateHomeData() async {
    var res = await UserApi.getHomeListWithDeviceList(
        homegroupId: Global.profile.homeInfo?.homegroupId);

    if (res.isSuccess) {
      var homeInfo = res.data.homeList[0];
      var roomList = homeInfo.roomList ?? [];
      Global.profile.roomInfo = roomList
          .where((element) =>
              element.roomId == (Global.profile.roomInfo?.roomId ?? ''))
          .toList()[0];
    }
  }

  initPage() async {
    // 更新家庭信息
    await updateHomeData();
    // 查灯组列表
    if (!mounted) return;
    context.read<DeviceListModel>().selectLightGroupList();
    // 更新设备detail
    var deviceList = context.read<DeviceListModel>().deviceList;
    debugPrint('加载到的设备列表$deviceList');
    for (int xx = 1; xx <= deviceList.length; xx++) {
      var deviceInfo = deviceList[xx - 1];
      debugPrint('遍历中$deviceInfo');
      // 查看品类控制器看是否支持该品类
      var hasController = getController(deviceInfo) != null;
      if (hasController &&
          DeviceService.isOnline(deviceInfo) &&
          (DeviceService.isSupport(deviceInfo) ||
              DeviceService.isVistual(deviceInfo))) {
        // 调用provider拿detail存入状态管理里
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo,
            callback: () => {
                  // todo: 优化刷新效率
                  if (DeviceService.isVistual(deviceInfo))
                    {DeviceService.setVistualDevice(context, deviceInfo)}
                });
      } else {
        if (DeviceService.isVistual(deviceInfo)) {
          DeviceService.setVistualDevice(context, deviceInfo);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "${time.month}月${time.day}日  ${weekday[time.weekday]}     ${formatDate(time, [
                              HH,
                              ':',
                              nn
                            ])}",
                        style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 18.0,
                          fontFamily: "MideaType-Regular",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                    PopupMenuButton(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      )),
                      offset: const Offset(0, 36.0),
                      itemBuilder: (context) {
                        return btnList.map((item) {
                          return PopupMenuItem<String>(
                              value: item['route'],
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: "MideaType-Regular",
                                      fontWeight: FontWeight.w400),
                                ),
                              ));
                        }).toList();
                      },
                      onSelected: (String route) {
                        toConfigPage(route);
                      },
                      child: Image.asset(
                        "assets/imgs/icon/select_room.png",
                        width: 40,
                        height: 40,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      context.watch<RoomModel>().roomInfo.name,
                      textScaleFactor: roomTitleScale,
                      style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 30.0,
                        fontFamily: "MideaType-Regular",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: EasyRefresh(
                  header: const ClassicHeader(
                    dragText: '下拉刷新',
                    armedText: '释放执行刷新',
                    readyText: '正在刷新...',
                    processingText: '正在刷新...',
                    processedText: '刷新完成',
                    noMoreText: '没有更多信息',
                    failedText: '失败',
                    messageText: '上次更新 %T',
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 2));
                    if (!mounted) {
                      return;
                    }
                    initPage();
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              curtainControl(),
                              Expanded(flex: 1, child: lightControl())
                            ],
                          ),
                          airConditionControl(),
                          quickScene()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget curtainControl() {
    return MzMetalCard(
      width: 103,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 23, 28, 23),
        child: SizedBox(
          height: 167,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => curtainHandle(false),
                child: Column(
                  children: [
                    !CenterControlService.isCurtainPower(context)
                        ? Image.asset(
                            "assets/imgs/device/chuanglian_icon_on.png",
                            width: 42,
                            height: 42)
                        : Image.asset(
                            "assets/imgs/device/chuanglian_icon_off.png",
                            width: 42,
                            height: 42),
                    Text(
                      '窗帘关',
                      style: TextStyle(
                          color: !CenterControlService.isCurtainPower(context)
                              ? const Color(0xFFFFFFFF)
                              : const Color(0x7AFFFFFF)),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => curtainHandle(true),
                child: Column(
                  children: [
                    CenterControlService.isCurtainPower(context)
                        ? Image.asset(
                            "assets/imgs/device/chuanglian_icon_on.png",
                            width: 42,
                            height: 42)
                        : Image.asset(
                            "assets/imgs/device/chuanglian_icon_off.png",
                            width: 42,
                            height: 42),
                    Text(
                      '窗帘开',
                      style: TextStyle(
                          color: CenterControlService.isCurtainPower(context)
                              ? const Color(0xFFFFFFFF)
                              : const Color(0x7AFFFFFF)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget airConditionControl() {
    return MzMetalCard(
      width: 440,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              direction: Axis.horizontal,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Text(
                    '空调',
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'MideaType-Regular'),
                  ),
                ),
                GestureDetector(
                  onTap: () => switchACPanel(true),
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/imgs/device/wendu.png'),
                          const Text(
                            '温度',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontFamily: 'MideaType-Regular'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => switchACPanel(false),
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/imgs/device/songfeng.png'),
                          const Text(
                            '风速',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontFamily: 'MideaType-Regular'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: DropdownMenu(
                      menuWidth: 84,
                      arrowSize: 20,
                      menu: btnList.map(
                        (item) {
                          return PopupMenuItem<String>(
                            padding: EdgeInsets.zero,
                            value: item['key'],
                            child: Center(
                              child: Container(
                                width: 80,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: getCurACMode()["key"] == item['key']// TODO: 完善
                                      ? const Color(0xff575757)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Opacity(
                                  opacity: getCurACMode()["key"] == item['key'] // TODO: 完善
                                      ? 1
                                      : 0.7,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(item['icon']!,
                                          width: 30, height: 30),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            7, 0, 7, 0),
                                        child: Text(
                                          item['text']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      trigger: Opacity(
                        opacity: menuVisible ? 0.5 : 1,
                        child: Row(
                          children: [
                            Image.asset(
                                getCurACMode()["icon"]!,
                                width: 30,
                                height: 30),
                            Text(
                              getCurACMode()["text"]!,
                              style: const TextStyle(
                                color: Color(0X7FFFFFFF),
                                fontSize: 14.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.w200,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onVisibleChange: (visible) {
                        setState(() {
                          menuVisible = visible;
                        });
                      },
                      onSelected: (dynamic mode) {
                        airConditionModeHandle(mode);
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => airConditionPowerHandle(!CenterControlService.isAirConditionPower(context)),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image.asset(
                      CenterControlService.isAirConditionPower(context)
                          ? 'assets/imgs/device/on.png'
                          : 'assets/imgs/device/off.png',
                      alignment: Alignment.centerRight,
                      width: 50,
                      height: 50,
                    ),
                  ),
                )
              ],
            ),
          ),
          SliderButtonContent(
            unit: airConditionPanel ? '℃' : '档',
            min: airConditionPanel ? 17 : 1,
            max: airConditionPanel ? 30 : 6,
            value: airConditionPanel
                ? CenterControlService.airConditionTemperature(context)
                : CenterControlService.airConditionGear(context),
            sliderWidth: 400,
            onChanged: (value) {
              airConditionValueHandle(value);
            },
          )
        ],
      ),
    );
  }

  Widget lightControl() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        height: 230,
        child: MzMetalCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 10, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '灯光',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontFamily: 'MideaType-Regular',
                          letterSpacing: 1.0),
                    ),
                    GestureDetector(
                      onTap: () => lightPowerHandle(
                          !CenterControlService.isLightPower(context)),
                      child: Image.asset(
                        CenterControlService.isLightPower(context)
                            ? 'assets/imgs/device/on.png'
                            : 'assets/imgs/device/off.png',
                        alignment: Alignment.centerRight,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '亮度 | ${CenterControlService.lightTotalBrightness(context)}%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    MzSlider(
                      value: CenterControlService.lightTotalBrightness(context),
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD185),
                        Color(0xFFFFD185)
                      ],
                      onChanged: lightBrightHandle,
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 14)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '色温 | ${(3000 + (5700 - 3000) * CenterControlService.lightTotalColorTemperature(context) / 100).toInt()}K',
                        style: const TextStyle(
                            fontSize: 14, fontFamily: 'MideaType-Regular'),
                      ),
                    ),
                    MzSlider(
                      value: CenterControlService.lightTotalColorTemperature(
                          context),
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD39F),
                        Color(0xFF55A2FA)
                      ],
                      onChanged: lightColorHandle,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget quickScene() {
    return MzMetalCard(
      width: 440,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '快捷场景',
                  style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontFamily: 'MideaType-Regular',
                      letterSpacing: 1.0),
                ),
                Image.asset(
                  'assets/imgs/device/changjing.png',
                  alignment: Alignment.centerRight,
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF393E43), Color(0xFF333135)],
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/imgs/scene/huijia.png',
                          width: 42, height: 42),
                      const Text('回家')
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF393E43), Color(0xFF333135)],
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/imgs/scene/huijia.png',
                          width: 42, height: 42),
                      Text('回家')
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF393E43), Color(0xFF333135)],
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/imgs/scene/huijia.png',
                          width: 42, height: 42),
                      Text('回家')
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF393E43), Color(0xFF333135)],
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/imgs/scene/huijia.png',
                          width: 42, height: 42),
                      Text('回家')
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
