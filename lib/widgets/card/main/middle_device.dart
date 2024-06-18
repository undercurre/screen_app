import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/card/method.dart';

import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../event_bus.dart';

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
  final void Function(BuildContext, DeviceCardDataAdapter)?
      goToPageDetailFunction;

  final AdapterGenerateFunction<DeviceCardDataAdapter> adapterGenerateFunction;

  const MiddleDeviceCardWidget(
      {super.key,
      required this.applianceCode,
      required this.name,
      required this.icon,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      required this.adapterGenerateFunction,
      this.goToPageDetailFunction,
      this.disableOnOff = true,
      this.hasMore = true,
      this.disabled = false,
      this.discriminative = false,
      this.onTap});

  @override
  _MiddleDeviceCardWidgetState createState() => _MiddleDeviceCardWidgetState();
}

class _MiddleDeviceCardWidgetState extends State<MiddleDeviceCardWidget> {
  late DeviceCardDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if (!widget.disabled) {
      adapter.bindDataUpdateFunction(updateCallback);
    }
  }

  bool onlineState() {
    return adapter.fetchOnlineState(context, widget.applianceCode);
  }

  @override
  void dispose() {
    super.dispose();
    adapter.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {
      Log.i('中卡片状态更新');
      setState(() {
        adapter.data = adapter.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);

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

      if (!onlineState()) {
        return '离线';
      }
      //
      // if (adapter.dataState == DataState.LOADING) {
      //   return '';
      // }
      //
      // if (adapter.dataState == DataState.NONE) {
      //   return '离线';
      // }

      if (adapter.dataState == DataState.ERROR) {
        return '离线';
      }

      return adapter.getCharacteristic() ?? '';
    }

    String getRoomName() {
      if (widget.disabled) {
        return deviceListModel.getDeviceRoomName(
            deviceId: widget.applianceCode);
      }

      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '';
      }

      return deviceListModel.getDeviceRoomName(deviceId: widget.applianceCode);
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
      if (widget.isFault) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: getBigCardColorBg('fault'),

        );
      }
      if (!online) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'),
        );
      }
      if ((curPower && !widget.disabled)) {
        return BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          gradient: getBigCardColorBg('open'),
        );
      }
      return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'),
      );
    }

    return GestureDetector(
      onTap: () {
        if (adapter.dataState != DataState.SUCCESS) {
          adapter.fetchDataInSafety(widget.applianceCode);
          TipsUtils.toast(content: '网络服务异常，控制设备失败');
        }
        if (!onlineState() && !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing: (!onlineState() || adapter.dataState != DataState.SUCCESS),
        child: GestureDetector(
          onTap: () {
            Log.i('disabled: ${widget.disabled}');
            if (!widget.disabled && onlineState()) {
              widget.onTap?.call();
              adapter.power(
                adapter.getPowerStatus(),
              );
              bus.emit('operateDevice',
                  adapter.getCardStatus()?["nodeId"] ?? widget.applianceCode);
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
                      if (adapter.dataState != DataState.SUCCESS) {
                        adapter.fetchData();
                        // TipsUtils.toast(content: '数据缺失，控制设备失败');
                        return;
                      }
                      Log.i('点击进入插件', adapter.type);
                      if (!onlineState()) {
                        TipsUtils.toast(content: '设备已离线，请检查连接状态');
                        return;
                      }
                      if (!widget.disabled) {
                        // 2024/5/23 新增加一种跳入详情页的方式
                        if (widget.goToPageDetailFunction != null) {
                          widget.goToPageDetailFunction!(context, adapter);
                        } else {
                          if (adapter.type == AdapterType.wifiLight) {
                            Navigator.pushNamed(context, '0x13', arguments: {
                              "name": widget.name,
                              "adapter": adapter
                            });
                          } else if (adapter.type == AdapterType.wifiCurtain) {
                            Navigator.pushNamed(context, '0x14', arguments: {
                              "name": widget.name,
                              "adapter": adapter
                            });
                          } else if (adapter.type == AdapterType.zigbeeLight) {
                            Navigator.pushNamed(context, '0x21_light_colorful',
                                arguments: {
                                  "name": widget.name,
                                  "adapter": adapter
                                });
                          } else if (adapter.type == AdapterType.lightGroup) {
                            Navigator.pushNamed(context, 'lightGroup',
                                arguments: {
                                  "name": widget.name,
                                  "adapter": adapter
                                });
                          } else if (adapter.type == AdapterType.wifiAir) {
                            Navigator.pushNamed(context, '0xAC', arguments: {
                              "name": widget.name,
                              "adapter": adapter
                            });
                          } else if (adapter.type == AdapterType.wifiDianre) {
                            Navigator.pushNamed(context, '0xE2', arguments: {
                              "name": widget.name,
                              "adapter": adapter
                            });
                          } else if (adapter.type == AdapterType.wifiRanre) {
                            Navigator.pushNamed(context, '0xE3', arguments: {
                              "name": widget.name,
                              "adapter": adapter
                            });
                          } else if (adapter?.type == AdapterType.wifiLightFun) {
                            Navigator.pushNamed(context, '0x13_fun',
                                arguments: {
                                  "name": widget.name,
                                  "adapter": adapter
                                });
                          }
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
                        constraints: BoxConstraints(
                            maxWidth: widget.isNative ? 110 : 160),
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
                          _getRightText().isNotEmpty
                              ? " | ${_getRightText()}"
                              : "",
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
        ),
      ),
    );
  }
}
