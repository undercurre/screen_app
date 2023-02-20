

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/channel/index.dart';
import '../common/index.dart';
import '../widgets/event_bus.dart';

/// ota升级辅助器
mixin OtaSdkInitialize<T extends StatefulWidget> on State<T> {

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    initOtaSDK();
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    resetOtaSDK();
  }

  void initOtaSDK() async {
    String? sn = await aboutSystemChannel.getGatewaySn();
    if(sn == null) {
      logger.e('初始化ota失败，获取网关SN失败导致');
    } else {
      otaChannel.init(
          Global.user?.uid ?? "",
          Global.user?.deviceId ?? "",
          Global.user?.mzAccessToken ?? "",
          sn);
    }
  }

  void resetOtaSDK() {
    otaChannel.reset();
  }

}

enum OtaUpgradeType {
  normal, direct, rom
}

class OtaChannel extends AbstractChannel {

  OtaChannel.fromName(super.channelName) : super.fromName();

  bool? _isInit;
  bool? _hasNewVersion;
  bool? _isDownloading;

  bool get isInit => _isInit ?? false;
  bool get hasNewVersion => _hasNewVersion ?? false;
  bool get isDownloading => _isDownloading ?? false;

  void Function()? _onUpgrade;

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

  // 初始化ota
  void init(String uid, String deviceId, String mzToken, String sn) async {
    if(_isInit != true) {
      bool suc = await methodChannel.invokeMethod('init', {
        'uid': uid,
        'deviceId': deviceId,
        'mzToken': mzToken,
        'sn': sn
      });
      _isInit = suc;
    }
  }
  // 重置ota
  void reset() async {
    await methodChannel.invokeMethod('reset');
    _isInit = false;
  }

  /// 普通检查更新
  void checkNormalAndRom(bool isBackground) {
    checkUpgrade(OtaUpgradeType.normal, () {
      checkUpgrade(OtaUpgradeType.rom, () {
        if(!isBackground) {
          TipsUtils.toast(content: "已经是最新版本");
        }
      });
    });
  }

  /// 定向检查更新
  void checkDirect() {
    checkUpgrade(OtaUpgradeType.direct, () {
      TipsUtils.toast(content: "已经是最新版本");
    });
  }

  // 检查更新
  void checkUpgrade(OtaUpgradeType type, void Function() onUpgrade) async {

    if(_isInit != true) {
      logger.e('ota sdk 还未初始化');
      return;
    }
    if(OtaUpgradeType.normal == type && !await supportNormalOta) {
      logger.e('暂时不支持normal类型ota');
      onUpgrade.call();
      return;
    }
    if(OtaUpgradeType.direct == type && !await supportDirectOTA) {
      logger.e('暂时不支持direct类型ota');
      onUpgrade.call();
      return;
    }
    if(OtaUpgradeType.rom == type && !await supportRomOTA) {
      logger.e('暂时不支持rom类型ota');
      onUpgrade.call();
      return;
    }

    int numType;
    if(OtaUpgradeType.normal == type) {
      numType = 1;
    } else if(OtaUpgradeType.direct == type) {
      numType = 2;
    } else {
      numType = 3;
    }

    _onUpgrade = onUpgrade;

    try {
      methodChannel.invokeMethod('checkUpgrade', numType);
    } on PlatformException catch (e) {
      if(e.code == '-1') {
        _isInit = false;
      } else if(e.code == '-2') {
        _isDownloading = true;
      }
      TipsUtils.toast(content: e.message ?? '请稍后重试');
      logger.e(e.message, e.stacktrace);
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
    String content = arguments;
    bus.emit('ota-new-version', content);
    logger.i('ota-new-version');
    _onUpgrade = null;
  }
  // 提示没有新版本更新
  void onHandlerNoNewVersion(dynamic arguments) async {
    _onUpgrade?.call();
    _onUpgrade = null;
    logger.i('ota-no-version');
  }
  // 下载安装包成功
  void onHandlerDownloadSuc(dynamic arguments) {
    bus.emit('ota-download-suc');
    logger.i('ota-download-suc');
  }
  // 下载安装包失败
  void onHandlerDownloadFail(dynamic arguments) {
    _isDownloading = false;
    bus.emit('ota-download-fail');
    logger.i('ota-download-fail');
  }
  // 正在下载安装包
  void onHandlerDownloading(dynamic arguments) {
    int process = arguments;// 0 - 100
    bus.emit('ota-download-loading', process / 100);
    logger.i('ota-downloading-$process');
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