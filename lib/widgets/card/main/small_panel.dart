import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/panel_data_adapter.dart';
import 'package:screen_app/common/global.dart';

import '../../../common/logcat_helper.dart';
import '../../mz_dialog.dart';

class SmallPanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  PanelDataAdapter adapter; // 数据适配器

  SmallPanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    required this.isOnline,
    required this.name,
  });

  @override
  _SmallPanelCardWidgetState createState() => _SmallPanelCardWidgetState();
}

class _SmallPanelCardWidgetState extends State<SmallPanelCardWidget> {
  bool _isFetching = false;
  Timer? _debounceTimer;

  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(Duration(milliseconds: 500), () async {
        Log.i('触发更新');
        await widget.adapter.fetchData();
        _isFetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.adapter.init();
    widget.adapter.bindDataUpdateFunction(() {
      updateData();
    });
  }

  void updateData() {
    if (mounted) {
      setState(() {
        widget.adapter.data.statusList[0] = widget.adapter.data.statusList[0];
      });
      // Log.i('更新数据', widget.adapter.data.nameList);
    }
  }

  @override
  void didUpdateWidget(covariant SmallPanelCardWidget oldWidget) {
    widget.adapter.init();
    widget.adapter.bindDataUpdateFunction(() {
      updateData();
    });
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
    return GestureDetector(
      onTap: () async {
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
          await widget.adapter.fetchOrderPowerMeiju(1);
          _throttledFetchData();
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
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              child: widget.icon,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  Text(
                    '${widget.roomName} | ${_getRightText()}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.64),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Object? _getRightText() {
    if (widget.isOnline == '0') {
      return '离线';
    }
    if (widget.adapter.data!.statusList.isNotEmpty) {
      return widget.adapter.data!.statusList[0] ? '开启' : '关闭';
    } else {
      return '离线';
    }
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.isOnline != '0' &&
        widget.adapter.data!.statusList.isNotEmpty &&
        widget.adapter.data!.statusList[0]) {
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
}
