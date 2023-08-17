

import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/homlux/push/homlu_push_manager.dart';
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
      HomluxPushManager.startConnect();
    } else {
      Log.file('程序执行异常');
    }
  }

  void stopConnect() {
    if (platform.inMeiju()) {
      MeiJuPushManager.stopConnect();
    } else if (platform.inHomlux()) {
      HomluxPushManager.stopConnect();
    } else {
      Log.file('程序执行异常');
    }
  }




}