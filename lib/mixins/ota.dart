import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screen_app/channel/index.dart';

import '../common/logcat_helper.dart';
import '../widgets/event_bus.dart';
import '../widgets/mz_slider.dart';

mixin Ota<T extends StatefulWidget> on State<T> {
  int? _otaUpgradeLastTime;

  @override
  void initState() {
    super.initState();
    bus.on("ota-new-version", (arg) {
      // 显示OTA弹窗
      showOtaDialog(context, arg);
    });
  }

  void checkOtaUpgrade() {
    /// 每隔半天请求一次
    if (DateTime.now().millisecond - (_otaUpgradeLastTime ?? 0) >
        12 * 60 * 60 * 1000) {
      _otaUpgradeLastTime = DateTime.now().millisecond;
      if (!otaChannel.isDownloading) {
        otaChannel.checkNormalAndRom(true);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    bus.off('ota-new-version');
  }

  void showOtaDialog(BuildContext context, String content) {
    OtaDialog.show(context, content);
  }
}

enum _DownloadState { normal, downloading, downloadFail, downloadSuc }

const int _stepNormal = 1;
const int _stepDownload = 2;
const int _stepInstall = 3;

class OtaDialog {
  static bool isShow = false;

  static void show(BuildContext context, String detail) {
    Log.i('ota-OtaDialog.show()');

    if (isShow) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return _OtaDialog(
            upgradeDetail: detail,
            lifeCallback: (show) {
              isShow = show;
            },
          );
        });
  }
}

// 定义Dialog显示或者隐藏回调
typedef _DialogLifeCallback = Function(bool show);

@immutable
class _OtaDialog extends StatefulWidget {
  // 更新内容
  String upgradeDetail;
  _DialogLifeCallback lifeCallback;

  _OtaDialog(
      {super.key, required this.upgradeDetail, required this.lifeCallback});

  @override
  State<StatefulWidget> createState() {
    return _OtaState1();
  }
}

class _OtaState1 extends State<_OtaDialog> {
  // 下载过程的子状态
  _DownloadState state = _DownloadState.normal;

  // 记录当前更新阶段
  int step = _stepNormal;
  double progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    bus.on('ota-download-loading', (arg) {
      print("当前下载的进度为：$arg");
      setState(() {
        step = _stepDownload;
        state = _DownloadState.downloading;
        progress = arg;
      });
    });
    bus.on('ota-download-fail', (arg) {
      debugPrint('ota-download-fail');
      setState(() {
        state = _DownloadState.downloadFail;
      });
    });
    bus.on('ota-download-suc', (arg) {
      debugPrint('ota-download-suc');
      setState(() {
        state = _DownloadState.downloadSuc;
        step = _stepInstall;
        progress = 0;
        _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
          setState(() {
            progress += 0.01;
          });
        });
      });
    });
    bus.on('ota-install-suc', (arg) {
      state = _DownloadState.downloadSuc;
      step = _stepInstall;
      progress = 1;
    });
    widget.lifeCallback.call(true);
  }

  void cancelReDownload() {
    Navigator.of(context).pop();
  }

  void reDownload() {
    Navigator.of(context).pop();
    otaChannel.checkNormalAndRom(false);
  }

  void cancelDownload() {
    otaChannel.cancelDownload();
    Navigator.of(context).pop();
  }

  void confirmDownload() {
    otaChannel.confirmDownload();
    setState(() {
      state = _DownloadState.downloading;
      step = _stepDownload;
      progress = 0;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    widget.lifeCallback.call(false);
    bus.off('ota-download-loading');
    bus.off('ota-download-fail');
    bus.off('ota-download-suc');
    bus.off('ota-install-suc');
  }

  @override
  Widget build(BuildContext context) {

    ButtonStyle buttonStyleOff = TextButton.styleFrom(
        backgroundColor: const Color(0xFF858D9A),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(29))),
        padding: const EdgeInsets.symmetric(vertical: 10));

    // 激活按钮样式
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color(0xFF267AFF),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(29))),
        padding: const EdgeInsets.symmetric(vertical: 10));

    // 按钮文字样式
    TextStyle textStyle = const TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.80),
        fontSize: 24,
        height: 1.65,
        fontFamily: 'MideaType',
        fontWeight: FontWeight.w400);

    List<Widget> content = [];
    if(_stepNormal == step) {
      content = [
        Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(
                maxHeight: 200
            ),
            child: ListView(
              children: [
                Text(
                  widget.upgradeDetail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 24,
                      fontFamily: 'MideaType'
                  ),
                )
              ],
            )),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 168,
                height: 56,
                child: TextButton(
                  style: buttonStyleOff,
                  child: Text('取消', style: textStyle),
                  onPressed: () {
                    // 取消下载
                    cancelDownload();
                  }, //关闭对话框
                ),
              ),
              SizedBox(
                width: 168,
                height: 56,
                child: TextButton(
                  style: buttonStyleOn,
                  child: Text('更新', style: textStyle),
                  onPressed: () {
                    // 确认下载
                    confirmDownload();
                  }, //关闭对话框
                ),
              ),
            ],
          ),
        )
      ];
    }
    else if(_stepDownload == step) {
      if(state == _DownloadState.downloading) {
        content = [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(width: 10),
                Text(
                  '下载中',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white54
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: MzSlider(width: 300, height: 4, value: progress * 100),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 200,
              height: 56,
              child: TextButton(
                style: buttonStyleOff,
                child: Text('取消', style: textStyle),
                onPressed: () {
                  cancelDownload();
                }, //关闭对话框
              ),
            ),
          )
        ];
      }
      else if(state == _DownloadState.downloadFail) {
        content = [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 168,
                  height: 56,
                  child: TextButton(
                    style: buttonStyleOff,
                    child: Text('取消', style: textStyle),
                    onPressed: () {
                      // 下载失败，取消再下载
                      cancelReDownload();
                    }, //关闭对话框
                  ),
                ),
                SizedBox(
                  width: 168,
                  height: 56,
                  child: TextButton(
                    style: buttonStyleOn,
                    child: Text('重试', style: textStyle),
                    onPressed: () {
                      // 下载失败，重新下载
                      reDownload();
                    }, //关闭对话框
                  ),
                ),
              ],
            ),
          ),
        ];
      }
    } else if(_stepInstall == step) {
      content = [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(width: 10),
              Text(
                '安装中',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white54
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: MzSlider(
            activeColors: const [Colors.white, Colors.white],
            seekbarBgColor: Colors.white30,
            width: 300,
            height: 4,
            value: progress * 100 + 60,
            disabled: false),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            '${(progress * 100).floor()}%',
            style: const TextStyle(
              fontSize: 60
            ),
          ),
        )
      ];
    }

    return Dialog(
      backgroundColor: const Color(0xff494E59),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40))),
      alignment: AlignmentDirectional.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                step == _stepNormal
                    ? "有新版本可用"
                    : (state == _DownloadState.downloadFail
                    ? '下载失败'
                    : '有新版本可用'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              )),
          ...content
        ],
      ),
    );
  }

}


class _OtaState extends State<_OtaDialog> {
  // 下载过程的子状态
  _DownloadState state = _DownloadState.normal;

  // 记录当前更新阶段
  int step = _stepNormal;
  double progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    bus.on('ota-download-loading', (arg) {
      print("当前下载的进度为：$arg");
      setState(() {
        step = _stepDownload;
        state = _DownloadState.downloading;
        progress = arg;
      });
    });
    bus.on('ota-download-fail', (arg) {
      debugPrint('ota-download-fail');
      setState(() {
        state = _DownloadState.downloadFail;
      });
    });
    bus.on('ota-download-suc', (arg) {
      debugPrint('ota-download-suc');
      setState(() {
        state = _DownloadState.downloadSuc;
        step = _stepInstall;
        progress = 0;
        _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
          setState(() {
            progress += 0.01;
          });
        });
      });
    });
    bus.on('ota-install-suc', (arg) {
      state = _DownloadState.downloadSuc;
      step = _stepInstall;
      progress = 1;
    });
    widget.lifeCallback.call(true);
  }

  void cancelReDownload() {
    Navigator.of(context).pop();
  }

  void reDownload() {
    Navigator.of(context).pop();
    otaChannel.checkNormalAndRom(false);
  }

  void cancelDownload() {
    otaChannel.cancelDownload();
    Navigator.of(context).pop();
  }

  void confirmDownload() {
    otaChannel.confirmDownload();
    setState(() {
      state = _DownloadState.downloading;
      step = _stepDownload;
      progress = 0;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    widget.lifeCallback.call(false);
    bus.off('ota-download-loading');
    bus.off('ota-download-fail');
    bus.off('ota-download-suc');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff494E59),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40))),
      alignment: AlignmentDirectional.center,
      child: IntrinsicHeight(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  step == _stepNormal
                      ? "有新版本可用"
                      : (state == _DownloadState.downloadFail
                          ? '下载失败'
                          : '有新版本可用'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                )),
            Container(
                constraints: const BoxConstraints(
                    minWidth: 423,
                    maxWidth: 423,
                    minHeight: 100,
                    maxHeight: 200),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Visibility(
                        visible: step == _stepNormal,
                        child: Text(widget.upgradeDetail,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            )),
                      ),
                      Visibility(
                          visible: step == _stepInstall ||
                              step == _stepDownload &&
                                  state != _DownloadState.downloadFail,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CupertinoActivityIndicator(radius: 9),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  (step == _stepDownload ? "下载中..." : "安装中..."),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                )),
            Column(
              children: [
                Visibility(
                    visible: step == _stepDownload &&
                            state != _DownloadState.downloadFail ||
                        step == _stepInstall,
                    child: LinearProgressIndicator(
                      value: progress,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                      backgroundColor: const Color(0xff1b1b1b),
                    )),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility(
                        visible: step == _stepNormal ||
                            step == _stepDownload &&
                                state == _DownloadState.downloadFail,
                        child: Expanded(
                          flex: 1,
                          child: TextButton(
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                    const Size.fromHeight(50)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff282828)),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder())),
                            onPressed: () {
                              if (step == _stepNormal) {
                                // 取消下载
                                cancelDownload();
                              } else if (step == _stepDownload &&
                                  state == _DownloadState.downloadFail) {
                                // 下载失败，取消再下载
                                cancelReDownload();
                              }
                            },
                            child: const Text(
                              '取消',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )),
                    Visibility(
                      visible: step == _stepNormal ||
                          step == _stepDownload &&
                              state == _DownloadState.downloadFail,
                      child: Expanded(
                          flex: 1,
                          child: TextButton(
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                    const Size.fromHeight(50)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff267AFF)),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder())),
                            onPressed: () {
                              if (step == _stepNormal) {
                                // 确认下载
                                confirmDownload();
                              } else if (step == _stepDownload &&
                                  state == _DownloadState.downloadFail) {
                                // 下载失败，重新下载
                                reDownload();
                              }
                            },
                            child: Text(step == _stepNormal ? '现在更新' : '重新下载',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          )),
                    ),
                    Visibility(
                        visible: step == _stepInstall ||
                            step == _stepDownload &&
                                state != _DownloadState.downloadFail,
                        child: Expanded(
                          flex: 1,
                          child: TextButton(
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                    const Size.fromHeight(50)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff282828)),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder())),
                            onPressed: () {
                              cancelDownload();
                            },
                            child: Text(
                              (step == _stepDownload
                                  ? '取消'
                                  : "${(progress * 100).floor()}%"),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ))
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

