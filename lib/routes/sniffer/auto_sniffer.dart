import 'package:flutter/material.dart';

import '../../widgets/mz_notice.dart';

mixin AutoSniffer<T extends StatefulWidget> on State<T> {

  void onSniffer() {
    MzNotice mzNotice = MzNotice(
        title: '发现5个新设备', // TODO 加入查找逻辑
        backgroundColor: const Color(0XFF575757),
        onPressed: () {
          Navigator.of(context).pushNamed('developer');
        });

    // HACK 延时弹出，否则会因页面context不完整报错
    Future.delayed(const Duration(seconds: 1), () async {
      await mzNotice.show(context);
    });
  }

}
