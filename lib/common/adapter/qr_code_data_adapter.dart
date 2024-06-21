import 'dart:async';
import 'dart:convert';

import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';

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
    Log.i('二维码$qrcode');
  }

  QRCodeEntity.fromMeiJu(MeiJuQrCodeEntity data) {
    _meijuData = data;
    qrcode = "${data.shortUrl}?id=${System.PRODUCT}";
    Log.i('二维码$qrcode');
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

const networkErrorTip = "请检查您的网络";
const qrcodeInvalidTip = "二维码已失效";
/// 二维码数据适配层
class QRCodeDataAdapter extends MideaDataAdapter {
  QRCodeDataAdapter(super.platform);

  DataState qrCodeState = DataState.NONE;
  String errorTip = networkErrorTip;

  QRCodeEntity? qrCodeEntity;
  AuthQrCodeSucCallback? authQrCodeSucCallback;

  Timer? updateLoginStatusTime;
  bool authTokenState = false;

  /// ### 设置二维码授权成功回调
  void setAuthQrCodeSucCallback(AuthQrCodeSucCallback callback) {
    authQrCodeSucCallback = callback;
  }

  /// ### 请求二维码
  void requireQrCode() async {
    if (authTokenState) {
      Log.file('停止二维码活动');
      return;
    }
    if (platform.inHomlux()) {
      requireHomluxQrCode();
    } else if (platform.inMeiju()) {
      requireMeiJuQrCode();
    }
  }

  void requireHomluxQrCode() async {
    qrCodeState = DataState.LOADING;
    updateUI();
    try {
      HomluxResponseEntity<HomluxQrCodeEntity> code = await HomluxUserApi.queryQrCode();
      if (code.isSuccess && code.result != null) {
        qrCodeState = DataState.SUCCESS;
        qrCodeEntity = QRCodeEntity.fromHomlux(code.result!);
        _updateLoginStatus(3 * 60);
      } else {
        qrCodeState = DataState.ERROR;
        errorTip = networkErrorTip;
      }
    } catch (e) {
      Log.e(e);
      qrCodeState = DataState.ERROR;
      errorTip = networkErrorTip;
    }
    updateUI();
  }

  void requireMeiJuQrCode() async {
    qrCodeState = DataState.LOADING;
    updateUI();
    try {
      MeiJuResponseEntity<MeiJuQrCodeEntity> code = await MeiJuUserApi.queryQrCode();
      if (code.isSuccess && code.data != null) {
        qrCodeState = DataState.SUCCESS;
        qrCodeEntity = QRCodeEntity.fromMeiJu(code.data!);
        _updateLoginStatus(code.data!.effectTimeSecond!);
      } else {
        qrCodeState = DataState.ERROR;
        errorTip = networkErrorTip;
      }
    } catch (e) {
      qrCodeState = DataState.ERROR;
      errorTip = networkErrorTip;
      Log.e(e);
    }
    updateUI();
  }



  /// ### 轮询查询授权状态接口
  void _updateLoginStatus(int second) async {
    if (authTokenState) {
      Log.file('停止二维码活动1');
      return;
    }
    int tempSecond = second;
    updateLoginStatusTime?.cancel();
    updateLoginStatusTime = Timer.periodic(const Duration(seconds: 2) , (timer) async {
      tempSecond -= 2;

      if(tempSecond == 0 || authTokenState) {
        Log.file('停止轮询二维码状态');
        updateLoginStatusTime?.cancel();
        qrCodeState = DataState.ERROR;
        errorTip = qrcodeInvalidTip;
        updateUI();
        return;
      } else if(platform.inMeiju() && MeiJuGlobal.token != null) {
        // 补丁 - 出现已经授权成功。但是二维码还继续轮询问题
        Log.file('停止二维码活动2');
        updateLoginStatusTime?.cancel();
        return;
      } else if(platform.inHomlux() && HomluxGlobal.homluxQrCodeAuthEntity != null) {
        // 补丁 - 出现已经授权成功。但是二维码还继续轮询问题
        Log.file('停止二维码活动3');
        updateLoginStatusTime?.cancel();
        return;
      }

      if (platform.inMeiju()) {
        _loopMeiJuLoginStatus();
      } else {
        _loopHomluxLoginStatus();
      }
    });

  }

  Future<void> _loopMeiJuLoginStatus() async {
    try {
      var res = await MeiJuUserApi.getAccessToken(
          qrCodeEntity?._meijuData?.sessionId ?? '');
      if (res.isSuccess && res.data != null) {
        updateLoginStatusTime?.cancel(); // 取消状态轮询定时
        Log.i('美居授权成功: ${res.toJson()}');
        authQrCodeSucCallback?.call();
        // 自动保存登录Token
        MeiJuGlobal.token = res.data;
        authTokenState = true;
      }
    } catch (e) {
       Log.e(e);
    }
  }

  Future<void> _loopHomluxLoginStatus() async {
    try {
      var res = await HomluxUserApi.getAccessToken(qrCodeEntity?._homluxData?.qrcode ?? '');
      if (res.isSuccess && res.data?.authorizeStatus == 1) {
        updateLoginStatusTime?.cancel(); // 取消状态轮询定时
        Log.i('Homlux授权成功: ${res.toJson()}');
        authQrCodeSucCallback?.call();
        // 自动保存登录Token
        HomluxGlobal.homluxQrCodeAuthEntity = res.data;
        authTokenState = true;
      }
    } catch(e) {
      Log.e(e);
    }
  }

  @override
  void destroy() {
    super.destroy();
    Log.file('停止二维码活动');
    updateLoginStatusTime?.cancel();
  }

}
