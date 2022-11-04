import 'package:flutter/material.dart';

import '../../widgets/AdvancedVerticalSeekBar.dart';

class _DevicePageState extends State<DropDownDialog> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    late double po;

    late final AnimationController _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: false);

    late final Animation<double> _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    _controller.stop();

    return GestureDetector(
      // 点击遮罩层隐藏弹框
      child: Material(
          type: MaterialType.transparency, // 配置透明度
          child: Center(
              child: GestureDetector(
                  // 点击遮罩层关闭弹框，并且点击非遮罩区域禁止关闭
                  onVerticalDragDown: (details) {
                    po = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (details) {
                    if (po - details.globalPosition.dy > 180) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                      width: 480,
                      height: 480,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(children: <Widget>[
                        Container(
                          margin: const EdgeInsets.fromLTRB(25, 24, 25, 0),
                          width: 432,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF1a1a1a),
                          ),
                          child: Row(
                            children: [
                              Container(
                                  margin: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                                  child: RotationTransition(
                                      turns: _animation,
                                      child: Image.asset(
                                        "assets/imgs/dropDown/music-default.png",
                                        width: 120,
                                        height: 120,
                                      ) /* Your widget here */
                                      )),
                              Container(
                                alignment: Alignment.center,
                                width: 290,
                                height: 150,
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text("暂无歌曲",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                    const Text("暂无歌手",
                                        style: TextStyle(
                                          color: Color(0XFF8e8e8e),
                                          fontSize: 16.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      IconButton(
                                        onPressed: () {
                                          _controller.repeat();
                                        },
                                        iconSize: 50.0,
                                        icon: Image.asset(
                                          "assets/imgs/dropDown/left-icon.png",
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _controller.stop();
                                        },
                                        iconSize: 50.0,
                                        icon: Image.asset(
                                          "assets/imgs/dropDown/start-icon.png",
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _controller.repeat();
                                        },
                                        iconSize: 50.0,
                                        icon: Image.asset(
                                          "assets/imgs/dropDown/right-icon.png",
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                      margin: const EdgeInsets.fromLTRB(25, 16, 0, 0),
                                      width: 130,
                                      height: 104,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xFF1a1a1a),
                                      ),
                                      child: Wrap(
                                        direction: Axis.horizontal,
                                        spacing: 5,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/imgs/dropDown/ai-icon.png",
                                            width: 60,
                                            height: 60,
                                          ),
                                          const Text("智能语音",
                                              style: TextStyle(
                                                color: Color(0XFF8e8e8e),
                                                fontSize: 18.0,
                                                fontFamily: "MideaType",
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              )),
                                        ],
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.pop(context),
                                    Navigator.pushNamed(
                                      context,
                                      'SettingPage',
                                    )
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(25, 16, 0, 0),
                                    width: 130,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFF1a1a1a),
                                    ),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      spacing: 5,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/imgs/dropDown/setting-icon.png",
                                          width: 60,
                                          height: 60,
                                        ),
                                        const Text("系统设置",
                                            style: TextStyle(
                                              color: Color(0XFF8e8e8e),
                                              fontSize: 18.0,
                                              fontFamily: "MideaType",
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: AdvancedVerticalSeekBar(
                                    height: 224.0,
                                    width: 130.0,
                                    onValueChanged: (newValue) => print(newValue),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/imgs/dropDown/sound-black.png",
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: AdvancedVerticalSeekBar(
                                    height: 224.0,
                                    width: 130.0,
                                    onValueChanged: (newValue) => print(newValue),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/imgs/dropDown/light-black.png",
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ]))))),
    );
  }
}

class DropDownDialog extends StatefulWidget {
  const DropDownDialog({Key? key}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class MFDropDownDialog {
  static _DevicePageState showDropDownDialog(BuildContext context) {
    var widget = const DropDownDialog();
    showDialog(context: context, builder: (context) => widget);
    return widget.createState();
  }
}
