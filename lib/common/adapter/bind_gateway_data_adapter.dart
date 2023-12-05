import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/select_family_data_adapter.dart';
import 'package:screen_app/common/adapter/select_room_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/api/homlux_user_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/api/meiju_user_api.dart';

import '../../channel/index.dart';
import '../../models/device_entity.dart';
import '../helper.dart';
import '../homlux/models/homlux_family_entity.dart';
import '../homlux/models/homlux_room_list_entity.dart';
import '../logcat_helper.dart';
import '../meiju/meiju_global.dart';
import '../meiju/models/meiju_login_home_entity.dart';
import '../meiju/models/meiju_room_entity.dart';

/// 绑定网关适配层
class BindGatewayAdapter extends MideaDataAdapter {
  BindGatewayAdapter(super.platform);

  /// 是否已经绑定网关
  void checkGatewayBindState(SelectFamilyItem selectFamily,
      void Function(bool, DeviceEntity?) result, void Function() error) async {
    if (platform == GatewayPlatform.MEIJU) {
      MeiJuLoginHomeEntity familyEntity = selectFamily.meijuData;
      _meijuCheck(familyEntity.homegroupId).then((value) {
        Log.i('是否绑定${value.value1} 设备ID${value.value2}');
        if(value.value1) {
          Log.file('检查设备已经绑定, 设备ID为${MeiJuGlobal.gatewayApplianceCode}');
        }
        result.call(value.value1, value.value2);
      }, onError: (_) {
        error.call();
      });
    } else if (platform == GatewayPlatform.HOMLUX) {
      HomluxFamilyEntity familyEntity = selectFamily.homluxData as HomluxFamilyEntity;
      _homluxCheck(familyEntity.houseId).then((value) {
        Log.i('是否绑定${value.value1} 设备ID${value.value2}');
        if(value.value1) {
          Log.file('检查设备已经绑定, 设备ID为${HomluxGlobal.gatewayApplianceCode}');
        }
        result.call(value.value1, value.value2);
      }, onError: (error) {
        Log.i('查询绑定失败');
        error.call();
      });
    }
  }

  /// 修改网关到指定房间
  /// 此方法只能登录页调用，包含登录页的业务逻辑，其它地方不要随意调用
  Future<bool> modifyDevice(SelectFamilyItem selectFamily, SelectRoomItem selectRoom, DeviceEntity device) async {
    /// 此等情况无需修改房间
    if (selectRoom.id == device.roomId) {
      if(MideaRuntimePlatform.platform.inMeiju()) {
        MeiJuGlobal.gatewayApplianceCode = device.applianceCode;
        Log.i('保存网关，设备ID为${MeiJuGlobal.gatewayApplianceCode}');
        Log.i('迁移的房间id，与设备的所在的房间id一致.${selectRoom.id} 无需迁移，直接返回');
      } else {
        HomluxGlobal.gatewayApplianceCode = device.applianceCode;
        Log.i('保存网关，设备ID为${HomluxGlobal.gatewayApplianceCode}');
        Log.i('迁移的房间id，与设备的所在的房间id一致.${selectRoom.id} 无需迁移，直接返回');
      }
      return true;
    }
    if(platform == GatewayPlatform.HOMLUX) {
      var deviceType = '1';
      var type = '1';
      var houseId = selectFamily.familyId;
      var roomId = selectRoom.id;
      var deviceId = device.applianceCode;
      var httpResult = await HomluxUserApi.modifyDevice(deviceType, type, houseId, roomId!, deviceId);
      if(httpResult.isSuccess) {
        HomluxGlobal.gatewayApplianceCode = device.applianceCode;
        Log.i('保存网关，设备ID为${HomluxGlobal.gatewayApplianceCode}');
      }
      return httpResult.isSuccess;
    } else if(platform == GatewayPlatform.MEIJU) {
      var homeGroupId = selectFamily.familyId;
      var roomId = selectRoom.id;
      var applianceCode = device.applianceCode;
      var httpResult = await MeiJuUserApi.modifyDeviceRoom(homeGroupId!, roomId!, applianceCode);
      if(httpResult.isSuccess) {
        MeiJuGlobal.gatewayApplianceCode = device.applianceCode;
        Log.i('保存网关，设备ID为${MeiJuGlobal.gatewayApplianceCode}');
      }
      return httpResult.isSuccess;
    } else {
      Log.e('异常执行程序 modifyDevice');
      return false;
    }
  }

  /// 执行绑定网关
  Future<bool> bindGateway(
      SelectFamilyItem selectFamily, SelectRoomItem selectRoom) async {
    if (platform == GatewayPlatform.MEIJU) {
      MeiJuLoginHomeEntity familyEntity = selectFamily.meijuData;
      MeiJuRoomEntity roomEntity = selectRoom.meijuData as MeiJuRoomEntity;
      String? sn = await aboutSystemChannel.getGatewaySn(true, MeiJuGlobal.token?.seed ?? '');
      Log.i('绑定网关获取的SN = $sn');
      var res = await MeiJuUserApi.bindHome(
          sn: sn ?? '',
          homegroupId: familyEntity.homegroupId,
          roomId: roomEntity.roomId,
          applianceType: '0x16',
          modelNumber: 'MSGWZ010');
      if(res.isSuccess) {
        MeiJuGlobal.gatewayApplianceCode = res.data['applianceCode'];
        Log.file('绑定网关成功, 设备ID为${MeiJuGlobal.gatewayApplianceCode}');
      }
      return res.isSuccess;
    } else if (platform == GatewayPlatform.HOMLUX) {
      HomluxFamilyEntity familyEntity =
          selectFamily.homluxData as HomluxFamilyEntity;
      HomluxRoomInfo roomEntity = selectRoom.homluxData as HomluxRoomInfo;
      var sn = await aboutSystemChannel.getGatewaySn();
      String deviceType = '1';
      String homeId = familyEntity.houseId;
      String roomId = roomEntity.roomId;
      var res = await HomluxUserApi.bindDevice('智慧屏', homeId, roomId, sn!, deviceType);
      if(res.isSuccess) {
        HomluxGlobal.gatewayApplianceCode = res.result?.deviceId;
        Log.file('绑定网关成功, 设备ID为${HomluxGlobal.gatewayApplianceCode}');
      }
      return res.isSuccess && res.result?.isBind == true;
    } else {
      var exception = Exception('No No No 错误平台');
      Log.file("错误平台", exception, StackTrace.current);
      throw exception;
    }
  }

  /// bool 是否绑定
  /// String? 网关云ID
  Future<Pair<bool, DeviceEntity?>> _meijuCheck(String homeId) async {
    String seed = MeiJuGlobal.token?.seed ?? '';
    var sn = await aboutSystemChannel.getGatewaySn(true, seed); //获取加密sn
    var res = await MeiJuUserApi.getHomeDetail(homegroupId: homeId);

    DeviceEntity? deviceObj;
    bool bind = res.data!.homeList![0].roomList!.any((element) =>
        element.applianceList?.any((e) {
          if(e.sn == sn) {
            deviceObj = DeviceEntity();
            deviceObj!.name = e.name;
            deviceObj!.applianceCode = e.applianceCode;
            deviceObj!.type = e.type;
            deviceObj!.modelNumber = e.modelNumber;
            deviceObj!.sn8 = e.sn8;
            deviceObj!.roomName = element.name;
            deviceObj!.roomId = element.roomId;
            deviceObj!.masterId = e.masterId;
            deviceObj!.onlineStatus = e.onlineStatus;
          }
          return e.sn == sn;
        }) ?? false);

    return Pair.of(bind, deviceObj);
  }

  /// bool 是否绑定
  /// String? 网关云ID
  Future<Pair<bool, DeviceEntity?>> _homluxCheck(String homeId) async {
    var sn = await aboutSystemChannel.getGatewaySn(); //获取不加密sn
    var res = await HomluxDeviceApi.queryDeviceListByHomeId(homeId, enableCache: false);

    DeviceEntity? deviceObj;
    bool bind = res.result?.any((e) {
          if(sn == e.sn) {
            deviceObj = DeviceEntity();
            deviceObj!.name = e.deviceName!;
            deviceObj!.applianceCode = e.deviceId!;
            deviceObj!.type = e.proType!;
            // deviceObj.modelNumber = getModelNumber(e);
            deviceObj!.roomName = e.roomName!;
            deviceObj!.roomId = e.roomId!;
            deviceObj!.masterId = e.gatewayId ?? '';
            deviceObj!.onlineStatus = e.onLineStatus.toString();
          }
          return sn == e.sn;
    }) ?? false;
    return Pair.of(bind, deviceObj);
  }
}
