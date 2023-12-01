
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
  wifiLiangyi
}

/// 适配卡片功能接口类，需要在具体品类数据适配器里选择性实现接口
abstract class DeviceCardDataAdapter<T> extends MideaDataAdapter {
  AdapterType type = AdapterType.unKnow;

  DeviceCardDataAdapter(super.platform);

  T? data;

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