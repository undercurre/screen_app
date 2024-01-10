import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/meiju/models/meiju_device_entity.dart';

import '../../common/gateway_platform.dart';
import '../../common/homlux/api/homlux_device_api.dart';
import '../../common/homlux/api/homlux_scene_api.dart';
import '../../common/homlux/models/homlux_device_entity.dart';
import '../../common/homlux/models/homlux_response_entity.dart';
import '../../common/homlux/models/homlux_scene_entity.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/api/meiju_device_api.dart';
import '../../common/meiju/api/meiju_scene_api.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/meiju/models/meiju_response_entity.dart';
import '../../common/meiju/models/meiju_scene_list_entity.dart';
import '../../common/system.dart';
import '../../models/device_entity.dart';
import '../../routes/home/device/card_type_config.dart';
import '../../routes/home/device/layout_data.dart';
import '../../states/device_list_notifier.dart';
import '../../states/layout_notifier.dart';
import '../../states/scene_list_notifier.dart';
import '../../widgets/util/deviceEntityTypeInP4Handle.dart';

Future<bool> auto2Layout(BuildContext context) async {
  try {
    final layoutModel = context.read<LayoutModel>();
    // 取出现有布局
    List<String> currDeviceIds = layoutModel.layouts
        .where((element) =>
            element.type != DeviceEntityTypeInP4.Scene &&
            element.type != DeviceEntityTypeInP4.Default &&
            element.type != DeviceEntityTypeInP4.DeviceNull &&
            element.type != DeviceEntityTypeInP4.DeviceEdit &&
            element.type != DeviceEntityTypeInP4.Clock &&
            element.type != DeviceEntityTypeInP4.Weather)
        .map((e) => e.deviceId)
        .toList();
    List<String> currSceneIds =
        layoutModel.layouts.where((element) => element.type == DeviceEntityTypeInP4.Scene).map((e) => e.deviceId).toList();
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      // 请求设备数据，找到需要新增布局的设备部分
      var res = await HomluxDeviceApi.queryDeviceListByRoomId(System.roomInfo!.id!);
      if (res.data != null) {
        var deviceHomluxApiRes = res.data!;
        // 过滤掉已经存在布局中的设备
        var deviceHomluxNeeds = deviceHomluxApiRes.where((e) => !currDeviceIds.contains(e.deviceId)).toList();
      }
      // 请求场景数据，找到需要新增布局的场景部分
      HomluxResponseEntity<List<HomluxSceneEntity>> HomluxRes = await HomluxSceneApi.getSceneList();
      if (HomluxRes.isSuccess) {
        var sceneHomluxApiRes = HomluxRes.result!;
        // 过滤掉已经存在布局中的场景
        var sceneHomluxNeeds = sceneHomluxApiRes.where((e) => !currSceneIds.contains(e.sceneId)).toList();
      }
    } else {
      List<dynamic> deviceMeijuApiRes =
          await MeiJuDeviceApi.queryDeviceListByRoomId(MeiJuGlobal.token!.uid, System.familyInfo!.familyId, System.roomInfo!.id!);
      MeiJuResponseEntity<Map<String, dynamic>> deviceMeijuGroupsApiRes = await MeiJuDeviceApi.getGroupList();
      // if (deviceMeijuApiRes.data! && deviceMeijuGroupsApiRes.isSuccess) {
      //   // 过滤掉已经存在布局中的设备
      //   var deviceMeijuNeeds = deviceMeijuApiRes.where((e) => !currDeviceIds.contains(e.deviceId)).toList();
      // }
      MeiJuResponseEntity<MeiJuSceneListEntity> MeijuRes = await MeiJuSceneApi.getSceneList(System.familyInfo!.familyId, MeiJuGlobal.token!.uid);
      if (MeijuRes.isSuccess) {
        var sceneMeijuApiRes = MeijuRes.data!;
      }
    }

    // 完成布局，抛出
    return true;
  } catch (e) {
    return false;
  }
}
