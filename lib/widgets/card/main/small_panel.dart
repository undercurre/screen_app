import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/panel_data_adapter.dart';
import 'package:screen_app/common/global.dart';

class SmallPanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String? fakerName;
  final String? roomFakerName;
  PanelDataAdapter adapter; // 数据适配器

  SmallPanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    this.roomFakerName,
    this.fakerName,
  });

  @override
  _SmallPanelCardWidgetState createState() => _SmallPanelCardWidgetState();
}

class _SmallPanelCardWidgetState extends State<SmallPanelCardWidget> {
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
      onTap: () {
        logger.i('点击卡片', widget.adapter.applianceCode);
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
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.fakerName ?? widget.adapter.data!.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${widget.roomFakerName ?? widget.adapter.data!.roomName} | ${_getRightText()}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.64),
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Object? _getRightText() {
    if (!widget.adapter.data!.isOnline) {
      return '离线';
    }
    return widget.adapter.data!.statusList[0] ? '开启' : '关闭';
  }

  BoxDecoration _getBoxDecoration() {
    if (!widget.adapter.data!.isOnline) {
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
