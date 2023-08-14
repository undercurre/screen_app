import 'dart:async';

import 'package:flutter/cupertino.dart';
import '../../../common/adapter/panel_data_adapter.dart';
import '../../../common/logcat_helper.dart';

class BigDevicePanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  PanelDataAdapter adapter; // 数据适配器

  BigDevicePanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    required this.isOnline,
    required this.name,
  });

  @override
  _BigDevicePanelCardWidgetState createState() =>
      _BigDevicePanelCardWidgetState();
}

class _BigDevicePanelCardWidgetState
    extends State<BigDevicePanelCardWidget> {
  bool _isFetching = false;
  Timer? _debounceTimer;

  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(const Duration(milliseconds: 1000), () async {
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
        widget.adapter.data.statusList = widget.adapter.data.statusList;
      });
      Log.i('更新数据', widget.adapter.data.nameList);
    }
  }

  @override
  void didUpdateWidget(covariant BigDevicePanelCardWidget oldWidget) {
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
                    constraints:
                        const BoxConstraints(maxWidth: 140),
                    child: Text(widget.name,
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
                  constraints: const BoxConstraints(maxWidth: 90),
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
            left: 32,
            child: SizedBox(
              height: 120,
              width: 376,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.adapter.data.statusList.isNotEmpty) _panelItem(0),
                  if (widget.adapter.data.statusList.length >= 2) _panelItem(1),
                  if (widget.adapter.data.statusList.length >= 3) _panelItem(2),
                  if (widget.adapter.data.statusList.length >= 4) _panelItem(3),
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
          await widget.adapter.fetchOrderPowerMeiju(index + 1);
          _throttledFetchData();
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
    if (index < 0 || index > widget.adapter.data.statusList.length - 1) {
      return false;
    } else {
      return widget.adapter.data.statusList[index];
    }
  }

  String _getRightText() {
    if (widget.isOnline == '0') {
      return '离线';
    }
    if (widget.adapter.data!.statusList.isNotEmpty) {
      return '在线';
    } else {
      return '离线';
    }
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.isOnline != '0' && widget.adapter.data!.statusList.isNotEmpty) {
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
        color: const Color.fromRGBO(255, 255, 255, 0.32),
        width: 0.6,
      ),
    );
  }
}
