import 'package:catcher_2/mode/dialog_report_mode.dart';
import 'package:catcher_2/model/report.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/global.dart' as global;

class MzDialogReportMode extends DialogReportMode {

  @override
  void requestAction(Report report, BuildContext? context) {
    if(report.error is DioError) {
      global.logger.e(report.error);
    } else {
      super.requestAction(report, context);
    }
  }

}