/// @doc ~/docs/mz_dialog.md
import 'package:flutter/material.dart';

class MzDialog {
  String? title;
  double titleSize;
  String? desc;
  double descSize;
  int descMaxLines;
  Color? backgroundColor;
  EdgeInsetsGeometry? titlePadding;
  EdgeInsetsGeometry? contentPadding;
  double maxWidth;
  ShapeBorder? shape;
  List<String>? btns; // 底部操作按钮列表
  bool lastBtnOn; // 最后一个按钮激活
  Widget? contentSlot;
  Function? onPressed;

  MzDialog(
      {this.title,
      this.titleSize = 24,
      this.desc,
      this.descSize = 14,
      this.descMaxLines = 1,
      this.backgroundColor = const Color(0xff1b1b1b),
      this.titlePadding = const EdgeInsets.only(top: 30),
      this.contentPadding = const EdgeInsets.all(20),
      this.maxWidth = 480,
      this.shape =
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      this.btns,
      this.lastBtnOn = true,
      this.contentSlot,
      this.onPressed});

  Future<bool?> show(BuildContext context) {
    // 普通按钮样式
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 10));

    // 激活按钮样式
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 10));

    // 按钮文字样式
    TextStyle textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontFamily: 'MideaType',
        fontWeight: FontWeight.w400);

    // 标题及标题下描述
    Widget compositeTitle = SizedBox(
      width: maxWidth - titlePadding!.horizontal,
      child: Column(
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: titleSize,
                  fontFamily: 'MideaType',
                  fontWeight: FontWeight.w400,
                  height: 1.2),
            ),
          if (desc != null)
            Text(desc!,
                textAlign: TextAlign.center,
                maxLines: descMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: descSize,
                    fontFamily: 'MideaType',
                    fontWeight: FontWeight.w100,
                    height: 1.2))
        ],
      ),
    );

    // 内容区插槽，边距及宽度限制处理
    Widget? compositeContent = contentSlot != null
        ? SizedBox(
            width: maxWidth - contentPadding!.horizontal, child: contentSlot)
        : null;

    // 按钮列表
    List<Widget> btnList = [];
    if (btns != null) {
      for (int i = 0; i < btns!.length; i++) {
        bool isLast = btns!.length - 1 == i;
        btnList.add(Expanded(
            child: TextButton(
          style: isLast && lastBtnOn ? buttonStyleOn : buttonStyle,
          child: Text(btns![i], style: textStyle),
          onPressed: () {
            onPressed?.call(btns![i], i, context);

          }, //关闭对话框
        )));
        if (!isLast) {
          btnList.add(
              const VerticalDivider(width: 0.5, color: Colors.transparent));
        }
      }
    }

    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: compositeTitle,
            content: compositeContent,
            backgroundColor: backgroundColor,
            contentPadding: contentPadding,
            titlePadding: titlePadding,
            actionsPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(vertical: 20),
            shape: shape,
            actions: <Widget>[Row(children: btnList)],
          );
        });
  }
}
