import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/room_change_notifier.dart';

import '../../common/global.dart';
import '../../models/room_entity.dart';
import '../../states/device_change_notifier.dart';
import '../../widgets/business/select_room.dart';
import '../../widgets/mz_navigation_bar.dart';
import '../home/device/register_controller.dart';
import '../home/device/service.dart';

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key});

  @override
  State<SelectRoomPage> createState() => SelectRoomPageState();
}

class SelectRoomPageState extends State<SelectRoomPage> {

  void goBack() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Container(
            color: Colors.black,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                maxHeight: 60.0,
              ),
              child: MzNavigationBar(
                onLeftBtnTap: goBack,
                title: '选择房间',
                hasPower: false,
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: SelectRoom(
                  value: Global.profile.roomInfo?.roomId ?? '',
                  onChange: (RoomEntity room) {
                    debugPrint('SelectRoom: ${room.toJson()}');
                    Global.profile.roomInfo = room;
                    context.read<RoomModel>().roomInfo = room;
                    context.read<DeviceListModel>().deviceList = room.applianceList;
                    context.read<DeviceListModel>().deviceList.forEach((deviceInfo) {
                      // 查看品类控制器看是否支持该品类
                      var hasController = getController(deviceInfo) != null;
                      if (hasController &&
                          DeviceService.isOnline(deviceInfo) &&
                          DeviceService.isSupport(deviceInfo)) {
                        // 调用provider拿detail存入状态管理里
                        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
                      }
                    });
                  }
              )
          )
        ]
    );
  }
}
