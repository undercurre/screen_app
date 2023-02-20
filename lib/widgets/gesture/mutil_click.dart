import 'package:flutter/material.dart';

/// 使用场景：连接点击
@immutable
class MultiClick extends StatelessWidget {

  /// 子View
  Widget child;
  /// 连续点击次数
  int count;
  /// 有效时间内
  int duration;
  /// 记录点击次数
  late List<int> hits;
  /// 点击事件
  void Function()? clickListener;

  MultiClick({super.key,required this.child,  this.count = 2, this.duration = 1000, this.clickListener}) {
    hits = List.filled(count, 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /// 数组向左移动一位
        List.copyRange(hits, 0, hits, 1, hits.length);
        final millisecond = DateTime.now().millisecondsSinceEpoch;
        hits[hits.length - 1] = millisecond;
        if(hits[0] >= millisecond - duration) {
          clickListener?.call();
          /// 重新清除数组内容
          hits.fillRange(0, count, 0);
        }
      },
      child: child,
    );
  }

}