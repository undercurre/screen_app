import 'package:flutter/cupertino.dart';
import '../../../routes/plugins/0x21/0x21_485_cac/cac_data_adapter.dart';
import '../../mz_slider.dart';
import '../../util/nameFormatter.dart';

class Big485CACDeviceAirCardWidget extends StatefulWidget {
  final String name;
  bool onOff = false;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final Function? onMoreTap; // 右边的三点图标的点击事件
  //----
  int temperature = 26; // 温度值
  final int min; // 温度最小值
  final int max; // 温度最大值

  final void Function(num value)? onChanging; // 滑条滑动中
  final void Function(num value)? onChanged; // 滑条滑动结束/加减按钮点击

  final void Function(bool toOn)? onPowerTap; // 开关点击

  CACDataAdapter? adapter; // 数据适配器

  Big485CACDeviceAirCardWidget(
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
      required this.adapter,
      this.onPowerTap});

  @override
  _Big485CACDeviceAirCardWidgetState createState() =>
      _Big485CACDeviceAirCardWidgetState();
}

class _Big485CACDeviceAirCardWidgetState
    extends State<Big485CACDeviceAirCardWidget> {
  void updateData() {
    if (mounted) {
      setState(() {
        widget.temperature = int.parse(widget.adapter!.data!.targetTemp);
        widget.onOff = widget.adapter!.data!.OnOff == '1' ? true : false;
      });
    }
  }

  Future<void> updateDetail() async {
    widget.adapter?.fetchData();
  }

  @override
  void initState() {
    super.initState();
    widget.adapter!.init();
    widget.adapter!.bindDataUpdateFunction(updateData);
    updateDetail();
  }

  @override
  void didUpdateWidget(covariant Big485CACDeviceAirCardWidget oldWidget) {
    widget.adapter!.bindDataUpdateFunction(updateData);
    widget.adapter!.init();
    setState(() {
      widget.temperature = oldWidget.temperature;
      widget.onOff = oldWidget.onOff;
    });
  }

  @override
  void dispose() {
    widget.adapter!.unBindDataUpdateFunction(updateData);
    widget.adapter!.destroy();
    super.dispose();
  }

  void powerHandle(bool state) async {
    if (widget.onOff == true) {
      widget.adapter!.data!.OnOff = "0";
      widget.onOff = false;
      setState(() {});
      widget.adapter?.orderPower(0);
    } else {
      widget.adapter!.data!.OnOff = "1";
      widget.onOff = true;
      setState(() {});
      widget.adapter?.orderPower(1);
    }
  }

  Future<void> temperatureHandle(num value) async {
    if (!widget.onOff) {
      return;
    }
    widget.adapter?.orderTemp(value.toInt());
    widget.temperature = value.toInt();
    setState(() {});
    widget.adapter!.data!.targetTemp = value.toString();
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
              onTap: () => powerHandle(widget.onOff),
              child: Image(
                  width: 40,
                  height: 40,
                  image: AssetImage(widget.onOff
                      ? 'assets/newUI/card_power_on.png'
                      : 'assets/newUI/card_power_off.png')),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => {
                Navigator.pushNamed(context, '0x21_485CAC',
                    arguments: {"name": widget.name, "adapter": widget.adapter})
              },
              child: const Image(
                  width: 32,
                  height: 32,
                  image: AssetImage('assets/newUI/to_plugin.png')),
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
                    constraints:
                        BoxConstraints(maxWidth: widget.isNative ? 100 : 140),
                    child: Text(
                        NameFormatter.formatName(widget.name, 5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 22,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text( NameFormatter.formatName(widget.roomName, 4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0XA3FFFFFF),
                            fontSize: 16,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(" | ${_getRightText()}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0XA3FFFFFF),
                            fontSize: 16,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)),
                  ),
                ),
                if (widget.isNative)
                  Container(
                    alignment: Alignment.center,
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      border:
                          Border.all(color: const Color(0xFFFFFFFF), width: 1),
                    ),
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: const Text(
                      "本地",
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
                      temperatureHandle(widget.temperature > widget.min
                          ? widget.temperature - 1
                          : widget.min),
                    },
                    child: Image(
                        color: Color.fromRGBO(
                            255, 255, 255, widget.onOff ? 1 : 0.7),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/sub.png')),
                  ),
                  Text("${widget.temperature}",
                      style: TextStyle(
                          height: 1.5,
                          color: widget.onOff
                              ? const Color(0XFFFFFFFF)
                              : const Color(0XA3FFFFFF),
                          fontSize: 60,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                  GestureDetector(
                    onTap: () => {
                      temperatureHandle(widget.temperature < widget.max
                          ? widget.temperature + 1
                          : widget.max),
                    },
                    child: Image(
                        color: Color.fromRGBO(
                            255, 255, 255, widget.onOff ? 1 : 0.7),
                        width: 36,
                        height: 36,
                        image: const AssetImage('assets/newUI/add.png')),
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
              onChanging: (val, color) => {},
              onChanged: (val, color) => {temperatureHandle(val)},
            ),
          ),
        ],
      ),
    );
  }

  int _getTempVal() {
    return widget.temperature < widget.min
        ? widget.min
        : widget.temperature > widget.max
            ? widget.max
            : widget.temperature;
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
        color: const Color(0x00FFFFFF),
        width: 0,
      ),
    );
  }
}
