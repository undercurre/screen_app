
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/models/homlux_device_auth_entity.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/meiju/api/meiju_device_api.dart';
import 'package:screen_app/common/meiju/models/auth_device_bath_entity.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:screen_app/states/device_list_notifier.dart';
import 'midea_data_adapter.dart';

enum AdapterType {
  unKnow,
  wifiLight,
  zigbeeLight,
  zigbeeLightSingle, //单调光灯
  lightGroup,
  wifiCurtain,
  air485,
  CRC485,
  floor485,
  panel,
  wifiAir,
  wifiYuba,
  wifiLiangyi,
  wifiDianre,
  wifiRanre,

}

/// 美居OrHomlux配置
///       添加需要确权的设备类型 （一般普通的wifi设备都需判断确权）
const NeedCheckWaitLockAuthTypes = [
  AdapterType.wifiLight,
  AdapterType.wifiCurtain,
  AdapterType.wifiAir,
  AdapterType.wifiYuba,
  AdapterType.wifiLiangyi,
  AdapterType.wifiDianre,
  AdapterType.wifiRanre


];

/// 适配卡片功能接口类，需要在具体品类数据适配器里选择性实现接口
abstract class DeviceCardDataAdapter<T> extends MideaDataAdapter {
  AdapterType type = AdapterType.unKnow;

  DeviceCardDataAdapter(super.platform);

  T? data;

  /// 设备确权状态
  /// true      已确权
  /// false     未确权
  bool? _auth;


  bool fetchOnlineState(BuildContext context, String deviceId) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
    return deviceListModel.getOnlineStatus(deviceId: deviceId);
  }

  Future<void> fetchDataAndCheckWaitLockAuth(String deviceId) async {
    // 只有确切知道未确权，才会去拦截设备详情请求
    // 在断网的情况下，并不会命中此处的逻辑
    bool? result = await checkWaitLockAuth(deviceId);
    if(result == false) {
      const meijuTip = "设备未确权，请在APP端进行设备确权";
      const homluxTip = "设备未确权，请在小程序端进行设备确权";
      TipsUtils.toast(content: platform.inMeiju() ? meijuTip : homluxTip);
      return;
    }
    fetchData();
  }

  /// 判断设备是否解锁 - 待确权状态
  /// 返回值
  ///      null  未查出异常 - 特指网络请求失败
  ///      false 未解锁
  ///      true  已解锁
  Future<bool?> checkWaitLockAuth(String deviceId) async {

    final need = NeedCheckWaitLockAuthTypes.any((element) => element == type);
    if(need && (_auth == null || _auth == false)) {
      if(platform.inMeiju()) {
        MeiJuResponseEntity<MeiJuAuthDeviceBatchEntity> response = await MeiJuDeviceApi.getAuthBatchStatus([deviceId]);
        if(response.isSuccess) {
          _auth = response.data?.applianceAuthList?.any((e) => e.status != 1 && e.status != 2);
          return _auth;
        }
      } else {
        final familyItem = System.familyInfo;
        if(familyItem != null) {
          HomluxResponseEntity<HomluxDeviceAuthEntity> response = await HomluxDeviceApi.getDeviceIsNeedCheck(deviceId, familyItem.familyId);
          if(response.isSuccess) {
            _auth = response.data?.status != 1 && response.data?.status != 2;
            return _auth;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<void> fetchData();

  /// 返回特定的状态属性，用于大卡片
  /// 例：return {"power": true, ... };
  Map<String, dynamic>? getCardStatus() {
    return null;
  }

  bool? getPowerStatus() {
    return null;
  }

  String? getCharacteristic() {
    return null;
  }

  /// 返回主要状态描述，用于小、中卡片
  String? getStatusDes() {
    return null;
  }

  String? getDeviceId() {
    return null;
  }

  /// 设备主开关
  Future<dynamic> power(bool? onOff) async {}

  /// 滑条1，滑动到value
  Future<dynamic> slider1To(int? value) async {}
  /// 滑条1，假赋值
  Future<dynamic> slider1ToFaker(int? value) async {}
  /// 滑条2，滑动到value
  Future<dynamic> slider2To(int? value) async {}
  /// 滑条2，假赋值
  Future<dynamic> slider2ToFaker(int? value) async {}

  /// 增加按钮，增加到value
  Future<dynamic> increaseTo(int? value) async {}
  /// 减少按钮，减少到value
  Future<dynamic> reduceTo(int? value) async {}

  /// 开关列表，面板设置第几路开关
  Future<dynamic> panelTo(int? index, int? onOff) async {}

  /// tab选择，窗帘选择动作
  Future<dynamic> tabTo(int? index) async {}

  /// 找一找
  Future<dynamic> tryOnce() async {}

  /// 模式卡
  Future<dynamic> modeControl(int index) async {}
}