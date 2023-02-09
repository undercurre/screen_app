import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/safe_state.dart';

import '../../channel/index.dart';
import '../../channel/models/manager_devic.dart';
import '../../common/global.dart';
import '../../widgets/util/net_utils.dart';

class DeviceConnectViewModel {
  final DeviceConnectState _state;
  DeviceConnectViewModel(this._state);
  /// 已经添加的设备
  List<BindResult> alreadyAddedList = [];
  /// 还待添加的设备
  List<IFindDeviceResult> toBeAddedList = [];

  bool startBinding = false;

  /// 初始化
  void init(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments;
    if(args is! List<IFindDeviceResult>) {
      throw Exception('请传入正确的参数 ${args.runtimeType}');
    }
    startBind(args);
  }

  /// 发起绑定
  void startBind(List<IFindDeviceResult> findResult) {
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

  void bindZigbee(List<FindZigbeeResult> findResult) {
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
    Navigator.pop(context);
  }

}

class DeviceConnectState extends SafeState<DeviceConnectPage> {
  late Timer _timer; // to be deleted
  late DeviceConnectViewModel viewModel;

  // 生成设备列表
  List<MzCell> _listView() {
    return viewModel.alreadyAddedList.map((d) {
      return MzCell(
        title: d.findResult.name,
        titleSize: 24,
        // rightSlot: DropdownButtonHideUnderline(
        //     child: DropdownButton(
        //       value: d.bindResult!.roomName,
        //       borderRadius: const BorderRadius.all(Radius.circular(10)),
        //       alignment: AlignmentDirectional.topCenter,
        //       items: Global.profile.homeInfo!.roomList!
        //           .map<DropdownMenuItem<String>>((RoomEntity item) {
        //         return DropdownMenuItem<String>(
        //           value: item.name,
        //           child: Container(
        //             alignment: Alignment.center,
        //             constraints: const BoxConstraints(minWidth: 100),
        //             child: Text(item.name,
        //                 style: const TextStyle(
        //                     fontSize: 24,
        //                     fontFamily: "MideaType",
        //                     fontWeight: FontWeight.w400)),
        //           ),
        //         );
        //       }).toList(),
        //       dropdownColor: const Color(0XFF626262),
        //       focusColor: Colors.blue,
        //       icon: const Icon(Icons.keyboard_arrow_down_outlined),
        //       iconSize: 30,
        //       iconEnabledColor: Colors.white,
        //       onChanged: (data) {
        //         d.bindResult!.roomName = data as String;
        //         setSafeState(() { });
        //       }
        //     )),
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
    _timer.cancel();
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
              child: Row(children: [
                Expanded(
                  child: TextButton(
                      style: buttonStyle,
                      onPressed: () {
                        viewModel.goBack(context);
                      },
                      child: const Text('上一步',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: 'MideaType'))),
                ),
                Expanded(
                  child: TextButton(
                      style: buttonStyleOn,
                      onPressed: () => viewModel.goBack(context),
                      child: const Text('完成添加',
                          style: TextStyle(
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

class DeviceConnectPage extends StatefulWidget {
  const DeviceConnectPage({super.key});

  @override
  DeviceConnectState createState() => DeviceConnectState();
}
