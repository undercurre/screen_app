import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/adapter/panel_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../event_bus.dart';
import '../../mz_buttion.dart';
import '../../mz_dialog.dart';

class BigDevicePanelCardWidgetThree extends StatefulWidget {
  final String applianceCode;
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  final bool disabled;
  final bool disableOnOff;
  final bool discriminative;
  PanelDataAdapter adapter; // 数据适配器

  BigDevicePanelCardWidgetThree({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    this.disableOnOff = true,
    required this.isOnline,
    required this.name,
    required this.disabled,
    this.discriminative = false,
    required this.applianceCode,
  });

  @override
  _BigDevicePanelCardWidgetThreeState createState() =>
      _BigDevicePanelCardWidgetThreeState();
}

class _BigDevicePanelCardWidgetThreeState
    extends State<BigDevicePanelCardWidgetThree> {
  bool _isFetching = false;
  Timer? _debounceTimer;

  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
        Log.i('触发更新');
        await widget.adapter.fetchData();
        _isFetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _startPushListen();
    if (!widget.disabled) {
      widget.adapter.init();
      widget.adapter.bindDataUpdateFunction(updateData);
    }
  }

  void updateData() {
    if (mounted) {
      setState(() {
        widget.adapter.data.statusList = widget.adapter.data.statusList;
      });
      // Log.i('更新数据', widget.adapter.data.nameList);
    }
  }

  @override
  void didUpdateWidget(covariant BigDevicePanelCardWidgetThree oldWidget) {
    if (!widget.disabled) {
      widget.adapter.init();
      widget.adapter.bindDataUpdateFunction(updateData);
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    _stopPushListen();
    widget.adapter.unBindDataUpdateFunction(updateData);
    widget.adapter.destroy();
    super.dispose();
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
      // if (widget.adapter.dataState == DataState.LOADING ||
      //     widget.adapter.dataState == DataState.NONE) {
      //   return '在线';
      // }
      if (!deviceListModel.getOnlineStatus(
          deviceId: widget.applianceCode)) {
        return '离线';
      }
      if (widget.adapter.dataState == DataState.ERROR) {
        return '离线';
      }
      if (widget.adapter.data!.statusList.isNotEmpty) {
        return '在线';
      } else {
        return '离线';
      }
    }

    // if (mounted) {
    //   if (layoutModel.hasLayoutWithDeviceId(widget.applianceCode) &&
    //       deviceListModel.deviceCacheList.isNotEmpty) {
    //     List<DeviceEntity> hitList = deviceListModel.deviceCacheList.where((
    //         element) => element.applianceCode == widget.applianceCode).toList();
    //     if (hitList.isEmpty) {
    //       layoutModel.deleteLayout(widget.adapter.applianceCode);
    //       TipsUtils.toast(content: '已删除${hitList[0].name}');
    //     }
    //   }
    // }

    String getRoomName() {
      if (widget.disabled) {
        return deviceListModel.getDeviceRoomName(
            deviceId: widget.adapter.applianceCode);
      }

      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '';
      }

      return deviceListModel.getDeviceRoomName(
          deviceId: widget.adapter.applianceCode);
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
        deviceId: widget.adapter.applianceCode,
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

    return Container(
      width: 440,
      height: 196,
      decoration: _getBoxDecoration(),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 24,
            child:
                Image(width: 40, height: 40, image: AssetImage(_getIconSrc())),
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
                  child: Text("${_getRightText().isNotEmpty ? ' | ': ''}${_getRightText()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 68,
            left: 32,
            child: SizedBox(
              height: 120,
              width: 376,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.adapter.data.nameList.isNotEmpty) _panelItem(0),
                  if (widget.adapter.data.nameList.length >= 2) _panelItem(1),
                  if (widget.adapter.data.nameList.length >= 3) _panelItem(2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelItem(int index) {
    return SizedBox(
      width: 84,
      height: 120,
      child: GestureDetector(
        onTap: () async {
          Log.i('disabled', widget.disabled);
          if (!widget.disabled &&
              widget.adapter.dataState == DataState.SUCCESS) {
            if (widget.isOnline == '0') {
              MzDialog(
                  title: '该设备已离线',
                  titleSize: 28,
                  maxWidth: 432,
                  backgroundColor: const Color(0xFF494E59),
                  contentPadding: const EdgeInsets.fromLTRB(33, 24, 33, 0),
                  contentSlot: const Text("设备离线，请检查网络是否正常",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        color: Color(0xFFB6B8BC),
                        fontSize: 24,
                        height: 1.6,
                        fontFamily: "MideaType",
                        decoration: TextDecoration.none,
                      )),
                  btns: ['确定'],
                  onPressed: (_, position, context) {
                    Navigator.pop(context);
                  }).show(context);
            } else {
              await widget.adapter.fetchOrderPower(index + 1);
            }
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              height: 120,
              width: 84,
              image: _isPanelItemOn(index)
                  ? const AssetImage("assets/newUI/panel_btn_on.png")
                  : const AssetImage("assets/newUI/panel_btn_off.png"),
            ),
            Text(
              widget.adapter.data.nameList[index],
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Color(0XFFFFFFFF),
                  fontSize: 16,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            )
          ],
        ),
      ),
    );
  }

  String _getIconSrc() {
    if (widget.adapter.data.nameList.length == 1) {
      return "assets/newUI/device/0x21_1339.png";
    }
    if (widget.adapter.data.nameList.length == 2) {
      return "assets/newUI/device/0x21_1340.png";
    }
    if (widget.adapter.data.nameList.length == 3) {
      return "assets/newUI/device/0x21_1341.png";
    }
    return "assets/newUI/device/0x21_1342.png";
  }

  bool _isPanelItemOn(int index) {
    if (!widget.disabled) {
      if (index < 0 || index > widget.adapter.data.statusList.length - 1) {
        return false;
      } else {
        return widget.adapter.data.statusList[index];
      }
    } else {
      return false;
    }
  }

  BoxDecoration _getBoxDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
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

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    if (args.nodeId == widget.adapter.nodeId) {
      _throttledFetchData();
    }
  }

  void homluxPush(HomluxDevicePropertyChangeEvent arg) {
    if (arg.deviceInfo.eventData?.deviceId == widget.adapter.applianceCode) {
      _throttledFetchData();
    }
  }

  void _startPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush);
    } else {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush);
    } else {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }
}
