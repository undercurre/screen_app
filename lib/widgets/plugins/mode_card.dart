import 'dart:core';

import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';

class Mode {
  String key;
  String name;
  String onIcon;
  String offIcon;

  Mode(this.key, this.name, this.onIcon, this.offIcon);
}

class ModeCard extends StatelessWidget {
  final List<Mode> modeList;
  final Map<String, bool?> selectedKeys;
  final EdgeInsetsGeometry padding; // 卡片内边距
  final double spacing; // 两个元素之间的间距
  final double runSpacing; // 两行之间的间距
  final Function(Mode mode)? onTap;
  final String? title;

  const ModeCard({
    Key? key,
    required this.modeList,
    required this.selectedKeys,
    this.onTap,
    this.padding = const EdgeInsets.only(top: 18, bottom: 16),
    this.spacing = 22,
    this.runSpacing = 41,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemList = modeList
        .map(
          (mode) => ModeItem(
            mode: mode,
            selected: selectedKeys[mode.key] != null &&
                selectedKeys[mode.key] == true,
            onTap: (e) => onTap?.call(e),
          ),
        )
        .toList();
    return MzMetalCard(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) Padding(
              padding: const EdgeInsets.only(left: 18, bottom: 18),
              child: Text(
                '$title',
                style: const TextStyle(
                  fontFamily: "MideaType",
                  fontSize: 18,
                  height: 1.2,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: runSpacing,
                runAlignment: WrapAlignment.center,
                children: itemList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModeItem extends StatelessWidget {
  final Mode mode;
  final bool selected; // 当前模式是否选中
  final void Function(Mode mode)? onTap;

  const ModeItem(
      {Key? key, required this.mode, this.selected = false, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(mode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selected ? Colors.white : const Color(0x4c000000),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Image(
              height: 42,
              width: 42,
              image: AssetImage(
                selected ? mode.onIcon : mode.offIcon,
              ),
            ),
          ),
          Text(
            mode.name,
            style: const TextStyle(
              fontFamily: 'MideaType-Regular',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0x7AFFFFFF),
              decoration: TextDecoration.none,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
