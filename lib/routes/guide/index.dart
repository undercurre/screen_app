import 'package:flutter/material.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/widgets/mz_page_view.dart';

import '../../widgets/mz_buttion.dart';
import '../../widgets/mz_dash_line.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {

  late final List<Widget> _guides = <Widget>[
    const _FirstGuidePage(),
    const _SecondGuidePage()
  ];

  late var _pageIndex = 0;
  late PageController pageControl = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MzPageView(
        pageController: pageControl,
        childBuilder: (context, index) {
          return _guides[index];
        },
        childCount: _guides.length,
        onPageChange: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        bottomSlotCenterChild: MzButton(
          width: 168,
          height: 56,
          borderRadius: 29,
          backgroundColor: const Color(0xFF949CA8),
          borderColor: Colors.transparent,
          borderWidth: 1,
          text: _pageIndex == 0 ? '下一页' : '知道了',
          onPressed: () {
            if (_pageIndex + 1 >= _guides.length) {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'Home', ModalRoute.withName('/'));
            } else {
              pageControl.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn);
            }
          },
        ),
      ),
    );
  }
}

class _FirstGuidePage extends StatelessWidget {
  const _FirstGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return firstGuide();
  }

  Widget firstGuide() {
    return Stack(
      children: [
        Image.asset('assets/newUI/guide/guide_1.png'),
        const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("使用指引",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'MideaType-Regular')),
            )),
        // Container(
        //   margin: const EdgeInsets.only(left: 67),
        //   padding: const EdgeInsets.only(top: 50, bottom: 50),
        //   child: MzDashedLine(
        //     axis: Axis.vertical,
        //     dashedHeight: 6,
        //     count: 30,
        //     color: Colors.white,
        //   ),
        // ),
        Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 55, height: 50),
                      Container(
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        child: Text(
                          "1",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'MideaType-Regular'),
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xFF267AFF),
                            borderRadius:
                            BorderRadius.all(Radius.circular(30))),
                      ),
                      const SizedBox(width: 24),
                      const Text(
                        "添加智能设备",
                        style: TextStyle(
                            color: Color(0xFF4E92FF),
                            fontSize: 22,
                            fontFamily: 'MideaType-Regular'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 105, height: 50),
                      Container(
                        width: 320,
                        child: Text(
                            MideaRuntimePlatform.platform.inHomlux()
                                ? "使用美的照明HOMLUX小程序添加智能设备"
                                : "使用美的美居APP或者智慧屏添加智能设备",
                            softWrap: true,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'MideaType-Regular')),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 55, height: 50),
                      Container(
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            color: Color(0xFF267AFF),
                            borderRadius:
                            BorderRadius.all(Radius.circular(30))),
                        child: const Text(
                          "2",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'MideaType-Regular'),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Text(
                        "一键布局",
                        style: TextStyle(
                            color: Color(0xFF4E92FF),
                            fontSize: 22,
                            fontFamily: 'MideaType-Regular'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 105, height: 50),
                      Container(
                        width: 320,
                        child: const Text("快速将当前房间的场景、灯组、设备添加到桌面",
                            softWrap: true,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'MideaType-Regular')),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecondGuidePage extends StatefulWidget  {
  const _SecondGuidePage({super.key});

  @override
  State<_SecondGuidePage> createState() => _SecondGuidePageState();
}

class _SecondGuidePageState extends State<_SecondGuidePage> with SingleTickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3)
  );

  late final Animation<double> _positionAnimation = Tween<double>(begin: -30, end: 50)
      .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.ease
      ));

  late final Animation<double> _circleAnimation = Tween<double>(begin: 0, end: 80)
      .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease
  ));

  late final Animation<double> _opacityAnimation = Tween<double>(begin:0, end:1)
      .animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        _controller.forward(from: 0);
      }
    });
    _controller.forward().orCancel;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => secondGuide()
    );
  }

  Widget secondGuide() {
    return Stack(
      children: [
        Image.asset("assets/newUI/guide/guide_2.png"),
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            'assets/newUI/guide/guide_2_arrow.png',
            height: 90,
            width: 50,
          ),
        ),
        Positioned(
            left: 230,
            top: _circleAnimation.value,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                )
              ),
            )
        ),
        Positioned(
          left: 210,
          top: _positionAnimation.value,
          child: Image.asset(
            'assets/newUI/guide/guide_2_down.png',
            height: 142,
            width: 142,
          ),
        ),
        const Positioned(
          top: 200,
          left: 133,
          child: Text(
            '下拉后使用一键布局功能',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'MideaType-Regular'),
          ),
        )
      ],
    );
  }
}

