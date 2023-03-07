import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/models/index.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/safe_state.dart';

import '../../channel/index.dart';
import '../../channel/models/manager_devic.dart';
import '../../common/global.dart';
import '../../widgets/event_bus.dart';
import '../../widgets/util/net_utils.dart';

class DeviceConnectViewModel {
  final DeviceConnectState _state;
  DeviceConnectViewModel(this._state);
  /// 已经添加的设备
  List<BindResult> alreadyAddedList = [];
  /// 还待添加的设备
  List<IFindDeviceResult> toBeAddedList = [];
  /// 房间列表
  List<RoomEntity> rooms = [];

  bool startBinding = false;

  /// 切换房间
  void changeRoom(ApplianceBean bindResult, String roomName, String homeGroupId) {

    for (var value in rooms) {
      if(roomName == value.name) {
        deviceManagerChannel.setModifyDevicePositionListener((result) {
          deviceManagerChannel.setModifyDevicePositionListener(null);
          bindResult.roomName = roomName;
          _state.setSafeState(() { });
        });
        deviceManagerChannel.modifyDevicePosition(homeGroupId, value.roomId!, bindResult.applianceCode);
        break;
      }
    }

  }

  /// 初始化
  void init(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments;
    if(args is! Map<String, dynamic>) {
      throw Exception('请传入正确的参数 ${args.runtimeType}');
    }
    startBind(args['devices']);
    rooms = args['rooms'];
  }

  /// 发起绑定
  void startBind(List<IFindDeviceResult> findResult) async {
    if(!startBinding) {
      if(findResult.isEmpty) throw Exception('请确保数据不为空');
      toBeAddedList.addAll(findResult);

      /// 待绑定的wifi设备
      List<FindWiFiResult> wifiType = [];
      /// 待绑定zigbee设备
      List<FindZigbeeResult> zigbeeType = [];
      for (var element in findResult) {
        if(element is FindZigbeeResult) {
          zigbeeType.add(element);
        } else if(element is FindWiFiResult) {
          wifiType.add(element);
        }
      }

      if(zigbeeType.isNotEmpty) {
        bindZigbee(zigbeeType);

        /// 一直做查询, 直到zigbee设备绑定完成，才去绑定wifi设备
        await Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          return toBeAddedList.any((element) => element is FindZigbeeResult);
        });

      }

      if(wifiType.isNotEmpty) {
        bindWiFi(wifiType);
      }

      _state.setSafeState(() { });
      startBinding = true;
    }
  }

  /// 停止绑定
  void stopBind() {
    if(startBinding) {
      stopBindZigbee();
      stopBindWiFi();
      startBinding = false;
    }
  }

  void bindWiFi(List<FindWiFiResult> findResult) {
    NetUtils.checkConnectedWiFiRecord().then((value) {
      if(value == null) throw Exception('当前的wifi密码保存失败');
      deviceManagerChannel.setBindWiFiCallback((result) {
        logger.i('wifi设备绑定结果: $result');
        if(toBeAddedList.contains(result.findResult)) {
          if(result.code != 0) {
            TipsUtils.toast(content: '绑定${result.findResult.name}失败');
          } else {
            alreadyAddedList.add(result);
          }
          toBeAddedList.remove(result.findResult);
          _state.setSafeState(() {});
        }
      });
      deviceManagerChannel.binWiFi(
          value.ssid,
          value.bssid,
          value.password,
          value.encryptType,
          Global.profile.homeInfo?.homegroupId ?? "",
          Global.profile.roomInfo?.roomId ?? "",
          findResult // 指定需要绑定的wifi设备
      );
    });
  }

  void stopBindWiFi() {
    deviceManagerChannel.stopBindWiFi();
    deviceManagerChannel.setBindWiFiCallback(null);
  }

  void bindZigbee(List<FindZigbeeResult> findResult)  {
    deviceManagerChannel.setBindZigbeeListener((result) {
      logger.i('zigbee设备绑定结果: $result');
      if(toBeAddedList.contains(result.findResult)) {
        if(result.code != 0) {
          TipsUtils.toast(content: '绑定${result.findResult.name}失败');
        } else {
          alreadyAddedList.add(result);
        }
        toBeAddedList.remove(result.findResult);
        _state.setSafeState(() {});
      }
    });
    deviceManagerChannel.bindZigbee(
        Global.profile.homeInfo?.homegroupId ?? "",
        Global.profile.roomInfo?.roomId ?? "",
        findResult // 指定需要绑定的zigbee设备
    );
  }

  void stopBindZigbee() {
    deviceManagerChannel.stopFindZigbee(Global.profile.homeInfo?.homegroupId ?? "", Global.profile.applianceCode ?? "");
    deviceManagerChannel.setBindZigbeeListener(null);
  }

  /// 退出
  void goBack(BuildContext context) {
    stopBind();
    bus.emit('updateDeviceListState');
    bus.emit('updateDeviceCardState');
    Navigator.popUntil(context, (route) {
      return route.settings.name != "SnifferPage"
          && route.settings.name != "DeviceConnectPage";
    });
  }

}

class DeviceConnectState extends SafeState<DeviceConnectPage> {
  late DeviceConnectViewModel viewModel;

  // 生成设备列表
  List<MzCell> _listView() {
    return viewModel.alreadyAddedList.map((d) {
      return MzCell(
        title: d.findResult.name,
        titleSize: 24,
        rightSlot: DropdownButtonHideUnderline(
            child: DropdownButton(
              selectedItemBuilder:(context) => viewModel.rooms.map((item) =>
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(item.name,
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)),
              )).toList(),
              value: d.bindResult!.roomName,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              alignment: AlignmentDirectional.topCenter,
              items: viewModel.rooms
                  .map<DropdownMenuItem<String>>((RoomEntity item) {
                return DropdownMenuItem<String>(
                  alignment: Alignment.center,
                  value: item.name,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: d.bindResult!.roomName == item.name ? const ShapeDecoration(
                        color: Color(0xff575757),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))
                        )
                    ) : null,
                    // padding: const EdgeInsets.symmetric(horizontal: 5),
                    width: 120,
                    alignment: Alignment.center,
                    child: Text(item.name,
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)),
                  ),
                );
              }).toList(),
              dropdownColor: const Color(0XFF626262),
              focusColor: Colors.blue,
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              iconSize: 30,
              iconEnabledColor: Colors.white,
              onChanged: (String? data) {
                /// 改变房间
                viewModel.changeRoom(
                    d.bindResult!,
                    data!,
                    Global.profile.homeInfo!.homegroupId
                );
              }
            )),
        hasBottomBorder: true,
        padding:
        const EdgeInsets.symmetric(vertical: 17, horizontal: 26),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    viewModel = DeviceConnectViewModel(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel.init(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget saveBuild(BuildContext context) {
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
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          // 顶部导航
          MzNavigationBar(
            leftBtnVisible: false,
            onLeftBtnTap: () => viewModel.goBack(context),
            title: '设备连接',
            desc: '已成功添加${viewModel.alreadyAddedList.length}台设备',
            isLoading: viewModel.toBeAddedList.isNotEmpty,
            hasBottomBorder: true,
          ),

          Positioned(
              top: 70,
              left: 7,
              right: 7,
              bottom: 64,
              child: ListView(children: _listView())),

          Positioned(
              left: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: TextButton(
                  style: viewModel.toBeAddedList.isEmpty ? buttonStyleOn : buttonStyle,
                  onPressed: () => viewModel.goBack(context),
                  child: Text(viewModel.toBeAddedList.isEmpty ? '完成添加' : '停止添加',
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontFamily: 'MideaType')))),
        ],
      ),
    );
  }
}

class DeviceConnectPage extends StatefulWidget {
  const DeviceConnectPage({super.key});

  @override
  DeviceConnectState createState() => DeviceConnectState();
}
