import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/logcat_helper.dart';
import '../../widgets/keep_alive_wrapper.dart';

class _KeepAliveWrapper extends StatefulWidget {
  const _KeepAliveWrapper({
    Key? key,
    this.keepAlive = true,
    required this.child,
  }) : super(key: key);
  final bool keepAlive;
  final Widget child;

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant _KeepAliveWrapper oldWidget) {
    if(oldWidget.keepAlive != widget.keepAlive) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

class ItemPageView extends StatefulWidget {
  final String widgetKey;
  const ItemPageView({super.key, required this.widgetKey});

  @override
  State<ItemPageView> createState() => _ItemPageViewState();
}

class _ItemPageViewState extends State<ItemPageView> {

  @override
  void initState() {
    super.initState();
    Log.i("_ItemPageViewState initState ${this.widget.widgetKey}");
  }

  @override
  void dispose() {
    super.dispose();
    Log.i("_ItemPageViewState dispose ${this.widget.widgetKey}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Stack(
        children: [
          Text("${this.widget.widgetKey}")
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Indicator extends StatelessWidget {

  Indicator({
    required this.controller,
    this.itemCount = 0,
  }) : assert(controller != null);

  /// PageView的控制器
  final PageController controller;

  /// 指示器的个数
  final int itemCount;

  /// 普通的颜色
  final Color normalColor = Colors.blue;

  /// 选中的颜色
  final Color selectedColor = Colors.red;

  /// 点的大小
  final double size = 8.0;

  /// 点的间距
  final double spacing = 4.0;

  /// 点的Widget
  Widget _buildIndicator(
      int index, int pageCount, double dotSize, double spacing) {
    // 是否是当前页面被选中
    bool isCurrentPageSelected = index == (controller.page != null ? controller.page!.round() % pageCount : 0);

    return new Container(
      height: size,
      width: size + (2 * spacing),
      child: new Center(
        child: new Material(
          color: isCurrentPageSelected ? selectedColor : normalColor,
          type: MaterialType.circle,
          child: new Container(
            width: dotSize,
            height: dotSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, (int index) {
        return _buildIndicator(index, itemCount, size, spacing);
      }),
    );
  }
}


class TestPageView extends StatefulWidget {
  const TestPageView({super.key});

  @override
  State<TestPageView> createState() => _TestPageViewState();
}

class _TestPageViewState extends State<TestPageView> {
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text("Flutter开发者页面"),
        ),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (int position) {
                setState(() {});
              },
              children: [
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "1")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "2")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "3")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "4")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "5")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "6")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "7")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "8")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "9")),
                _KeepAliveWrapper(child: ItemPageView(widgetKey: "10")),
              ],
            ),
            Indicator(controller: _pageController, itemCount: 10)
          ],
        ));
  }
}
