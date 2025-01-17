import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/card/method.dart';

import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/utils.dart';
import '../../../routes/plugins/0x21/0x21_485_air/air_data_adapter.dart';
import '../../../states/device_list_notifier.dart';
import '../../util/nameFormatter.dart';

class Small485AirDeviceCardWidget extends StatefulWidget {
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
  final bool disable;
  final AdapterGenerateFunction<AirDataAdapter> adapterGenerateFunction;

  Small485AirDeviceCardWidget({
    super.key,
    required this.name,
    required this.applianceCode,
    required this.disable,
    required this.modelNumber,
    required this.masterId,
    required this.icon,
    required this.roomName,
    required this.characteristic,
    this.onTap,
    this.onMoreTap,
    required this.isFault,
    required this.adapterGenerateFunction,
  });

  @override
  _Small485AirDeviceCardWidget createState() => _Small485AirDeviceCardWidget();
  
}

class _Small485AirDeviceCardWidget extends State<Small485AirDeviceCardWidget> {
  late AirDataAdapter adapter;
  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if(!widget.disable) {
      adapter.bindDataUpdateFunction(updateData);
    }
  }

  @override
  void dispose() {
    super.dispose();
    adapter.unBindDataUpdateFunction(updateData);
  }

  void updateData() {
    if (mounted) {
      // if(widget.localOnline==widget.adapter!.data!.online&&adapter.data!.windSpeed == int.parse(widget.adapter!.data!.windSpeed)&& adapter.data!.OnOff == (widget.adapter!.data!.OnOff == '1' ? true : false)){
      //   return;
      // }
      setState(() {
      });
    }
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

  Future<void> updateDetail() async {
    adapter.fetchData();
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
        int windSpeed = 1;
        if (adapter.data!.windSpeed == 1) {
          windSpeed = 3;
        } else if (adapter.data!.windSpeed == 2) {
          windSpeed = 2;
        } else if (adapter.data!.windSpeed == 4) {
          windSpeed = 1;
        } else {
          windSpeed = 3;
        }
        return "$windSpeed档";
      } else {
        return "离线";
      }
    }

    return GestureDetector(
      onTap: () => {powerHandle(adapter.data!.OnOff)},
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        NameFormatter.formatName(getDeviceName(), 5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (adapter.isLocalDevice)
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
            ),
            GestureDetector(
              onTap: () => {
                if (adapter.data!.online)
                  {
                    Navigator.pushNamed(context, '0x21_485Air', arguments: {
                      "name": getDeviceName(),
                      "adapter": adapter
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
        gradient: getBigCardColorBg('fault'),
      );
    }
    if (adapter.data!.OnOff && adapter.data!.online) {
      return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: getBigCardColorBg('open'),
      );
    }
    if (!adapter.data!.online) {
      BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: getBigCardColorBg('open'),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: getBigCardColorBg('disabled'),
    );
  }
}
