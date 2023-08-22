

import 'package:dio/dio.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

class MeiJuGatewayCloudApi {
  
  static Future<MeiJuResponseEntity> queryPanelBindList(String applianceCode) async {
    var res = await MeiJuApi.requestMideaIot(
      '/mas/v5/app/proxy?alias=/v2/scene/panel/bind/list',
      options: Options(
          method: 'POST'),
      data: {
        'applianceCode': applianceCode,
        'appId': '12002'
      }
    );
    return res;
  }
  
  
}