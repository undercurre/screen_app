import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/system.dart';
import 'package:screen_app/routes/home/device/card_dialog.dart';
import 'package:screen_app/routes/home/device/card_dialog_scene.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/routes/home/device/layout_data.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';
import 'package:screen_app/widgets/util/compare.dart';
import 'package:screen_app/widgets/util/deviceEntityTypeInP4Handle.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../../channel/index.dart';
import '../../../common/adapter/select_room_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/homlux/models/homlux_room_list_entity.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/models/meiju_room_entity.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../models/scene_info_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../../widgets/card/main/panelNum.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../../widgets/business/dropdown_menu.dart' as ui;
import '../../../widgets/util/nameFormatter.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String roomID = System.inMeiJuPlatform()
      ? MeiJuGlobal.roomInfo?.roomId
      : HomluxGlobal.homluxRoomInfo?.roomId;
  bool menuVisible = false;
  late LayoutModel layoutModel;
  List<DeviceEntity> devices = [];
  List<DeviceEntity> deleteDevices = [];
  List<DeviceEntity> devicesAll = [];
  List<SceneInfoEntity> scenes = [];
  List<SceneInfoEntity> scenesAll = [];
  List<SceneInfoEntity> deleteScenes = [];
  List<OtherEntity> others = [
    OtherEntity('时间组件', DeviceEntityTypeInP4.Clock),
    OtherEntity('天气组件', DeviceEntityTypeInP4.Weather)
  ];

  List<Map<String, String>> btnList = [];

  List<MeiJuRoomEntity>? meijuRoomList;
  List<HomluxRoomInfo>? homluxRoomList;
  late Timer _timer;
  double selectRoomVisible = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _timer = Timer(const Duration(seconds: 15), () {
        settingMethodChannel.dismissLoading();
      });
      getRoomList();
    });
    super.initState();
  }

  Future<void> getRoomList() async {
    settingMethodChannel.showLoading("设备加载中");
    if (NetUtils.getNetState() == null) {
      settingMethodChannel.dismissLoading();
      TipsUtils.toast(content: '请检查网络');
    }
    try {
      SelectRoomDataAdapter roomDataAd =
          SelectRoomDataAdapter(MideaRuntimePlatform.platform);
      await roomDataAd?.queryRoomList(System.familyInfo!);
      homluxRoomList = roomDataAd.homluxRoomList;
      meijuRoomList = roomDataAd.meijuRoomList;
    } catch (e) {
      Log.i('加载房间失败');
    }
    initCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  initCache() async {
    try {
      if (System.inMeiJuPlatform()) {
        ///需要保留上次选的房间的话就打开
        // if (MeiJuGlobal.selectRoomId != null) {
        //   roomID = MeiJuGlobal.selectRoomId!;
        // }
        for (MeiJuRoomEntity room in meijuRoomList!) {
          btnList.add({'text': room.name!, 'key': room.roomId});
        }
      } else {
        // if (HomluxGlobal.selectRoomId != null) {
        //   roomID = HomluxGlobal.selectRoomId!;
        // }
        for (HomluxRoomInfo room in homluxRoomList!) {
          btnList.add({'text': room.roomName!, 'key': room.roomId!});
        }
      }

      final sceneListModel =
          Provider.of<SceneListModel>(context, listen: false);
      final deviceListModel =
          Provider.of<DeviceInfoListModel>(context, listen: false);
      List<DeviceEntity> deviceRes = deviceListModel.getCacheDeviceList();
      List<SceneInfoEntity> sceneRes = sceneListModel.getCacheSceneList();
      if (deviceRes.length > 8) {
        devicesAll = deviceRes
            .sublist(0, 8)
            .where((e) =>
                DeviceEntityTypeInP4Handle.getDeviceEntityType(
                    e.type, e.modelNumber) !=
                DeviceEntityTypeInP4.Default)
            .toList();
      } else {
        devicesAll = deviceRes
            .where((e) =>
                DeviceEntityTypeInP4Handle.getDeviceEntityType(
                    e.type, e.modelNumber) !=
                DeviceEntityTypeInP4.Default)
            .toList();
      }
      if (sceneRes.length > 8) {
        scenesAll = sceneRes.sublist(0, 8);
      } else {
        scenesAll = sceneRes;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (sceneRes.length > 8) {
        scenesAll.addAll(sceneRes.sublist(8));
      }
      if (deviceRes.length > 8) {
        devicesAll.addAll(deviceRes
            .sublist(8)
            .where((e) =>
                DeviceEntityTypeInP4Handle.getDeviceEntityType(
                    e.type, e.modelNumber) !=
                DeviceEntityTypeInP4.Default)
            .toList());
      }
    } catch (e) {
      Log.i('设备、场景数据加载失败');
    }

    Log.i(
        '其他组件',
        others.where((element) => !layoutModel.layouts
            .map((e) => e.deviceId)
            .contains(DeviceEntityTypeInP4Handle.extractLowercaseEntityType(
                element.type.toString()))));
    others = others
        .where((element) => !layoutModel.layouts
            .map((e) => e.deviceId)
            .contains(DeviceEntityTypeInP4Handle.extractLowercaseEntityType(
                element.type.toString())))
        .toList();

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
      Log.i("Device Results1: $deviceRes");
      Log.i("Scene Results1: $sceneRes");
      deviceCache = deviceCache
          .where((e) =>
              DeviceEntityTypeInP4Handle.getDeviceEntityType(
                  e.type, e.modelNumber) !=
              DeviceEntityTypeInP4.Default)
          .toList();
      deviceRes = deviceRes
          .where((e) =>
              DeviceEntityTypeInP4Handle.getDeviceEntityType(
                  e.type, e.modelNumber) !=
              DeviceEntityTypeInP4.Default)
          .toList();

      // Here you can work with deviceRes and sceneRes
      Log.i("Device Results2: $deviceRes");
      Log.i("Scene Results2: $sceneRes");
    } catch (error) {
      Log.i("Error occurred: $error");
      deviceRes = deviceCache;
      sceneRes = sceneCache;
    }

    Log.i('Scene Cache', sceneCache);
    List<List<DeviceEntity>> compareDevice =
        Compare.compareData<DeviceEntity>(deviceCache, deviceRes);
    List<List<SceneInfoEntity>> compareScene =
        Compare.compareData<SceneInfoEntity>(sceneCache, sceneRes);

    Log.i('设备删除了${compareDevice[1].length}, 增加${compareDevice[0].length}');
    Log.i('场景删除了${compareScene[1].length}, 增加${compareScene[0].length}');

    devicesAll.removeWhere((element) => compareDevice[1].contains(element));

    for (DeviceEntity item in compareDevice[0]) {
      int index = deviceRes.indexOf(item);
      if (index >= 0 && index <= devicesAll.length) {
        devicesAll.insert(index, item);
      } else {
        devicesAll.add(item);
      }
    }
    for (SceneInfoEntity item in compareScene[0]) {
      int index = sceneRes.indexOf(item);
      if (index >= 0 && index <= scenesAll.length) {
        scenesAll.insert(index, item);
      } else {
        scenesAll.add(item);
      }
    }
    selectRoom(roomID);
  }

  void selectRoom(String roomID) async {
    Log.i('选房间开始时', scenesAll.map((e) => e.roomId));
    if (System.inMeiJuPlatform()) {
      MeiJuGlobal.selectRoomId = roomID;
    } else {
      HomluxGlobal.selectRoomId = roomID;
    }
    List<DeviceEntity> devicesTemp = devicesAll.where((element) => element.roomId == roomID).toList();
    deleteDevices.clear();
    for (DeviceEntity device in devicesTemp) {
      if (layoutModel.hasLayoutWithDeviceId(device.applianceCode)) {
        deleteDevices.add(device);
      }
    }

    ///首页如果有灯1灯2就去掉
    List<String> deleteID = [];
    for (Layout lay in layoutModel.layouts) {
      if (lay.data.applianceCode == "localPanel1" ||
          lay.data.applianceCode == "localPanel2") {
        deleteID.add(lay.data.applianceCode);
      }
    }

    ///去掉自身的四寸屏
    if (System.inMeiJuPlatform()) {
      deleteID.add(MeiJuGlobal.gatewayApplianceCode!);
    } else {
      deleteID.add("G-${HomluxGlobal.gatewayApplianceCode!}");
    }

    for (DeviceEntity device in devicesTemp) {
      for (String id in deleteID) {
        if (device.applianceCode == id) {
          deleteDevices.add(device);
        }
      }
    }

    devicesTemp.removeWhere((i) => deleteDevices.contains(i));
    List<DeviceEntity> devicesLocalLight = [];
    List<DeviceEntity> devicesLightGroup = [];
    List<DeviceEntity> devicesPanel = [];
    for (DeviceEntity device in devicesTemp) {
      if (device.applianceCode == "localPanel1" ||
          device.applianceCode == "localPanel2") {
        devicesLocalLight.add(device);
      }
    }
    for (DeviceEntity device in devicesTemp) {
      if (isLightGroup(device.type, device.modelNumber)) {
        devicesLightGroup.add(device);
      }
    }
    for (DeviceEntity device in devicesTemp) {
      if (isPanel(device.type, device.modelNumber)) {
        devicesPanel.add(device);
      }
    }
    devices.clear();
    devicesTemp.removeWhere((i) => devicesLocalLight.contains(i));
    devicesTemp.removeWhere((i) => devicesLightGroup.contains(i));
    devicesTemp.removeWhere((i) => devicesPanel.contains(i));
    devicesPanel.removeWhere((i) => devicesLocalLight.contains(i));

    devices.addAll(devicesLocalLight);
    devices.addAll(devicesLightGroup);
    devices.addAll(devicesPanel);
    devices.addAll(devicesTemp);

    List<SceneInfoEntity> scenesTemp = scenesAll.where((element) => element.roomId == roomID).toList();
    deleteScenes.clear();
    scenes.clear();
    for (SceneInfoEntity scene in scenesAll) {
      if (layoutModel.hasLayoutWithDeviceId(scene.sceneId)) {
        deleteScenes.add(scene);
      }
    }
    scenesTemp.removeWhere((i) => deleteScenes.contains(i));
    Log.i('选房间$roomID后的${scenesAll.map((e) => e.roomId)}scenes$deleteDevices', scenesTemp);
    scenes.addAll(scenesTemp);
    setState(() {});
    settingMethodChannel.dismissLoading();
    _timer.cancel();
  }

  bool isLightGroup(String? type, String modelNum) {
    if (type == "0x21" && modelNum == "lightGroup") {
      return true;
    } else {
      return false;
    }
  }

  bool isPanel(String? type, String modelNum) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return true;
    }
    return panelList.containsKey(modelNum);
  }

  Map<String, String> getCurRoomConfig() {
    if (btnList.isNotEmpty) {
      List curRoom =
          btnList.where((element) => element["key"] == roomID).toList();
      if (curRoom.isNotEmpty) {
        return curRoom[0];
      } else {
        return <String, String>{};
      }
    } else {
      return <String, String>{};
    }
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[roomID] = true;
    return selectKeys;
  }

  Future<void> roomHandle(String roomID) async {
    this.roomID = roomID;
    selectRoom(roomID);
  }

  void sortList() {}

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0 || index == 1) {
        selectRoomVisible = 1;
      } else {
        selectRoomVisible = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    layoutModel = Provider.of<LayoutModel>(context);
    Layout resultData = Layout(
      uuid.v4(),
      DeviceEntityTypeInP4.Clock,
      CardType.Other,
      -1,
      [],
      DataInputCard(
        name: '',
        applianceCode: '',
        roomName: '',
        isOnline: '',
        disabled: true,
        type: '',
        masterId: '',
        modelNumber: '',
        onlineStatus: '1',
      ),
    );
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
            padding: const EdgeInsets.fromLTRB(0, 13, 10, 25),
            child: Column(
              children: [
                Row(
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 0, 0, 8),
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
                    Opacity(
                      opacity: selectRoomVisible,
                      child: ui.DropdownMenu(
                        disabled: selectRoomVisible == 0 ? true : false,
                        menu: btnList.map(
                          (item) {
                            return PopupMenuItem<String>(
                              padding: EdgeInsets.zero,
                              value: item['key'],
                              child: MouseRegion(
                                child: Center(
                                  child: Container(
                                    width: 130,
                                    height: 50,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0x26101010),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 200, // 设置最大宽度为 50
                                        child: Text(
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          NameFormatter.formatNamePopRoom(
                                              item['text']!, 6),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        trigger: SizedBox(
                          width: 80, // 设置最大宽度为 60
                          child: Text(
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            NameFormatter.formatName(
                                getCurRoomConfig()["text"] ?? '卧室', 4),
                            style: const TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 18.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.w200,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        onVisibleChange: (visible) {
                          setState(() {
                            menuVisible = visible;
                          });
                        },
                        onSelected: (dynamic roomID) {
                          if (roomID != null && roomID != getSelectedKeys()) {
                            roomHandle(roomID);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        allowImplicitScrolling: true,
                        onPageChanged: (index) {
                          _handlePageChange(index);
                        },
                        children: [
                          if (devices.isNotEmpty)
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
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: SmallDeviceCardWidget(
                                          applianceCode:
                                              devices[index].applianceCode,
                                          name: devices[index].name,
                                          icon: Image(
                                            image: AssetImage(_getIconUrl(
                                                devices[index].type,
                                                devices[index].modelNumber)),
                                          ),
                                          roomName: devices[index].roomName!,
                                          online: devices[index].onlineStatus ==
                                              '1',
                                          isFault: false,
                                          isNative: false,
                                          adapterGenerateFunction: null,
                                          disabled: true,
                                          disableOnOff: false,
                                          hasMore: false,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _getDeviceDialog(index, resultData);
                                        },
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
                                    ),
                                  ],
                                );
                              },
                            ),
                          if (devices.isEmpty && NetUtils.getNetState() != null)
                            Container(
                                child: Column(children: [
                              Image(
                                  image: AssetImage('assets/newUI/empty.png')),
                              Text(
                                '暂无设备',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 24,
                                ),
                              )
                            ])),
                          if (NetUtils.getNetState() == null)
                            Container(
                                child: Column(children: [
                              const Image(
                                  width: 300,
                                  height: 300,
                                  image:
                                      AssetImage('assets/newUI/net_error.png')),
                              Text(
                                '网络异常，请检查你的网络',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 24,
                                ),
                              )
                            ])),
                          if (scenes.isNotEmpty)
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
                                      (AllowMultipleGestureRecognizer
                                          instance) {
                                        instance.onTap = () {};
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
                                        child: GestureDetector(
                                          onTap: () {
                                            _getSceneDialog(index, resultData);
                                          },
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
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          if (scenes.isEmpty)
                            Container(
                                child: Column(children: [
                              Image(
                                  image: AssetImage('assets/newUI/empty.png')),
                              Text(
                                '暂无场景',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 24,
                                ),
                              )
                            ])),
                          if (others.isNotEmpty)
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 2,
                                crossAxisCount: 2, // 设置列数为4
                              ),
                              itemCount: others.length, // 网格项的总数
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {},
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
                                                transform:
                                                    const GradientRotation(213 *
                                                        3.1415927 /
                                                        180), // 设置渐变色的旋转角度
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      24), // 设置边框圆角
                                            ),
                                            child: Center(
                                              child: Text(
                                                others[index].name,
                                                style: const TextStyle(
                                                  fontFamily:
                                                      'PingFangSC-Regular',
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
                                        child: GestureDetector(
                                          onTap: () {
                                            resultData = Layout(
                                              DeviceEntityTypeInP4Handle
                                                  .extractLowercaseEntityType(
                                                      others[index]
                                                          .type
                                                          .toString()),
                                              others[index].type,
                                              CardType.Other,
                                              -1,
                                              [],
                                              DataInputCard(
                                                name: '',
                                                applianceCode:
                                                    DeviceEntityTypeInP4Handle
                                                        .extractLowercaseEntityType(
                                                            others[index]
                                                                .type
                                                                .toString()),
                                                roomName: '',
                                                isOnline: '',
                                                disabled: true,
                                                type: DeviceEntityTypeInP4Handle
                                                    .extractLowercaseEntityType(
                                                        others[index]
                                                            .type
                                                            .toString()),
                                                masterId: '',
                                                modelNumber: '',
                                                onlineStatus: '1',
                                              ),
                                            );
                                            Navigator.pop(context, resultData);
                                          },
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
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          if (others.isEmpty)
                            Container(
                                child: Column(children: [
                              Image(
                                  image: AssetImage('assets/newUI/empty.png')),
                              Text(
                                '暂无设备',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 24,
                                ),
                              )
                            ])),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _getSceneDialog(index, Layout resultData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CardDialogScene(
          name: scenes[index].name,
          sceneId: scenes[index].sceneId,
          icon: scenes[index].image
        );
      },
    ).then(
      (value) {
        if (value == null) return;
        resultData = Layout(
          scenes[index].sceneId,
          DeviceEntityTypeInP4.Scene,
          value,
          -1,
          [],
          DataInputCard(
            name: scenes[index].name,
            applianceCode:
            scenes[index].sceneId,
            roomName: '',
            sceneId: scenes[index].sceneId,
            icon: scenes[index].image,
            isOnline: '',
            disabled: true,
            type: 'scene',
            masterId: '',
            modelNumber: '',
            onlineStatus: '1',
          ),
        );
        Navigator.pop(context, resultData);
      },
    );
  }

  _getDeviceDialog(index, Layout resultData) {
    DeviceEntityTypeInP4 curDeviceEntity =
        DeviceEntityTypeInP4Handle.getDeviceEntityType(
            devices[index].type, devices[index].modelNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CardDialog(
          name: devices[index].name,
          type: devices[index].type,
          applianceCode: devices[index].applianceCode,
          modelNumber: devices[index].modelNumber,
          roomName: devices[index].roomName!,
          masterId: devices[index].masterId,
          onlineStatus: devices[index].onlineStatus,
        );
      },
    ).then(
      (value) {
        if (value == null) return;
        resultData = Layout(
          devices[index].applianceCode,
          curDeviceEntity,
          value,
          -1,
          [],
          DataInputCard(
            name: devices[index].name,
            applianceCode: devices[index].applianceCode,
            roomName: devices[index].roomName!,
            modelNumber: devices[index].modelNumber,
            masterId: devices[index].masterId,
            isOnline: devices[index].onlineStatus,
            sn8: devices[index].sn8,
            disabled: true,
            type: devices[index].type,
            onlineStatus: devices[index].onlineStatus,
          ),
        );
        Navigator.pop(context, resultData);
      },
    );
  }

  _getIconUrl(String type, String modelNum) {
    if (type == '0x21') {
      return 'assets/newUI/device/${type}_$modelNum.png';
    } else {
      return 'assets/newUI/device/$type.png';
    }
  }

  CardType _getPanelCardType(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return CardType.Small;
    }
    return panelList[modelNum] ?? CardType.Small;
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
