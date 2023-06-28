
import 'package:flutter/cupertino.dart';
import '../../mz_slider.dart';

class BigDevicePanelCardWidget extends StatefulWidget {
  final String name;
  final bool onOff;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final Function? onMoreTap; // 右边的三点图标的点击事件
  //----
  final List<String> buttonsName; // 面板按键名称，最多4个
  final List<bool> buttonsOnOff; // 面板按键是否开启

  /// index:索引，value: 将要设置的值，name；该路的名称
  final void Function(num index, bool value, String name)? onButtonTap; // 面板按键点击

  const BigDevicePanelCardWidget(
      {super.key,
        required this.name,
        required this.onOff,
        required this.roomName,
        this.onMoreTap,
        required this.online,
        required this.isFault,
        required this.isNative,
        required this.buttonsName,
        required this.buttonsOnOff,
        this.onButtonTap});

  @override
  _BigDevicePanelCardWidgetState createState() => _BigDevicePanelCardWidgetState();
}

class _BigDevicePanelCardWidgetState extends State<BigDevicePanelCardWidget> {

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
          Positioned(
            top: 14,
            left: 24,
            child: Image(
                width: 40,
                height: 40,
                image: AssetImage(_getIconSrc())
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
            top: 68,
            left: 32,
            child: SizedBox(
              height: 120,
              width: 376,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if(widget.buttonsName.isNotEmpty) _panelItem(0),
                  if(widget.buttonsName.length >= 2) _panelItem(1),
                  if(widget.buttonsName.length >= 3) _panelItem(2),
                  if(widget.buttonsName.length >= 4) _panelItem(3),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _panelItem(int index) {
    return SizedBox(
      width: 84,
      height: 120,
      child: GestureDetector(
        onTap: () => widget.onButtonTap?.call(index, !_isPanelItemOn(index), widget.buttonsName[index]),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              height: 120,
              width: 84,
              image: _isPanelItemOn(index) ? const AssetImage("assets/newUI/panel_btn_on.png") : const AssetImage("assets/newUI/panel_btn_off.png"),
            ),
            Text(widget.buttonsName[index],
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Color(0XFFFFFFFF),
                  fontSize: 16,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            )
          ],
        ),
      ),
    );
  }

  String _getIconSrc() {
    if(widget.buttonsName.length == 1) return "assets/newUI/device/一路面板@1x.png";
    if(widget.buttonsName.length == 2) return "assets/newUI/device/二路面板@1x.png";
    if(widget.buttonsName.length == 3) return "assets/newUI/device/三路面板@1x.png";
    return "assets/newUI/device/四路面板@1x.png";
  }

  bool _isPanelItemOn(int index) {
    if(index < 0 || index > widget.buttonsOnOff.length - 1) {
      return false;
    } else {
      return widget.buttonsOnOff[index];
    }
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
