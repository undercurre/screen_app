import 'package:flutter/material.dart';

import '../../../routes/plugins/0x21/0x21_485_air/air_data_adapter.dart';
import '../../util/nameFormatter.dart';

class Middle485AirDeviceCardWidget extends StatefulWidget {
  final String name;
  final String applianceCode;
  final String? modelNumber;
  final String? masterId;
  final Widget icon;
  bool onOff;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final String characteristic; // 特征值
  final Function? onTap; // 整卡点击事件
  final Function? onMoreTap; // 右边的三点图标的点击事件
  AirDataAdapter? adapter; // 数据适配器
  int windSpeed = 4; // 风速值


  Middle485AirDeviceCardWidget({
    super.key,
    required this.name,
    required this.applianceCode,
    required this.modelNumber,
    required this.masterId,
    required this.icon,
    required this.onOff,
    required this.roomName,
    required this.characteristic,
    this.onTap,
    this.onMoreTap,
    required this.online,
    required this.isFault,
    required this.isNative,
    required this.adapter,
  });

  @override
  _Middle485AirDeviceCardWidgetState createState() =>
      _Middle485AirDeviceCardWidgetState();
}

class _Middle485AirDeviceCardWidgetState extends State<Middle485AirDeviceCardWidget> {

  @override
  void initState() {
    super.initState();
    widget.adapter!.bindDataUpdateFunction(updateData);
    widget.adapter!.init();
    updateDetail();
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter?.unBindDataUpdateFunction(updateData);
    widget.adapter?.destroy();
  }



  @override
  void didUpdateWidget(covariant Middle485AirDeviceCardWidget oldWidget) {
    widget.adapter!.bindDataUpdateFunction(updateData);
    widget.adapter!.init();
    setState(() {
      widget.windSpeed=oldWidget.windSpeed;
      widget.onOff=oldWidget.onOff;
    });
  }

  void updateData() {
    if (mounted) {
      setState(() {
        widget.adapter?.data = widget.adapter!.data!;
        widget.onOff =widget.adapter!.data!.OnOff == '1'?true:false;
        widget.windSpeed =int.parse(widget.adapter!.data!.windSpeed);
      });
    }
  }

  void powerHandle(bool state) async {
    if (widget.onOff == true) {
      widget.adapter!.data!.OnOff = "0";
      widget.onOff=false;
      setState(() {});
      widget.adapter?.orderPower(0);
    } else {
      widget.adapter!.data!.OnOff = "1";
      widget.onOff=true;
      setState(() {});
      widget.adapter?.orderPower(1);
    }
  }

  Future<void> updateDetail() async {
    widget.adapter?.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        powerHandle(widget.onOff)
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
                onTap: () => {
                  Navigator.pushNamed(context, '0x21_485Air', arguments: {
                    "name": widget.name,
                    "adapter": widget.adapter
                  })
                },
                child: const Image(
                    width: 32,
                    height: 32,
                    image: AssetImage('assets/newUI/to_plugin.png')),
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
                      NameFormatter.formatName(widget.name, 5),
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
                      NameFormatter.formatName(widget.roomName, 4),
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
    int windSpeed = 1;
    if (widget.windSpeed == 1) {
      windSpeed = 3;
    } else if (widget.windSpeed == 2) {
      windSpeed = 2;
    } else if (widget.windSpeed == 4) {
      windSpeed = 1;
    } else {
      windSpeed = 3;
    }
    return "$windSpeed档";

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
        color: const Color(0x00FFFFFF),
        width: 0,
      ),
    );
  }
}
