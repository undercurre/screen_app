
import 'package:flutter/cupertino.dart';
import '../../mz_slider.dart';

class BigDeviceAirCardWidget extends StatefulWidget {
  final String name;
  final bool onOff;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final Function? onMoreTap; // 右边的三点图标的点击事件
  //----
  final int temperature; // 温度值
  final int min; // 温度最小值
  final int max; // 温度最大值

  final void Function(num value)? onChanging; // 滑条滑动中
  final void Function(num value)? onChanged; // 滑条滑动结束/加减按钮点击

  final void Function(bool toOn)? onPowerTap; // 开关点击

  const BigDeviceAirCardWidget(
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
        required this.temperature,
        required this.min,
        required this.max,
        this.onPowerTap});

  @override
  _BigDeviceAirCardWidgetState createState() => _BigDeviceAirCardWidgetState();
}

class _BigDeviceAirCardWidgetState extends State<BigDeviceAirCardWidget> {

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
            child: GestureDetector(
              onTap: () => widget.onPowerTap?.call(!widget.onOff),
              child: Image(
                  width: 40,
                  height: 40,
                  image: AssetImage(widget.onOff ? 'assets/newUI/card_power_on.png' : 'assets/newUI/card_power_off.png')
              ),
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
            top: 62,
            left: 20,
            child: SizedBox(
              height: 84,
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => {
                      widget.onChanged?.call(widget.temperature > widget.min ? widget.temperature - 1 : widget.min),
                    },
                    child: Image(
                        color: Color.fromRGBO(255, 255, 255, widget.onOff ? 1 : 0.7),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/sub.png')
                    ),
                  ),

                  Text("${widget.temperature}",
                      style: TextStyle(
                          height: 1.5,
                          color: widget.onOff ? const Color(0XFFFFFFFF) : const Color(0XA3FFFFFF),
                          fontSize: 60,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)
                  ),

                  GestureDetector(
                    onTap: () => {
                      widget.onChanged?.call(widget.temperature < widget.max ? widget.temperature + 1 : widget.max),
                    },
                    child: Image(
                        color: Color.fromRGBO(255, 255, 255, widget.onOff ? 1 : 0.7),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/add.png')
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 140,
            left: 4,
            child: MzSlider(
              value: _getTempVal(),
              width: 390,
              height: 16,
              min: widget.min,
              max: widget.max,
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

  int _getTempVal() {
    return widget.temperature < widget.min ? widget.min : widget.temperature > widget.max ? widget.max : widget.temperature;
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
