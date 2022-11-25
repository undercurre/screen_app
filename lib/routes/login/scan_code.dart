import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/index.dart';

class _ScanCode extends State<ScanCode> {
  String qrLink = '';
  late String sessionId;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    //初始化状态
    debugPrint("scan_code.dart-initState");
    updateQrCode();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");

    const hiView = Image(image: AssetImage("assets/imgs/login/hello.png"));

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
        const Positioned(
            bottom: 24, right: 16, width: 103, height: 141, child: hiView)
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("scan_code.dart-dispose");
    timer.cancel();
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

      updateLoginStatus();
    }
  }

  /// 大屏端轮询授权状态接口
  void updateLoginStatus() {
    timer = Timer(const Duration(seconds: 5), () async {
      var res = await UserApi.getAccessToken(sessionId);

      if (res.isSuccess) {
        await UserApi.autoLogin();

        // 获取美智token
        await UserApi.authToken();

        Global.saveProfile();

        TipsUtils.toast(context: context, title: '提示', content: '授权成功');
        widget.onSuccess!();
      } else {
        updateLoginStatus();
      }
    });
  }
}

class ScanCode extends StatefulWidget {
  final Function? onSuccess;

  const ScanCode({super.key, this.onSuccess});

  @override
  State<ScanCode> createState() => _ScanCode();
}
