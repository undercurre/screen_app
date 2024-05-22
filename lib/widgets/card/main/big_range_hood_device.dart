import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/range_hood_device_data_adapter.dart';

import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../routes/plugins/0xB6/index.dart';
import '../../../states/device_list_notifier.dart';
import '../../event_bus.dart';
import '../../mz_slider.dart';

class BigRangeHoodDeviceCardWidget extends StatefulWidget {
  final String applianceCode;
  final String name;
  final bool online;
  final String roomName;
  final bool discriminative;
  final bool disabled;

  AdapterGenerateFunction<RangeHoodDeviceDataAdapter> adapterGenerateFunction;

  BigRangeHoodDeviceCardWidget(
      {super.key,
      required this.disabled,
      required this.discriminative,
      required this.applianceCode,
      required this.name,
      required this.roomName,
      required this.adapterGenerateFunction,
      required this.online});

  @override
  State<BigRangeHoodDeviceCardWidget> createState() =>
      _BigRangeHoodDeviceCardWidgetState();
}

class _BigRangeHoodDeviceCardWidgetState
    extends State<BigRangeHoodDeviceCardWidget> {
  late RangeHoodDeviceDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    adapter.bindDataUpdateFunction(updateCallback);
  }

  @override
  void dispose() {
    super.dispose();
    adapter.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {
      adapter.data = adapter.data;

    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: true);

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: adapter.applianceCode,
          maxLength: 6,
          startLength: 3,
          endLength: 2);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return nameInModel;
    }

    String getRoomName() {
      String nameInModel =
          deviceListModel.getDeviceRoomName(deviceId: adapter.applianceCode);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    return GestureDetector(
      onTap: () {
        if (!adapter.data!.online && !widget.disabled) {
          adapter.fetchDataAndCheckWaitLockAuth(widget.applianceCode);
          // TipsUtils.toast(content: '数据缺失，控制设备失败');
          return;
        }
        if (!adapter.data!.online && !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing: (!adapter.data!.online && !widget.disabled) || adapter.dataState != DataState.SUCCESS,
        child: Container(
          width: 440,
          height: 196,
          decoration: _getBoxDecoration(),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    adapter.power(
                      !adapter.getData().onOff,
                    );
                    bus.emit('operateDevice', widget.applianceCode);
                  },
                  child: Image(
                      width: 40,
                      height: 40,
                      image: AssetImage(adapter.getPowerStatus() ?? false
                          ? 'assets/newUI/card_power_on.png'
                          : 'assets/newUI/card_power_off.png')),
                ),
              ),

              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RangeHoodPage(adapter: adapter)));
                    },
                    child: const Image(
                        width: 32,
                        height: 32,
                        image: AssetImage('assets/newUI/to_plugin.png'))),
              ),
              Positioned(
                top: 10,
                left: 88,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 设备名
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(getDeviceName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: 22,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),
                      ),
                    ),
                    // 房间名
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 90),
                      child: Text(getRoomName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0XA3FFFFFF),
                              fontSize: 16,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 90),
                      child: Text(
                          " ${getRightText().isNotEmpty ? '|' : ''} ${getRightText()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0XA3FFFFFF),
                              fontSize: 16,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ),
                    // if (widget.isNative)
                    // Container(
                    //   alignment: Alignment.center,
                    //   width: 48,
                    //   height: 24,
                    //   decoration: BoxDecoration(
                    //     borderRadius:
                    //         const BorderRadius.all(Radius.circular(24)),
                    //     border: Border.all(
                    //         color: const Color(0xFFFFFFFF), width: 1),
                    //   ),
                    //   margin: const EdgeInsets.fromLTRB(12, 0, 0, 6),
                    //   child: const Text(
                    //     "本地",
                    //     style: TextStyle(
                    //         height: 1.6,
                    //         color: Color(0XFFFFFFFF),
                    //         fontSize: 14,
                    //         fontFamily: "MideaType",
                    //         fontWeight: FontWeight.normal,
                    //         decoration: TextDecoration.none),
                    //   ),
                    // )
                  ],
                ),
              ),
              // 加减按钮组
              Positioned(
                top: 62,
                left: 20,
                child: SizedBox(
                  height: 84,
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          adapter.reduceTo(adapter.getData().currentSpeed - 1);
                          bus.emit('operateDevice', widget.applianceCode);
                        },
                        child: Image(
                            color: Color.fromRGBO(255, 255, 255,
                                (adapter.getPowerStatus() ?? false) ? 1 : 0.7),
                            width: 36,
                            height: 36,
                            image: const AssetImage('assets/newUI/sub.png')),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${adapter.getData().currentSpeed}",
                              style: TextStyle(
                                  height: 1.5,
                                  color: (adapter.getPowerStatus() ?? false)
                                      ? const Color(0XFFFFFFFF)
                                      : const Color(0XA3FFFFFF),
                                  fontSize: 60,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none)),
                          Text("档",
                              style: TextStyle(
                                  height: 1.5,
                                  color: (adapter.getPowerStatus() ?? false)
                                      ? const Color(0XFFFFFFFF)
                                      : const Color(0XA3FFFFFF),
                                  fontSize: 18,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none))
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          adapter.increaseTo(adapter.getData().currentSpeed + 1);
                          bus.emit('operateDevice', widget.applianceCode);
                        },
                        child: Image(
                            color: Color.fromRGBO(255, 255, 255,
                                (adapter.getPowerStatus() ?? false) ? 1 : 0.7),
                            width: 36,
                            height: 36,
                            image: const AssetImage('assets/newUI/add.png')),
                      ),
                    ],
                  ),
                ),
              ),
              // 滑动条
              Positioned(
                top: 140,
                left: 4,
                child: MzSlider(
                  step: 0,
                  value: adapter.data!.currentSpeed,
                  width: 390,
                  height: 16,
                  min: adapter.data!.minSpeed,
                  max: adapter.data!.maxSpeed,
                  disabled: widget.disabled ||
                      adapter.data?.onOff == false ||
                      adapter.data?.online == false,
                  activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
                  onChanged: (val, color) {
                    adapter.slider1To(val.toInt());
                    bus.emit('operateDevice', widget.applianceCode);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getRightText() {
    if (adapter.data!.online == true) {
      return "在线";
    } else {
      return '离线';
    }
  }

  BoxDecoration _getBoxDecoration() {
    if (adapter.data!.onOff && adapter.data!.online) {
      return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF818895),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
        ),
      );
    }
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x33616A76),
          Color(0x33434852),
        ],
      ),
      border: Border.all(
        color: const Color(0x00FFFFFF),
        width: 0,
      ),
    );
  }
}
