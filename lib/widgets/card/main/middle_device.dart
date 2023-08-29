import 'package:flutter/material.dart';

import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/logcat_helper.dart';

class MiddleDeviceCardWidget extends StatefulWidget {
  final String name;
  final Widget icon;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool hasMore;
  final bool disabled;
  final Function? onTap; // 整卡点击事件

  final DeviceCardDataAdapter? adapter;

  const MiddleDeviceCardWidget(
      {super.key,
      required this.name,
      required this.icon,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.disableOnOff = true,
      this.hasMore = true,
      this.disabled = false,
      this.adapter,
      this.onTap});

  @override
  _MiddleDeviceCardWidgetState createState() => _MiddleDeviceCardWidgetState();
}

class _MiddleDeviceCardWidgetState extends State<MiddleDeviceCardWidget> {
  bool onOff = false;
  String characteristic = "";

  @override
  void initState() {
    super.initState();
    widget.adapter?.bindDataUpdateFunction(updateCallback);
    widget.adapter?.init();
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
        height: 196,
        decoration: _getBoxDecoration(),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  if (widget.adapter?.type == AdapterType.wifiLight) {
                    Navigator.pushNamed(context, '0x13', arguments: {
                      "name": widget.name,
                      "adapter": widget.adapter
                    });
                  } else if (widget.adapter?.type == AdapterType.zigbeeLight) {
                    Navigator.pushNamed(context, '0x21_light_colorful',
                        arguments: {
                          "name": widget.name,
                          "adapter": widget.adapter
                        });
                  } else if (widget.adapter?.type == AdapterType.lightGroup) {
                    Navigator.pushNamed(context, 'lightGroup', arguments: {
                      "name": widget.name,
                      "adapter": widget.adapter
                    });
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
                    constraints:
                        BoxConstraints(maxWidth: widget.isNative ? 110 : 160),
                    child: Text(
                      widget.name,
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
                      widget.roomName,
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
                      _getRightText() != "" ? " | ${_getRightText()}" : "",
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
    if ((onOff && widget.online && !widget.disabled) ||
        (widget.disabled && widget.disableOnOff)) {
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
    );
  }
}
