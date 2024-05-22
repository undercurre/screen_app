import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/utils.dart';
import '../../../routes/plugins/0x21/0x21_485_floor/floor_data_adapter.dart';
import '../../../states/device_list_notifier.dart';
import '../../mz_slider.dart';
import '../../util/nameFormatter.dart';

class Big485FloorDeviceAirCardWidget extends StatefulWidget {
  final String name;
  final bool isFault;
  final String roomName;
  final Function? onMoreTap; // 右边的三点图标的点击事件
  final String applianceCode;
  bool disable;
  AdapterGenerateFunction<FloorDataAdapter> adapterGenerateFunction;

  //----
  final int min; // 温度最小值
  final int max; // 温度最大值

  final void Function(num value)? onChanging; // 滑条滑动中
  final void Function(num value)? onChanged; // 滑条滑动结束/加减按钮点击

  final void Function(bool toOn)? onPowerTap; // 开关点击



  Big485FloorDeviceAirCardWidget(
      {super.key,
      required this.name,
      required this.disable,
      required this.applianceCode,
      required this.roomName,
      this.onMoreTap,
      required this.isFault,
      this.onChanging,
      this.onChanged,
      required this.min,
      required this.max,
      required this.adapterGenerateFunction,
      this.onPowerTap});

  @override
  _Big485FloorDeviceAirCardWidgetState createState() => _Big485FloorDeviceAirCardWidgetState();
}

class _Big485FloorDeviceAirCardWidgetState extends State<Big485FloorDeviceAirCardWidget> {
  
  late FloorDataAdapter adapter;
  
  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if(!widget.disable){
      adapter.bindDataUpdateFunction(update485BigFloorData);
    }
  }

  void update485BigFloorData() {
    if (mounted) {
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    adapter.unBindDataUpdateFunction(update485BigFloorData);
    super.dispose();
  }

  void powerHandle(bool state) async {
    if (!adapter.data!.online) {
      adapter.fetchData();
      TipsUtils.toast(content: '设备已离线,请检查设备');
      return;
    }
    if (adapter.data!.OnOff == true) {
      adapter.data!.OnOff = false;
      setState(() {});
      adapter.orderPower(0);
    } else {
      adapter.data!.OnOff = true;
      setState(() {});
      adapter.orderPower(1);
    }
  }

  Future<void> temperatureHandle(num value) async {
    if (!adapter.data!.OnOff) {
      return;
    }
    if (!adapter.data!.online) {
      return;
    }
    adapter.orderTemp(value.toInt());
    adapter.data!.targetTemp = value.toInt();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: true);

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: adapter.applianceCode,
          maxLength: 6,
          startLength: 3,
          endLength: 2);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return nameInModel;
    }

    String getRoomName() {
      String nameInModel = deviceListModel.getDeviceRoomName(
          deviceId: adapter.applianceCode);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    String getRightText() {
      if(adapter.data?.online == true) {
        return "在线";
      } else {
        return "离线";
      }
    }

    String getPowerIcon() {
      if (adapter.data!.OnOff && adapter.data!.online) {
        return "assets/newUI/card_power_on.png";
      } else if (!adapter.data!.online) {
        return "assets/newUI/card_power_off.png";
      } else if (!adapter.data!.OnOff) {
        return "assets/newUI/card_power_off.png";
      } else {
        return "assets/newUI/card_power_on.png";
      }
    }

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
              onTap: () => powerHandle(adapter.data!.OnOff),
              child: Image(
                  width: 40, height: 40, image: AssetImage(getPowerIcon())),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => {
                if (adapter.data!.online)
                  {
                    Navigator.pushNamed(context, '0x21_485Floor', arguments: {
                      "name": getDeviceName(),
                      "adapter": adapter
                    })
                  }
                else
                  {TipsUtils.toast(content: '设备已离线,请检查设备')}
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
                        BoxConstraints(maxWidth: 140),
                    child: Text(NameFormatter.formatName(getDeviceName(), 5),
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
                    child: Text(NameFormatter.formatName(getRoomName(), 4),
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
                    child: Text(" | ${getRightText()}",
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
                if (adapter.isLocalDevice)
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
                  // GestureDetector(
                  //   onTap: () => {
                  //     temperatureHandle(adapter!.data!.targetTemp > widget.min
                  //         ? adapter!.data!.targetTemp - 1
                  //         : widget.min),
                  //   },
                  //   child: Image(
                  //       color: Color.fromRGBO(
                  //           255, 255, 255, adapter!.data!.OnOff ? 1 : 0.7),
                  //       width: 36,
                  //       height: 36,
                  //       image: const AssetImage('assets/newUI/sub.png')),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${adapter.data!.targetTemp>90?26:adapter.data!.targetTemp}",
                          style: TextStyle(
                              height: 1.5,
                              color: adapter.data!.OnOff&&adapter.data!.online
                                  ? const Color(0XFFFFFFFF)
                                  : const Color(0XA3FFFFFF),
                              fontSize: 60,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                      Padding( padding: const EdgeInsets.fromLTRB(0, 0, 0, 37),
                        child:Text("℃",
                            style: TextStyle(
                                height: 1.5,
                                color: adapter.data!.OnOff&&adapter.data!.online
                                    ? const Color(0XFFFFFFFF)
                                    : const Color(0XA3FFFFFF),
                                fontSize: 18,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),

                      ),
                    ],
                  ),
                  // GestureDetector(
                  //   onTap: () => {
                  //     temperatureHandle(adapter!.data!.targetTemp < widget.max
                  //         ? adapter!.data!.targetTemp + 1
                  //         : widget.max),
                  //   },
                  //   child: Image(
                  //       color: Color.fromRGBO(
                  //           255, 255, 255, adapter!.data!.OnOff ? 1 : 0.7),
                  //       width: 36,
                  //       height: 36,
                  //       image: const AssetImage('assets/newUI/add.png')),
                  // ),
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
              disabled: !adapter.data!.OnOff || !adapter.data!.online,
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
    return adapter.data!.targetTemp < widget.min
        ? widget.min
        : adapter.data!.targetTemp > widget.max
            ? widget.max
            : adapter.data!.targetTemp;
  }

  BoxDecoration _getBoxDecoration() {
    if (adapter.data!.OnOff && adapter.data!.online) {
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
