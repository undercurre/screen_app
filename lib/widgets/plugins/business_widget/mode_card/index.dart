import 'dart:core';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/base_widget/glass_card/index.dart';
import 'package:screen_app/common/device_mode/mode.dart';
import 'package:screen_app/widgets/plugins/business_widget/mode_card/mode_item.dart';

class ModeCard extends StatelessWidget {
  final List<Mode> modeList;
  final Map<String, bool?> selectedKeys;
  final Function(Mode mode)? onClick;
  final EdgeInsetsGeometry padding; // 卡片内边距
  final double spacing; // 两个元素之间的间距
  final double runSpacing; // 两行之间的间距

  const ModeCard({
    Key? key,
    required this.modeList,
    required this.selectedKeys,
    this.onClick,
    this.padding = const EdgeInsets.only(top: 18, bottom: 16),
    this.spacing = 22,
    this.runSpacing = 41,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemList = modeList
        .map(
          (mode) => ModeItem(
            mode: mode,
            selected: selectedKeys[mode.key] != null &&
                selectedKeys[mode.key] == true,
            onTap: (e) => onClick?.call(e),
          ),
        )
        .toList();
    return GlassCard(
      child: Padding(
        padding: padding,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: runSpacing,
          runAlignment: WrapAlignment.center,
          children: itemList,
        ),
      ),
    );
  }
}
