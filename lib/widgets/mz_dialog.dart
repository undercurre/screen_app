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
  bool closeAble;

  MzDialog(
      {this.title,
      this.titleSize = 24,
      this.desc,
      this.descSize = 14,
      this.descMaxLines = 1,
      this.backgroundColor = const Color(0xff494E59),
      this.titlePadding = const EdgeInsets.only(top: 30),
      this.contentPadding = const EdgeInsets.all(33),
      this.maxWidth = 480,
      this.shape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
      this.btns,
      this.lastBtnOn = true,
      this.contentSlot,
      this.onPressed,
      this.closeAble = false});

  Future<bool?> show(BuildContext context) {
    // 普通按钮样式
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color(0xFF858D9A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(29))),
        padding: const EdgeInsets.symmetric(vertical: 10));

    // 激活按钮样式
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color(0xFF267AFF),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(29))),
        padding: const EdgeInsets.symmetric(vertical: 10));

    // 按钮文字样式
    TextStyle textStyle = const TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.80), fontSize: 24, height: 1.65, fontFamily: 'MideaType', fontWeight: FontWeight.w400);

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
              style: TextStyle(fontSize: titleSize, fontFamily: 'MideaType', fontWeight: FontWeight.w400, height: 1.2),
            ),
          if (desc != null)
            Text(desc!,
                textAlign: TextAlign.center,
                maxLines: descMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: descSize, fontFamily: 'MideaType', fontWeight: FontWeight.w100, height: 1.2))
        ],
      ),
    );

    // 内容区插槽，边距及宽度限制处理
    Widget? compositeContent = contentSlot != null ? SizedBox(width: maxWidth - contentPadding!.horizontal, child: contentSlot) : null;

    // 按钮列表
    List<Widget> btnList = [];
    if (btns != null && btns!.isNotEmpty) {
      for (int i = 0; i < btns!.length; i++) {
        bool isLast = btns!.length - 1 == i;
        btnList.add(SizedBox(
            width: btns!.length > 1 ? 154 : 240,
            height: 56,
            child: TextButton(
              style: isLast && lastBtnOn ? buttonStyleOn : buttonStyle,
              child: Text(btns![i], style: textStyle),
              onPressed: () => onPressed?.call(btns![i], i, context), //关闭对话框
            )));
        if (!isLast) {
          btnList.add(const VerticalDivider(width: 0.5, color: Colors.transparent));
        }
      }
    }

    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return Stack(children: [
            AlertDialog(
              title: compositeTitle,
              content: compositeContent,
              backgroundColor: backgroundColor,
              contentPadding: contentPadding,
              titlePadding: titlePadding,
              actionsPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(vertical: 20),
              shape: shape,
              actions: <Widget>[
                if (btnList.isNotEmpty)
                  Container(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                      child: Row(
                          mainAxisAlignment: btnList.length > 1 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                          children: btnList))
              ],
            ),
            if (closeAble)
              Positioned(
                right: 50,
                top: 105,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/newUI/关闭@1x.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
          ]);
        });
  }
}
