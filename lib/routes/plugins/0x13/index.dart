import 'package:flutter/material.dart';

class WifiLightPageState extends State<WifiLightPage> {
  double _alignmentY = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    setState(() {
      _alignmentY = -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
    });
    print('滚动组件最大滚动距离:${metrics.maxScrollExtent}');
    print('当前滚动位置:${metrics.pixels}');
    print('当前变量:$_alignmentY');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WifiLightPage extends StatefulWidget {
  const WifiLightPage({super.key});

  @override
  State<WifiLightPage> createState() => WifiLightPageState();
}
