import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/widgets/event_bus.dart';
import 'package:screen_app/widgets/mz_notice.dart';

mixin AutoSniffer<T extends StatefulWidget> on State<T> {
  late Timer _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bus.on("backHome", (arg) {
      logger.i('bus.backHome trigger');

      MzNotice mzNotice = MzNotice(
          title: '发现5个新设备', // TODO 加入查找逻辑
          backgroundColor: const Color(0XFF575757),
          onPressed: () {});

      // HACK 延时弹出，否则会因页面context不完整报错
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        _timer.cancel();
        await mzNotice.show(context);
      });
    });
  }

  @override
  void dispose() {
    bus.off("backHome");
    super.dispose();
  }
}
