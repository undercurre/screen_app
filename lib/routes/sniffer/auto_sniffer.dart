import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';

import '../../widgets/mz_notice.dart';
import '../../widgets/util/net_utils.dart';

mixin AutoSniffer<T extends StatefulWidget> on State<T> {

  void onSniffer() {
    /// 只有在WiFi连接的状态下才能搜索wifi设备
    if(NetUtils.getNetState()?.isWifi ?? false) {
      deviceManagerChannel.setFindWiFiCallback((result) {
        /// 注意：每使用一次就置空
        deviceManagerChannel.setFindWiFiCallback(null);
        if(result.isEmpty) return;

        MzNotice mzNotice = MzNotice(
            title: '发现${result.length}个新设备',
            backgroundColor: const Color(0XFF575757),
            onPressed: () {
              Navigator.of(context).pushNamed('developer');
            });

        mzNotice.show(context);
        // HACK 延时弹出，否则会因页面context不完整报错
        // Future.delayed(const Duration(seconds: 1), () async {
        //   await mzNotice.show(context);
        // });
      });
      deviceManagerChannel.autoFindWiFi();
    }

  }

}
