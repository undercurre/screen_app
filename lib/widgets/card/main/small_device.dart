import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';

class SmallDeviceCardWidget extends StatefulWidget {
  final String name;
  final Widget icon;
  final bool onOff;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final String characteristic; // 特征值
  final Function? onTap; // 整卡点击事件
  final Function? onMoreTap; // 右边的三点图标的点击事件

  const SmallDeviceCardWidget(
      {super.key,
      required this.name,
      required this.icon,
      required this.onOff,
      required this.roomName,
      required this.characteristic,
      this.onTap,
      this.onMoreTap,
      required this.online,
      required this.isFault,
      required this.isNative});

  @override
  _SmallDeviceCardWidgetState createState() => _SmallDeviceCardWidgetState();
}

class _SmallDeviceCardWidgetState extends State<SmallDeviceCardWidget> {
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
    return GestureDetector(
        onTap: () => widget.onTap?.call(),
        child: Container(
          width: 210,
          height: 88,
          padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w400),
                      ),
                      if (widget.isNative)
                        Container(
                          margin: const EdgeInsets.only(left: 14),
                          width: 36,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color.fromRGBO(255, 255, 255, 0.32),
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
                    Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${widget.roomName} | ${_getRightText()}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.64),
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ))
                  ],
                ),
              ),
              GestureDetector(
                  onTap: () => widget.onMoreTap?.call(),
                  child: const Image(
                      width: 24,
                      image: AssetImage('assets/newUI/to_plugin.png')))
            ],
          ),
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
    if (!widget.online) {
      BoxDecoration(
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
      border: Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.32),
        width: 0.6,
      ),
    );
  }
}
