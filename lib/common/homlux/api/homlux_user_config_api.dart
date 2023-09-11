
import '../homlux_global.dart';
import '../models/homlux_response_entity.dart';
import '../models/homlux_user_config_info.dart';
import 'homlux_api.dart';

class HomluxUserConfigApi {

  /// 查询工程模式开关配置
  static Future<HomluxResponseEntity<HomluxUserConfigInfo>> queryEngineeringMode() async {
    var res = await HomluxApi.request<HomluxUserConfigInfo>(
        '/v1/mzgd/user/queryUserDeviceConfigInfo',
        data: {"deviceId": HomluxGlobal.gatewayApplianceCode,
          "type": "1"});
    return res;
  }

  /// 设置工程模式开关
  static Future<HomluxResponseEntity> updateEngineeringMode(bool isEnable) async {
    var res = await HomluxApi.request(
        '/v1/mzgd/user/updateUserDeviceConfigInfo',
        data: {"deviceId": HomluxGlobal.gatewayApplianceCode,
          "type": "1",
          "businessValue": isEnable ? "1" : "0"});
    return res;
  }

}