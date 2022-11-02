/// @doc ~/docs/cell.md
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Cell extends StatefulWidget {
  final String? title; // 标题
  final Widget? titleSlot; // 标题插槽
  final Widget? rightSlot; // 右侧插槽
  final String? desc; // 描述
  final String? tag; // 标签、标注
  final Color? titleColor; // 标题颜色
  final double titleSize; // 标题大小
  final FontWeight fontWeight; // 标题粗细
  final int titleMaxLines; // 标题最大行数
  final Color bgColor; // 背景颜色
  final Widget? avatarIcon; // 左侧图标
  final Widget? rightIcon; // 右侧图标
  final String? rightText; // 显示右边文本
  final bool hasArrow; // 显示右箭头
  final bool hasSwitch; // 显示右边Switch
  final bool initSwitchValue; // Switch初始值
  final Color borderColor; // 边框颜色
  final bool hasTopBorder; // 显示上边框
  final bool hasBottomBorder; // 显示下边框
  final ValueChanged<bool>? onSwitch; // switch emit
  final Function? onTap; // tap emit
  final Function? onLongPress; // long press emit

  const Cell(
      {super.key,
      this.title = '',
      this.titleSlot,
      this.rightSlot,
      this.desc,
      this.tag,
      this.titleColor = Colors.white,
      this.titleSize = 20.0,
      this.fontWeight = FontWeight.normal,
      this.titleMaxLines = 2,
      this.bgColor = Colors.black,
      this.avatarIcon,
      this.rightIcon,
      this.rightText,
      this.hasArrow = false,
      this.hasSwitch = false,
      this.initSwitchValue = false,
      this.borderColor = const Color.fromRGBO(151, 151, 151, 0.2),
      this.hasTopBorder = false,
      this.hasBottomBorder = false,
      this.onSwitch,
      this.onTap,
      this.onLongPress});

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  late bool switchValue;

  @override
  void initState() {
    super.initState();
    switchValue = widget.initSwitchValue;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 属性校验
    if (widget.titleSlot != null &&
        (widget.title != '' || widget.desc != null || widget.tag != null)) {
      throw Error.safeToString('titleSlot与其他title属性不应同时赋值');
    }
    if (widget.titleSlot == null && widget.title == '') {
      throw Error.safeToString('titleSlot与title属性赋值必须有一个非空');
    }

    List<Widget> cellChildren = <Widget>[];
    List<Widget> middleCell = <Widget>[]; // 中间列
    List<Widget> compositeTitle = <Widget>[]; // 中间列-标题行，包括标题与Label

    // 插入标题
    if (widget.title != null) {
      compositeTitle.add(Text(
        widget.title!,
        maxLines: widget.titleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: widget.titleSize,
            fontFamily: "MideaType",
            fontWeight: widget.fontWeight,
            decoration: TextDecoration.none,
            color: widget.titleColor,
            height: 1.2),
      ));
    }

    // 插入tag
    if (widget.tag != null) {
      compositeTitle.add(Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(
            color: Color.fromRGBO(216, 216, 216, 0.3),
            borderRadius: BorderRadius.all(Radius.circular(11.0))),
        child: Text(
          widget.tag!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: "MideaType",
            fontWeight: FontWeight.w100,
            decoration: TextDecoration.none,
            color: Color.fromRGBO(255, 255, 255, 0.85),
            height: 1.5,
          ),
        ),
      ));
    }

    middleCell.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: compositeTitle,
    ));

    // 插入描述
    if (widget.desc != null) {
      middleCell.add(Text(
        widget.desc!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontSize: 13,
            fontFamily: "MideaType",
            fontWeight: FontWeight.w100,
            decoration: TextDecoration.none,
            color: Color.fromRGBO(255, 255, 255, 0.85),
            height: 1.5),
      ));
    }

    // 判断是否插入左边图标
    if (widget.avatarIcon != null) {
      cellChildren.add(Padding(
          padding: const EdgeInsets.only(right: 10),
          child: widget.avatarIcon!));
    }

    // 插入中间列，middleCell || titleSlot
    cellChildren.add(Expanded(
        child: widget.titleSlot == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: middleCell,
              )
            : widget.titleSlot!));

    if (widget.rightSlot != null) {
      cellChildren.add(widget.rightSlot!);
    }

    if (widget.rightText != null) {
      cellChildren.add(Text(
        widget.rightText!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontFamily: "MideaType",
          fontWeight: FontWeight.w100,
          decoration: TextDecoration.none,
          color: Color.fromRGBO(0, 145, 255, 1),
        ),
      ));
    }

    // 判断是否插入右边图标
    if (widget.rightIcon != null) {
      cellChildren.add(Padding(
          padding: const EdgeInsets.only(left: 10), child: widget.rightIcon!));
    }

    if (widget.hasSwitch) {
      cellChildren.add(Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
              value: switchValue,
              activeColor: Colors.blue,
              trackColor: const Color.fromRGBO(62, 62, 62, 1),
              thumbColor: Colors.white,
              onChanged: (bool value) {
                setState(() => switchValue = value);
                if (widget.onSwitch != null) {
                  widget.onSwitch!(value);
                }
              })));
    }

    // 判断是否插入右箭头，图标库箭头太粗，换一个
    if (widget.hasArrow) {
      cellChildren.add(Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset("assets/imgs/icon/arrow-right.png", width: 15.0)));
    }

    // 背景、边框设置
    BoxDecoration cellDecoration = BoxDecoration(
        color: widget.bgColor,
        border: Border(
            top: widget.hasTopBorder
                ? BorderSide(color: widget.borderColor)
                : BorderSide.none,
            bottom: widget.hasBottomBorder
                ? BorderSide(color: widget.borderColor)
                : BorderSide.none));

    return GestureDetector(
        child: DecoratedBox(
            position: DecorationPosition.background,
            decoration: cellDecoration,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: cellChildren,
              ),
            )),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress!();
          }
        });
  }
}
