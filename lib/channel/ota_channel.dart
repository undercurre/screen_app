

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';

import '../common/index.dart';
import '../widgets/event_bus.dart';

class OtaChannel extends AbstractChannel {

  OtaChannel.fromName(super.channelName) : super.fromName();

  bool? _isInit;
  bool? _hasNewVersion;
  bool? _isDownloading;

  bool get isInit => _isInit ?? false;
  bool get hasNewVersion => _hasNewVersion ?? false;
  bool get isDownloading => _isDownloading ?? false;

  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
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
    }
  }

  // 初始化ota
  void init(String uid, String deviceId, String mzToken, String sn) async {
   bool suc = await methodChannel.invokeMethod('init', {
      'uid': uid,
      'deviceId': deviceId,
      'mzToken': mzToken,
      'sn': sn
    });
    _isInit = suc;
  }
  // 重置ota
  void reset() async {
    bool suc = await methodChannel.invokeMethod('reset');
    _isInit = false;
  }
  // 检查是否更新中
  void checkUpgrade() async {
    try {
      methodChannel.invokeMethod('checkUpgrade');
    } on PlatformException catch (e) {
      if(e.code == '-1') {
        _isInit = false;
        debugPrint(e.message);
      } else if(e.code == '-2') {
        _isDownloading = true;
        debugPrint(e.message);
      }
    }
  }
  // 取消确认下载（此时还未下载，还在确认下载阶段）
  void cancelConfirmDownload() async {
    bool suc = await methodChannel.invokeMethod('cancelConfirmDownload');
    _isDownloading = false;
  }
  // 确认下载
  void confirmDownload() async {
    bool suc = await methodChannel.invokeMethod('confirmDownload');
    _isDownloading = suc;
  }
  // 取消下载
  void cancelDownload() async {
    bool suc = await methodChannel.invokeMethod('cancelDownload');
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
  }
  // 提示没有新版本更新
  void onHandlerNoNewVersion(dynamic arguments) async {
    TipsUtils.toast(content: "已经是最新版本");
  }
  // 下载安装包成功
  void onHandlerDownloadSuc(dynamic arguments) {
    bus.emit('ota-download-suc');
  }
  // 下载安装包失败
  void onHandlerDownloadFail(dynamic arguments) {
    _isDownloading = false;
    bus.emit('ota-download-fail');
  }
  // 正在下载安装包
  void onHandlerDownloading(dynamic arguments) {
    int process = arguments;// 0 - 100
    bus.emit('ota-download-loading', process / 100);
  }

}