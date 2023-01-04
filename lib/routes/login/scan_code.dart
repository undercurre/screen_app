import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../channel/index.dart';
import '../../common/index.dart';

class _ScanCode extends State<ScanCode> {
  String qrLink = '';
  String? sessionId;
  Timer? updateQrCodeTime;
  Timer? updateLoginStatusTime;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    //初始化状态
    debugPrint("scan_code.dart-initState");
    updateQrCode();
    updateLoginStatus();

    initSocket();
  }

  void initSocket() {
    debugPrint('initSocket');
    IO.Socket socket = IO.io('https://172.18.5.171:7501');
    socket.onConnect((_) {
      debugPrint('connect');
      socket.emit('msg', 'test');
    });
    socket.on('event', (data) => debugPrint(data));
    socket.onDisconnect((_) => debugPrint('disconnect'));
    socket.on('fromServer', (_) => debugPrint(_));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");

    var hiView = Listener(
        child: const Image(image: AssetImage("assets/imgs/login/hello.png")),
        onPointerDown: (PointerDownEvent event) {
          debugPrint('hiView: $event');
        });

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
        Form(
          child: TextFormField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Send a message'),
          ),
        ),
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
  void updateLoginStatus() {
    updateLoginStatusTime =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (StrUtils.isNullOrEmpty(sessionId)) {
        return;
      }

      var res = await UserApi.getAccessToken(sessionId ?? '');

      if (res.isSuccess) {
        timer.cancel(); // 取消登录状态查询定时

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
