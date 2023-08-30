import 'dart:async';

import 'package:flutter/cupertino.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/adapter/panel_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../event_bus.dart';
import '../../mz_dialog.dart';

class MiddleDevicePanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  final bool disabled;
  PanelDataAdapter adapter; // 数据适配器

  MiddleDevicePanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    required this.isOnline,
    required this.name,
    required this.disabled,
  });

  @override
  _MiddleDevicePanelCardWidgetState createState() =>
      _MiddleDevicePanelCardWidgetState();
}

class _MiddleDevicePanelCardWidgetState
    extends State<MiddleDevicePanelCardWidget> {
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
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>((args) {
        if (args.nodeId == widget.adapter.nodeId) {
          _throttledFetchData();
        }
      });
    } else {
      bus.typeOn<HomluxDevicePropertyChangeEvent>((arg) {
        if (arg.deviceInfo.eventData?.deviceId == widget.adapter.applianceCode) {
          _throttledFetchData();
        }
      });
    }
    if (!widget.disabled) {
      widget.adapter.init();
      widget.adapter.bindDataUpdateFunction(() {
        updateData();
      });
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
  void didUpdateWidget(covariant MiddleDevicePanelCardWidget oldWidget) {
    if (!widget.disabled) {
      widget.adapter.init();
      widget.adapter.bindDataUpdateFunction(() {
        updateData();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.adapter.unBindDataUpdateFunction(() {
      updateData();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 196,
      decoration: _getBoxDecoration(),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: widget.adapter.dataState == DataState.ERROR
                ? GestureDetector(
              onTap: () {
                _throttledFetchData();
              },
              child: const Image(
                width: 40,
                height: 40,
                image: AssetImage('assets/newUI/refresh.png'),
              ),
            )
                : widget.icon,
          ),
          Positioned(
            top: 0,
            left: 72,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 20,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
            ),
          ),
          Positioned(
            top: 32,
            left: 72,
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 50),
                  child: Text(widget.roomName,
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
                  constraints: const BoxConstraints(maxWidth: 50),
                  child: Text(" | ${_getRightText()}",
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
            left: 16,
            child: GestureDetector(
              onTap: () async {
                Log.i('disabled', widget.disabled);
                if (!widget.disabled) {
                  if (widget.isOnline == '0') {
                    MzDialog(
                        title: '该设备已离线',
                        titleSize: 28,
                        maxWidth: 432,
                        backgroundColor: const Color(0xFF494E59),
                        contentPadding:
                            const EdgeInsets.fromLTRB(33, 24, 33, 0),
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
                    await widget.adapter.fetchOrderPower(1);
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(widget.adapter.data.statusList[0] && !widget.disabled
                          ? 'assets/newUI/panel_btn_on.png'
                          : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain),
                ),
                child: SizedBox(
                  width: 84,
                  child: Center(
                    child: Text(
                      widget.adapter.data.nameList[0],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 68,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                Log.i('disabled', widget.disabled);
                if (!widget.disabled  && widget.adapter.dataState == DataState.SUCCESS) {
                  if (widget.isOnline == '0') {
                    MzDialog(
                        title: '该设备已离线',
                        titleSize: 28,
                        maxWidth: 432,
                        backgroundColor: const Color(0xFF494E59),
                        contentPadding:
                            const EdgeInsets.fromLTRB(33, 24, 33, 0),
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
                    await widget.adapter.fetchOrderPower(2);
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(widget.adapter.data.statusList[1] && !widget.disabled
                          ? 'assets/newUI/panel_btn_on.png'
                          : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain),
                ),
                child: SizedBox(
                  width: 84,
                  child: Center(
                    child: Text(
                      widget.adapter.data.nameList[1],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRightText() {
    if (widget.disabled) {
      return '未加载';
    }
    if (widget.adapter.dataState == DataState.LOADING  || widget.adapter.dataState == DataState.NONE) {
      return '加载中';
    }
    if (widget.isOnline == '0') {
      return '离线';
    }
    if (widget.adapter.dataState == DataState.ERROR) {
      return '加载失败';
    }
    if (widget.adapter.data!.statusList.isNotEmpty) {
      return '在线';
    } else {
      return '离线';
    }
  }

  BoxDecoration _getBoxDecoration() {
    return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0x33616A76),
            Color(0x33434852),
          ],
        ));
  }
}
