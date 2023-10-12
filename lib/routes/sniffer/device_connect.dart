import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/safe_state.dart';

import '../../channel/index.dart';
import '../../channel/models/manager_devic.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/meiju/models/meiju_room_entity.dart';
import '../../widgets/event_bus.dart';
import '../../widgets/mz_buttion.dart';
import '../../widgets/util/nameFormatter.dart';
import '../../widgets/util/net_utils.dart';

class DeviceConnectViewModel {
  final DeviceConnectState _state;
  DeviceConnectViewModel(this._state);
  /// 已经添加的设备
  List<BindResult> alreadyAddedList = [];
  /// 还待添加的设备
  List<IFindDeviceResult> toBeAddedList = [];
  /// 房间列表
  List<MeiJuRoomEntity> rooms = [];

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
        deviceManagerChannel.modifyDevicePosition(homeGroupId, value.roomId, bindResult.applianceCode);
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

    rooms = args['rooms'];
    startBind(args['devices']);
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
        Log.file('wifi设备绑定结果: $result');
        if(toBeAddedList.contains(result.findResult)) {
          if(result.code != 0) {
            TipsUtils.toast(content: '绑定${result.findResult.name}失败');
          } else {
            for (var room in rooms) {
              if (room.roomId == result.bindResult!.roomId.toString()) {
                result.bindResult!.roomName = room.name!;
              }
            }

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
          MeiJuGlobal.homeInfo?.homegroupId ?? "",
          MeiJuGlobal.roomInfo?.roomId ?? "",
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
      Log.i('zigbee设备绑定结果: $result');
      if(toBeAddedList.contains(result.findResult)) {
        if(result.code != 0) {
          TipsUtils.toast(content: '绑定${result.findResult.name}失败');
        } else {
          for (var room in rooms) {
            if (room.roomId == result.bindResult!.roomId.toString()) {
              result.bindResult!.roomName = room.name!;
            }
          }

          alreadyAddedList.add(result);
        }
        toBeAddedList.remove(result.findResult);
        _state.setSafeState(() {});
      }
    });
    deviceManagerChannel.bindZigbee(
        MeiJuGlobal.homeInfo?.homegroupId ?? "",
        MeiJuGlobal.roomInfo?.roomId ?? "",
        findResult // 指定需要绑定的zigbee设备
    );
  }

  void stopBindZigbee() {
    deviceManagerChannel.stopFindZigbee(MeiJuGlobal.homeInfo?.homegroupId ?? "", MeiJuGlobal.gatewayApplianceCode ?? "");
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
                    child: Text(NameFormatter.formatName(item.name ?? '未知房间', 6),
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)),
              )).toList(),
              value: d.bindResult!.roomName,
              borderRadius: const BorderRadius.all(Radius.circular(13)),
              alignment: AlignmentDirectional.topStart,
              items: viewModel.rooms
                  .map<DropdownMenuItem<String>>((MeiJuRoomEntity item) {
                return DropdownMenuItem<String>(
                  alignment: Alignment.center,
                  value: item.name,
                  child: Container(
                    decoration: d.bindResult!.roomName == item.name ? const ShapeDecoration(
                        color: Color(0x26101010),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(13))
                        )
                    ) : null,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: 120,
                    alignment: Alignment.center,
                    child: Text(NameFormatter.formatName(item.name ?? '未知房间', 6),
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)),
                  ),
                );
              }).toList(),
              dropdownColor: const Color(0XFF88909F),
              focusColor: Colors.blue,
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              iconSize: 30,
              menuMaxHeight: 252,
              iconEnabledColor: Colors.white,
              onChanged: (String? data) {
                /// 改变房间
                viewModel.changeRoom(
                    d.bindResult!,
                    data!,
                    MeiJuGlobal.homeInfo!.homegroupId
                );
              }
            )),
        hasBottomBorder: true,
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
            title: '设备连接(${viewModel.alreadyAddedList.length}/${viewModel.toBeAddedList.length + viewModel.alreadyAddedList.length})',
            isLoading: viewModel.toBeAddedList.isNotEmpty,
            hasBottomBorder: false,
          ),

          Positioned(
              top: 70,
              left: 7,
              right: 0,
              bottom: 64,
              child: ListView(children: _listView())),

          Positioned(
            left: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 72,
                  color: const Color(0x19FFFFFF),
                  alignment: Alignment.center,
                  child: MzButton(
                    width: 240,
                    height: 56,
                    borderRadius: 29,
                    backgroundColor: viewModel.toBeAddedList.isEmpty ? const Color(0xFF267AFF) : const Color(0xFF4E77BD),
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    text: viewModel.toBeAddedList.isEmpty ? "完成添加" : "停止添加",
                    onPressed: () {
                      viewModel.goBack(context);
                    },
                  ),
                ),
              ),
            ),
          ),

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
