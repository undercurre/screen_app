import 'dart:async';

import '../../../../common/adapter/device_card_data_adapter.dart';

class _CurtainDataEntity {
  int curtainPosition;
  String curtainStatus;
  String curtainDirection;
  int onlineState;

  _CurtainDataEntity(
      {required this.curtainDirection,
      required this.curtainStatus,
      required this.curtainPosition,
      required this.onlineState});

  _CurtainDataEntity.fromMeiJu(dynamic data)
      : curtainPosition = 0,
        curtainStatus = 'stop',
        curtainDirection = 'positive',
        onlineState = 0;

  _CurtainDataEntity.fromHomlux(dynamic data)
      : curtainPosition = 0,
        curtainStatus = 'stop',
        curtainDirection = 'positive',
        onlineState = 0;

  _CurtainDataEntity.defaultState()
      : curtainPosition = 0,
        curtainStatus = 'stop',
        curtainDirection = 'positive',
        onlineState = 0;


  Map<String, dynamic> toJson() {
    return {
      'curtainPosition': curtainPosition,
      'curtainStatus': curtainStatus,
      'curtainDirection': curtainDirection,
      'onlineState': onlineState
    };
  }
}

class ZigbeeCurtainDataAdapter extends DeviceCardDataAdapter<_CurtainDataEntity> {
  String deviceName = 'zigbee窗帘';
  
  final String applianceCode;

  dynamic _meijuData;

  dynamic _homluxData;

  Timer? delayTimer;

  _CurtainDataEntity dataEntity = _CurtainDataEntity.defaultState();

  ZigbeeCurtainDataAdapter(super.platform, this.applianceCode);

}



