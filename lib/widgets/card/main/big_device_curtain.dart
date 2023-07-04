
import 'package:flutter/cupertino.dart';
import '../../mz_slider.dart';

class BigDeviceCurtainCardWidget extends StatefulWidget {
  final String name;
  final bool onOff;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final Function? onMoreTap; // 右边的三点图标的点击事件
  //----
  final int percent; // 开合百分比

  final void Function(num value)? onChanging; // 滑条滑动中
  final void Function(num value)? onChanged; // 滑条滑动结束

  final int? index; // 三个操作选项index=0|1|2，都不选传null
  final void Function(int value)? onTap; // 三个操作选项点击

  const BigDeviceCurtainCardWidget(
      {super.key,
        required this.name,
        required this.onOff,
        required this.roomName,
        this.onMoreTap,
        required this.online,
        required this.isFault,
        required this.isNative,
        this.onChanging,
        this.onChanged,
        required this.percent,
        this.index,
        this.onTap});

  @override
  _BigDeviceCurtainCardWidgetState createState() => _BigDeviceCurtainCardWidgetState();
}

class _BigDeviceCurtainCardWidgetState extends State<BigDeviceCurtainCardWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      height: 196,
      decoration: _getBoxDecoration(),
      child: Stack(
        children: [
          const Positioned(
            top: 14,
            left: 24,
            child: Image(
                width: 40,
                height: 40,
                image: AssetImage('assets/newUI/device/窗帘@1x.png')
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => widget.onMoreTap?.call(),
              child: const Image(
                  width: 32,
                  height: 32,
                  image: AssetImage('assets/newUI/to_plugin.png')
              ),
            ),
          ),

          Positioned(
              top: 10,
              left: 88,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: widget.isNative ? 100 : 140
                      ),
                      child: Text(widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 22,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)
                      ),
                    ),
                  ),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 90
                    ),
                    child: Text(widget.roomName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0XA3FFFFFF),
                            fontSize: 16,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 90
                    ),
                    child: Text(" | ${_getRightText()}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0XA3FFFFFF),
                            fontSize: 16,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)
                    ),
                  ),

                  if(widget.isNative) Container(
                    alignment: Alignment.center,
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
                    ),
                    margin: const EdgeInsets.fromLTRB(12, 0, 0, 6),
                    child: const Text("本地",
                      style: TextStyle(
                          height: 1.6,
                          color: Color(0XFFFFFFFF),
                          fontSize: 14,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  )
                ],
              ),
          ),

          Positioned(
            top: 44,
            left: 32,
            child: Text("${widget.percent == 0 ? '全关' : widget.percent == 100 ? '全开' : widget.percent}",
                style: const TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 60,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)
            ),
          ),
          if(widget.percent > 0 && widget.percent < 100) const Positioned(
            top: 66,
            left: 114,
            child: Text("%",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 18,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)
            ),
          ),

          Positioned(
            top: 74,
            left: 174,
            child: CupertinoSlidingSegmentedControl(
              backgroundColor: widget.onOff ? const Color(0xFF767D87) : const Color(0xFF4C525E),
              thumbColor: const Color(0xC1B7C4CF),
              padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
              children: {
                0: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                  child: const Text('全开',
                      style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
                1: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                  child: const Text('暂停',
                      style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
                2: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                  child: const Text('全关',
                      style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                )
              },
              groupValue: _getGroupIndex(),
              onValueChanged: (int? value) {
                widget.onTap?.call(value!);
              },
            ),
          ),

          Positioned(
            top: 140,
            left: 4,
            child: MzSlider(
              value: widget.percent,
              width: 390,
              height: 16,
              min: 0,
              max: 100,
              disabled: !widget.onOff,
              activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
              onChanging: (val, color) => {
                widget.onChanging?.call(val)
              },
              onChanged: (val, color) => {
                widget.onChanged?.call(val)
              },
            ),
          ),
        ],
      ),
    );
  }

  int? _getGroupIndex() {
    if(widget.index == null) return null;
    if(widget.index! < 0 || widget.index! > 2) return null;
    return widget.index;
  }

  String _getRightText() {
    if (widget.isFault) {
      return '故障';
    }
    if (!widget.online) {
      return '离线';
    }
    return '在线';
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.onOff && widget.online) {
      return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF818895),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
        ),
      );
    }
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x33616A76),
          Color(0x33434852),
        ],
      ),
      border: Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.32),
        width: 0.6,
      ),
    );
  }

}
