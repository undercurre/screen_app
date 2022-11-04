import 'package:flutter/material.dart';

import '../../widgets/AdvancedVerticalSeekBar.dart';

class DropDownDialog extends Dialog {
  final double width; // 宽度
  final double height; // 高度

  const DropDownDialog({
    super.key,
    this.width = 480,
    this.height = 480,
  });

  @override
  Widget build(BuildContext context) {
    late double po;

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
                                child: Image.asset(
                                  "assets/imgs/dropDown/music-default.png",
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 290,
                                height: 140,
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
                                      Image.asset(
                                        "assets/imgs/dropDown/left-icon.png",
                                        width: 82,
                                        height: 51,
                                      ),
                                      Image.asset(
                                        "assets/imgs/dropDown/start-icon.png",
                                        width: 42,
                                        height: 31,
                                      ),
                                      Image.asset(
                                        "assets/imgs/dropDown/right-icon.png",
                                        width: 82,
                                        height: 51,
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
