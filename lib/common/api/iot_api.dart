import 'package:dio/dio.dart';

import 'api.dart';
import '../../models/index.dart';

class IotApi {
  /// 登录接口，登录成功后返回用户信息
  static Future<IotResult> getQrCode() async {
    var res = await Api.requestIot("/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': '38f6b0a50b2328ea428293858a726671', 'checkType': 1},
        options: Options(
            method: 'POST',
            extra: { 'isEncrypt': false }
        ));

    res.data = QrCode.fromJson(res.data);
    return res;
  }
}
