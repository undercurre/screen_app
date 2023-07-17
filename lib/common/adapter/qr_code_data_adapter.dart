import 'dart:async';
import 'dart:convert';

import 'package:screen_app/common/adapter/midea_data_adapter.dart';

import '../homlux/api/homlux_user_api.dart';
import '../homlux/generated/json/base/homlux_json_convert_content.dart';
import '../homlux/models/homlux_qr_code_entity.dart';
import '../homlux/models/homlux_response_entity.dart';
import '../logcat_helper.dart';
import '../meiju/api/meiju_user_api.dart';
import '../meiju/generated/json/base/meiju_json_convert_content.dart';
import '../meiju/models/meiju_qr_code_entity.dart';
import '../meiju/models/meiju_response_entity.dart';
import '../system.dart';

// 二维码数据封装层
class QRCodeEntity {
  // 二维码展示的内容
  late String qrcode;

  QRCodeEntity.fromHomlux(HomluxQrCodeEntity data) {
    _homluxData = data;
    qrcode = "https://web.meizgd.com/homlux/qrCode.html?mode=10&code=${data.qrcode}&modelId=${System.PRODUCT}";
  }

  QRCodeEntity.fromMeiJu(MeiJuQrCodeEntity data) {
    _meijuData = data;
    qrcode = "${data.shortUrl}?id=${System.PRODUCT}";
  }

  MeiJuQrCodeEntity? _meijuData;

  HomluxQrCodeEntity? _homluxData;

  /// 下面两方法对UI层的意义
  /// 提供 Json -> Object 之间切换
  /// 意义：方便对UI层的数据快速持久化
  factory QRCodeEntity.fromJson(Map<String, dynamic> json) {
    if (json['_homluxData'] != null) {
      return QRCodeEntity.fromHomlux(
          homluxJsonConvert.convert(json['homluxData']));
    } else if (json['_meijuData'] != null) {
      return QRCodeEntity.fromMeiJu(
          meijuJsonConvert.convert(json['_meijuData']));
    } else {
      throw UnimplementedError(
          "失败：fromJson解析QRCodeEntity失败 解析的数据为：${const JsonEncoder().convert(json)}");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "_homluxData": _homluxData?.toJson(),
      "_meijuData": _meijuData?.toJson()
    };
  }

  @override
  String toString() {
    return jsonEncode({
      "_homluxData": _homluxData?.toJson(),
      "_meijuData": _meijuData?.toJson(),
      "qrcode": qrcode
    });
  }

  dynamic get meijuData {
    return _meijuData;
  }

  dynamic get homluxData {
    return _homluxData;
  }

}

/// 二维码授权成功回调
typedef AuthQrCodeSucCallback = void Function();

/// 二维码数据适配层
class QRCodeDataAdapter extends MideaDataAdapter {

  QRCodeDataAdapter(super.platform);

  DataState qrCodeState = DataState.NONE;
  QRCodeEntity? qrCodeEntity;
  AuthQrCodeSucCallback? authQrCodeSucCallback;

  Timer? updateLoginStatusTime;
  Timer? updateQrCodeTime;

  /// ### 设置二维码授权成功回调
  void setAuthQrCodeSucCallback(AuthQrCodeSucCallback callback) {
    authQrCodeSucCallback = callback;
  }

  void requireQrCode() async {
    if (platform.inHomlux()) {
      qrCodeState = DataState.LONGING;
      HomluxResponseEntity<HomluxQrCodeEntity> code = await HomluxUserApi.queryQrCode();
      if (code.isSuccess && code.result != null) {
        qrCodeState = DataState.SUCCESS;
        qrCodeEntity = QRCodeEntity.fromHomlux(code.result!);
        updateQrCodeTime = Timer(const Duration(seconds: 3 * 60 - 20), () {
          requireQrCode();
        });
      } else {
        qrCodeState = DataState.ERROR;
      }

    } else if (platform.inMeiju()) {
      qrCodeState = DataState.LONGING;
      MeiJuResponseEntity<MeiJuQrCodeEntity> code = await MeiJuUserApi.queryQrCode();
      if (code.isSuccess && code.data != null) {
        qrCodeState = DataState.SUCCESS;
        qrCodeEntity = QRCodeEntity.fromMeiJu(code.data!);
        updateQrCodeTime = Timer(Duration(seconds: code.data!.effectTimeSecond! - 20), () {
          requireQrCode();
        });
      } else {
        qrCodeState = DataState.ERROR;
      }
    }
    updateUI();
  }

  /// ### 轮询查询授权状态接口
  void updateLoginStatus() async {
    var delaySec = 2; // 2s轮询间隔
    if (qrCodeEntity == null) {
      updateLoginStatusTime = Timer(Duration(seconds: delaySec), () {
        updateLoginStatus();
      });
      return;
    }

    if(platform.inMeiju()) {
      var res = await MeiJuUserApi.getAccessToken(qrCodeEntity?._meijuData?.sessionId ?? '');
      if (res.isSuccess && res.data != null) {
        updateQrCodeTime?.cancel(); // 取消登录状态查询定时
        Log.i('授权成功: ${res.toJson()}');
        authQrCodeSucCallback?.call();
      } else {
        updateLoginStatusTime = Timer(Duration(seconds: delaySec), () {
          updateLoginStatus();
        });
      }
    } else if(platform.inHomlux()) {
      var res = await HomluxUserApi.getAccessToken(qrCodeEntity?._homluxData?.qrcode ?? '');
      if(res.isSuccess && res.data?.authorizeStatus == 1) {
        updateQrCodeTime?.cancel(); // 取消登录状态查询定时
        Log.i('授权成功: ${res.toJson()}');
        authQrCodeSucCallback?.call();
      } else {
        updateLoginStatusTime = Timer(Duration(seconds: delaySec), () {
          updateLoginStatus();
        });
      }
    } else {
      throw Exception("No No No 异常调用");
    }
  }

  @override
  void destroy() {
    super.destroy();
    updateLoginStatusTime?.cancel();
    updateQrCodeTime?.cancel();
  }

}
