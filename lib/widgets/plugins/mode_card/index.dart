import 'dart:core';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/glass_card/index.dart';

import '../../../common/device_mode/mode.dart';

class ModeCard extends StatefulWidget {
  final List<Mode> modeList;
  final String selectedKey;
  final Function(Mode mode)? onClick;

  const ModeCard({
    super.key,
    required this.modeList,
    required this.selectedKey,
    this.onClick
  });

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  late List<Mode> modeList;

  @override
  void initState() {
    super.initState();
    modeList = widget.modeList;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(21, 18, 25, 0),
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: modeList
              .map(
                (mode) => Listener(
                  onPointerDown: (PointerDownEvent event) => widget.onClick != null ? widget.onClick!(mode) : print('点击了'),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 11),
                        decoration: BoxDecoration(
                          color: mode.key == widget.selectedKey
                              ? Colors.white
                              : Colors.black,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Image(
                          image: AssetImage(mode.key == widget.selectedKey
                              ? mode.onIcon
                              : mode.offIcon),
                        ),
                      ),
                      Text(
                        mode.name,
                        style: const TextStyle(
                            fontFamily: 'MEIDITYPE-REGULAR',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0x7AFFFFFF),
                            decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    throw UnimplementedError();
  }
}
