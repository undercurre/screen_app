import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';

class MiddleDeviceCardWidget extends StatefulWidget {
  final String applianceCode;
  final String name;
  final Widget icon;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool discriminative;
  final bool hasMore;
  final bool disabled;
  final Function? onTap; // 整卡点击事件

  final DeviceCardDataAdapter? adapter;

  const MiddleDeviceCardWidget(
      {super.key,
      required this.applianceCode,
      required this.name,
      required this.icon,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.disableOnOff = true,
      this.hasMore = true,
      this.disabled = false,
      this.discriminative = false,
      this.adapter,
      this.onTap});

  @override
  _MiddleDeviceCardWidgetState createState() => _MiddleDeviceCardWidgetState();
}

class _MiddleDeviceCardWidgetState extends State<MiddleDeviceCardWidget> {
  @override
  void initState() {
    super.initState();
    widget.adapter?.bindDataUpdateFunction(updateCallback);
    widget.adapter?.init();
  }

  @override
  void didUpdateWidget(covariant MiddleDeviceCardWidget oldWidget) {
    if (!widget.disabled) {
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter?.unBindDataUpdateFunction(updateCallback);
    widget.adapter?.destroy();
  }

  void updateCallback() {
    setState(() {
      Log.i('中卡片状态更新');
      setState(() {
        widget.adapter?.data = widget.adapter?.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);

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

      // if (widget.isFault) {
      //   return '故障';
      // }

      if (!deviceListModel.getOnlineStatus(
          deviceId: widget.applianceCode)) {
        return '离线';
      }
      //
      // if (widget.adapter?.dataState == DataState.LOADING) {
      //   return '';
      // }
      //
      // if (widget.adapter?.dataState == DataState.NONE) {
      //   return '离线';
      // }

      if (widget.adapter?.dataState == DataState.ERROR) {
        return '离线';
      }

      return widget.adapter?.getCharacteristic() ?? '';
    }

    String getRoomName() {
      if (widget.disabled) {
        return widget.roomName;
      }

      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '';
      }

      return deviceListModel.getDeviceRoomName(
          deviceId: widget.applianceCode);
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
        deviceId: widget.applianceCode,
      );

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
      bool curPower = widget.adapter?.getPowerStatus() ?? false;
      bool online = deviceListModel.getOnlineStatus(deviceId: widget.applianceCode);
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
          border: Border.all(
            color: const Color.fromRGBO(255, 0, 0, 0.32),
            width: 0.6,
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
              widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33616A76),
              widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33434852),
            ],
            stops: [0.06, 1.0],
            transform: GradientRotation(213 * (3.1415926 / 360.0)),
          ),
        );
      }
      if ((curPower && !widget.disabled)) {
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
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33616A76),
            widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33434852),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Log.i('disabled: ${widget.disabled}');
        if (!widget.disabled) {
          widget.onTap?.call();
          widget.adapter?.power(
            widget.adapter?.getPowerStatus(),
          );
        }
      },
      child: Container(
        width: 210,
        height: 196,
        decoration: _getBoxDecoration(),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Log.i('点击进入插件', widget.adapter?.type);
                  if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)){
                    TipsUtils.toast(content: '设备已离线，请检查连接状态');
                    return;
                  }
                  if (!widget.disabled) {
                    if (widget.adapter?.type == AdapterType.wifiLight) {
                      Navigator.pushNamed(context, '0x13', arguments: {
                        "name": widget.name,
                        "adapter": widget.adapter
                      });
                    } else if (widget.adapter?.type ==
                        AdapterType.wifiCurtain) {
                      Navigator.pushNamed(context, '0x14', arguments: {
                        "name": widget.name,
                        "adapter": widget.adapter
                      });
                    } else if (widget.adapter?.type ==
                        AdapterType.zigbeeLight) {
                      Navigator.pushNamed(context, '0x21_light_colorful',
                          arguments: {
                            "name": widget.name,
                            "adapter": widget.adapter
                          });
                    } else if (widget.adapter?.type ==
                        AdapterType.lightGroup) {
                      Navigator.pushNamed(context, 'lightGroup',
                          arguments: {
                            "name": widget.name,
                            "adapter": widget.adapter
                          });
                    } else if (widget.adapter?.type ==
                        AdapterType.wifiAir) {
                      Navigator.pushNamed(context, '0xAC', arguments: {
                        "name": widget.name,
                        "adapter": widget.adapter
                      });
                    }
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
              top: 16,
              left: 24,
              child: widget.icon,
            ),
            Positioned(
              top: 90,
              left: 24,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: widget.isNative ? 110 : 160),
                    child: Text(
                      getDeviceName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
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
                      margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
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
              ),
            ),
            Positioned(
              top: 136,
              left: 24,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      getRoomName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0XA3FFFFFF),
                        fontSize: 20,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      _getRightText().isNotEmpty ? " | ${_getRightText()}" : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0XA3FFFFFF),
                        fontSize: 20,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
