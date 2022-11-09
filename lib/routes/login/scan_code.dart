import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/index.dart';

class _ScanCode extends State<ScanCode> {
  String qrLink = '1111';
  late String sessionId;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    //初始化状态
    debugPrint("initState");
    updateQrCode();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");
    return Center(
        child: Container(
          color: Colors.white,
      child: QrImage(
        data: qrLink,
        version: QrVersions.auto,
        size: 200.0,
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("dispose");
    timer.cancel();
  }

  /// 绑定二维码url
  void updateQrCode() async {
    var res = await IotApi.getQrCode();

    if (res.isSuccess) {
      setState(() {
        // 拼接二维码url
        qrLink = '${res.data.shortUrl}?id=${Global.productCode}';
      });

      sessionId = res.data.sessionId;

      updateLoginStatus();
    }
  }

  /// 大屏端轮询授权状态接口
  void updateLoginStatus() {
    timer = Timer(const Duration(seconds: 5), () async {
      var res = await IotApi.getAccessToken(sessionId);

      if (res.isSuccess) {
        await IotApi.autoLogin();
      } else {
        updateLoginStatus();
      }
    });
  }
}

class ScanCode extends StatefulWidget {
  const ScanCode({super.key});

  @override
  State<ScanCode> createState() => _ScanCode();
}
