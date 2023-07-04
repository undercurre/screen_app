import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';

import '../../../common/global.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/mz_buttion.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange() {
    setState(() {
      _currentIndex = _pageController.page!.round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF272F41), Color(0xFF080C14)],
            ),
          ),
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {
                                _currentIndex = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 25),
                              child: Text(
                                '设备',
                                style: TextStyle(
                                  fontFamily: 'PingFangSC-Regular',
                                  // 设置字体
                                  fontSize: _currentIndex == 0 ? 24 : 20,
                                  // 设置字体大小
                                  color: _currentIndex == 0
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.37),
                                  // 设置字体颜色
                                  letterSpacing: 0,
                                  // 设置字间距
                                  fontWeight: FontWeight.w400, // 设置字重
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {
                                _currentIndex = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 25),
                              child: Text(
                                '场景',
                                style: TextStyle(
                                  fontFamily: 'PingFangSC-Regular',
                                  // 设置字体
                                  fontSize: _currentIndex == 1 ? 24 : 20,
                                  // 设置字体大小
                                  color: _currentIndex == 1
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.37),
                                  // 设置字体颜色
                                  letterSpacing: 0,
                                  // 设置字间距
                                  fontWeight: FontWeight.w400, // 设置字重
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                2,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {
                                _currentIndex = 2;
                              });
                            },
                            child: Text(
                              '其他',
                              style: TextStyle(
                                fontFamily: 'PingFangSC-Regular',
                                // 设置字体
                                fontSize: _currentIndex == 2 ? 24 : 20,
                                // 设置字体大小
                                color: _currentIndex == 2
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.37),
                                // 设置字体颜色
                                letterSpacing: 0,
                                // 设置字间距
                                fontWeight: FontWeight.w400, // 设置字重
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {},
                    children: [
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 2,
                          crossAxisCount: 2, // 设置列数为4
                        ),
                        itemCount: 8, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: SmallDeviceCardWidget(
                                  name: '灯光1',
                                  icon: const Image(
                                    image: AssetImage(
                                        'assets/newUI/device/light.png'),
                                  ),
                                  onOff: true,
                                  roomName: '客厅',
                                  characteristic: '40%',
                                  onTap: () => {logger.i('点击卡片')},
                                  online: true,
                                  isFault: true,
                                  isNative: false,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF6B6D73),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 2,
                          crossAxisCount: 2, // 设置列数为4
                        ),
                        itemCount: 8, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: const SmallSceneCardWidget(
                                    name: '默认情景',
                                    icon: Image(
                                      image: AssetImage(
                                          'assets/newUI/scene/default.png'),
                                    ),
                                    onOff: true),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF6B6D73),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 2,
                          crossAxisCount: 2, // 设置列数为4
                        ),
                        itemCount: 8, // 网格项的总数
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  width: 210,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF616A76)
                                            .withOpacity(0.22),
                                        // 设置渐变色起始颜色
                                        const Color(0xFF434852)
                                            .withOpacity(0.22),
                                        // 设置渐变色结束颜色
                                      ],
                                      begin: const Alignment(0.6, 0),
                                      // 设置渐变色的起始位置
                                      end: const Alignment(1, 1),
                                      // 设置渐变色的结束位置
                                      stops: [0.06, 1.0],
                                      // 设置渐变色的起始和结束位置的停止点
                                      transform: const GradientRotation(
                                          213 * 3.1415927 / 180), // 设置渐变色的旋转角度
                                    ),
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 0.32), // 设置边框颜色和透明度
                                      width: 0.6, // 设置边框宽度
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(24), // 设置边框圆角
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '时间组件',
                                      style: TextStyle(
                                        fontFamily: 'PingFangSC-Regular',
                                        // 设置字体
                                        fontSize: 20,
                                        // 设置字体大小
                                        color: Colors.white,
                                        // 设置字体颜色
                                        letterSpacing: 0,
                                        // 设置字间距
                                        fontWeight: FontWeight.w400,
                                        // 设置字重
                                        height: 1.2, // 设置行高
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF6B6D73),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.05),
                width: MediaQuery.of(context).size.width,
                height: 72,
                child: Center(
                  child: MzButton(
                    width: 240,
                    height: 56,
                    borderRadius: 29,
                    backgroundColor: const Color(0xFF818C98),
                    borderColor: Colors.transparent,
                    borderWidth: 1,
                    text: '返回',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
