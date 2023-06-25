
import 'package:flutter/material.dart';
import '../../mz_slider.dart';

class BigDeviceLightCardWidget extends StatefulWidget {
  final String name;
  final bool onOff;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final Function? onPowerTap; // 开关点击事件
  final Function? onMoreTap; // 右边的三点图标的点击事件
  //----
  final int brightness; // 亮度
  final int colorTemp; // 色温值
  final int colorPercent; // 色温滑条百分比

  /// type: 0-亮度，1-色温; value: 百分比; activeColor: 当前颜色
  final void Function(num type, num value, Color activeColor)? onChanging;
  /// type: 0-亮度，1-色温; value: 百分比; activeColor: 当前颜色
  final void Function(num type, num value, Color activeColor)? onChanged;

  const BigDeviceLightCardWidget(
      {super.key,
        required this.name,
        required this.onOff,
        required this.roomName,
        this.onPowerTap,
        this.onMoreTap,
        required this.online,
        required this.isFault,
        required this.isNative,
        required this.brightness,
        required this.colorTemp,
        required this.colorPercent,
        this.onChanging,
        this.onChanged});

  @override
  _BigDeviceLightCardWidgetState createState() => _BigDeviceLightCardWidgetState();
}

class _BigDeviceLightCardWidgetState extends State<BigDeviceLightCardWidget> {
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
      width: 440,
      height: 196,
      decoration: _getBoxDecoration(),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 24,
            child: GestureDetector(
              onTap: () => widget.onPowerTap?.call(),
              child: Image(
                  width: 40,
                  height: 40,
                  image: AssetImage(widget.onOff ? 'assets/newUI/card_power_on.png' : 'assets/newUI/card_power_off.png')
              ),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
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
              top: 10,
              left: 88,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: widget.isNative ? 100 : 140
                      ),
                      child: Text(widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 22,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)
                      ),
                    ),
                  ),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 90
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
                        maxWidth: 90
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

                  if(widget.isNative) Container(
                    alignment: Alignment.center,
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
                    ),
                    margin: const EdgeInsets.fromLTRB(12, 0, 0, 6),
                    child: const Text("本地",
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
              )
          ),

          Positioned(
            top: 62,
            left: 25,
            child: Text("亮度 | ${widget.brightness}%",
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

          Positioned(
            top: 80,
            left: 4,
            child: MzSlider(
              value: widget.brightness,
              width: 390,
              height: 16,
              min: 0,
              max: 100,
              disabled: !widget.onOff,
              activeColors: const [Color(0xFFCE8F31), Color(0xFFFFFFFF)],
              onChanging: (val, color) => {
                widget.onChanging?.call(0, val, color)
              },
              onChanged: (val, color) => {
                widget.onChanged?.call(0, val, color)
              },
            ),
          ),

          Positioned(
            top: 124,
            left: 25,
            child: Text("色温 | ${widget.colorTemp}K",
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

          Positioned(
            top: 140,
            left: 4,
            child: MzSlider(
              value: widget.colorPercent,
              width: 390,
              height: 16,
              min: 0,
              max: 100,
              disabled: !widget.onOff,
              activeColors: const [Color(0xFFFFCC71), Color(0xFF55A2FA)],
              isBarColorKeepFull: true,
              onChanging: (val, color) => {
                widget.onChanging?.call(1, val, color)
              },
              onChanged: (val, color) => {
                widget.onChanged?.call(1, val, color)
              },
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
    return '在线';
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.onOff && widget.online) {
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
