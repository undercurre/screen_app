

import 'package:dio/dio.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

class MeiJuGatewayCloud {
  
  static Future<MeiJuResponseEntity> queryPanelBindList(String applianceCode) async {
    var res = await MeiJuApi.requestGCloudIot(
      '/mas/v5/app/proxy?alias=/v2/scene/panel/bind/list',
      options: Options(
          method: 'POST',
          headers: {
            'secretversion': 1
          }),
      data: {
        'applianceCode': applianceCode
      }
    );
    return res;
  }
  
  
}