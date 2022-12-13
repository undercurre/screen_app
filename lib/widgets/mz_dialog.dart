/// @doc ~/docs/mz_dialog.md
import 'package:flutter/material.dart';

class MzDialog {
  String title;
  double titleSize;
  String? des;
  Color? backgroundColor;
  EdgeInsetsGeometry? titlePadding;
  EdgeInsetsGeometry? contentPadding;
  ShapeBorder? shape;
  List<String>? btns;
  Widget? contentSlot;
  Function? onPressed;

  MzDialog(
      {required this.title,
      this.titleSize = 24,
      this.des,
      this.backgroundColor = const Color(0xff1b1b1b),
      this.titlePadding = const EdgeInsets.only(top: 20),
      this.contentPadding = const EdgeInsets.all(20),
      this.shape =
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      this.btns,
      this.contentSlot,
      this.onPressed});

  Future<bool?> show(BuildContext context) {
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 10));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 10));
    TextStyle textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontFamily: 'MideaType',
        fontWeight: FontWeight.w400);

    List<Widget> btnList = [];
    if (btns != null) {
      for (int i = 0; i < btns!.length; i++) {
        bool isLast = btns!.length - 1 == i;
        btnList.add(Expanded(
            child: TextButton(
          style: isLast ? buttonStyleOn : buttonStyle,
          child: Text(btns![i], style: textStyle),
          onPressed: () {
            onPressed?.call(btns![i], i);
            Navigator.of(context).pop(isLast);
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
            title: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontFamily: 'MideaType',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (des != null)
                  Text(des!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MideaType',
                          fontWeight: FontWeight.w100,
                          height: 1))
              ],
            ),
            content: contentSlot,
            backgroundColor: backgroundColor,
            contentPadding: contentPadding,
            titlePadding: titlePadding,
            actionsPadding: EdgeInsets.zero,
            shape: shape,
            actions: <Widget>[Row(children: btnList)],
          );
        });
  }
}
