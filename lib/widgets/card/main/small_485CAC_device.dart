import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../routes/plugins/0x21/0x21_485_cac/cac_data_adapter.dart';
import '../../../states/device_list_notifier.dart';
import '../../util/nameFormatter.dart';

class Small485CACDeviceCardWidget extends StatefulWidget {
  final String name;
  final String applianceCode;
  final String? modelNumber;
  final String? masterId;
  final Widget icon;
  bool onOff;
  bool online;
  bool localOnline = false;
  final bool isFault;
  bool isNative;
  final String roomName;
  final String characteristic; // 特征值
  final Function? onTap; // 整卡点击事件
  final Function? onMoreTap; // 右边的三点图标的点击事件
  CACDataAdapter? adapter; // 数据适配器
  String temperature = "26"; // 温度值

  Small485CACDeviceCardWidget({
    super.key,
    required this.name,
    required this.applianceCode,
    required this.modelNumber,
    required this.masterId,
    required this.icon,
    required this.onOff,
    required this.roomName,
    required this.characteristic,
    this.onTap,
    this.onMoreTap,
    required this.online,
    required this.isFault,
    required this.isNative,
    required this.adapter,
  });

  @override
  _Small485CACDeviceCardWidget createState() => _Small485CACDeviceCardWidget();
}

class _Small485CACDeviceCardWidget extends State<Small485CACDeviceCardWidget> {
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
  void dispose() {
    super.dispose();
    widget.adapter?.unBindDataUpdateFunction(updateData);
    widget.adapter?.destroy();
  }

  @override
  void didUpdateWidget(covariant Small485CACDeviceCardWidget oldWidget) {
    oldWidget.adapter?.destroy();
    widget.adapter!.bindDataUpdateFunction(updateData);
    widget.adapter!.init();
    setState(() {
      widget.temperature = oldWidget.temperature;
      widget.onOff = oldWidget.onOff;
      widget.online = oldWidget.online;
      widget.isNative = oldWidget.isNative;
      widget.localOnline = oldWidget.localOnline;
    });
  }

  void updateData() {
    if (mounted) {
      setState(() {
        if (int.parse(widget.adapter!.data!.targetTemp) < 35) {
          widget.temperature = widget.adapter!.data!.targetTemp;
          widget.onOff = widget.adapter!.data!.OnOff == '1' ? true : false;
          widget.localOnline=widget.adapter!.data!.online;
          widget.isNative= widget.adapter!.isLocalDevice;
          if(widget.localOnline){
            widget.online = true;
          }else{
            widget.online = false;
          }
        }
      });
    }
  }

  void powerHandle(bool state) async {
    if (!widget.online) {
      TipsUtils.toast(content: '设备已离线,请检查设备');
      return;
    }
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

  Future<void> updateDetail() async {
    widget.adapter?.fetchData();
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
      if (!deviceListModel.getOnlineStatus(
          deviceId: widget.adapter?.applianceCode)) {
        if (widget.localOnline) {
          widget.online = true;
        } else {
          widget.online = false;
        }
        widget.localOnline = false;
        // Future.delayed(const Duration(seconds: 3), () {
        //   widget.adapter?.fetchData();
        // });
        if (widget.online) {
          return "${widget.temperature}℃";
        } else {
          return '离线';
        }
      } else {
        if (widget.localOnline) {
          widget.online = true;
        } else {
          widget.online = false;
        }
        widget.localOnline = true;
        // Future.delayed(const Duration(seconds: 3), () {
        //   widget.adapter?.fetchData();
        // });
        if (widget.online) {
          return "${widget.temperature}℃";
        } else {
          return '离线';
        }
      }
    }

    return GestureDetector(
      onTap: () => {powerHandle(widget.onOff)},
      child: Container(
        width: 210,
        height: 88,
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        decoration: _getBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              child: widget.icon,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      maxLines: 1,
                      NameFormatter.formatName(getDeviceName(), 5),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (widget.isNative)
                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      width: 36,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.32),
                          width: 0.6,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '本地',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.64),
                          ),
                        ),
                      ),
                    )
                ]),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    maxLines: 1,
                    '${NameFormatter.formatName(getRoomName(), 4)} | ${getRightText()}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.64),
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
            GestureDetector(
              onTap: () => {
                if (widget.online)
                  {
                    Navigator.pushNamed(context, '0x21_485CAC', arguments: {
                      "name": getDeviceName(),
                      "adapter": widget.adapter
                    })
                  }
                else
                  {TipsUtils.toast(content: '设备已离线,请检查设备')}
              },
              child: const Image(
                width: 24,
                image: AssetImage('assets/newUI/to_plugin.png'),
              ),
            )
          ],
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.isFault) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x77AE4C5E),
            Color.fromRGBO(167, 78, 97, 0.32),
          ],
          stops: [0, 1],
          transform: GradientRotation(222 * (3.1415926 / 360.0)),
        ),
      );
    }
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
    if (!widget.online) {
      BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF767B86),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
          stops: [0, 0.24, 1],
          transform: GradientRotation(194 * (3.1415926 / 360.0)),
        ),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x33616A76),
          Color(0x33434852),
        ],
        stops: [0.06, 1.0],
        transform: GradientRotation(213 * (3.1415926 / 360.0)),
      ),
    );
  }
}
