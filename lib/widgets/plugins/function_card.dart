import 'dart:core';

import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';

class FunctionCard extends StatefulWidget {
  final Widget? icon; // title左侧的icon
  final String title;
  final String? subTitle; // title右侧的副标题
  final Widget child; // 卡片右侧部分内容

  const FunctionCard({
    super.key,
    this.icon,
    required this.title,
    this.subTitle,
    required this.child,
  });

  @override
  State<FunctionCard> createState() => _FunctionCardState();
}

class _FunctionCardState extends State<FunctionCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 19, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.icon!,
                  ),
                Text(
                  '${widget.title}${widget.subTitle != null ? ' | ' : ''}',
                  style: const TextStyle(
                      fontFamily: 'MideaType-Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Color(0xFFFFFFFF),
                      decoration: TextDecoration.none),
                ),
                if (widget.subTitle != null)
                  Text(
                    widget.subTitle!,
                    style: const TextStyle(
                      fontFamily: 'MideaType-Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0x7AFFFFFF),
                      decoration: TextDecoration.none,
                    ),
                  )
              ],
            ),
            widget.child
          ],
        ),
      ),
    );
  }
}
