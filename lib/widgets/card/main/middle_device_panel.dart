import 'package:flutter/material.dart';
import 'package:screen_app/common/logcat_helper.dart';
import '../../../common/adapter/panel_data_adapter.dart';

class MiddleDevicePanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  PanelDataAdapter adapter; // 数据适配器

  MiddleDevicePanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    required this.isOnline,
    required this.name,
  });

  @override
  _MiddleDevicePanelCardWidgetState createState() =>
      _MiddleDevicePanelCardWidgetState();
}

class _MiddleDevicePanelCardWidgetState
    extends State<MiddleDevicePanelCardWidget> {
  @override
  void initState() {
    super.initState();
    widget.adapter.init();
    widget.adapter.bindDataUpdateFunction(() {
      updataData();
    });
  }

  void updataData() {
    widget.adapter.bindDataUpdateFunction(() {
      setState(() {
        widget.adapter.data.statusList = widget.adapter.data.statusList;
      });
      Log.i('更新数据', widget.adapter.data.nameList);
    });
  }

  @override
  void didUpdateWidget(covariant MiddleDevicePanelCardWidget oldWidget) {
    widget.adapter.init();
    widget.adapter.bindDataUpdateFunction(() {
      updataData();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.adapter.unBindDataUpdateFunction(() {
      updataData();
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
            child: widget.icon,
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
                await widget.adapter.fetchOrderPowerMeiju(1);
                await widget.adapter.fetchData();
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(widget.adapter.data.statusList[0]
                          ? 'assets/newUI/panel_btn_on.png'
                          : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain),
                ),
                child: Text(widget.adapter.data.nameList[0],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
            ),
          ),
          Positioned(
            top: 68,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await widget.adapter.fetchOrderPowerMeiju(2);
                await widget.adapter.fetchData();
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(widget.adapter.data.statusList[1]
                          ? 'assets/newUI/panel_btn_on.png'
                          : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain),
                ),
                child: Text(widget.adapter.data.nameList[1],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
            ),
          ),
        ],
      ),
    );
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
