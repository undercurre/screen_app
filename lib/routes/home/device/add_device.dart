import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/device/card_dialog.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';

import '../../../common/global.dart';
import '../../../models/device_entity.dart';
import '../../../models/scene_info_entity.dart';
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
    OtherEntity('时间组件', 'time'),
    OtherEntity('天气组件', 'weather')
  ];

  @override
  void initState() {
    super.initState();
    // 请求接口获取到设备、场景
    // 然后过滤并准备卡片
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
    // 虚拟一台一路面板
    DeviceEntity yilumianban = DeviceEntity();
    yilumianban.name = '一路面板';
    yilumianban.type = '0x21';
    yilumianban.modelNumber = '1339';
    yilumianban.applianceCode = '1703838324';
    yilumianban.roomName = '客厅';
    devices.add(yilumianban);
    // 虚拟一台调光灯
    DeviceEntity tiaoguangdeng = DeviceEntity();
    tiaoguangdeng.name = '调光灯';
    tiaoguangdeng.type = '0x21';
    tiaoguangdeng.modelNumber = '55';
    tiaoguangdeng.applianceCode = '1703838325';
    tiaoguangdeng.roomName = '客厅';
    devices.add(tiaoguangdeng);
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
                                duration: Duration(milliseconds: 500),
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
                          return Stack(
                            children: [
                              Container(
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
                                  onTap: () => {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CardDialog(type: devices[index].type,);
                                      },
                                    )
                                  },
                                  online: true,
                                  isFault: false,
                                  isNative: false,
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
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: SmallSceneCardWidget(
                                    name: scenes[index].name,
                                    icon: Image(
                                      image: AssetImage(
                                          'assets/newUI/scene/${scenes[index].image}.png'),
                                    ),
                                    onOff: false),
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
                          return Stack(
                            children: [
                              Container(
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
                                          213 * 3.1415927 / 180), // 设置渐变色的旋转角度
                                    ),
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 0.32), // 设置边框颜色和透明度
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
}

class OtherEntity {
  OtherEntity(String s, String t) {
    name = s;
    type = t;
  }

  late String name;
  late String type;
}
