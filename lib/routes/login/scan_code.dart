import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../channel/index.dart';
import '../../common/index.dart';

class _ScanCode extends State<ScanCode> {
  String qrLink = '';
  String? sessionId;
  Timer? updateQrCodeTime;
  Timer? updateLoginStatusTime;

  @override
  void initState() {
    super.initState();
    //初始化状态
    debugPrint("scan_code.dart-initState");
    updateQrCode();
    updateLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");

    var hiView = const Image(image: AssetImage("assets/imgs/login/hello.png"));

    return Stack(
      children: [
        Center(
          child: StrUtils.isNotNullAndEmpty(qrLink)
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImage(
                    data: qrLink,
                    version: QrVersions.auto,
                    size: 270.0,
                    padding: const EdgeInsets.all(20),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
        Positioned(
            bottom: 24, right: 16, width: 103, height: 141, child: hiView),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("scan_code.dart-dispose");
    updateQrCodeTime?.cancel();
    updateLoginStatusTime?.cancel();
  }

  /// 绑定二维码url
  void updateQrCode() async {
    var res = await UserApi.getQrCode();

    if (res.isSuccess) {
      setState(() {
        // 拼接二维码url
        qrLink = '${res.data.shortUrl}?id=${Global.productCode}';
      });

      sessionId = res.data.sessionId;
      var effectTimeSecond = res.data.effectTimeSecond;

      updateQrCodeTime = Timer(Duration(seconds: effectTimeSecond - 20), () {
        updateQrCode();
      });
    }
  }

  /// 大屏端轮询授权状态接口
  void updateLoginStatus() async {
    var delaySec = 2; // 2s轮询间隔
    if (StrUtils.isNullOrEmpty(sessionId)) {
      updateLoginStatusTime = Timer(Duration(seconds: delaySec), () {
        updateLoginStatus();
      });
      return;
    }

    var res = await UserApi.getAccessToken(sessionId ?? '');

    if (res.isSuccess) {
      updateQrCodeTime?.cancel(); // 取消登录状态查询定时

      String? sn;
      try {
        sn = await aboutSystemChannel.getGatewaySn(true, Global.user?.seed);
      } catch (error) {
        logger.e('getGatewaySn-error: $error');
      }
      debugPrint('getGatewaySn: $sn');

      Global.profile.deviceSn = sn;

      await System.refreshToken();

      debugPrint('getAccessToken: ${res.toJson()}');
      TipsUtils.toast(content: '授权成功');
      widget.onSuccess!();
    } else {
      updateLoginStatusTime = Timer(Duration(seconds: delaySec), () {
        updateLoginStatus();
      });
    }
  }
}

class ScanCode extends StatefulWidget {
  final Function? onSuccess;

  const ScanCode({super.key, this.onSuccess});

  @override
  State<ScanCode> createState() => _ScanCode();
}
