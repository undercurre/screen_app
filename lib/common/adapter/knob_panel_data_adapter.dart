

import 'package:screen_app/common/adapter/device_card_data_adapter.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/models/homlux_device_entity.dart';

import '../../widgets/event_bus.dart';
import '../homlux/api/homlux_device_api.dart';
import '../homlux/models/homlux_response_entity.dart';
import '../homlux/push/event/homlux_push_event.dart';
import '../logcat_helper.dart';
import '../meiju/push/event/meiju_push_event.dart';

class DeviceDataEntity {
  bool power = false; //开关

  DeviceDataEntity.defaultData() {
    power = false;
  }

  DeviceDataEntity.fromMeiJu() {
    power = false;
  }

  DeviceDataEntity.fromHomlux(HomluxDeviceEntity data) {
    power = data.mzgdPropertyDTOList?.x1?.power == 1;
    Log.i('${data.deviceName}状态显示', power);
  }

}

class KnobPanelDataAdapter extends DeviceCardDataAdapter<DeviceDataEntity> {

  final String applianceCode;
  final String masterId;
  String nodeId = '';
  String modelNumber = '';

  HomluxDeviceEntity? _homluxData;

  static KnobPanelDataAdapter create(String applianceCode, String masterId, String modelNumber) {
    return KnobPanelDataAdapter(applianceCode, masterId, modelNumber, MideaRuntimePlatform.platform);
  }

  KnobPanelDataAdapter(this.applianceCode, this.masterId, this.modelNumber, super.platform) {
    data = DeviceDataEntity.defaultData();
  }


  @override
  void init() {
    super.init();
    _startPushListen();
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

  @override
  Future<void> fetchData() async {
    if(super.platform == GatewayPlatform.HOMLUX) {
      dataState = DataState.LOADING;
      updateUI();
      _homluxData = await fetchHomluxData();
      if(_homluxData == null) {
        dataState == DataState.ERROR;
        data = DeviceDataEntity.defaultData();
        updateUI();
      } else {
        dataState = DataState.SUCCESS;
        data = DeviceDataEntity.fromHomlux(_homluxData!);
        updateUI();
      }
    } else {
      /// debug环境下，提示报错信息
      assert((){
        throw UnimplementedError('美居平台还未存在旋钮面板');
      }());
      dataState = DataState.ERROR;
      data = DeviceDataEntity.fromMeiJu();
      updateUI();
    }
  }

  Future<HomluxDeviceEntity?> fetchHomluxData() async {
    HomluxDeviceEntity? nodeInfo;
    try {
      HomluxResponseEntity<HomluxDeviceEntity> nodeInfoRes = await HomluxDeviceApi.queryDeviceStatusByDeviceId(applianceCode);
      nodeInfo = nodeInfoRes.result;
    } catch (e) {
      Log.e(e);
    }
    if(nodeInfo == null && _homluxData != null) {
      nodeInfo = _homluxData;
    }
    return nodeInfo;
  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    if (args.nodeId == nodeId) {
      fetchData();
    }
  }

  void homluxPush(HomluxDevicePropertyChangeEvent arg) {
    if (arg.deviceInfo.eventData?.deviceId == applianceCode) {
      fetchData();
    }
  }

  void _startPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      Log.develop('$hashCode bind');
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush);
    } else {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      Log.develop('$hashCode unbind');
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush);
    } else {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  Future<void> fetchOrderPower(int PanelIndex) async {
    if (platform.inMeiju()) {
      assert((){
        throw UnimplementedError("还未实现该方法");
      }());
    } else {
      fetchOrderPowerHomlux(PanelIndex);
    }
  }

  Future<HomluxResponseEntity> fetchOrderPowerHomlux(int PanelIndex) async {
    data!.power = !data!.power;
    updateUI();
    HomluxResponseEntity HomluxRes = await HomluxDeviceApi.controlPanelOnOff(
        applianceCode,
        PanelIndex.toString(),
        masterId,
        data!.power ? 1 : 0);
    if (!HomluxRes.isSuccess) {
      data!.power = !data!.power;
      updateUI();
    }
    return HomluxRes;
  }

}