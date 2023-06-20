
import 'package:flutter/material.dart';

class MiddleDevicePanelCardWidget extends StatefulWidget {
  final String name;
  final Widget icon;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final String characteristic; // 特征值
  final Function? onMoreTap; // 右边的三点图标的点击事件

  /// 按钮1
  final String btn1Name; // 名称
  final bool btn1IsOn; // 开关状态

  /// 按钮2
  final String btn2Name; // 名称
  final bool btn2IsOn; // 开关状态

  /// 按钮事件 (index) => {}
  final void Function(int index)? onBtnTap;

  const MiddleDevicePanelCardWidget(
      {super.key,
        required this.name,
        required this.icon,
        required this.roomName,
        required this.characteristic,
        this.onMoreTap,
        required this.online,
        required this.isFault,
        required this.isNative,
        required this.btn1Name,
        required this.btn1IsOn,
        required this.btn2Name,
        required this.btn2IsOn,
        this.onBtnTap});

  @override
  _MiddleDevicePanelCardWidgetState createState() => _MiddleDevicePanelCardWidgetState();
}

class _MiddleDevicePanelCardWidgetState extends State<MiddleDevicePanelCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
            right: 12,
            child: GestureDetector(
              onTap: () => widget.onMoreTap?.call(),
              child: const Image(
                  width: 32,
                  height: 32,
                  image: AssetImage('assets/newUI/to_plugin.png')
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: widget.icon,
          ),

          Positioned(
            top: 0,
            left: 72,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 90
              ),
              child: Text(widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 20,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)
              ),
            ),
          ),

          Positioned(
            top: 32,
            left: 72,
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 50
                  ),
                  child: Text(widget.roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 50
                  ),
                  child: Text(" | ${_getRightText()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 68,
            left: 16,
            child: GestureDetector(
              onTap: () {
                widget.onBtnTap?.call(0);
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(widget.btn1IsOn ? 'assets/newUI/panel_btn_on.png' : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain
                  ),
                ),
                child: Text(widget.btn1Name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)
                ),
              ),
            ),
          ),

          Positioned(
            top: 68,
            right: 16,
            child: GestureDetector(
              onTap: () {
                widget.onBtnTap?.call(1);
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(widget.btn2IsOn ? 'assets/newUI/panel_btn_on.png' : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain
                  ),
                ),
                child: Text(widget.btn2Name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRightText() {
    if (widget.isFault) {
      return '故障';
    }
    if (!widget.online) {
      return '离线';
    }
    return widget.characteristic;
  }

  BoxDecoration _getBoxDecoration() {
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
