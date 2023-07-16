import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/select_family_data_adapter.dart';
import 'package:screen_app/common/adapter/select_room_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/api/homlux_user_api.dart';
import 'package:screen_app/common/meiju/api/meiju_user_api.dart';

import '../../channel/index.dart';
import '../helper.dart';
import '../homlux/models/homlux_family_entity.dart';
import '../homlux/models/homlux_room_list_entity.dart';
import '../logcat_helper.dart';
import '../meiju/models/meiju_home_info_entity.dart';
import '../meiju/models/meiju_room_entity.dart';

/// 绑定网关适配层
class BindGatewayAdapter extends MideaDataAdapter {
  BindGatewayAdapter(super.platform);

  /// 是否已经绑定网关
  void checkGatewayBindState(SelectFamilyItem selectFamily,
      void Function(bool, String?) result, void Function() error) async {
    if (platform == GatewayPlatform.MEIJU) {

      MeiJuHomeInfoEntity familyEntity = selectFamily.meijuData as MeiJuHomeInfoEntity;
      if (familyEntity.homegroupId != null) {
        _meijuCheck(familyEntity.homegroupId!).then((value) {
            Log.i('是否绑定${value.value1} 设备ID${value.value2}');
            result.call(value.value1, value.value2);
          }, onError: (error) {
            error.call();
        });
      } else {
        error.call();
        Log.i('房间ID为空');
      }
    } else if (platform == GatewayPlatform.HOMLUX) {
      HomluxFamilyEntity familyEntity = selectFamily.homluxData as HomluxFamilyEntity;
      _homluxCheck(familyEntity.houseId).then((value) {
        Log.i('是否绑定${value.value1} 设备ID${value.value2}');
        result.call(value.value1, value.value2);
      }, onError: (error) {
        Log.i('查询绑定失败');
        error.call();
      });
    }
  }

  /// 执行绑定网关
  Future<bool> bindGateway(SelectFamilyItem selectFamily, SelectRoomItem selectRoom) async {
    if (platform == GatewayPlatform.MEIJU) {
      MeiJuHomeInfoEntity familyEntity = selectFamily.meijuData as MeiJuHomeInfoEntity;
      MeiJuRoomEntity roomEntity = selectRoom.meijuData as MeiJuRoomEntity;
      String seed = '';
      var sn = await aboutSystemChannel.getGatewaySn(true, seed);
      var res = await MeiJuUserApi.bindHome(
          sn: sn!,
          homegroupId: familyEntity.homegroupId,
          roomId: roomEntity.roomId,
          applianceType: '0x16',
          modelNumber: 'MSGWZ010');
      return res.isSuccess;
    } else if (platform == GatewayPlatform.HOMLUX) {
      HomluxFamilyEntity familyEntity = selectFamily.homluxData as HomluxFamilyEntity;
      HomluxRoomInfo roomEntity = selectRoom.homluxData as HomluxRoomInfo;
      var sn = await aboutSystemChannel.getGatewaySn();
      String deviceType = '1';
      String homeId = familyEntity.houseId;
      String roomId = roomEntity.roomId;
      var res = await HomluxUserApi.bindDevice('智慧屏', homeId, roomId, sn!, '1');
      return res.isSuccess && res.result?.isBind == true;
    } else {
      throw Exception('No No No 错误平台');
    }
  }

  /// bool 是否绑定
  /// String? 网关云ID
  Future<Pair<bool, String?>> _meijuCheck(String homeId) async {
    // Todo 传入当前的Seed密钥
    String seed = '';
    var sn = await aboutSystemChannel.getGatewaySn(true, seed);//获取加密sn
    var res = await MeiJuUserApi.getHomeDetail(homegroupId: homeId);

    /// 网关云ID
    String? applianceCode;
    bool bind = res.data!.homeList![0].roomList!.any((element) =>
        element.applianceList?.any((element) {
          applianceCode = element.applianceCode;
          return element.sn == sn;
        }) ?? false);

    return Pair.of(bind, applianceCode);
  }

  /// bool 是否绑定
  /// String? 网关云ID
  Future<Pair<bool, String?>> _homluxCheck(String homeId) async {
    var sn = await aboutSystemChannel.getGatewaySn();//获取不加密sn
    var res = await HomluxDeviceApi.queryDeviceListByHomeId(homeId);
    String? deviceId;
    bool bind = res.result?.any((element) {
      deviceId = element.deviceId;
      return sn == element.sn;
    }) ?? false;
    return Pair.of(bind, deviceId);
  }

}
