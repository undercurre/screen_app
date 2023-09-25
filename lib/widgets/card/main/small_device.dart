import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../util/nameFormatter.dart';

class SmallDeviceCardWidget extends StatefulWidget {
  final String applianceCode;
  final String name;
  final Widget icon;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool discriminative;
  final bool disabled;
  final bool hasMore;
  final Function? onTap; // 整卡点击事件

  final DeviceCardDataAdapter? adapter;

  const SmallDeviceCardWidget(
      {super.key,
      required this.applianceCode,
      required this.name,
      required this.icon,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.hasMore = true,
      this.disableOnOff = true,
      this.discriminative = false,
      this.disabled = false,
      this.adapter,
      this.onTap});

  @override
  _SmallDeviceCardWidgetState createState() => _SmallDeviceCardWidgetState();
}

class _SmallDeviceCardWidgetState extends State<SmallDeviceCardWidget> {
  @override
  void initState() {
    if (!widget.disabled) {
      super.initState();
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void didUpdateWidget(covariant SmallDeviceCardWidget oldWidget) {
    if (!widget.disabled) {
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    Log.i('小卡片状态更新');
    setState(() {
      widget.adapter?.data = widget.adapter?.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);
    final layoutModel = context.read<LayoutModel>();

    if (layoutModel.hasLayoutWithDeviceId(widget.applianceCode)) {
      List<DeviceEntity> hitList = deviceListModel.deviceCacheList.where((element) => element.applianceCode == widget.applianceCode).toList();
      if (hitList.isEmpty) {
        layoutModel.deleteLayout(widget.applianceCode);
        TipsUtils.toast(content: '已删除${hitList[0].name}');
      }
    }

    String _getRightText() {
      if (widget.applianceCode == 'localPanel1' || widget.applianceCode == 'localPanel2') {
        return '';
      }
      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '';
      }

      if (widget.disabled) {
        if (deviceListModel.getOnlineStatus(
            deviceId: widget.adapter?.getDeviceId())) {
          return '在线';
        } else {
          return '离线';
        }
      }

      if (widget.isFault) {
        return '故障';
      }

      if (!deviceListModel.getOnlineStatus(
          deviceId: widget.adapter?.getDeviceId())) {
        return '离线';
      }

      if (widget.adapter?.dataState == DataState.LOADING) {
        return '在线';
      }

      if (widget.adapter?.dataState == DataState.NONE) {
        return '离线';
      }

      if (widget.adapter?.dataState == DataState.ERROR) {
        return '离线';
      }

      return widget.adapter?.getCharacteristic() ?? '';
    }

    String getRoomName() {
      String nameInModel = deviceListModel.getDeviceRoomName(
          deviceId: widget.adapter?.getDeviceId());
      if (widget.disabled) {
        return NameFormatter.formatName(widget.roomName, 3);
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.adapter?.getDeviceId());

      if (widget.disabled) {
        return (nameInModel == '未知id' || nameInModel == '未知设备')
            ? NameFormatter.formatName(widget.name, 4)
            : nameInModel;
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return nameInModel;
    }

    BoxDecoration _getBoxDecoration() {
      bool curPower = widget.adapter?.getPowerStatus() ?? false;
      bool online = deviceListModel.getOnlineStatus(
        deviceId: widget.adapter?.getDeviceId(),
      );
      // if (widget.disabled) {
      //   Log.i('widget:${widget.disableOnOff}');
      //   if (widget.disableOnOff) {
      //     return BoxDecoration(
      //       borderRadius: BorderRadius.circular(24),
      //       gradient: const LinearGradient(
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //         colors: [
      //           Color(0xFF767B86),
      //           Color(0xFF88909F),
      //           Color(0xFF516375),
      //         ],
      //         stops: [0, 0.24, 1],
      //         transform: GradientRotation(194 * (3.1415926 / 360.0)),
      //       ),
      //     );
      //   } else {
      //     return BoxDecoration(
      //       borderRadius: BorderRadius.circular(24),
      //       gradient: const LinearGradient(
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //         colors: [
      //           Color(0x33616A76),
      //           Color(0x33434852),
      //         ],
      //         stops: [0.06, 1.0],
      //         transform: GradientRotation(213 * (3.1415926 / 360.0)),
      //       ),
      //     );
      //   }
      // }
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
            stops: const [0.06, 1.0],
            transform: const GradientRotation(213 * (3.1415926 / 360.0)),
          ),
        );
      } else {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF767B86),
              Color(0xFF88909F),
              Color(0xFF516375),
            ],
            stops: [0, 0.24, 1],
            transform: GradientRotation(194 * (3.1415926 / 360.0)),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () {
        Log.i('disabled: ${widget.disabled}');
        if (!widget.disabled) {
          widget.onTap?.call();
          widget.adapter?.power(widget.adapter?.getPowerStatus());
        } else {
          widget.adapter?.tryOnce();
        }
      },
      child: Container(
        width: 210,
        height: 88,
        padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
        decoration: _getBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              child: widget.icon,
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          getDeviceName(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'MideaType',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (widget.isNative)
                          Container(
                            margin: const EdgeInsets.only(left: 14),
                            width: 36,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    const Color.fromRGBO(255, 255, 255, 0.32),
                                width: 0.6,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '本地',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.64),
                                ),
                              ),
                            ),
                          )
                      ]),
                      if (getRoomName() != '' || _getRightText() != '')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 80),
                                  child: Text(
                                    '${getRoomName()}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: 'MideaType',
                                      color: Colors.white.withOpacity(0.64),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Text(
                                    '${_getRightText().isNotEmpty ? '|': ''}',
                                    style: TextStyle(
                                      fontFamily: 'MideaType',
                                      color: Colors.white.withOpacity(0.64),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${_getRightText()}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'MideaType',
                                    color: Colors.white.withOpacity(0.64),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ]),
                        )
                    ],
                  ),
                ),
                if (widget.adapter?.type != AdapterType.panel)
                  GestureDetector(
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
                            width: 24,
                            image: AssetImage('assets/newUI/to_plugin.png'),
                          )
                        : Container(),
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
