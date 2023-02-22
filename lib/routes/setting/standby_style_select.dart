import 'package:flutter/material.dart';
import 'package:screen_app/routes/setting/screen_saver/index.dart';

import '../../common/setting.dart';

class SelectStandbyStylePage extends StatefulWidget {

  const SelectStandbyStylePage({super.key});

  @override
  State<StatefulWidget> createState() => SelectStandbyStylePageState();

}

class SelectStandbyStylePageState extends State<SelectStandbyStylePage> {

  var imageList = <String>[
    'assets/imgs/setting/dial1.png',
    'assets/imgs/setting/dial2.png',
    'assets/imgs/setting/dial3.png',
    'assets/imgs/setting/dial4.png',
    'assets/imgs/setting/dial5.png',
    'assets/imgs/setting/dial6.png',
    'assets/imgs/setting/dial7.png',
    'assets/imgs/setting/dial8.png',
    'assets/imgs/setting/dial9.png',
  ];

  /// 当前选中的位置
  int? currentSelectPosition;

  @override
  void initState() {
    super.initState();
    currentSelectPosition = Setting.instant().screenSaverId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("待机样式", style: TextStyle(
                    color: Colors.white,
                    fontSize: 24
                )),
                Ink(
                  decoration: const ShapeDecoration(
                    color: Color(0x20ffffff),
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(currentSelectPosition);
                      },
                      icon: const Icon(
                          Icons.close_sharp,
                          size: 30,
                          color: Color(0xff979797))
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                            child: Text("时钟", style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14
                            )),
                          )
                        ]
                      )
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                    sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 164,
                            crossAxisSpacing: 10
                        ),
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                              return generateClockStyleItem(0, index, currentSelectPosition, (position) {
                                setState(() {
                                  debugPrint("点击位置$position");
                                  /// 时钟
                                  Setting.instant().screenSaverId = position;
                                  currentSelectPosition = position;
                                });
                              });
                            },
                            childCount: 3
                        )),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                              child: Text("星空", style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14
                              ),),
                            )
                          ]
                      )
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                    sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 164,
                            crossAxisSpacing: 10
                        ),
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                              return generateClockStyleItem(3, index, currentSelectPosition, (position) {
                                setState(() {
                                  /// 星空
                                  Setting.instant().screenSaverId = position;
                                  currentSelectPosition = position;
                                });
                              });
                            },
                            childCount: 3
                        )),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                              child: Text("自然", style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14
                              ),),
                            )
                          ]
                      )
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                    sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 164,
                            crossAxisSpacing: 10
                        ),
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                              return generateClockStyleItem(6, index, currentSelectPosition, (position) {
                                setState(() {
                                  /// 自然
                                  Setting.instant().screenSaverId = position;
                                  currentSelectPosition = position;
                                });
                              });
                            },
                            childCount: 3
                        )),
                  ),
                ],
              ),
          )
        ],
      ),
    );
  }
  
  Widget generateClockStyleItem(int start, int offset,int? currentPosition, void Function(int) onChange) {
    return _StandbyStyleItem(
        imgPath: imageList[start + offset],
        position: start + offset,
        currentPosition: currentPosition,
        onChange: onChange,
    );
  }

}

class _StandbyStyleItem extends StatefulWidget {
  /// 展示的图片
  String imgPath;
  /// 当前选中的值
  int? currentPosition;
  /// 表示的值
  int position;
  /// 选中回调
  void Function(int)? onChange;

  _StandbyStyleItem({super.key, required this.imgPath, required this.position, this.currentPosition, this.onChange});

  @override
  State<StatefulWidget> createState() => _StandbyStyleItemState();

}

class _StandbyStyleItemState extends State<_StandbyStyleItem> {

  _StandbyStyleItemState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator
                  .of(context)
                  .push(MaterialPageRoute(builder: (context) => PreviewStandbyPage(widget.position) ))
                  .then((value) {
                    debugPrint('选中的位置是$value');
                    widget.onChange?.call(value);
                  });
            },
            child: Image.asset(widget.imgPath),
          ),
          Radio<int?>(
              activeColor: const Color(0XFF267AFF),
              value: widget.position,
              groupValue: widget.currentPosition,
              onChanged: (int? position) {
                if(position != null) {
                  widget.onChange?.call(position);
                }
              }
          )
        ],
      ),
    );
  }

}

/// 待机样式预览页
class PreviewStandbyPage extends StatefulWidget {

  int position;
  PreviewStandbyPage(this.position, {super.key});

  @override
  State<StatefulWidget> createState() => PreviewStandbyStylePageState();

}

class PreviewStandbyStylePageState extends State<PreviewStandbyPage> {
  late PageController _pageController;
  late int initPosition;

  @override
  void initState() {
    initPosition = widget.position;
    _pageController = PageController(initialPage: initPosition);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSavers = ScreenSaver.getAll();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              return screenSavers[index];
            },
            onPageChanged: (index) {
              setState(() {
                initPosition = index;
              });
            },
            itemCount: screenSavers.length,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CircleIndicator(pageCount: 9, selectPosition: initPosition),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        width: 104,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                            color: const Color(0xff565656).withOpacity(0.6),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25)))
                        ),
                        child: const Text("取消", style: TextStyle(
                            color: Colors.white,
                            fontSize: 22
                        )
                        ))
                )),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop(initPosition);
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                  alignment: Alignment.bottomRight,
                child: Container(
                  width: 104,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: const Color(0xff565656).withOpacity(0.6),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25)))
                  ),
                  child: const Text("设定", style: TextStyle(
                      color: Colors.white,
                      fontSize: 22
                  )
                ))
            )),
          )
        ],
      ),
    );
  }

}

/// 圆形指示器
@immutable
class CircleIndicator extends StatelessWidget {

  double circleWidth = 4;
  double circleHeight = 4;
  double spacing = 4.0;
  int pageCount;
  int selectPosition = 0;

  CircleIndicator({super.key, required this.pageCount , required this.selectPosition});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildIndicator(pageCount),
    );
  }

  List<Widget> _buildIndicator(int count) {
    return List<Widget>.generate(count, (index) {
      return Padding(
        padding: EdgeInsets.all(spacing),
        child: Container(
          width: circleWidth,
          height: circleHeight,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(circleWidth / 2)),
              color: index == selectPosition ? Colors.white : Colors.white30
          ),
        ),
      );
    });
  }

}