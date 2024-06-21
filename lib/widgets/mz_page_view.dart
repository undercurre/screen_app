import 'package:flutter/material.dart';

import 'mz_circle_Indicator.dart';

class MzPageView extends StatefulWidget {

  // 页面控制器
  PageController pageController;

  NullableIndexedWidgetBuilder childBuilder;

  ValueChanged<int>? onPageChange;

  int childCount;

  Widget? bottomSlotCenterChild;

  double slotMarginBottom;


  MzPageView({super.key,
    PageController? pageController,
    this.slotMarginBottom = 30,
    this.bottomSlotCenterChild,
    required this.childBuilder,
    this.onPageChange,
    required this.childCount}) :
        pageController = pageController ?? PageController(initialPage: 0);

  @override
  State<StatefulWidget> createState() => _MzPageViewState();

}

class _MzPageViewState extends State<MzPageView> {
  late int pagePosition;

  @override
  void initState() {
    super.initState();
    pagePosition = widget.pageController.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: widget.pageController,
          itemBuilder: widget.childBuilder,
          onPageChanged: (index) {
            setState(() {pagePosition = index;});
            widget.onPageChange?.call(index);
          },
          itemCount: widget.childCount,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: MzCircleIndicator(pageCount: widget.childCount, selectPosition: pagePosition),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: widget.slotMarginBottom),
            child: widget.bottomSlotCenterChild,
          ),
        )
      ],
    );
  }

}
