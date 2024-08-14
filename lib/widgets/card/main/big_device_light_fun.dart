import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../routes/plugins/0x13_fan/data_adapter.dart';
import '../../../states/device_list_notifier.dart';
import '../../business/fan_control_pannel.dart';
import '../../util/nameFormatter.dart';
import '../method.dart';

class BigDeviceLightFunCardWidget extends StatefulWidget {
  final String applianceCode;
  final String name;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool discriminative;
  final bool hasMore;
  final bool disabled;

  final AdapterGenerateFunction<WIFILightFunDataAdapter> adapterGenerateFunction;

  BigDeviceLightFunCardWidget(
      {super.key,
      required this.applianceCode,
      required this.name,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      required this.adapterGenerateFunction,
      this.hasMore = true,
      this.disabled = false,
      this.discriminative = false,
      this.disableOnOff = true});

  @override
  _BigDeviceLightFunCardWidgetState createState() =>
      _BigDeviceLightFunCardWidgetState();
}

class _BigDeviceLightFunCardWidgetState extends State<BigDeviceLightFunCardWidget> {
  late WIFILightFunDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if (!widget.disabled) {
      adapter.bindDataUpdateFunction(updateCallback);
    }
  }

  @override
  void dispose() {
    super.dispose();
    adapter.unBindDataUpdateFunction(updateCallback);
  }

  bool onlineState() {
    return adapter.fetchOnlineState(context, widget.applianceCode);
  }

  void updateCallback() {
    setState(() {
      Log.i('大卡片状态更新');
      setState(() {
        adapter.data = adapter.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);

    String _getRightText() {
      if (widget.discriminative) {
        return '';
      }
      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      if (widget.disabled) {
        return '';
      }

      if (!onlineState()) {
        return '离线';
      }

      if (adapter.dataState == DataState.ERROR) {
        return '离线';
      }

      return '在线';
    }

    String getRoomName() {
      String BigCardName = '';

      List<DeviceEntity> curOne = deviceListModel.deviceCacheList
          .where((element) => element.applianceCode == widget.applianceCode)
          .toList();
      if (curOne.isNotEmpty) {
        BigCardName = NameFormatter.formatName(curOne[0].roomName!, 6);
      } else {
        BigCardName = '未知区域';
      }

      if (widget.disabled) {
        return deviceListModel.getDeviceRoomName(
            deviceId: widget.applianceCode);
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return BigCardName;
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.applianceCode,
          maxLength: 6,
          startLength: 3,
          endLength: 2);

      if (widget.disabled) {
        return (nameInModel == '未知id' || nameInModel == '未知设备')
            ? widget.name
            : nameInModel;
      }

      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '加载中';
      }

      return nameInModel;
    }

    BoxDecoration _getBoxDecoration() {
      bool curPower = adapter.getPowerStatus() ?? false;
      bool online = onlineState();
      if (widget.disabled) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x33616A76),
              Color(0x33434852),
            ],
            stops: [0.06, 1.0],
            transform: GradientRotation(213 * (3.1415926 / 360.0)),
          ),
        );
      }
      if (widget.isFault) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x77AE4C5E),
              Color.fromRGBO(167, 78, 97, 0.32),
            ],
            stops: [0, 1],
            transform: GradientRotation(222 * (3.1415926 / 360.0)),
          ),
        );
      }
      if (!online) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.discriminative
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0x33616A76),
              widget.discriminative
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0x33434852),
            ],
            stops: [0.06, 1.0],
            transform: GradientRotation(213 * (3.1415926 / 360.0)),
          ),
        );
      }
      if (!curPower) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.discriminative
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0x33616A76),
              widget.discriminative
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0x33434852),
            ],
            stops: [0.06, 1.0],
            transform: GradientRotation(213 * (3.1415926 / 360.0)),
          ),
        );
      } else {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient:  getBigCardColorBg('open'),
        );
      }
    }

    return GestureDetector(
      onTap: () {
        if (!onlineState() && !widget.disabled) {
          adapter.fetchDataInSafety(widget.applianceCode);
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
        if (adapter.dataState != DataState.SUCCESS) {
          adapter.fetchDataInSafety(widget.applianceCode);
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing: (!onlineState() || adapter.dataState != DataState.SUCCESS),
        child: Container(
          width: 440,
          height: 196,
          decoration: _getBoxDecoration(),
          child: Stack(
            children: [
              const Positioned(
                top: 14,
                left: 24,
                child: Image(
                  width: 35,
                  height: 35,
                  image: AssetImage('assets/newUI/device/0x13_fan.png'),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    if (adapter.dataState != DataState.SUCCESS) {
                      adapter.fetchData();
                      // TipsUtils.toast(content: '数据缺失，控制设备失败');
                      return;
                    }
                    if (!onlineState()) {
                      TipsUtils.toast(content: '设备已离线，请检查连接状态');
                      return;
                    }
                    if (!widget.disabled) {
                      Navigator.pushNamed(context, '0x13_fan', arguments: {
                        "name": getDeviceName(),
                        "adapter": adapter
                      });
                    }
                  },
                  child: widget.hasMore
                      ? const Image(
                          width: 32,
                          height: 32,
                          image: AssetImage('assets/newUI/to_plugin.png'))
                      : Container(),
                ),
              ),
              Positioned(
                  top: 10,
                  left: 88,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: widget.isNative ? 100 : 140),
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
                            "${_getRightText().isNotEmpty ? ' | ' : ''}${_getRightText()}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0XA3FFFFFF),
                                fontSize: 16,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),
                      ),
                      if (widget.isNative)
                        Container(
                          alignment: Alignment.center,
                          width: 48,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            border: Border.all(
                                color: const Color(0xFFFFFFFF), width: 1),
                          ),
                          margin: const EdgeInsets.fromLTRB(12, 0, 0, 6),
                          child: const Text(
                            "本地",
                            style: TextStyle(
                                height: 1.6,
                                color: Color(0XFFFFFFFF),
                                fontSize: 14,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none),
                          ),
                        )
                    ],
                  )),
              Positioned(
                top: 62,
                left: 20,
                bottom: 5,
                right: 20,
                child: FanControlPanel(
                    minGear: 1,
                    maxGear: 6,
                    disable: adapter.data == null || adapter.data?.onlineState == 0,
                    fanOnOff: adapter.data?.funPower ?? false,
                    lightOnOff: adapter.data?.ledPower ?? false,
                    gear: getWindSpeed(),
                    onGearChanged: adapter.controlWindSpeed,
                    onFanOnOffChange: (onOff) {
                      adapter.controlFanPower(onOff);
                    },
                    onLightOnOffChange: (onOff) {
                      adapter.controlLedPower(onOff);
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getWindSpeed() {
    if (adapter.data!.fanSpeed == 1) {
      return 1;
    } else if (adapter.data!.fanSpeed == 21) {
      return 2;
    } else if (adapter.data!.fanSpeed == 41) {
      return 3;
    } else if (adapter.data!.fanSpeed == 61) {
      return 4;
    } else if (adapter.data!.fanSpeed == 81) {
      return 5;
    } else if (adapter.data!.fanSpeed == 100) {
      return 6;
    } else {
      return 1;
    }
  }
}
