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
import '../../event_bus.dart';
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

  final AdapterGenerateFunction<DeviceCardDataAdapter>? adapterGenerateFunction;

  SmallDeviceCardWidget(
      {super.key,
      required this.applianceCode,
      required this.name,
      required this.icon,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      required this.adapterGenerateFunction,
      this.hasMore = true,
      this.disableOnOff = true,
      this.discriminative = false,
      this.disabled = false,
      this.onTap});

  @override
  _SmallDeviceCardWidgetState createState() => _SmallDeviceCardWidgetState();
}

class _SmallDeviceCardWidgetState extends State<SmallDeviceCardWidget> {
  DeviceCardDataAdapter? adapter;

  @override
  void initState() {
    super.initState();
    if (widget.adapterGenerateFunction != null) {
      adapter = widget.adapterGenerateFunction!.call(widget.applianceCode);
      adapter!.init();
      if (!widget.disabled) {
        adapter!.bindDataUpdateFunction(updateCallback);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    adapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    Log.i('小卡片状态更新');
    if (mounted) {
      setState(() {
        adapter?.data = adapter?.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);

    String _getRightText() {
      if (widget.discriminative) {
        return '';
      }
      if (widget.applianceCode == 'localPanel1' ||
          widget.applianceCode == 'localPanel2') {
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

      if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
        return '离线';
      }

      // if (adapter.dataState == DataState.LOADING) {
      //   return '在线';
      // }
      //
      // if (adapter.dataState == DataState.NONE) {
      //   return '离线';
      // }

      if (adapter?.dataState == DataState.ERROR) {
        return '离线';
      }

      return adapter?.getCharacteristic() ?? '';
    }

    String getRoomName() {
      String nameInModel =
          deviceListModel.getDeviceRoomName(deviceId: widget.applianceCode);
      if (widget.disabled) {
        return nameInModel;
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.applianceCode,
          maxLength: 4,
          startLength: 1,
          endLength: 2);

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
      bool curPower = adapter?.getPowerStatus() ?? false;
      bool online =
          deviceListModel.getOnlineStatus(deviceId: widget.applianceCode);
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
            widget.discriminative
                ? Colors.white.withOpacity(0.12)
                : const Color(0x33616A76),
            widget.discriminative
                ? Colors.white.withOpacity(0.12)
                : const Color(0x33434852),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (widget.disabled) return;
        if (adapter?.dataState != DataState.SUCCESS) {
          adapter?.fetchDataAndCheckWaitLockAuth(widget.applianceCode);
          // TipsUtils.toast(content: '数据缺失，控制设备失败');
          return;
        }
        Log.i('点击卡片',
            deviceListModel.getOnlineStatus(deviceId: widget.applianceCode));
        if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) &&
            !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing:
            (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) ||
                adapter?.dataState != DataState.SUCCESS),
        child: GestureDetector(
          onTap: () {
            if (!widget.disabled &&
                deviceListModel.getOnlineStatus(
                    deviceId: widget.applianceCode)) {
              // widget.onTap?.call();
              adapter?.power(adapter?.getPowerStatus());
              bus.emit('operateDevice',
                  adapter?.getCardStatus()?["nodeId"] ?? widget.applianceCode);
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
                                    color: const Color.fromRGBO(
                                        255, 255, 255, 0.32),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: Text(
                                        '${_getRightText().isNotEmpty ? '|' : ''}',
                                        style: TextStyle(
                                          fontFamily: 'MideaType',
                                          color: Colors.white.withOpacity(0.64),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 45),
                                      child: Text(
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
                                    )
                                  ]),
                            )
                        ],
                      ),
                    ),
                    if (adapter?.type != AdapterType.panel)
                      GestureDetector(
                        onTap: () {
                          if (adapter?.dataState != DataState.SUCCESS) {
                            adapter?.fetchData();
                            // TipsUtils.toast(content: '数据缺失，控制设备');
                          }
                          Log.i('点击进入插件', adapter?.type);
                          if (!deviceListModel.getOnlineStatus(
                              deviceId: widget.applianceCode)) {
                            TipsUtils.toast(content: '设备已离线，请检查连接状态');
                            return;
                          }
                          if (!widget.disabled) {
                            if (adapter?.type == AdapterType.wifiLight) {
                              Navigator.pushNamed(context, '0x13', arguments: {
                                "name": widget.name,
                                "adapter": adapter
                              });
                            } else if (adapter?.type ==
                                AdapterType.wifiCurtain) {
                              Navigator.pushNamed(context, '0x14', arguments: {
                                "name": widget.name,
                                "adapter": adapter
                              });
                            } else if (adapter?.type ==
                                AdapterType.zigbeeLight) {
                              Navigator.pushNamed(
                                  context, '0x21_light_colorful', arguments: {
                                "name": widget.name,
                                "adapter": adapter
                              });
                            } else if (adapter?.type ==
                                AdapterType.lightGroup) {
                              Navigator.pushNamed(context, 'lightGroup',
                                  arguments: {
                                    "name": widget.name,
                                    "adapter": adapter
                                  });
                            } else if (adapter?.type == AdapterType.wifiAir) {
                              Navigator.pushNamed(context, '0xAC', arguments: {
                                "name": widget.name,
                                "adapter": adapter
                              });
                            }else if (adapter?.type == AdapterType.wifiDianre) {
                              Navigator.pushNamed(context, '0xE2', arguments: {
                                "name": widget.name,
                                "adapter": adapter
                              });
                            }else if (adapter?.type == AdapterType.wifiRanre) {
                              Navigator.pushNamed(context, '0xE3', arguments: {
                                "name": widget.name,
                                "adapter": adapter
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
        ),
      ),
    );
  }
}
