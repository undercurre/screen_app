import 'package:flutter/material.dart';

class MzNavigationBar extends StatefulWidget {
  final String title;
  final String? desc;
  final bool power;
  final bool hasPower;
  final bool isLoading;
  final bool hasBottomBorder;
  final Widget? rightSlot;
  final double sideBtnWidth;
  final void Function()? onRightBtnTap;
  final void Function()? onLeftBtnTap;
  final bool leftBtnVisible;

  const MzNavigationBar({
    super.key,
    this.title = '',
    this.desc,
    this.power = false,
    this.hasPower = false,
    this.isLoading = false,
    this.hasBottomBorder = false,
    this.leftBtnVisible = true,
    this.rightSlot,
    this.sideBtnWidth = 70,
    this.onRightBtnTap,
    this.onLeftBtnTap,
  });

  @override
  State<StatefulWidget> createState() => _MzNavigationBarState();
}

class _MzNavigationBarState extends State<MzNavigationBar> {
  @override
  Widget build(BuildContext context) {
    // 属性校验
    if (widget.rightSlot != null && (widget.hasPower)) {
      throw Error.safeToString('rightSlot与hasPower属性不应同时赋值');
    }

    // 电源按钮
    Widget? powerBtn = widget.hasPower
        ? Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(
              widget.power ? 'assets/imgs/plugins/common/power_on.png' : 'assets/imgs/plugins/common/power_off.png',
              alignment: Alignment.centerRight,
              width: 60,
              height: 60,
            ))
        : null;

    // 右侧按钮判断显示
    Widget? compositeRight = (widget.rightSlot != null) ? widget.rightSlot : powerBtn;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 65,
      decoration: BoxDecoration(
          border: Border(
              bottom: widget.hasBottomBorder ? const BorderSide(width: 1, style: BorderStyle.solid, color: Color(0xff979797), strokeAlign: StrokeAlign.center) :
              BorderSide.none)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左边按钮，返回
          Opacity(
              opacity: widget.leftBtnVisible ? 1.0 : 0.0,
              child: GestureDetector(
                  onTap: () {
                    if (widget.leftBtnVisible) {
                      widget.onLeftBtnTap?.call();
                    }
                  },
                  child: SizedBox(
                      width: widget.sideBtnWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Image.asset('assets/imgs/plugins/common/arrow_left.png',
                            alignment: Alignment.centerLeft, // 图标距离左端(40 / widget.sideBtnWidth - 1)*widget.sideBtnWidth/2 约20
                            width: 40,
                            height: 40),
                      )))),
          // 中间，标题、描述、Loading
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 28), // 占位，保证标题居中
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          height: 1.6,
                          fontSize: 24,
                          color: Colors.white,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      )),
                  SizedBox(
                    width: 28,
                    child: (widget.isLoading) ? Image.asset('assets/imgs/loading.gif', width: 28, height: 28) : null,
                  ),
                ],
              ),
              if (widget.desc != null)
                Text(
                  widget.desc!,
                  style: const TextStyle(
                    height: 1,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.w100,
                    decoration: TextDecoration.none,
                  ),
                )
            ],
          ),

          // 右边按钮，开关
          GestureDetector(onTap: () => widget.onRightBtnTap?.call(), child: SizedBox(width: widget.sideBtnWidth, child: compositeRight))
        ],
      ),
    );
  }
}
