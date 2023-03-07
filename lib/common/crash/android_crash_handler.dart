

import 'dart:async';

import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:catcher/model/report_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/global.dart' as global;

class AndroidCrashReportHandler extends ReportHandler {

  @override
  List<PlatformType> getSupportedPlatforms() {
    return [PlatformType.android];
  }

  @override
  Future<bool> handle(Report error, BuildContext? context) {
    if(error.error is DioError) {
        global.logger.e(error.error);
    } else if(error.error is TimeoutException) {

    } else {
        buglyReportChannel.report(
        error.error.runtimeType.toString(),
        error.error.toString(),
        error.stackTrace as StackTrace?);
    }
    return Future.value(true);
  }

}