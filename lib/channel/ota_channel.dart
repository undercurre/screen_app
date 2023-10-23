

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:screen_app/channel/asb_channel.dart';

import '../common/homlux/homlux_global.dart';
import '../common/index.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/meiju_global.dart';
import '../widgets/event_bus.dart';

enum OtaUpgradeType {
  normal, direct, rom
}

class OtaChannel extends AbstractChannel {

  OtaChannel.fromName(super.channelName) : super.fromName();

  bool? _hasNewVersion;
  bool? _isDownloading;

  bool get hasNewVersion => _hasNewVersion ?? false;
  bool get isDownloading => _isDownloading ?? false;

  void Function()? _onUpgrade;

  /// 网关SN
  String? gatewaySn;

  /// 是否支持app与网关更新
  Future<bool> get supportNormalOta async => await methodChannel.invokeMethod('supportNormalOTA')  as bool;
  /// 是否支持定向更新[app与网关]
  Future<bool> get supportDirectOTA async => await methodChannel.invokeMethod('supportDirectOTA')  as bool;
  /// 是否支持rom更新
  Future<bool> get supportRomOTA async => await methodChannel.invokeMethod('supportRomOTA')  as bool;

  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    super.onMethodCallHandler(call);
    switch(call.method) {
      case "downloadSuc":
        onHandlerDownloadSuc(call.arguments);
        break;
      case "downloadFail":
        onHandlerDownloadFail(call.arguments);
        break;
      case "downloading":
        onHandlerDownloading(call.arguments);
        break;
      case "newVersion":
        onHandlerNewVersion(call.arguments);
        break;
      case "noNewVersion":
        onHandlerNoNewVersion(call.arguments);
        break;
      case "installSuc":
        break;
      case "installFail":
        break;
    }
  }

  /// 普通检查更新
  void checkNormalAndRom(bool isBackground) {
    checkUpgrade(OtaUpgradeType.rom, () {
      checkUpgrade(OtaUpgradeType.normal, () {
        if(!isBackground) {
          TipsUtils.toast(content: "已经是最新版本", position: EasyLoadingToastPosition.bottom);
        }
      });
    });
  }

  /// 定向检查更新
  void checkDirect([bool isBackground = false]) async {
    checkUpgrade(OtaUpgradeType.direct, () {
      if(isBackground) {
        TipsUtils.toast(
            content: "已经是最新版本", position: EasyLoadingToastPosition.bottom);
      }
    });
  }

  // 检查更新
  void checkUpgrade(OtaUpgradeType type, void Function() noUpgrade) async {

    if(OtaUpgradeType.normal == type && !await supportNormalOta) {
      Log.e('暂时不支持normal类型ota');
      noUpgrade.call();
      return;
    }
    if(OtaUpgradeType.direct == type && !await supportDirectOTA) {
      Log.e('暂时不支持direct类型ota');
      noUpgrade.call();
      return;
    }
    if(OtaUpgradeType.rom == type && !await supportRomOTA) {
      Log.e('暂时不支持rom类型ota');
      noUpgrade.call();
      return;
    }

    String deviceId = System.deviceId ?? "";
    String token = System.getToken() ?? '';
    String uid = System.getUid() ?? '';
    String sn = await System.gatewaySn ?? '';

    int numType;
    if(OtaUpgradeType.normal == type) {
      numType = 1;
    } else if(OtaUpgradeType.direct == type) {
      numType = 2;
    } else {
      numType = 3;
    }

    _onUpgrade = noUpgrade;

    try {
      methodChannel.invokeMethod('checkUpgrade', {
        'numType': numType,
        'uid': uid,
        'deviceId': deviceId,
        'token': token,
        'sn': sn
      });
    } on PlatformException catch (e) {
      if(e.code == '-1') {
      } else if(e.code == '-2') {
        _isDownloading = true;
      }
      TipsUtils.toast(content: e.message ?? '请稍后重试');
      Log.e(e.message ?? '请稍后重试', e.stacktrace);
    }
  }
  // 确认下载
  void confirmDownload() async {
    bool suc = await methodChannel.invokeMethod('confirmDownload');
    _isDownloading = suc;
  }
  // 取消下载
  void cancelDownload() async {
    await methodChannel.invokeMethod('cancelDownload');
    _isDownloading = false;
  }

  // 是否已经初始化
  Future<bool> __isInit() async {
    bool suc = await methodChannel.invokeMethod('isInit');
    return suc;
  }
  // 是否正在下载
  Future<bool> __isDownloading() async {
    bool suc = await methodChannel.invokeMethod('isDownloading');
    return suc;
  }

  // 提示有新版本更新
  void onHandlerNewVersion(dynamic arguments) async {
    _hasNewVersion = true;
    String content = arguments;
    bus.emit('ota-new-version', content);
    // 用于关于页的New提醒
    bus.emit('ota-new-version-tip', true);
    Log.i('ota-new-version');
    _onUpgrade = null;
  }
  // 提示没有新版本更新
  void onHandlerNoNewVersion(dynamic arguments) async {
    _hasNewVersion = false;
    _onUpgrade?.call();
    _onUpgrade = null;
    // 用于关于页的New提醒
    bus.emit('ota-new-version-tip', false);
    Log.i('ota-no-version');
  }
  // 下载安装包成功
  void onHandlerDownloadSuc(dynamic arguments) {
    bus.emit('ota-download-suc');
    Log.i('ota-download-suc');
  }
  // 下载安装包失败
  void onHandlerDownloadFail(dynamic arguments) {
    _isDownloading = false;
    bus.emit('ota-download-fail');
    Log.i('ota-download-fail');
  }
  // 正在下载安装包
  void onHandlerDownloading(dynamic arguments) {
    int process = arguments;// 0 - 100
    bus.emit('ota-download-loading', process / 100);
    Log.i('ota-downloading-$process');
  }
  // 安装失败
  void onHandlerInstallFail() {
    bus.emit('ota-install-fail');
  }
  // 安装成功
  void onHandleInstallSuc() {
    bus.emit('ota-install-suc');
  }

}