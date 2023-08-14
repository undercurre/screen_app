import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/homlux/api/homlux_dui_token_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';

import '../../channel/index.dart';
import '../global.dart';
import '../homlux/models/homlux_dui_token_entity.dart';
import '../logcat_helper.dart';
import '../meiju/api/meiju_ai_author_api.dart';
import '../meiju/meiju_global.dart';

// 获取初始化语音需要的数据
class AiDataAdapter extends MideaDataAdapter {

  AiDataAdapter(super.platform);

  Future<bool> homluxQueryAiStartUpData(String houseId) async {
    var aiClientId = dotenv.get('HOMLUX_AI_CLIENT_ID');
    var result = await HomluxDuiTokenApi.queryDuiToken(houseId, aiClientId);
    if (result.isSuccess && result.result != null) {
      HomluxDuiTokenEntity aiToken = result.result!;
      HomluxGlobal.aiToken = aiToken;
      Log.file('查询到Homlux语音数据${aiToken.toJson()}');
      return true;
    }
    return false;
  }

  // 启动AI语音
  void initAiVoice() async {
    if (platform.inMeiju()) {
      Log.file('正在初始化美居AI语音');
      Future.delayed(const Duration(milliseconds: 4000), () {
        MeiJuAiAuthorApi.AiAuthor(deviceId: MeiJuGlobal.gatewayApplianceCode);
      });
      String? deviceSn = await aboutSystemChannel.getGatewaySn(false);
      String? deviceId = MeiJuGlobal.gatewayApplianceCode;
      String macAddress = await aboutSystemChannel.getMacAddress();
      await aiMethodChannel.initialAi({
        'platform': 1,
        'deviceSn': deviceSn,
        'deviceId': deviceId,
        'macAddress': macAddress,
        'aiEnable': Global.profile.aiEnable
      });
    } else if (platform.inHomlux()) {
      Log.file('正在初始化美的照明AI语音');
      if(HomluxGlobal.homluxHomeInfo != null) {
        await aiMethodChannel.initialAi({
          'platform': 2,
          'uid': HomluxGlobal.homluxUserInfo?.userId,
          'token': HomluxGlobal.homluxQrCodeAuthEntity?.token,
          'aiEnable': Global.profile.aiEnable,
          'houseId': HomluxGlobal.homluxHomeInfo!.houseId,
          'aiClientId': dotenv.get('HOMLUX_AI_CLIENT_ID')
        });
      }
    } else {
      Log.file('程序执行异常');
    }
  }

  // 停止AI语音
  void stopAiVoice() {
    if (platform.inMeiju()) {
      aiMethodChannel.stopAi();
    } else if (platform.inHomlux()) {
      aiMethodChannel.stopAi();
    } else {
      Log.file('程序执行异常');
    }
  }

}