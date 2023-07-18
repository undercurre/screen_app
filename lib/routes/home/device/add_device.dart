import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/routes/home/device/card_dialog.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/routes/home/device/layout_data.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';

import '../../../common/global.dart';
import '../../../models/device_entity.dart';
import '../../../models/scene_info_entity.dart';
import '../../../states/device_position_notifier.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/mz_buttion.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<DeviceEntity> devices = [];
  List<SceneInfoEntity> scenes = [];
  List<OtherEntity> others = [
    OtherEntity('时间组件', DeviceEntityTypeInP4.Clock),
    OtherEntity('天气组件', DeviceEntityTypeInP4.Weather)
  ];

  @override
  void initState() {
    super.initState();
    // 请求接口获取到设备、场景
    // 然后过滤并准备卡片
    // 虚拟一个wifi灯
    DeviceEntity wifilight = DeviceEntity();
    wifilight.name = 'WIFI灯';
    wifilight.type = '0x13';
    wifilight.modelNumber = '';
    wifilight.applianceCode = '1703838320';
    wifilight.roomName = '卧室';
    devices.add(wifilight);
    // 虚拟一台空调
    DeviceEntity kongtiao = DeviceEntity();
    kongtiao.name = '空调';
    kongtiao.type = '0xAC';
    kongtiao.modelNumber = '';
    kongtiao.applianceCode = '1703838321';
    kongtiao.roomName = '卧室';
    devices.add(kongtiao);
    // 虚拟一台窗帘
    DeviceEntity chuanglian = DeviceEntity();
    chuanglian.name = '窗帘';
    chuanglian.type = '0x14';
    chuanglian.modelNumber = '';
    chuanglian.applianceCode = '1703838322';
    chuanglian.roomName = '卧室';
    devices.add(chuanglian);
    // 虚拟一台新风
    DeviceEntity xinfeng = DeviceEntity();
    xinfeng.name = '新风';
    xinfeng.type = '0xCE';
    xinfeng.modelNumber = '';
    xinfeng.applianceCode = '1703838323';
    xinfeng.roomName = '客厅';
    devices.add(xinfeng);
    // 虚拟一台地暖
    DeviceEntity dinuan = DeviceEntity();
    dinuan.name = '地暖';
    dinuan.type = '0xCF';
    dinuan.modelNumber = '';
    dinuan.applianceCode = '1703838330';
    dinuan.roomName = '客厅';
    devices.add(dinuan);
    // 虚拟一台一路面板
    DeviceEntity yilumianban = DeviceEntity();
    yilumianban.name = '一路面板';
    yilumianban.type = '0x21';
    yilumianban.modelNumber = '1339';
    yilumianban.applianceCode = '1703838334';
    yilumianban.roomName = '客厅';
    devices.add(yilumianban);
    // 虚拟一台二路面板
    DeviceEntity erlumianban = DeviceEntity();
    erlumianban.name = '二路面板';
    erlumianban.type = '0x21';
    erlumianban.modelNumber = '1340';
    erlumianban.applianceCode = '1703838335';
    erlumianban.roomName = '客厅';
    devices.add(erlumianban);
    // 虚拟一台一路面板
    DeviceEntity sanlumianban = DeviceEntity();
    sanlumianban.name = '三路面板';
    sanlumianban.type = '0x21';
    sanlumianban.modelNumber = '1341';
    sanlumianban.applianceCode = '1703838336';
    sanlumianban.roomName = '客厅';
    devices.add(sanlumianban);
    // 虚拟一台一路面板
    DeviceEntity silumianban = DeviceEntity();
    silumianban.name = '四路面板';
    silumianban.type = '0x21';
    silumianban.modelNumber = '1342';
    silumianban.applianceCode = '1703838337';
    silumianban.roomName = '客厅';
    devices.add(silumianban);
    // 虚拟一台一路面板
    DeviceEntity yiluduogongnengmianban = DeviceEntity();
    yiluduogongnengmianban.name = '一路多功能面板';
    yiluduogongnengmianban.type = '0x21';
    yiluduogongnengmianban.modelNumber = '1360';
    yiluduogongnengmianban.applianceCode = '1703838351';
    yiluduogongnengmianban.roomName = '客厅';
    devices.add(yiluduogongnengmianban);
    // 虚拟一台二路面板
    DeviceEntity erluduogongnengmianban = DeviceEntity();
    erluduogongnengmianban.name = '二路多功能面板';
    erluduogongnengmianban.type = '0x21';
    erluduogongnengmianban.modelNumber = '1361';
    erluduogongnengmianban.applianceCode = '1703838352';
    erluduogongnengmianban.roomName = '客厅';
    devices.add(erluduogongnengmianban);
    // 虚拟一台一路面板
    DeviceEntity sanduogongnenglumianban = DeviceEntity();
    sanduogongnenglumianban.name = '三路多功能面板';
    sanduogongnenglumianban.type = '0x21';
    sanduogongnenglumianban.modelNumber = '1362';
    sanduogongnenglumianban.applianceCode = '1703838353';
    sanduogongnenglumianban.roomName = '客厅';
    devices.add(sanduogongnenglumianban);
    // 虚拟一台一路面板
    DeviceEntity siluduogongnengmianban = DeviceEntity();
    siluduogongnengmianban.name = '四路多功能面板';
    siluduogongnengmianban.type = '0x21';
    siluduogongnengmianban.modelNumber = '1363';
    siluduogongnengmianban.applianceCode = '1703838354';
    siluduogongnengmianban.roomName = '客厅';
    devices.add(siluduogongnengmianban);
    // 虚拟一台一路面板
    DeviceEntity yiluchuanglianmianban = DeviceEntity();
    yiluchuanglianmianban.name = '一路窗帘面板';
    yiluchuanglianmianban.type = '0x21';
    yiluchuanglianmianban.modelNumber = '1345';
    yiluchuanglianmianban.applianceCode = '1703838355';
    yiluchuanglianmianban.roomName = '客厅';
    devices.add(yiluchuanglianmianban);
    // 虚拟一台二路面板
    DeviceEntity erluchuanglianmianban = DeviceEntity();
    erluchuanglianmianban.name = '二路窗帘面板';
    erluchuanglianmianban.type = '0x21';
    erluchuanglianmianban.modelNumber = '1346';
    erluchuanglianmianban.applianceCode = '1703838356';
    erluchuanglianmianban.roomName = '客厅';
    devices.add(erluchuanglianmianban);
    // 虚拟一台调光灯
    DeviceEntity tiaoguangdeng = DeviceEntity();
    tiaoguangdeng.name = 'zigbee调光灯';
    tiaoguangdeng.type = '0x21';
    tiaoguangdeng.modelNumber = '55';
    tiaoguangdeng.applianceCode = '1703838317';
    tiaoguangdeng.roomName = '客厅';
    devices.add(tiaoguangdeng);
    // 虚拟一台zigbee窗帘
    DeviceEntity zigbeechanglian = DeviceEntity();
    zigbeechanglian.name = '窗帘控制器';
    zigbeechanglian.type = '0x21';
    zigbeechanglian.modelNumber = '1364';
    zigbeechanglian.applianceCode = '1703838338';
    zigbeechanglian.roomName = '客厅';
    devices.add(zigbeechanglian);
    // 虚拟一台本地线控器1
    DeviceEntity localPanel1 = DeviceEntity();
    localPanel1.name = '本地线控器1';
    localPanel1.type = 'localPanel1';
    localPanel1.modelNumber = '';
    localPanel1.applianceCode = '1703838339';
    localPanel1.roomName = '客厅';
    devices.add(localPanel1);
    // 虚拟一台本地线控器2
    DeviceEntity localPanel2 = DeviceEntity();
    localPanel2.name = '本地线控器2';
    localPanel2.type = 'localPanel2';
    localPanel2.modelNumber = '';
    localPanel2.applianceCode = '1703838350';
    localPanel2.roomName = '客厅';
    devices.add(localPanel2);
    // 虚拟场景——回家模式
    SceneInfoEntity backhome = SceneInfoEntity();
    backhome.name = '回家模式';
    backhome.sceneId = '251';
    backhome.image = '1';
    scenes.add(backhome);
    // 虚拟场景——睡眠模式
    SceneInfoEntity sleep = SceneInfoEntity();
    sleep.name = '睡眠模式';
    sleep.sceneId = '252';
    sleep.image = '2';
    scenes.add(sleep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Layout resultData = Layout(
        uuid.v4(), DeviceEntityTypeInP4.Clock, CardType.Other, -1, [], null);
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF272F41), Color(0xFF080C14)],
            ),
          ),
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 13, 10, 25),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              logger.i('设备页');
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {
                                _currentIndex = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '设备',
                                style: TextStyle(
                                  fontFamily: 'PingFangSC-Regular',
                                  // 设置字体
                                  fontSize: _currentIndex == 0 ? 24 : 20,
                                  // 设置字体大小
                                  color: _currentIndex == 0
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.37),
                                  // 设置字体颜色
                                  letterSpacing: 0,
                                  // 设置字间距
                                  fontWeight: FontWeight.w400, // 设置字重
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              logger.i('场景页');
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {
                                _currentIndex = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '场景',
                                style: TextStyle(
                                  fontFamily: 'PingFangSC-Regular',
                                  // 设置字体
                                  fontSize: _currentIndex == 1 ? 24 : 20,
                                  // 设置字体大小
                                  color: _currentIndex == 1
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.37),
                                  // 设置字体颜色
                                  letterSpacing: 0,
                                  // 设置字间距
                                  fontWeight: FontWeight.w400, // 设置字重
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              logger.i('其他页');
                              _pageController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {
                                _currentIndex = 2;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '其他',
                                style: TextStyle(
                                  fontFamily: 'PingFangSC-Regular',
                                  // 设置字体
                                  fontSize: _currentIndex == 2 ? 24 : 20,
                                  // 设置字体大小
                                  color: _currentIndex == 2
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.37),
                                  // 设置字体颜色
                                  letterSpacing: 0,
                                  // 设置字间距
                                  fontWeight: FontWeight.w400, // 设置字重
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      _handlePageChange(index);
                    },
                    children: [
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 2,
                          crossAxisCount: 2, // 设置列数为4
                        ),
                        itemCount: devices.length, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              resultData = Layout(
                                  devices[index].applianceCode,
                                  getDeviceEntityType(devices[index].type,
                                      devices[index].modelNumber),
                                  CardType.Small,
                                  -1,
                                  [],
                                  null);
                              Navigator.pop(context, resultData);
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: SmallDeviceCardWidget(
                                      name: devices[index].name,
                                      icon: Image(
                                        image: AssetImage(_getIconUrl(
                                            devices[index].type,
                                            devices[index].modelNumber)),
                                      ),
                                      onOff: false,
                                      roomName: devices[index].roomName!,
                                      characteristic: '',
                                      onTap: () {
                                        DeviceEntityTypeInP4 curDeviceEntity =
                                            getDeviceEntityType(
                                                devices[index].type,
                                                devices[index].modelNumber);
                                        if (_isPanel(devices[index].modelNumber,
                                            devices[index].type)) {
                                          CardType curCardType =
                                              _getPanelCardType(
                                                  devices[index].modelNumber,
                                                  devices[index].type);
                                          resultData = Layout(
                                              devices[index].applianceCode,
                                              curDeviceEntity,
                                              curCardType,
                                              -1,
                                              [],
                                              null);
                                          Navigator.pop(context, resultData);
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CardDialog(
                                                name: devices[index].name,
                                                type: devices[index].type,
                                                modelNumber:
                                                    devices[index].modelNumber,
                                                roomName:
                                                    devices[index].roomName!,
                                              );
                                            },
                                          ).then(
                                            (value) {
                                              resultData = Layout(
                                                  devices[index].applianceCode,
                                                  curDeviceEntity,
                                                  value,
                                                  -1,
                                                  [],
                                                  null);
                                              Navigator.pop(
                                                  context, resultData);
                                            },
                                          );
                                        }
                                      },
                                      online: true,
                                      isFault: false,
                                      isNative: false,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF6B6D73),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 2,
                          crossAxisCount: 2, // 设置列数为4
                        ),
                        itemCount: scenes.length, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              resultData = Layout(
                                  scenes[index].sceneId,
                                  DeviceEntityTypeInP4.Scene,
                                  CardType.Small,
                                  -1, [], {
                                'name': scenes[index].name,
                                'icon': Image(
                                  image: AssetImage(
                                      'assets/newUI/scene/${scenes[index].image}.png'),
                                ),
                                'onOff': false,
                              });
                              Navigator.pop(context, resultData);
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: SmallSceneCardWidget(
                                        name: scenes[index].name,
                                        icon: Image(
                                          image: AssetImage(
                                              'assets/newUI/scene/${scenes[index].image}.png'),
                                        ),
                                        onOff: false),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF6B6D73),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 2,
                          crossAxisCount: 2, // 设置列数为4
                        ),
                        itemCount: others.length, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              resultData = Layout(uuid.v4(), others[index].type,
                                  CardType.Other, -1, [], null);
                              Navigator.pop(context, resultData);
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 210,
                                      height: 88,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF616A76)
                                                .withOpacity(0.22),
                                            // 设置渐变色起始颜色
                                            const Color(0xFF434852)
                                                .withOpacity(0.22),
                                            // 设置渐变色结束颜色
                                          ],
                                          begin: const Alignment(0.6, 0),
                                          // 设置渐变色的起始位置
                                          end: const Alignment(1, 1),
                                          // 设置渐变色的结束位置
                                          stops: [0.06, 1.0],
                                          // 设置渐变色的起始和结束位置的停止点
                                          transform: const GradientRotation(
                                              213 *
                                                  3.1415927 /
                                                  180), // 设置渐变色的旋转角度
                                        ),
                                        border: Border.all(
                                          color: const Color.fromRGBO(255, 255,
                                              255, 0.32), // 设置边框颜色和透明度
                                          width: 0.6, // 设置边框宽度
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(24), // 设置边框圆角
                                      ),
                                      child: Center(
                                        child: Text(
                                          others[index].name,
                                          style: const TextStyle(
                                            fontFamily: 'PingFangSC-Regular',
                                            // 设置字体
                                            fontSize: 20,
                                            // 设置字体大小
                                            color: Colors.white,
                                            // 设置字体颜色
                                            letterSpacing: 0,
                                            // 设置字间距
                                            fontWeight: FontWeight.w400,
                                            // 设置字重
                                            height: 1.2, // 设置行高
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF6B6D73),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                    text: '返回',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _getIconUrl(String type, String modelNum) {
    if (type == '0x21') {
      return 'assets/newUI/device/${type}_${modelNum}.png';
    } else {
      return 'assets/newUI/device/${type}.png';
    }
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
      } else {
        if (deviceType.toString() == 'DeviceEntityTypeInP4.Device$value') {
          return deviceType;
        }
      }
    }
    return DeviceEntityTypeInP4.Default;
  }

  CardType _getPanelCardType(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return CardType.Small;
    }
    Map<String, CardType> cardTypeMap = {
      '1339': CardType.Small,
      '1340': CardType.Middle,
      '1341': CardType.Big,
      '1342': CardType.Big,
      '1345': CardType.Small,
      '1346': CardType.Middle,
      '1360': CardType.Small,
      '1361': CardType.Middle,
      '1362': CardType.Big,
      '1363': CardType.Big
    };
    return cardTypeMap[modelNum] ?? CardType.Small;
  }

  bool _isPanel(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return true;
    }
    List<String> panelList = [
      '1339',
      '1340',
      '1341',
      '1342',
      '1345',
      '1346',
      '1360',
      '1361',
      '1362',
      '1363'
    ];
    return panelList.contains(modelNum);
  }
}

class OtherEntity {
  OtherEntity(String s, DeviceEntityTypeInP4 t) {
    name = s;
    type = t;
  }

  late String name;
  late DeviceEntityTypeInP4 type;
}
