import 'package:flutter/material.dart';

import '../../common/adapter/select_room_data_adapter.dart';
import '../../common/logcat_helper.dart';
import '../../common/system.dart';
import '../../widgets/business/select_room.dart';
import '../../widgets/event_bus.dart';
import '../../widgets/mz_navigation_bar.dart';

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key});

  @override
  State<SelectRoomPage> createState() => SelectRoomPageState();
}

class SelectRoomPageState extends State<SelectRoomPage> {
  void goBack() {
    bus.emit('updateDeviceListState');
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(direction: Axis.vertical, children: <Widget>[
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
        child: Container(
          color: Colors.black,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: double.infinity,
                minHeight: MediaQuery.of(context).size.height - 60),
            child: SelectRoom(
              //value: Global.profile.roomInfo?.roomId ?? '',
              onChange: (SelectRoomItem room) {
                Log.i('SelectRoom: ${room.toJson()}');
                System.roomInfo = room;
                // Global.profile.roomInfo = room;
                // context.read<RoomModel>().roomInfo = room;
                // var deviceModel = context.read<DeviceListModel>();
                // deviceModel.deviceList = room.applianceList;
                // for (var deviceInfo in deviceModel.deviceList) {
                //   // 查看品类控制器看是否支持该品类
                //   var hasController = getController(deviceInfo) != null;
                //   if (hasController &&
                //       DeviceService.isOnline(deviceInfo) &&
                //       DeviceService.isSupport(deviceInfo)) {
                //     // 调用provider拿detail存入状态管理里
                //     context
                //         .read<DeviceListModel>()
                //         .updateDeviceDetail(deviceInfo);
                //   }
                // }
              },
            ),
          ),
        ),
      ),
    ]);
  }
}
