import 'package:flutter/material.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../mz_slider.dart';

class BigDeviceLightCardWidget extends StatefulWidget {
  final String name;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool hasMore;
  final bool disabled;

  final DeviceCardDataAdapter? adapter;

  const BigDeviceLightCardWidget(
      {super.key,
      required this.name,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.hasMore = true,
      this.disabled = false,
      this.adapter,
      this.disableOnOff = true});

  @override
  _BigDeviceLightCardWidgetState createState() =>
      _BigDeviceLightCardWidgetState();
}

class _BigDeviceLightCardWidgetState extends State<BigDeviceLightCardWidget> {
  @override
  void initState() {
    super.initState();
    widget.adapter?.bindDataUpdateFunction(updateCallback);
    widget.adapter?.init();
  }

  @override
  void didUpdateWidget(covariant BigDeviceLightCardWidget oldWidget) {
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
    setState(() {
      Log.i('大卡片状态更新');
      setState(() {
        widget.adapter?.data = widget.adapter?.data;
      });
    });
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
              onTap: () {
                Log.i('disabled: ${widget.disabled}');
                if (!widget.disabled) {
                  widget.adapter?.power(
                    widget.adapter?.getPowerStatus(),
                  );
                }
              },
              child: Image(
                  width: 40,
                  height: 40,
                  image: AssetImage(widget.adapter?.getPowerStatus() ?? false
                      ? 'assets/newUI/card_power_on.png'
                      : 'assets/newUI/card_power_off.png')),
            ),
          ),
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
              top: 10,
              left: 88,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: widget.isNative ? 100 : 140),
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
                      margin: const EdgeInsets.fromLTRB(12, 0, 0, 6),
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
              )),
          Positioned(
            top: 62,
            left: 25,
            child: Text(
                "亮度 | ${widget.disabled ? '0' : widget.adapter?.getCardStatus()?['brightness'] ?? ''}%",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0XA3FFFFFF),
                    fontSize: 16,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)),
          ),
          Positioned(
            top: 80,
            left: 4,
            child: MzSlider(
              value: widget.disabled
                  ? 0
                  : widget.adapter?.getCardStatus()?['brightness'] ?? '',
              width: 390,
              height: 16,
              min: 0,
              max: 100,
              disabled: !(widget.adapter?.getPowerStatus() ?? false) ||
                  widget.disabled,
              activeColors: const [Color(0xFFCE8F31), Color(0xFFFFFFFF)],
              onChanging: (val, color) {
                widget.adapter?.slider1To(val.toInt());
              },
              onChanged: (val, color) {
                widget.adapter?.slider1To(val.toInt());
              },
            ),
          ),
          Positioned(
            top: 124,
            left: 25,
            child: Text(
                "色温 | ${_getColorK()}K",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0XA3FFFFFF),
                    fontSize: 16,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)),
          ),
          Positioned(
            top: 140,
            left: 4,
            child: MzSlider(
              value: widget.disabled
                  ? 0
                  : widget.adapter?.getCardStatus()?['colorTemp'] ?? '',
              width: 390,
              height: 16,
              min: 0,
              max: 100,
              disabled: !(widget.adapter?.getPowerStatus() ?? false) ||
                  widget.disabled,
              activeColors: const [Color(0xFFFFCC71), Color(0xFF55A2FA)],
              isBarColorKeepFull: true,
              onChanging: (val, color) {
                widget.adapter?.slider2To(val.toInt());
              },
              onChanged: (val, color) {
                widget.adapter?.slider2To(val.toInt());
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _getRightText() {
    if (widget.isFault) {
      return '故障';
    }
    if (!widget.online) {
      return '离线';
    }

    if (widget.disabled) {
      return '未加载';
    }

    if (widget.adapter?.dataState == DataState.LOADING) {
      return '加载中';
    }

    if (widget.adapter?.dataState == DataState.NONE) {
      return '未加载';
    }

    if (widget.adapter?.dataState == DataState.ERROR) {
      return '加载失败';
    }

    return widget.adapter?.getCharacteristic();
  }

  BoxDecoration _getBoxDecoration() {
    bool curPower = widget.adapter?.getPowerStatus() ?? false;
    if ((curPower && widget.online && !widget.disabled) ||
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

  int _getColorK() {
    if (widget.disabled) {
      return 0;
    }

    if (widget.adapter != null) {
      if (widget.adapter!.getCardStatus()?['maxColorTemp'] != null) {
        return ((widget.adapter?.getCardStatus()?['colorTemp'] as int) / 100 * ((widget.adapter?.getCardStatus()?['maxColorTemp'] as int) - (widget.adapter?.getCardStatus()?['minColorTemp'] as int)) + (widget.adapter?.getCardStatus()?['minColorTemp'] as int)).toInt();
      }
    }

    return ((widget.adapter?.getCardStatus()?['colorTemp'] as int) / 100 * (6500 - 2700) + 2700).toInt();
  }
}
