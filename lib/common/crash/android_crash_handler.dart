

import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:catcher/model/report_handler.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';

class AndroidCrashReportHandler extends ReportHandler {

  @override
  List<PlatformType> getSupportedPlatforms() {
    return [PlatformType.android];
  }

  @override
  Future<bool> handle(Report error, BuildContext? context) {
    buglyReportChannel.report(
        error.error.runtimeType.toString(),
        error.error.toString(),
        error.stackTrace as StackTrace?);
    return Future.value(true);
  }

}