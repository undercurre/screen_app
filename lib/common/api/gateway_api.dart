
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/channel/index.dart';

import '../../models/device_home_list_entity.dart';
import '../../models/mz_response_entity.dart';
import 'api.dart';
import '../global.dart';

class GatewayApi {

  /// 判定当前网关是否绑定
  static void check(void Function(bool,String?) result, void Function() error) async {
    _check().then((bind){
      logger.i('检查绑定', bind);
      _code().then((code) {
        result.call(bind == true,code);
      });
    }, onError: (_) {
      error.call();
    });
  }


  /// return null, false 表示没绑定 ， true 表示已经绑定
  static Future<bool?> _check() async {
   var sn = await aboutSystemChannel.getGatewaySn();

   var res = await queryHomeList();

      /// 查找当前家庭下所有的设备，判断是否存在设备与网关sn相同
     return res.result.homeList?[0]
         .roomList?.any((element) =>
              element.applianceList?.any((element) =>
                      element.sn == sn) ?? false);
  }

  static Future<String?> _code() async {
    var sn = await aboutSystemChannel.getGatewaySn();

    var res = await queryHomeList();
    String? ret;

    /// 查找当前家庭下所有的设备，判断是否存在设备与网关sn相同
    res.result.homeList?[0]
        .roomList?.forEach((rooms) {
        rooms.applianceList?.forEach((appliance) {
          if (appliance.sn == sn) {
            ret = appliance.applianceCode;
          }
      });
    });
    return ret;
  }

  static Future<MzResponseEntity<DeviceHomeListEntity>> queryHomeList() async {
    var res = await Api.requestMzIot<DeviceHomeListEntity>(
        "/v1/category/midea/device/list",
        data: {
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDROID",
          "reqId": uuid.v4(),
          "userId": Global.user?.uid,
          "homeGroupId": Global.profile.homeInfo?.homegroupId,
          "version": "1.0",
          "timestamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

}