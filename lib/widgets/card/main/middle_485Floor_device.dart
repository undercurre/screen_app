import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/utils.dart';
import '../../../routes/plugins/0x21/0x21_485_floor/floor_data_adapter.dart';
import '../../../states/device_list_notifier.dart';
import '../../util/nameFormatter.dart';

class Middle485FloorDeviceCardWidget extends StatefulWidget {
  final String name;
  final String applianceCode;
  final String? modelNumber;
  final String? masterId;
  final Widget icon;
  final bool isFault;
  final String roomName;
  final String characteristic; // 特征值
  final Function? onTap; // 整卡点击事件
  final Function? onMoreTap; // 右边的三点图标的点击事件

  bool disable;
  AdapterGenerateFunction<FloorDataAdapter> adapterGenerateFunction;

  Middle485FloorDeviceCardWidget({
    super.key,
    required this.name,
    required this.applianceCode,
    required this.disable,
    required this.adapterGenerateFunction,
    required this.modelNumber,
    required this.masterId,
    required this.icon,
    required this.roomName,
    required this.characteristic,
    this.onTap,
    this.onMoreTap,
    required this.isFault,
  });

  @override
  _Middle485FloorDeviceCardWidgetState createState() =>
      _Middle485FloorDeviceCardWidgetState();
}

class _Middle485FloorDeviceCardWidgetState
    extends State<Middle485FloorDeviceCardWidget> {
  late FloorDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if (!widget.disable) {
      adapter.bindDataUpdateFunction(updateData);
    }
  }

  void updateData() {
    if (mounted) {
      setState(() {});
    }
  }

  void powerHandle(bool state) async {
    if (!adapter.data!.online) {
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

  Future<void> updateDetail() async {
    adapter.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: true);

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
      String nameInModel =
          deviceListModel.getDeviceRoomName(deviceId: adapter.applianceCode);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    String getRightText() {
      if (!deviceListModel.getOnlineStatus(deviceId: adapter.applianceCode)) {
        if (adapter.isLocalDevice && adapter.data!.online) {
          return "${adapter.data!.targetTemp}℃";
        }
        return '离线';
      } else {
        if (adapter.isLocalDevice && !adapter.data!.online) {
          return '离线';
        }
        return "${adapter.data!.targetTemp}℃";
      }
    }

    return GestureDetector(
      onTap: () => {powerHandle(adapter.data!.OnOff)},
      child: Container(
        width: 210,
        height: 196,
        decoration: _getBoxDecoration(),
        child: Stack(
          children: [
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
              top: 16,
              left: 24,
              child: widget.icon,
            ),
            Positioned(
              top: 90,
              left: 24,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 160),
                    child: Text(
                      NameFormatter.formatName(getDeviceName(), 5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  if (adapter.isLocalDevice)
                    Container(
                      alignment: Alignment.center,
                      width: 48,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24)),
                        border: Border.all(
                            color: const Color(0xFFFFFFFF), width: 1),
                      ),
                      margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
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
              top: 136,
              left: 24,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      NameFormatter.formatName(getRoomName(), 4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0XA3FFFFFF),
                        fontSize: 20,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      " | ${getRightText()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0XA3FFFFFF),
                        fontSize: 20,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
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
    return const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x33616A76),
          Color(0x33434852),
        ],
      ),
    );
  }
}
