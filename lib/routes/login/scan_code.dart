import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../common/api/iot_api.dart';
import '../../common/index.dart';

class _ScanCode extends State<ScanCode> {
  String qrLink = '1111';

  @override
  void initState() {
    super.initState();
    //初始化状态
    debugPrint("initState");
    updateCode();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");
    return Center(
        child: Container(
          color: Colors.green,
      child: QrImage(
        data: qrLink,
        version: QrVersions.auto,
        size: 200.0,
      ),
    ));
  }

  void updateCode() async {
    var res = await IotApi.getQrCode();

    if (res.isSuccess) {
      setState(() {
        qrLink = '${res.data.shortUrl}?id=${Global.productCode}';

        debugPrint("QrCode: $qrLink");
      });
    }
  }
}

class ScanCode extends StatefulWidget {
  const ScanCode({super.key});

  @override
  State<ScanCode> createState() => _ScanCode();
}
