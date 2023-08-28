import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/logcat_helper.dart';

class SmallDeviceCardWidget extends StatefulWidget {
  final String name;
  final Widget icon;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool disabled;
  final bool hasMore;
  final Function? onTap; // 整卡点击事件

  final DeviceCardDataAdapter? adapter;

  const SmallDeviceCardWidget(
      {super.key,
      required this.name,
      required this.icon,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.hasMore = true,
      this.disableOnOff = true,
      this.disabled = false,
      this.adapter,
      this.onTap});

  @override
  _SmallDeviceCardWidgetState createState() => _SmallDeviceCardWidgetState();
}

class _SmallDeviceCardWidgetState extends State<SmallDeviceCardWidget> {
  bool onOff = true;
  String characteristic = "";

  @override
  void initState() {
    super.initState();
    if (!widget.disabled) {
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void didUpdateWidget(covariant SmallDeviceCardWidget oldWidget) {
    if (!widget.disabled) {
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    var status = widget.adapter?.getCardStatus();
    setState(() {
      onOff = status?["power"] ?? false;
      characteristic = widget.adapter?.getStatusDes() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Log.i('disabled: ${widget.disabled}');
        if (!widget.disabled) {
          widget.onTap?.call();
          widget.adapter?.power(!onOff);
        }
      },
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
                child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        SizedBox(
                          width: 102,
                          child: Text(
                            widget.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
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
                                color:
                                    const Color.fromRGBO(255, 255, 255, 0.32),
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
                      if (widget.roomName != '' || _getRightText() != '')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${widget.roomName} ${_getRightText() != '' ? '|' : ''} ${_getRightText()}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.64),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                    ],
                  ),
                ),
                if (widget.adapter?.type != AdapterType.panel)
                  GestureDetector(
                    onTap: () {
                      if (widget.adapter?.type == AdapterType.wifiLight) {
                        Navigator.pushNamed(context, '0x13', arguments: {
                          "name": widget.name,
                          "adapter": widget.adapter
                        });
                      } else if (widget.adapter?.type ==
                          AdapterType.zigbeeLight) {
                        Navigator.pushNamed(context, '0x21_light_colorful',
                            arguments: {
                              "name": widget.name,
                              "adapter": widget.adapter
                            });
                      } else if (widget.adapter?.type ==
                          AdapterType.lightGroup) {
                        Navigator.pushNamed(context, 'lightGroup', arguments: {
                          "name": widget.name,
                          "adapter": widget.adapter
                        });
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
    );
  }

  String _getRightText() {
    if (widget.isFault) {
      return '故障';
    }
    if (!widget.online) {
      return '离线';
    }
    return characteristic;
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.disabled) {
      Log.i('widget:${widget.disableOnOff}');
      if (widget.disableOnOff) {
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
      } else {
        BoxDecoration(
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
    );
  }
}
