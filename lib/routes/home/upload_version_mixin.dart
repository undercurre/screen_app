import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../channel/index.dart';
import '../../common/homlux/api/homlux_user_api.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/api/meiju_user_api.dart';
import '../../common/system.dart';

/// 上传版本信息
mixin UploadVersionMixin<T extends StatefulWidget> on State<T> {
  int time = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    NetUtils.stickRegisterListenerNetAvailableState(netStateChange);
  }

  @override
  void dispose() {
    NetUtils.stickRegisterListenerNetAvailableState(netStateChange);
    super.dispose();
  }

  void netStateChange(bool available) {
    if(available && System.isLogin()) {
      time = 3;
      upload();
    }
  }

  void upload() async {
    timer?.cancel();
    if(time == 0) {
      return;
    }
    /// 未上报版本记录
    Log.develop("检查是否已上传");
    if(await _record()?.hasRecord() == false) {
      Log.develop("准备上传版本");
      bool? uploadResult = await _record()?.upload();
      Log.develop("上传是否成功：$uploadResult");
      if(uploadResult != true) {
        --time;
        timer = Timer(Duration(seconds: 10 * (3 - time)), () {
          upload();
          Log.develop("预备重新上传");
        });
      }
    }
  }

  _UploadVersionRecord? _record() {
    if(MideaRuntimePlatform.inHomlux()) {
      return _HomluxUploadVersionRecord();
    } else if(MideaRuntimePlatform.inMeiJu()) {
      return _MeiJuUploadVersionRecord();
    }
    return null;
  }

}

abstract class _UploadVersionRecord {

  abstract String preKey;

  Future<bool> hasRecord() async {
    String version = await getVersion();
    SharedPreferences sp = await SharedPreferences.getInstance();
    Log.develop('当前版本 $version 缓存版本 ${sp.get(key())}');
    return version == sp.getString(key());
  }

  String key() {
    return '${preKey}_${System.gatewayApplianceCode}';
  }

  Future<bool> upload();

  Future<String> getVersion() async {
    return aboutSystemChannel.getSystemVersion();
  }

}

class _MeiJuUploadVersionRecord extends _UploadVersionRecord {

  @override
  String preKey = 'meiju-upload-version';

  @override
  Future<bool> upload() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final version = await getVersion();
    if(System.isLogin()) {
      var res = await MeiJuUserApi
          .uploadVersion(
          System.gatewayApplianceCode!, (await System.gatewaySn)!, version,
          System.getUid()!);
      if (res.isSuccess) {
        sp.setString(key(), version);
      }
      return res.isSuccess;
    }
    return false;
  }

}

class _HomluxUploadVersionRecord extends _UploadVersionRecord {

  @override
  String preKey = 'homlux-upload-version';

  @override
  Future<bool> upload() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final version = await getVersion();
    if(System.isLogin()) {
      var res = await HomluxUserApi.modifyDevice(
          '1', '4', System.gatewayApplianceCode!, softVersion: version);
      if (res.isSuccess) {
        Log.develop('version上传成功');
        sp.setString(key(), version);
      }
      return res.isSuccess;
    }
    return false;
  }

}