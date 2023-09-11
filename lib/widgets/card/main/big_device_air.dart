import 'package:flutter/cupertino.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../mz_slider.dart';

class BigDeviceAirCardWidget extends StatefulWidget {
  final String name;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool hasMore;
  final bool disabled;

  //----
  final DeviceCardDataAdapter? adapter;

  const BigDeviceAirCardWidget(
      {super.key,
      required this.name,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.adapter,
      this.hasMore = true,
      this.disabled = false,
      this.disableOnOff = true});

  @override
  _BigDeviceAirCardWidgetState createState() => _BigDeviceAirCardWidgetState();
}

class _BigDeviceAirCardWidgetState extends State<BigDeviceAirCardWidget> {
  @override
  void initState() {
    super.initState();
    widget.adapter?.bindDataUpdateFunction(updateCallback);
    widget.adapter?.init();
  }

  @override
  void didUpdateWidget(covariant BigDeviceAirCardWidget oldWidget) {
    widget.adapter?.bindDataUpdateFunction(updateCallback);
    widget.adapter?.init();
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
                Navigator.pushNamed(context, '0xAC', arguments: {
                  "name": widget.name,
                  "adapter": widget.adapter
                });
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
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      border:
                          Border.all(color: const Color(0xFFFFFFFF), width: 1),
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
            ),
          ),
          Positioned(
            top: 62,
            left: 20,
            child: SizedBox(
              height: 84,
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!widget.disabled) {
                        double value =
                            widget.adapter!.getCardStatus()?["temperature"] +
                                widget.adapter!
                                    .getCardStatus()?["smallTemperature"] -
                                0.5;
                        widget.adapter?.reduceTo(value.toInt());
                      }
                    },
                    child: Image(
                        color: Color.fromRGBO(
                            255,
                            255,
                            255,
                            (widget.adapter?.getPowerStatus() ?? false)
                                ? 1
                                : 0.7),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/sub.png')),
                  ),
                  Text("${_getTempVal()}",
                      style: TextStyle(
                          height: 1.5,
                          color: (widget.adapter?.getPowerStatus() ?? false)
                              ? const Color(0XFFFFFFFF)
                              : const Color(0XA3FFFFFF),
                          fontSize: 60,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                  GestureDetector(
                    onTap: () {
                      if (!widget.disabled) {
                        double value =
                            widget.adapter!.getCardStatus()?["temperature"] +
                                widget.adapter!
                                    .getCardStatus()?["smallTemperature"] +
                                0.5;
                        widget.adapter?.increaseTo(value.toInt());
                      }
                    },
                    child: Image(
                        color: Color.fromRGBO(
                            255,
                            255,
                            255,
                            (widget.adapter?.getPowerStatus() ?? false)
                                ? 1
                                : 0.7),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/add.png')),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 4,
            child: MzSlider(
              step: 0.5,
              value: _getTempVal(),
              width: 390,
              height: 16,
              min: 16,
              max: 30,
              disabled: !(widget.adapter?.getPowerStatus() ?? false),
              activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
              onChanging: (val, color) =>
                  {widget.adapter?.slider1To(val.toInt())},
              onChanged: (val, color) =>
                  {widget.adapter?.slider1To(val.toInt())},
            ),
          ),
        ],
      ),
    );
  }

  num _getTempVal() {
    if (widget.adapter == null) {
      return 0;
    }
    return widget.adapter!.getCardStatus()?["temperature"] +
        widget.adapter!.getCardStatus()?["smallTemperature"];
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
    // if ((curPower && widget.online && !widget.disabled) ||
    //     (widget.disabled && widget.disableOnOff)) {
    if ((curPower && widget.online && !widget.disabled) || widget.disabled) {
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
    return const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      gradient: LinearGradient(
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
