
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/adapter/midea_data_adapter.dart';
import '../../common/adapter/qr_code_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/index.dart';

class _ScanCode extends State<ScanCode> {

  QRCodeDataAdapter? qrDataAd;

  @override
  void initState() {
    super.initState();
    //初始化状态
    qrDataAd = QRCodeDataAdapter(MideaRuntimePlatform.platform);
    /// 授权成功回调
    qrDataAd?.setAuthQrCodeSucCallback(() {
      TipsUtils.toast(content: '授权成功', duration: 1000);
      widget.onSuccess!();
    });
    /// 更新二维码数据回调
    qrDataAd?.bindDataUpdateFunction(() {
      if(qrDataAd?.qrCodeState == DataState.ERROR) {
        TipsUtils.toast(content: qrDataAd?.errorTip ?? "请检查你的网络", duration: 1000);
      }
      setState(() {});
    });
    /// 请求数据
    qrDataAd?.requireQrCode();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 480,
      height: 290,
      alignment: Alignment.center,
      child: Stack(
        children: [
          if (StrUtils.isNotNullAndEmpty(qrDataAd?.qrCodeEntity?.qrcode)) const Positioned(
            right: 14,
            bottom: 11,
            child: Image(
              image: AssetImage("assets/imgs/login/hello.png"),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 480,
              alignment: Alignment.center,
              child: Text(
                MideaRuntimePlatform.platform == GatewayPlatform.MEIJU ? '请使用美居APP扫一扫' : "请使用美的照明小程序扫一扫",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  letterSpacing: 0,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          if (StrUtils.isNotNullAndEmpty(qrDataAd?.qrCodeEntity?.qrcode)) Positioned(
            left: 120,
            top: 10,
            child: GestureDetector(
              onTap: () {
                qrDataAd?.requireQrCode();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImage(
                  data: qrDataAd?.qrCodeEntity?.qrcode ?? '',
                  version: QrVersions.auto,
                  size: 240.0,
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
          ),
          if (qrDataAd?.qrCodeState == DataState.ERROR) Positioned(
            left: 197,
            top: 90,
            child: GestureDetector(
              onTap: () {
                qrDataAd?.requireQrCode();
              },
              child: const Image(
                height: 80,
                width: 80,
                image: AssetImage("assets/newUI/login/reload.png"),
              ),
            ),
          ),
          if (!StrUtils.isNotNullAndEmpty(qrDataAd?.qrCodeEntity?.qrcode)) Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 480,
              height: 260,
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(radius: 25),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    qrDataAd?.destroy();
    qrDataAd = null;
  }

}

class ScanCode extends StatefulWidget {
  final Function? onSuccess;

  const ScanCode({super.key, this.onSuccess});

  @override
  State<ScanCode> createState() => _ScanCode();
}
