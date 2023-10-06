import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../routes/plugins/0x21/0x21_485_air/air_data_adapter.dart';
import '../../../states/device_list_notifier.dart';
import '../../plugins/gear_485_card.dart';
import '../../util/nameFormatter.dart';

class Big485AirDeviceAirCardWidget extends StatefulWidget {
  final String name;
  bool onOff;
  bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  int windSpeed = 4; // 风速值
  final Function? onMoreTap; // 右边的三点图标的点击事件
  //----

  final void Function(num value)? onChanging; // 滑条滑动中
  final void Function(num value)? onChanged; // 滑条滑动结束/加减按钮点击

  final void Function(bool toOn)? onPowerTap; // 开关点击

  AirDataAdapter? adapter; // 数据适配器

  Big485AirDeviceAirCardWidget(
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
      required this.adapter,
      this.onPowerTap});

  @override
  _Big485AirDeviceAirCardWidgetState createState() =>
      _Big485AirDeviceAirCardWidgetState();
}

class _Big485AirDeviceAirCardWidgetState extends State<Big485AirDeviceAirCardWidget> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.adapter!.init();
    widget.adapter!.bindDataUpdateFunction(updateData);
  }

  @override
  void didUpdateWidget(covariant Big485AirDeviceAirCardWidget oldWidget) {
    oldWidget.adapter?.destroy();
    widget.adapter!.bindDataUpdateFunction(updateData);
    widget.adapter!.init();
    setState(() {
      widget.windSpeed=oldWidget.windSpeed;
      widget.onOff=oldWidget.onOff;
    });
  }


  void updateData() {
    if (mounted) {
      setState(() {
        widget.onOff =widget.adapter!.data!.OnOff == '1'?true:false;
        widget.windSpeed= int.parse(widget.adapter!.data!.windSpeed);
      });
    }
  }

  @override
  void dispose() {
    widget.adapter!.unBindDataUpdateFunction(updateData);
    widget.adapter!.destroy();
    super.dispose();
  }

  void powerHandle(bool state) async {
    if(!widget.online){
      return;
    }
    if (widget.onOff == true) {
      widget.adapter!.data!.OnOff = "0";
      widget.onOff=false;
      setState(() {});
      widget.adapter?.orderPower(0);
    } else {
      widget.adapter!.data!.OnOff = "1";
      widget.onOff=true;
      setState(() {});
      widget.adapter?.orderPower(1);
    }
  }

  Future<void> gearHandle(num value) async {
    if(!widget.onOff){
      return;
    }
    if(!widget.online){
      return;
    }
    if (value == 1) {
      value = 4;
    } else if (value == 3) {
      value = 1;
    }
    widget.adapter!.data!.windSpeed = value.toString();
    widget.windSpeed=value.toInt();
    setState(() {});
    widget.adapter?.orderSpeed(value.toInt());
  }

  Future<void> updateDetail() async {
    widget.adapter?.fetchData();
  }

  int setWinSpeed(int wind) {
    int speed = wind;
    if (speed == 1) {
      speed = 3;
    } else if (speed == 2) {
      speed = 2;
    } else if (speed == 4) {
      speed = 1;
    } else {
      speed = 3;
    }
    return speed;
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.adapter?.applianceCode,
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
          deviceId: widget.adapter?.applianceCode);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    String getRightText() {
      if (!deviceListModel.getOnlineStatus(deviceId: widget.adapter?.applianceCode)) {
        widget.online=false;
        return '离线';
      }else{
        widget.online=true;
        return '在线';
      }
    }

    String getPowerIcon(){
      if(widget.onOff&&widget.online){
        return "assets/newUI/card_power_on.png";
      }else if(!widget.online){
        return "assets/newUI/card_power_off.png";
      }else if(!widget.onOff){
        return "assets/newUI/card_power_off.png";
      }else{
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
              onTap: () => powerHandle(widget.onOff),
              child: Image(
                  width: 40,
                  height: 40,
                  image: AssetImage(getPowerIcon())),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => {
                if(widget.online){
                  Navigator.pushNamed(context, '0x21_485Air',
                      arguments: {"name": getDeviceName(), "adapter": widget.adapter})
                }
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
                        NameFormatter.formatName(getDeviceName(), 5),
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
                    child: Text( NameFormatter.formatName(getRoomName(), 4),
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
              width: 400,
              child: Container(
                margin: const EdgeInsets.only(bottom: 0),
                child: Gear485Card(
                  disabled: !widget.onOff||!widget.online,
                  value: setWinSpeed(widget.windSpeed),
                  maxGear: 3,
                  minGear: 1,
                  onChanged: gearHandle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
