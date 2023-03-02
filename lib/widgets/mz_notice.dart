/// @doc ~/docs/mz_notice.md
import 'package:flutter/material.dart';

class MzNotice {
  String title;
  Color? backgroundColor;
  ShapeBorder? shape;
  String btnText; // 操作按钮文字
  Widget icon; // 左边图标
  Widget? rightSlot;
  Function? onPressed;

  MzNotice(
      {required this.title,
      this.backgroundColor = const Color(0xff1b1b1b),
      this.shape,
      this.btnText = '查看',
      this.icon = const Image(
          image: AssetImage('assets/imgs/icon/focus.png'), width: 26),
      this.rightSlot,
      this.onPressed});

  Future<bool?> show(BuildContext context) {
    // 按钮样式
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18));

    // 按钮文字样式
    TextStyle textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontFamily: 'MideaType',
        fontWeight: FontWeight.w400);

    Widget leftSide =
        Padding(padding: const EdgeInsets.only(right: 18), child: icon);

    Widget rightSide = rightSlot ??
        TextButton(
          style: buttonStyle,
          child: Text(btnText, style: textStyle),
          onPressed: () {
            Navigator.of(context).pop();
            onPressed?.call();
          }, //关闭对话框
        );

    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: backgroundColor,
            insetPadding: const EdgeInsets.only(top: 26, right: 65, left: 65),
            shape: shape ??
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: Color(0XFF1D1D1D), strokeAlign: StrokeAlign.center)),
            alignment: Alignment.topCenter,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Row(
                  children: [
                    leftSide,
                    Expanded(
                        child: Text(
                      title,
                      style: textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                    rightSide
                  ],
                )),
          );
        });
  }
}
