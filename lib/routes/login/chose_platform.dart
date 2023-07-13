
import 'package:flutter/material.dart';

class ChosePlatform extends StatefulWidget {
  final void Function(int index)? onChose; //平台选择时，0=美居，1=homlux

  const ChosePlatform({super.key, this.onChose});

  @override
  State<ChosePlatform> createState() => _ChosePlatform();
}

class _ChosePlatform extends State<ChosePlatform> {

  bool isChose = false;
  int choseIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      width: 480,
      decoration: const BoxDecoration(
        color: Colors.black
      ),
      child: _getStepView(),
    );
  }

  Widget _getStepView() {
    if (!isChose) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 32),
            child: const Text("请选择登录平台",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 24,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.w500)
            ),
          ),

          GestureDetector(
            onTap: () => {
              setState(() {
                choseIndex = 0;
                isChose = true;
              })
            },
            child: Container(
              height: 138,
              width: 400,
              margin: const EdgeInsets.only(top: 43),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              decoration: BoxDecoration(
                  color: const Color(0x28FFFFFF),
                  borderRadius: BorderRadius.circular(32)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Image(
                    height: 90,
                    width: 90,
                    image: AssetImage("assets/newUI/login/meiju_logo.png"),
                  ),
                  Container(
                    width: 200,
                    margin: const EdgeInsets.only(left: 32),
                    child: const Text("美的美居",
                        style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)
                    ),
                  ),
                  const Image(
                    height: 24,
                    width: 24,
                    image: AssetImage("assets/newUI/箭头@2x.png"),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () => {
              setState(() {
                choseIndex = 1;
                isChose = true;
              })
            },
            child: Container(
              height: 138,
              width: 400,
              margin: const EdgeInsets.only(top: 43),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              decoration: BoxDecoration(
                  color: const Color(0x28FFFFFF),
                  borderRadius: BorderRadius.circular(32)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Image(
                    height: 90,
                    width: 90,
                    image: AssetImage("assets/newUI/login/homlux_logo.png"),
                  ),
                  Container(
                    width: 200,
                    margin: const EdgeInsets.only(left: 32),
                    child: const Text("美的照明",
                        style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)
                    ),
                  ),
                  const Image(
                    height: 24,
                    width: 24,
                    image: AssetImage("assets/newUI/箭头@2x.png"),
                  ),
                ],
              ),
            ),
          ),

        ],
      );
    } else {
      return Stack(
        children: [
          SizedBox(
            width: 480,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: Text(choseIndex == 0 ? "美的美居扫码指引" : "美的照明扫码指引",
                      style: const TextStyle(
                        height: 1,
                        color: Color(0XFFFFFFFF),
                        fontSize: 24,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.w500)
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: Text(choseIndex == 0 ? "第一步：下载并打开“美的美居”APP" : "第一步：微信搜索“美的照明Homlux”小程序",
                      style: const TextStyle(
                        height: 1,
                        color: Color(0XFFFFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.w400)
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: Image(
                    height: 72,
                    width: 296,
                    image: AssetImage(choseIndex == 0 ? "assets/newUI/login/meiju_guide_1.png" : "assets/newUI/login/homlux_guide_1.png"),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: const Text("第二步：进入首页后点击右上角“+”",
                      style: TextStyle(
                          height: 1,
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.w400)
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: Image(
                    height: 72,
                    width: 296,
                    image: AssetImage(choseIndex == 0 ? "assets/newUI/login/meiju_guide_2.png" : "assets/newUI/login/homlux_guide_2.png"),
                  ),
                ),

              ],
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 480,
              height: 72,
              color: const Color(0x19FFFFFF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => {
                      setState(() {
                        choseIndex = 0;
                        isChose = false;
                      })
                    },
                    child: Container(
                      height: 56,
                      width: 168,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                          color: const Color(0xFF939AA8),
                          borderRadius: BorderRadius.circular(29)
                      ),
                      child: const Text("上一步",
                          style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.w400)
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => {
                      setState(() {
                        widget.onChose?.call(choseIndex);
                      })
                    },
                    child: Container(
                      height: 56,
                      width: 168,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          color: const Color(0xFF267AFF),
                          borderRadius: BorderRadius.circular(29)
                      ),
                      child: const Text("我已了解",
                          style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.w400)
                      ),
                    ),
                  ),

                ],
              ),
            ),
          )
        ],
      );
    }
  }
  
}