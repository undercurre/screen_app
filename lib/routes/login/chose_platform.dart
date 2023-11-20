
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/widgets/gesture/mutil_click.dart';

import '../../common/gateway_platform.dart';
import '../../common/utils.dart';
import '../../widgets/mz_dialog.dart';

class ChosePlatform extends StatefulWidget {
  final void Function()? onFinished; //选择并了解确认
  final bool isChose; //是否已经选择平台

  const ChosePlatform({super.key, this.onFinished, required this.isChose});

  @override
  State<ChosePlatform> createState() => _ChosePlatform();
}

class _ChosePlatform extends State<ChosePlatform> {

  bool isChose = false;

  @override
  void initState() {
    super.initState();
    isChose = widget.isChose;
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
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () {
                    aboutSystemChannel.translateToProductionTestPage();
                  },
                  child: const Text(
                    "请选择登录平台",
                    style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.w500),
                  ))),
          _card("美的美居",
              "assets/newUI/login/meiju_logo.png",
              MideaRuntimePlatform.platform == GatewayPlatform.MEIJU, () {
                if (MideaRuntimePlatform.platform != GatewayPlatform.MEIJU) {
                  if (MideaRuntimePlatform.platform == GatewayPlatform.NONE) {
                    changeTo(0);
                  } else {
                    showClearUserDataDialog(context, 0);
                  }
                } else {
                  setState(() {
                    isChose = true;
                  });
                }
              }
          ),
          _card("美的照明",
              "assets/newUI/login/homlux_logo.png",
              MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX, () {
                if (MideaRuntimePlatform.platform != GatewayPlatform.HOMLUX) {
                  if (MideaRuntimePlatform.platform == GatewayPlatform.NONE) {
                    changeTo(1);
                  } else {
                    showClearUserDataDialog(context, 1);
                  }
                } else {
                  setState(() {
                    isChose = true;
                  });
                }
              }
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
                  child: Text(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU ? "美的美居扫码指引" : "美的照明扫码指引",
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
                  child: Text(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU
                      ? "第一步：下载并打开“美的美居”APP" : "第一步：微信搜索“美的照明Homlux”小程序",
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
                    image: AssetImage(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU
                        ? "assets/newUI/login/meiju_guide_1.png" : "assets/newUI/login/homlux_guide_1.png"),
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
                    image: AssetImage(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU
                        ? "assets/newUI/login/meiju_guide_2.png" : "assets/newUI/login/homlux_guide_2.png"),
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
                        widget.onFinished?.call();
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

  Widget _card(String name, String iconStr, bool isLogin, Function? onTap) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        height: 138,
        width: 400,
        margin: const EdgeInsets.only(top: 43),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        decoration: BoxDecoration(
            color: isLogin? const Color(0x510091FF) : const Color(0x28FFFFFF),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: isLogin ? const Color(0xFF0070C7) : Colors.transparent, width: 2)
        ),
        child: Row(
          children: [
            Image(
              height: 90,
              width: 90,
              image: AssetImage(iconStr),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 40),
                    child: Text(name,
                        style: const TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)
                    ),
                  ),
                  if (isLogin) const Text("已选择",
                      style: TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 20,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none)
                  ),
                  if (!isLogin) const Image(
                    height: 24,
                    width: 24,
                    image: AssetImage("assets/newUI/箭头@2x.png"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showClearUserDataDialog(BuildContext context, int index) async {
    MzDialog (
        title: '切换至${index == 0 ? "美的美居" : "美的照明"}平台',
        titleSize: 28,
        maxWidth: 432,
        contentSlot: const Text('此操作将会清除智慧屏上的所有\n数据',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(255, 255, 255, 0.60),
                fontFamily: 'MideaType',
                fontWeight: FontWeight.w400,
                height: 1.2)),
        btns: ['取消', '确定'],
        contentPadding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
        onPressed: (_, position, context) async {
          Navigator.pop(context);
          if (position == 1) {
            changeTo(index);
          }
        }
    ).show(context);
  }

  Future<void> changeTo(int index) async {
    bool isSuccess = false;
    if (index == 0) {
      isSuccess = await ChangePlatformHelper.changeToMeiju();
    } else if (index == 1) {
      isSuccess = await ChangePlatformHelper.changeToHomlux();
    }
    if (!isSuccess) {
      TipsUtils.toast(content: '切换失败，请再次尝试', position: EasyLoadingToastPosition.bottom);
      return;
    }
    setState(() {
      isChose = true;
    });
  }
  
}