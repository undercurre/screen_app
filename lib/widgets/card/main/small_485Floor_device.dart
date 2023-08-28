import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/logcat_helper.dart';

import '../../../routes/plugins/0x21/0x21_485_cac/cac_data_adapter.dart';
import '../../../routes/plugins/0x21/0x21_485_floor/floor_data_adapter.dart';

class Small485FloorDeviceCardWidget extends StatefulWidget {
  final String name;
  final String applianceCode;
  final String? modelNumber;
  final String? masterId;
  final Widget icon;
  bool onOff;
  final String online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final String characteristic; // 特征值
  final Function? onTap; // 整卡点击事件
  final Function? onMoreTap; // 右边的三点图标的点击事件
  FloorDataAdapter? adapter; // 数据适配器

  Small485FloorDeviceCardWidget({
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
  _Small485FloorDeviceCardWidget createState() => _Small485FloorDeviceCardWidget();
}

class _Small485FloorDeviceCardWidget extends State<Small485FloorDeviceCardWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.adapter?.init();
      widget.onOff =widget.adapter!.data.OnOff == '1'?true:false;
      widget.adapter!.bindDataUpdateFunction(() {
        updateData();
      });
      updateDetail();
    });
    super.initState();
  }

  void updateData() {
    if (mounted) {
      setState(() {
        widget.adapter?.data = widget.adapter!.data;
        widget.onOff =widget.adapter!.data.OnOff == '1'?true:false;
      });
    }
  }

  void powerHandle(bool state) async {
    if (widget.onOff == true) {
      widget.adapter!.data.OnOff = "0";
      widget.onOff=false;
      setState(() {});
      widget.adapter?.orderPower(0);
    } else {
      widget.adapter!.data.OnOff = "1";
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    SizedBox(
                      width: 100,
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
            if (widget.onMoreTap != null)
              GestureDetector(
                onTap: () => {
                  Navigator.pushNamed(context, '0x21_485Floor',
                      arguments: {"name": widget.name,"adapter": widget.adapter})
                },
                child: const Image(
                  width: 24,
                  image: AssetImage('assets/newUI/to_plugin.png'),
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
    if (widget.online == "0") {
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
    if (widget.onOff && widget.online=="1") {
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
    if (widget.online == "0") {
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
