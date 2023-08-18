import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/routes/home/device/card_dialog.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/routes/home/device/layout_data.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';

import '../../../common/logcat_helper.dart';
import '../../../models/device_entity.dart';
import '../../../models/scene_info_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../../widgets/card/main/panelNum.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/mz_buttion.dart';
import '../../../widgets/mz_dialog.dart';

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initCache();
  }

  initCache() async {
    final sceneListModel = Provider.of<SceneListModel>(context);
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);
    List<DeviceEntity> deviceRes = deviceListModel.getCacheDeviceList();
    List<SceneInfoEntity> sceneRes = sceneListModel.getCacheSceneList();
    if (deviceRes.length > 8) {
      setState(() {
        devices = deviceRes
            .sublist(0, 8)
            .where((e) =>
                getDeviceEntityType(e.type, e.modelNumber) !=
                DeviceEntityTypeInP4.Default)
            .toList();
      });
    } else {
      setState(() {
        devices = deviceRes
            .where((e) =>
                getDeviceEntityType(e.type, e.modelNumber) !=
                DeviceEntityTypeInP4.Default)
            .toList();
      });
    }
    if (sceneRes.length > 8) {
      setState(() {
        scenes = sceneRes.sublist(0, 8);
      });
    } else {
      setState(() {
        scenes = sceneRes;
      });
    }
    await Future.delayed(Duration(milliseconds: 500));
    if (sceneRes.length > 8) {
      setState(() {
        scenes.addAll(sceneRes.sublist(8));
      });
    }
    if (deviceRes.length > 8) {
      devices.addAll(deviceRes
          .sublist(8)
          .where((e) =>
              getDeviceEntityType(e.type, e.modelNumber) !=
              DeviceEntityTypeInP4.Default)
          .toList());
    }
    initData();
  }

  initData() async {
    final sceneListModel = Provider.of<SceneListModel>(context, listen: false);
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);
    List<DeviceEntity> deviceCache = deviceListModel.getCacheDeviceList();
    List<SceneInfoEntity> sceneCache = sceneListModel.getCacheSceneList();
    Future<List<DeviceEntity>> deviceFuture = deviceListModel.getDeviceList();
    Future<List<SceneInfoEntity>> sceneFuture = sceneListModel.getSceneList();

    List<DeviceEntity> deviceRes = [];
    List<SceneInfoEntity> sceneRes = [];

    try {
      await Future.wait([deviceFuture, sceneFuture]);
      deviceRes = await deviceFuture;
      sceneRes = await sceneFuture;
      deviceCache = deviceCache
          .where((e) =>
              getDeviceEntityType(e.type, e.modelNumber) !=
              DeviceEntityTypeInP4.Default)
          .toList();
      deviceRes = deviceRes
          .where((e) =>
              getDeviceEntityType(e.type, e.modelNumber) !=
              DeviceEntityTypeInP4.Default)
          .toList();

      // Here you can work with deviceRes and sceneRes
      print("Device Results: $deviceRes");
      print("Scene Results: $sceneRes");
    } catch (error) {
      print("Error occurred: $error");
    }
    List<List<DeviceEntity>> compareDevice = compareData<DeviceEntity>(deviceCache, deviceRes);
    List<List<SceneInfoEntity>> compareScene = compareData<SceneInfoEntity>(sceneCache, sceneRes);

    Log.i('设备删除了${compareDevice[1].length}, 增加${compareDevice[0].length}');

    setState(() {
      devices.removeWhere((element) => compareDevice[1].contains(element));
      scenes.removeWhere((element) => compareScene[1].contains(element));

      for (DeviceEntity item in compareDevice[0]) {
        int index = deviceRes.indexOf(item);
        if (index >= 0 && index <= devices.length) {
          devices.insert(index, item);
        } else {
          devices.add(item);
        }
      }
      for (SceneInfoEntity item in compareScene[0]) {
        int index = sceneRes.indexOf(item);
        if (index >= 0 && index <= scenes.length) {
          scenes.insert(index, item);
        } else {
          scenes.add(item);
        }
      }
    });
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
    final layoutModel = Provider.of<LayoutModel>(context);
    Layout resultData = Layout(
        uuid.v4(),
        DeviceEntityTypeInP4.Clock,
        CardType.Other,
        -1,
        [],
        DataInputCard(name: '', applianceCode: '', roomName: '', isOnline: ''));
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
                              if (layoutModel.hasLayoutWithDeviceId(
                                  devices[index].applianceCode)) {
                                MzDialog(
                                    title: '该设备已添加',
                                    titleSize: 28,
                                    maxWidth: 432,
                                    backgroundColor: const Color(0xFF494E59),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        33, 24, 33, 0),
                                    contentSlot: const Text("如需更换卡片，请先删除再添加",
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: Color(0xFFB6B8BC),
                                          fontSize: 24,
                                          height: 1.6,
                                          fontFamily: "MideaType",
                                          decoration: TextDecoration.none,
                                        )),
                                    btns: ['确定'],
                                    onPressed: (_, position, context) {
                                      Navigator.pop(context);
                                    }).show(context);
                              }
                              resultData = Layout(
                                devices[index].applianceCode,
                                getDeviceEntityType(devices[index].type,
                                    devices[index].modelNumber),
                                CardType.Small,
                                -1,
                                [],
                                DataInputCard(
                                  name: devices[index].name,
                                  applianceCode: devices[index].applianceCode,
                                  roomName: devices[index].roomName!,
                                  modelNumber: devices[index].modelNumber,
                                  masterId: devices[index].masterId,
                                  isOnline: devices[index].onlineStatus,
                                ),
                              );
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
                                        if (layoutModel.hasLayoutWithDeviceId(
                                            devices[index].applianceCode)) {
                                          MzDialog(
                                              title: '该设备已添加',
                                              titleSize: 28,
                                              maxWidth: 432,
                                              backgroundColor:
                                                  const Color(0xFF494E59),
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      33, 24, 33, 0),
                                              contentSlot: const Text(
                                                  "如需更换卡片，请先删除再添加",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                    color: Color(0xFFB6B8BC),
                                                    fontSize: 24,
                                                    height: 1.6,
                                                    fontFamily: "MideaType",
                                                    decoration:
                                                        TextDecoration.none,
                                                  )),
                                              btns: ['确定'],
                                              onPressed:
                                                  (_, position, context) {
                                                Navigator.pop(context);
                                              }).show(context);
                                        } else {
                                          DeviceEntityTypeInP4 curDeviceEntity =
                                              getDeviceEntityType(
                                                  devices[index].type,
                                                  devices[index].modelNumber);
                                          if (_isPanel(
                                              devices[index].modelNumber,
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
                                              DataInputCard(
                                                name: devices[index].name,
                                                applianceCode: devices[index]
                                                    .applianceCode,
                                                roomName:
                                                    devices[index].roomName!,
                                                modelNumber:
                                                    devices[index].modelNumber,
                                                masterId:
                                                    devices[index].masterId,
                                                isOnline:
                                                    devices[index].onlineStatus,
                                              ),
                                            );
                                            Navigator.pop(context, resultData);
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CardDialog(
                                                  name: devices[index].name,
                                                  type: devices[index].type,
                                                  applianceCode: devices[index]
                                                      .applianceCode,
                                                  modelNumber: devices[index]
                                                      .modelNumber,
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
                                                  DataInputCard(
                                                    name: devices[index].name,
                                                    applianceCode:
                                                        devices[index]
                                                            .applianceCode,
                                                    roomName: devices[index]
                                                        .roomName!,
                                                    modelNumber: devices[index]
                                                        .modelNumber,
                                                    masterId:
                                                        devices[index].masterId,
                                                    isOnline: devices[index]
                                                        .onlineStatus,
                                                  ),
                                                );
                                                Navigator.pop(
                                                    context, resultData);
                                              },
                                            );
                                          }
                                        }
                                      },
                                      online: true,
                                      isFault: false,
                                      isNative: false,
                                      adapter: null,
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
                          return RawGestureDetector(
                            gestures: {
                              AllowMultipleGestureRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                      AllowMultipleGestureRecognizer>(
                                () => AllowMultipleGestureRecognizer(),
                                (AllowMultipleGestureRecognizer instance) {
                                  instance.onTap = () {
                                    resultData = Layout(
                                      scenes[index].sceneId,
                                      DeviceEntityTypeInP4.Scene,
                                      CardType.Small,
                                      -1,
                                      [],
                                      DataInputCard(
                                        name: scenes[index].name,
                                        applianceCode: uuid.v4(),
                                        roomName: '',
                                        sceneId: scenes[index].sceneId,
                                        disabled: false,
                                        icon: scenes[index].image,
                                        isOnline: '',
                                      ),
                                    );
                                    Navigator.pop(context, resultData);
                                  };
                                },
                              )
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: SmallSceneCardWidget(
                                      name: scenes[index].name,
                                      icon: scenes[index].image,
                                      sceneId: scenes[index].sceneId,
                                      disabled: true,
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
                        itemCount: others.length, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              resultData = Layout(
                                uuid.v4(),
                                others[index].type,
                                CardType.Other,
                                -1,
                                [],
                                DataInputCard(
                                  name: '',
                                  applianceCode: uuid.v4(),
                                  roomName: '',
                                  isOnline: '',
                                ),
                              );
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
                                          stops: const [0.06, 1.0],
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
      return 'assets/newUI/device/${type}_$modelNum.png';
    } else {
      return 'assets/newUI/device/$type.png';
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
    return panelList[modelNum] ?? CardType.Small;
  }

  bool _isPanel(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return true;
    }

    return panelList.containsKey(modelNum);
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

class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

List<List<T>> compareData<T>(List<T> cachedData, List<T> apiData) {
  Set<T> cachedDataSet = Set.from(cachedData);
  Set<T> apiDataSet = Set.from(apiData);
  Set<T> addedData = apiDataSet.difference(cachedDataSet);
  Set<T> removedData = cachedDataSet.difference(apiDataSet);

  return [addedData.toList(), removedData.toList()];
}
