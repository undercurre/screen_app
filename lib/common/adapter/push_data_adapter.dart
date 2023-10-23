

import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/homlux/push/homlux_push_manager.dart';
import 'package:screen_app/common/meiju/push/meiju_push_manager.dart';

import '../logcat_helper.dart';

class PushDataAdapter extends MideaDataAdapter {

  PushDataAdapter(super.platform);

  bool isConnect() {
    if (platform.inHomlux()) {
      return HomluxPushManager.isConnect();
    } else if (platform.inMeiju()) {
      return MeiJuPushManager.isConnect();
    } else {
      throw Exception('NO NO NO 请不要访问此方法');
    }
  }

  void startConnect() {
    if (platform.inMeiju()) {
      MeiJuPushManager.startConnect();
    } else if (platform.inHomlux()) {
      HomluxPushManager.init();
    } else {
      Log.file('程序执行异常');
    }
  }

  void stopConnect() {
    MeiJuPushManager.stopConnect();
    HomluxPushManager.destroy();
  }




}