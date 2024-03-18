import 'dart:ui';

import 'package:screen_app/common/homlux/models/homlux_device_entity.dart';

import '../generated/json/base/homlux_json_convert_content.dart';

HomluxDeviceEntity $HomluxDeviceEntityFromJson(Map<String, dynamic> json) {
	final HomluxDeviceEntity homluxDeviceEntity = HomluxDeviceEntity();
	final String? deviceName = homluxJsonConvert.convert<String>(json['deviceName']);
	if (deviceName != null) {
		homluxDeviceEntity.deviceName = deviceName;
	}
	final String? pic = homluxJsonConvert.convert<String>(json['pic']);
	if (pic != null) {
		homluxDeviceEntity.pic = pic;
	}
	final String? deviceId = homluxJsonConvert.convert<String>(json['deviceId']);
	if (deviceId != null) {
		homluxDeviceEntity.deviceId = deviceId;
	}
	final String? roomName = homluxJsonConvert.convert<String>(json['roomName']);
	if (roomName != null) {
		homluxDeviceEntity.roomName = roomName;
	}
	final String? roomId = homluxJsonConvert.convert<String>(json['roomId']);
	if (roomId != null) {
		homluxDeviceEntity.roomId = roomId;
	}
	final String? gatewayName = homluxJsonConvert.convert<String>(json['gatewayName']);
	if (gatewayName != null) {
		homluxDeviceEntity.gatewayName = gatewayName;
	}
	final String? gatewayId = homluxJsonConvert.convert<String>(json['gatewayId']);
	if (gatewayId != null) {
		homluxDeviceEntity.gatewayId = gatewayId;
	}
	final String? version = homluxJsonConvert.convert<String>(json['version']);
	if (version != null) {
		homluxDeviceEntity.version = version;
	}
	final int? deviceType = homluxJsonConvert.convert<int>(json['deviceType']);
	if (deviceType != null) {
		homluxDeviceEntity.deviceType = deviceType;
	}
	final String? proType = homluxJsonConvert.convert<String>(json['proType']);
	if (proType != null) {
		homluxDeviceEntity.proType = proType;
	}
	final int? updateStamp = homluxJsonConvert.convert<int>(json['updateStamp']);
	if (proType != null) {
		homluxDeviceEntity.updateStamp = updateStamp;
	}
	final List<HomluxDeviceSwitchInfoDTOList>? switchInfoDTOList = homluxJsonConvert.convertListNotNull<HomluxDeviceSwitchInfoDTOList>(json['switchInfoDTOList']);
	if (switchInfoDTOList != null) {
		homluxDeviceEntity.switchInfoDTOList = switchInfoDTOList;
	}
	final HomluxDeviceMzgdPropertyDTOList? mzgdPropertyDTOList = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList>(json['mzgdPropertyDTOList']);
	if (mzgdPropertyDTOList != null) {
		homluxDeviceEntity.mzgdPropertyDTOList = mzgdPropertyDTOList;
	}
	final dynamic methodList = homluxJsonConvert.convert<dynamic>(json['methodList']);
	if (methodList != null) {
		homluxDeviceEntity.methodList = methodList;
	}
	final int? onLineStatus = homluxJsonConvert.convert<int>(json['onLineStatus']);
	if (onLineStatus != null) {
		homluxDeviceEntity.onLineStatus = onLineStatus;
	}
	final int? orderNum = homluxJsonConvert.convert<int>(json['orderNum']);
	if (orderNum != null) {
		homluxDeviceEntity.orderNum = orderNum;
	}
	final String? sn = homluxJsonConvert.convert<String>(json['sn']);
	if (sn != null) {
		homluxDeviceEntity.sn = sn;
	}
	final String? lightRelId = homluxJsonConvert.convert<String>(json['lightRelId']);
	if (lightRelId != null) {
		homluxDeviceEntity.lightRelId = lightRelId;
	}
	final String? productId = homluxJsonConvert.convert<String>(json['productId']);
	if (productId != null) {
		homluxDeviceEntity.productId = productId;
	}
	return homluxDeviceEntity;
}

Map<String, dynamic> $HomluxDeviceEntityToJson(HomluxDeviceEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['deviceName'] = entity.deviceName;
	data['pic'] = entity.pic;
	data['deviceId'] = entity.deviceId;
	data['roomName'] = entity.roomName;
	data['roomId'] = entity.roomId;
	data['gatewayName'] = entity.gatewayName;
	data['gatewayId'] = entity.gatewayId;
	data['version'] = entity.version;
	data['deviceType'] = entity.deviceType;
	data['proType'] = entity.proType;
	data['switchInfoDTOList'] =  entity.switchInfoDTOList?.map((v) => v.toJson()).toList();
	data['mzgdPropertyDTOList'] = entity.mzgdPropertyDTOList?.toJson();
	data['methodList'] = entity.methodList;
	data['onLineStatus'] = entity.onLineStatus;
	data['orderNum'] = entity.orderNum;
	data['sn'] = entity.sn;
	data['lightRelId'] = entity.lightRelId;
	data['productId'] = entity.productId;
	data['updateStamp'] = entity.updateStamp;
	return data;
}

HomluxDeviceSwitchInfoDTOList $HomluxDeviceSwitchInfoDTOListFromJson(Map<String, dynamic> json) {
	final HomluxDeviceSwitchInfoDTOList homluxDeviceSwitchInfoDTOList = HomluxDeviceSwitchInfoDTOList();
	final String? switchId = homluxJsonConvert.convert<String>(json['switchId']);
	if (switchId != null) {
		homluxDeviceSwitchInfoDTOList.switchId = switchId;
	}
	final String? panelId = homluxJsonConvert.convert<String>(json['panelId']);
	if (panelId != null) {
		homluxDeviceSwitchInfoDTOList.panelId = panelId;
	}
	final String? switchName = homluxJsonConvert.convert<String>(json['switchName']);
	if (switchName != null) {
		homluxDeviceSwitchInfoDTOList.switchName = switchName;
	}
	final String? houseId = homluxJsonConvert.convert<String>(json['houseId']);
	if (houseId != null) {
		homluxDeviceSwitchInfoDTOList.houseId = houseId;
	}
	final String? roomId = homluxJsonConvert.convert<String>(json['roomId']);
	if (roomId != null) {
		homluxDeviceSwitchInfoDTOList.roomId = roomId;
	}
	final String? roomName = homluxJsonConvert.convert<String>(json['roomName']);
	if (roomName != null) {
		homluxDeviceSwitchInfoDTOList.roomName = roomName;
	}
	final String? pic = homluxJsonConvert.convert<String>(json['pic']);
	if (pic != null) {
		homluxDeviceSwitchInfoDTOList.pic = pic;
	}
	final String? switchRelId = homluxJsonConvert.convert<String>(json['switchRelId']);
	if (switchRelId != null) {
		homluxDeviceSwitchInfoDTOList.switchRelId = switchRelId;
	}
	final int? orderNum = homluxJsonConvert.convert<int>(json['orderNum']);
	if (orderNum != null) {
		homluxDeviceSwitchInfoDTOList.orderNum = orderNum;
	}
	final String? lightRelId = homluxJsonConvert.convert<String>(json['lightRelId']);
	if (lightRelId != null) {
		homluxDeviceSwitchInfoDTOList.lightRelId = lightRelId;
	}
	return homluxDeviceSwitchInfoDTOList;
}

Map<String, dynamic> $HomluxDeviceSwitchInfoDTOListToJson(HomluxDeviceSwitchInfoDTOList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['switchId'] = entity.switchId;
	data['panelId'] = entity.panelId;
	data['switchName'] = entity.switchName;
	data['houseId'] = entity.houseId;
	data['roomId'] = entity.roomId;
	data['roomName'] = entity.roomName;
	data['pic'] = entity.pic;
	data['switchRelId'] = entity.switchRelId;
	data['orderNum'] = entity.orderNum;
	data['lightRelId'] = entity.lightRelId;
	return data;
}

HomluxDeviceMzgdPropertyDTOList $HomluxDeviceMzgdPropertyDTOListFromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList homluxDeviceMzgdPropertyDTOList = HomluxDeviceMzgdPropertyDTOList();
	final HomluxDeviceMzgdPropertyDTOList1? x1 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList1>(json['wallSwitch1']);
	if (x1 != null) {
		homluxDeviceMzgdPropertyDTOList.x1 = x1;
	}
	final HomluxDeviceMzgdPropertyDTOList2? x2 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList2>(json['wallSwitch2']);
	if (x2 != null) {
		homluxDeviceMzgdPropertyDTOList.x2 = x2;
	}
	final HomluxDeviceMzgdPropertyDTOList3? x3 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList3>(json['wallSwitch3']);
	if (x3 != null) {
		homluxDeviceMzgdPropertyDTOList.x3 = x3;
	}
	final HomluxDeviceMzgdPropertyDTOList4? x4 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList4>(json['wallSwitch4']);
	if (x4 != null) {
		homluxDeviceMzgdPropertyDTOList.x4 = x4;
	}
	final HomluxDeviceMzgdPropertyDTOListLight? light = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListLight>(json['light']);
	if (light != null) {
		homluxDeviceMzgdPropertyDTOList.light = light;
	}
	final HomluxDeviceMzgdPropertyDTOListCurtain? curtain = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListCurtain>(json['curtain']);
	if (curtain != null) {
		homluxDeviceMzgdPropertyDTOList.curtain = curtain;
	}
	final HomluxDeviceMzgdPropertyDTOListBathHeat? bathHeat = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListBathHeat>(json['bathHeat']);
	if (bathHeat != null) {
		homluxDeviceMzgdPropertyDTOList.bathHeat = bathHeat;
	}
	/// 云端同名的json对象中包含字段相同，值的类型不同

	/// 普通空调
	try {
		final HomluxDeviceMzgdPropertyDTOListAirCondition? airCondition = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListAirCondition>(json['airConditioner']);
		if (airCondition != null) {
			homluxDeviceMzgdPropertyDTOList.airCondition = airCondition;
		}
	} catch(e, s){}

	/// 485空调
	try {
		final HomluxDeviceMzgdPropertyDTOListAir? airConditioner = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListAir>(json['airConditioner']);
		if (airConditioner != null) {
			homluxDeviceMzgdPropertyDTOList.air485Conditioner = airConditioner;
		}
	} catch(e ,s) {}

	final HomluxDeviceMzgdPropertyDTOListClothesDryingRack? clothesDryingRack = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListClothesDryingRack>(json['clothesDryingRack']);
	if (clothesDryingRack != null) {
		homluxDeviceMzgdPropertyDTOList.clothesDryingRack = clothesDryingRack;
	}
	final HomluxDeviceMzgdPropertyDTOListFreshAir? freshAir = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListFreshAir>(json['freshAir']);
	if (freshAir != null) {
		homluxDeviceMzgdPropertyDTOList.freshAir = freshAir;
	}
	final HomluxDeviceMzgdPropertyDTOListFloorHeating? floorHeating = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOListFloorHeating>(json['floorHeating']);
	if (floorHeating != null) {
		homluxDeviceMzgdPropertyDTOList.floorHeating = floorHeating;
	}
	return homluxDeviceMzgdPropertyDTOList;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListToJson(HomluxDeviceMzgdPropertyDTOList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['wallSwitch1'] = entity.x1?.toJson();
	data['wallSwitch2'] = entity.x2?.toJson();
	data['wallSwitch3'] = entity.x3?.toJson();
	data['wallSwitch4'] = entity.x4?.toJson();
	data['light'] = entity.light?.toJson();
	data['curtain'] = entity.curtain?.toJson();
	data['bathHeat'] = entity.bathHeat?.toJson();
	data['airConditioner'] = entity.airCondition?.toJson();
	data['clothesDryingRack'] = entity.clothesDryingRack?.toJson();
	data['floorHeating'] = entity.floorHeating?.toJson();
	data['airConditioner'] = entity.air485Conditioner?.toJson();
	data['freshAir'] = entity.freshAir?.toJson();
	return data;
}

HomluxDeviceMzgdPropertyDTOList1 $HomluxDeviceMzgdPropertyDTOList1FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList1 homluxDeviceMzgdPropertyDTOList1 = HomluxDeviceMzgdPropertyDTOList1();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['buttonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList1.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['buttonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList1.buttonMode = buttonMode;
	}
	final int? power = homluxJsonConvert.convert<int>(json['power']);
	if (power != null) {
		homluxDeviceMzgdPropertyDTOList1.power = power;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList1.startUpOnOff = startUpOnOff;
	}
	final int? colorTemperature = homluxJsonConvert.convert<int>(json['colorTemperature']);
	if (colorTemperature != null) {
		homluxDeviceMzgdPropertyDTOList1.colorTemperature = colorTemperature;
	}
	final int? brightness = homluxJsonConvert.convert<int>(json['brightness']);
	if (brightness != null) {
		homluxDeviceMzgdPropertyDTOList1.brightness = brightness;
	}
	final int? duration = homluxJsonConvert.convert<int>(json['Duration']);
	if (duration != null) {
		homluxDeviceMzgdPropertyDTOList1.duration = duration;
	}
	final int? bcReportTime = homluxJsonConvert.convert<int>(json['BcReportTime']);
	if (bcReportTime != null) {
		homluxDeviceMzgdPropertyDTOList1.bcReportTime = bcReportTime;
	}
	final int? delayClose = homluxJsonConvert.convert<int>(json['DelayClose']);
	if (delayClose != null) {
		homluxDeviceMzgdPropertyDTOList1.delayClose = delayClose;
	}
	final String? curtainPosition = homluxJsonConvert.convert<String>(json['curtain_position']);
	if (curtainPosition != null) {
		homluxDeviceMzgdPropertyDTOList1.curtainPosition = curtainPosition;
	}
	final String? curtainStatus = homluxJsonConvert.convert<String>(json['curtain_status']);
	if (curtainStatus != null) {
		homluxDeviceMzgdPropertyDTOList1.curtainStatus = curtainStatus;
	}
	final String? curtainDirection = homluxJsonConvert.convert<String>(json['curtain_direction']);
	if (curtainDirection != null) {
		homluxDeviceMzgdPropertyDTOList1.curtainDirection = curtainDirection;
	}
	final String? wifiLightPower = homluxJsonConvert.convert<String>(json['power']);
	if (wifiLightPower != null) {
		homluxDeviceMzgdPropertyDTOList1.wifiLightPower = wifiLightPower;
	}
	final String? wifiLightDelayOff = homluxJsonConvert.convert<String>(json['delay_light_off']);
	if (wifiLightDelayOff != null) {
		homluxDeviceMzgdPropertyDTOList1.wifiLightDelayOff = wifiLightDelayOff;
	}
	final String? wifiLightScene = homluxJsonConvert.convert<String>(json['scene_light']);
	if (wifiLightScene != null) {
		homluxDeviceMzgdPropertyDTOList1.wifiLightScene = wifiLightScene;
	}
	return homluxDeviceMzgdPropertyDTOList1;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList1ToJson(HomluxDeviceMzgdPropertyDTOList1 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['buttonScene'] = entity.buttonScene;
	data['buttonMode'] = entity.buttonMode;
	data['power'] = entity.power;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['ColorTemp'] = entity.colorTemperature;
	data['brightness'] = entity.brightness;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	data['power'] = entity.wifiLightPower;
	data['delay_light_off'] = entity.wifiLightDelayOff;
	data['scene_light'] = entity.wifiLightScene;
	return data;
}

HomluxDeviceMzgdPropertyDTOList2 $HomluxDeviceMzgdPropertyDTOList2FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList2 homluxDeviceMzgdPropertyDTOList2 = HomluxDeviceMzgdPropertyDTOList2();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['buttonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList2.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['buttonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList2.buttonMode = buttonMode;
	}
	final int? power = homluxJsonConvert.convert<int>(json['power']);
	if (power != null) {
		homluxDeviceMzgdPropertyDTOList2.power = power;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList2.startUpOnOff = startUpOnOff;
	}
	final int? colorTemperature = homluxJsonConvert.convert<int>(json['colorTemperature']);
	if (colorTemperature != null) {
		homluxDeviceMzgdPropertyDTOList2.colorTemperature = colorTemperature;
	}
	final int? brightness = homluxJsonConvert.convert<int>(json['brightness']);
	if (brightness != null) {
		homluxDeviceMzgdPropertyDTOList2.brightness = brightness;
	}
	final int? duration = homluxJsonConvert.convert<int>(json['Duration']);
	if (duration != null) {
		homluxDeviceMzgdPropertyDTOList2.duration = duration;
	}
	final int? bcReportTime = homluxJsonConvert.convert<int>(json['BcReportTime']);
	if (bcReportTime != null) {
		homluxDeviceMzgdPropertyDTOList2.bcReportTime = bcReportTime;
	}
	final int? delayClose = homluxJsonConvert.convert<int>(json['DelayClose']);
	if (delayClose != null) {
		homluxDeviceMzgdPropertyDTOList2.delayClose = delayClose;
	}
	final String? curtainPosition = homluxJsonConvert.convert<String>(json['curtain_position']);
	if (curtainPosition != null) {
		homluxDeviceMzgdPropertyDTOList2.curtainPosition = curtainPosition;
	}
	final String? curtainStatus = homluxJsonConvert.convert<String>(json['curtain_status']);
	if (curtainStatus != null) {
		homluxDeviceMzgdPropertyDTOList2.curtainStatus = curtainStatus;
	}
	final String? curtainDirection = homluxJsonConvert.convert<String>(json['curtain_direction']);
	if (curtainDirection != null) {
		homluxDeviceMzgdPropertyDTOList2.curtainDirection = curtainDirection;
	}
	final String? wifiLightPower = homluxJsonConvert.convert<String>(json['power']);
	if (wifiLightPower != null) {
		homluxDeviceMzgdPropertyDTOList2.wifiLightPower = wifiLightPower;
	}
	final String? wifiLightDelayOff = homluxJsonConvert.convert<String>(json['delay_light_off']);
	if (wifiLightDelayOff != null) {
		homluxDeviceMzgdPropertyDTOList2.wifiLightDelayOff = wifiLightDelayOff;
	}
	final String? wifiLightScene = homluxJsonConvert.convert<String>(json['scene_light']);
	if (wifiLightScene != null) {
		homluxDeviceMzgdPropertyDTOList2.wifiLightScene = wifiLightScene;
	}
	return homluxDeviceMzgdPropertyDTOList2;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList2ToJson(HomluxDeviceMzgdPropertyDTOList2 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['buttonScene'] = entity.buttonScene;
	data['buttonMode'] = entity.buttonMode;
	data['power'] = entity.power;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['colorTemperature'] = entity.colorTemperature;
	data['brightness'] = entity.brightness;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	data['power'] = entity.wifiLightPower;
	data['delay_light_off'] = entity.wifiLightDelayOff;
	data['scene_light'] = entity.wifiLightScene;
	return data;
}

HomluxDeviceMzgdPropertyDTOList3 $HomluxDeviceMzgdPropertyDTOList3FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList3 homluxDeviceMzgdPropertyDTOList3 = HomluxDeviceMzgdPropertyDTOList3();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['buttonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList3.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['buttonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList3.buttonMode = buttonMode;
	}
	final int? power = homluxJsonConvert.convert<int>(json['power']);
	if (power != null) {
		homluxDeviceMzgdPropertyDTOList3.power = power;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList3.startUpOnOff = startUpOnOff;
	}
	final int? colorTemperature = homluxJsonConvert.convert<int>(json['colorTemperature']);
	if (colorTemperature != null) {
		homluxDeviceMzgdPropertyDTOList3.colorTemperature = colorTemperature;
	}
	final int? brightness = homluxJsonConvert.convert<int>(json['brightness']);
	if (brightness != null) {
		homluxDeviceMzgdPropertyDTOList3.brightness = brightness;
	}
	final int? duration = homluxJsonConvert.convert<int>(json['Duration']);
	if (duration != null) {
		homluxDeviceMzgdPropertyDTOList3.duration = duration;
	}
	final int? bcReportTime = homluxJsonConvert.convert<int>(json['BcReportTime']);
	if (bcReportTime != null) {
		homluxDeviceMzgdPropertyDTOList3.bcReportTime = bcReportTime;
	}
	final int? delayClose = homluxJsonConvert.convert<int>(json['DelayClose']);
	if (delayClose != null) {
		homluxDeviceMzgdPropertyDTOList3.delayClose = delayClose;
	}
	final String? curtainPosition = homluxJsonConvert.convert<String>(json['curtain_position']);
	if (curtainPosition != null) {
		homluxDeviceMzgdPropertyDTOList3.curtainPosition = curtainPosition;
	}
	final String? curtainStatus = homluxJsonConvert.convert<String>(json['curtain_status']);
	if (curtainStatus != null) {
		homluxDeviceMzgdPropertyDTOList3.curtainStatus = curtainStatus;
	}
	final String? curtainDirection = homluxJsonConvert.convert<String>(json['curtain_direction']);
	if (curtainDirection != null) {
		homluxDeviceMzgdPropertyDTOList3.curtainDirection = curtainDirection;
	}
	final String? wifiLightPower = homluxJsonConvert.convert<String>(json['power']);
	if (wifiLightPower != null) {
		homluxDeviceMzgdPropertyDTOList3.wifiLightPower = wifiLightPower;
	}
	final String? wifiLightDelayOff = homluxJsonConvert.convert<String>(json['delay_light_off']);
	if (wifiLightDelayOff != null) {
		homluxDeviceMzgdPropertyDTOList3.wifiLightDelayOff = wifiLightDelayOff;
	}
	final String? wifiLightScene = homluxJsonConvert.convert<String>(json['scene_light']);
	if (wifiLightScene != null) {
		homluxDeviceMzgdPropertyDTOList3.wifiLightScene = wifiLightScene;
	}
	return homluxDeviceMzgdPropertyDTOList3;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList3ToJson(HomluxDeviceMzgdPropertyDTOList3 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['buttonScene'] = entity.buttonScene;
	data['buttonMode'] = entity.buttonMode;
	data['power'] = entity.power;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['colorTemperature'] = entity.colorTemperature;
	data['brightness'] = entity.brightness;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	data['power'] = entity.wifiLightPower;
	data['delay_light_off'] = entity.wifiLightDelayOff;
	data['scene_light'] = entity.wifiLightScene;
	return data;
}

HomluxDeviceMzgdPropertyDTOList4 $HomluxDeviceMzgdPropertyDTOList4FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList4 homluxDeviceMzgdPropertyDTOList4 = HomluxDeviceMzgdPropertyDTOList4();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['buttonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList4.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['buttonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList4.buttonMode = buttonMode;
	}
	final int? power = homluxJsonConvert.convert<int>(json['power']);
	if (power != null) {
		homluxDeviceMzgdPropertyDTOList4.power = power;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList4.startUpOnOff = startUpOnOff;
	}
	final int? colorTemperature = homluxJsonConvert.convert<int>(json['colorTemperature']);
	if (colorTemperature != null) {
		homluxDeviceMzgdPropertyDTOList4.colorTemperature = colorTemperature;
	}
	final int? brightness = homluxJsonConvert.convert<int>(json['brightness']);
	if (brightness != null) {
		homluxDeviceMzgdPropertyDTOList4.brightness = brightness;
	}
	final int? duration = homluxJsonConvert.convert<int>(json['Duration']);
	if (duration != null) {
		homluxDeviceMzgdPropertyDTOList4.duration = duration;
	}
	final int? bcReportTime = homluxJsonConvert.convert<int>(json['BcReportTime']);
	if (bcReportTime != null) {
		homluxDeviceMzgdPropertyDTOList4.bcReportTime = bcReportTime;
	}
	final int? delayClose = homluxJsonConvert.convert<int>(json['DelayClose']);
	if (delayClose != null) {
		homluxDeviceMzgdPropertyDTOList4.delayClose = delayClose;
	}
	final String? curtainPosition = homluxJsonConvert.convert<String>(json['curtain_position']);
	if (curtainPosition != null) {
		homluxDeviceMzgdPropertyDTOList4.curtainPosition = curtainPosition;
	}
	final String? curtainStatus = homluxJsonConvert.convert<String>(json['curtain_status']);
	if (curtainStatus != null) {
		homluxDeviceMzgdPropertyDTOList4.curtainStatus = curtainStatus;
	}
	final String? curtainDirection = homluxJsonConvert.convert<String>(json['curtain_direction']);
	if (curtainDirection != null) {
		homluxDeviceMzgdPropertyDTOList4.curtainDirection = curtainDirection;
	}
	final String? wifiLightPower = homluxJsonConvert.convert<String>(json['power']);
	if (wifiLightPower != null) {
		homluxDeviceMzgdPropertyDTOList4.wifiLightPower = wifiLightPower;
	}
	final String? wifiLightDelayOff = homluxJsonConvert.convert<String>(json['delay_light_off']);
	if (wifiLightDelayOff != null) {
		homluxDeviceMzgdPropertyDTOList4.wifiLightDelayOff = wifiLightDelayOff;
	}
	final String? wifiLightScene = homluxJsonConvert.convert<String>(json['scene_light']);
	if (wifiLightScene != null) {
		homluxDeviceMzgdPropertyDTOList4.wifiLightScene = wifiLightScene;
	}
	return homluxDeviceMzgdPropertyDTOList4;
}

HomluxColorTempRange $HomluxColorTempRangeFromJson(Map<String, dynamic> json) {
	HomluxColorTempRange range = HomluxColorTempRange();
	range.maxColorTemp = homluxJsonConvert.convert<int>(json["maxColorTemp"]);
	range.minColorTemp = homluxJsonConvert.convert<int>(json["minColorTemp"]);
	return range;
}

Map<String, dynamic> $HomluxColorTempRangeToJson(HomluxColorTempRange range) {
	return {
		"maxColorTemp": range.maxColorTemp,
		"minColorTemp": range.minColorTemp,
	};
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList4ToJson(HomluxDeviceMzgdPropertyDTOList4 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['buttonScene'] = entity.buttonScene;
	data['buttonMode'] = entity.buttonMode;
	data['power'] = entity.power;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['colorTemperature'] = entity.colorTemperature;
	data['brightness'] = entity.brightness;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	data['power'] = entity.wifiLightPower;
	data['delay_light_off'] = entity.wifiLightDelayOff;
	data['scene_light'] = entity.wifiLightScene;
	return data;
}

HomluxDeviceMzgdPropertyDTOListLight $HomluxDeviceMzgdPropertyDTOListLightFromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOListLight homluxDeviceMzgdPropertyDTOListLight = HomluxDeviceMzgdPropertyDTOListLight();

	final HomluxColorTempRange? colorTempRange = homluxJsonConvert.convert<HomluxColorTempRange>(json['colorTempRange']);
	if (colorTempRange != null) {
		homluxDeviceMzgdPropertyDTOListLight.colorTempRange = colorTempRange;
	}
	final int? buttonScene = homluxJsonConvert.convert<int>(json['buttonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOListLight.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['buttonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOListLight.buttonMode = buttonMode;
	}
	final int? power = homluxJsonConvert.convert<int>(json['power']);
	if (power != null) {
		homluxDeviceMzgdPropertyDTOListLight.power = power;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOListLight.startUpOnOff = startUpOnOff;
	}
	final int? colorTemperature = homluxJsonConvert.convert<int>(json['colorTemperature']);
	if (colorTemperature != null) {
		homluxDeviceMzgdPropertyDTOListLight.colorTemperature = colorTemperature;
	}
	final int? brightness = homluxJsonConvert.convert<int>(json['brightness']);
	if (brightness != null) {
		homluxDeviceMzgdPropertyDTOListLight.brightness = brightness;
	}
	final int? duration = homluxJsonConvert.convert<int>(json['Duration']);
	if (duration != null) {
		homluxDeviceMzgdPropertyDTOListLight.duration = duration;
	}
	final int? bcReportTime = homluxJsonConvert.convert<int>(json['BcReportTime']);
	if (bcReportTime != null) {
		homluxDeviceMzgdPropertyDTOListLight.bcReportTime = bcReportTime;
	}
	final int? delayClose = homluxJsonConvert.convert<int>(json['DelayClose']);
	if (delayClose != null) {
		homluxDeviceMzgdPropertyDTOListLight.delayClose = delayClose;
	}
	final String? curtainPosition = homluxJsonConvert.convert<String>(json['curtain_position']);
	if (curtainPosition != null) {
		homluxDeviceMzgdPropertyDTOListLight.curtainPosition = curtainPosition;
	}
	final String? curtainStatus = homluxJsonConvert.convert<String>(json['curtain_status']);
	if (curtainStatus != null) {
		homluxDeviceMzgdPropertyDTOListLight.curtainStatus = curtainStatus;
	}
	final String? curtainDirection = homluxJsonConvert.convert<String>(json['curtain_direction']);
	if (curtainDirection != null) {
		homluxDeviceMzgdPropertyDTOListLight.curtainDirection = curtainDirection;
	}
	final String? wifiLightPower = homluxJsonConvert.convert<String>(json['power']);
	if (wifiLightPower != null) {
		homluxDeviceMzgdPropertyDTOListLight.wifiLightPower = wifiLightPower;
	}
	final String? wifiLightDelayOff = homluxJsonConvert.convert<String>(json['delay_light_off']);
	if (wifiLightDelayOff != null) {
		homluxDeviceMzgdPropertyDTOListLight.wifiLightDelayOff = wifiLightDelayOff;
	}
	final String? wifiLightScene = homluxJsonConvert.convert<String>(json['scene_light']);
	if (wifiLightScene != null) {
		homluxDeviceMzgdPropertyDTOListLight.wifiLightScene = wifiLightScene;
	}
	return homluxDeviceMzgdPropertyDTOListLight;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListLightToJson(HomluxDeviceMzgdPropertyDTOListLight entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['buttonScene'] = entity.buttonScene;
	data['buttonMode'] = entity.buttonMode;
	data['power'] = entity.power;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['colorTemperature'] = entity.colorTemperature;
	data['brightness'] = entity.brightness;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	data['colorTempRange'] = entity.colorTempRange?.toJson();
	data['power'] = entity.wifiLightPower;
	data['delay_light_off'] = entity.wifiLightDelayOff;
	data['scene_light'] = entity.wifiLightScene;
	return data;
}

HomluxDeviceMzgdPropertyDTOListCurtain $HomluxDeviceMzgdPropertyDTOListCurtainFromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOListCurtain homluxDeviceMzgdPropertyDTOListCurtain = HomluxDeviceMzgdPropertyDTOListCurtain();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['buttonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['buttonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.buttonMode = buttonMode;
	}
	final int? power = homluxJsonConvert.convert<int>(json['power']);
	if (power != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.power = power;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.startUpOnOff = startUpOnOff;
	}
	final int? colorTemperature = homluxJsonConvert.convert<int>(json['colorTemperature']);
	if (colorTemperature != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.colorTemperature = colorTemperature;
	}
	final int? brightness = homluxJsonConvert.convert<int>(json['brightness']);
	if (brightness != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.brightness = brightness;
	}
	final int? duration = homluxJsonConvert.convert<int>(json['Duration']);
	if (duration != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.duration = duration;
	}
	final int? bcReportTime = homluxJsonConvert.convert<int>(json['BcReportTime']);
	if (bcReportTime != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.bcReportTime = bcReportTime;
	}
	final int? delayClose = homluxJsonConvert.convert<int>(json['DelayClose']);
	if (delayClose != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.delayClose = delayClose;
	}
	final String? curtainPosition = homluxJsonConvert.convert<String>(json['curtain_position']);
	if (curtainPosition != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.curtainPosition = curtainPosition;
	}
	final String? curtainStatus = homluxJsonConvert.convert<String>(json['curtain_status']);
	if (curtainStatus != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.curtainStatus = curtainStatus;
	}
	final String? curtainDirection = homluxJsonConvert.convert<String>(json['curtain_direction']);
	if (curtainDirection != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.curtainDirection = curtainDirection;
	}
	final String? wifiLightPower = homluxJsonConvert.convert<String>(json['power']);
	if (wifiLightPower != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.wifiLightPower = wifiLightPower;
	}
	final String? wifiLightDelayOff = homluxJsonConvert.convert<String>(json['delay_light_off']);
	if (wifiLightDelayOff != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.wifiLightDelayOff = wifiLightDelayOff;
	}
	final String? wifiLightScene = homluxJsonConvert.convert<String>(json['scene_light']);
	if (wifiLightScene != null) {
		homluxDeviceMzgdPropertyDTOListCurtain.wifiLightScene = wifiLightScene;
	}
	return homluxDeviceMzgdPropertyDTOListCurtain;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListCurtainToJson(HomluxDeviceMzgdPropertyDTOListCurtain entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['buttonScene'] = entity.buttonScene;
	data['buttonMode'] = entity.buttonMode;
	data['power'] = entity.power;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['colorTemperature'] = entity.colorTemperature;
	data['brightness'] = entity.brightness;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	data['power'] = entity.wifiLightPower;
	data['delay_light_off'] = entity.wifiLightDelayOff;
	data['scene_light'] = entity.wifiLightScene;
	return data;
}

HomluxDeviceMzgdPropertyDTOListBathHeat $HomluxDeviceMzgdPropertyDTOListBathHeatFromJson(Map<String, dynamic> json) {
	return HomluxDeviceMzgdPropertyDTOListBathHeat(
		delayEnable: json['delay_enable'],
		dehumidityTrigger: json['dehumidity_trigger'],
		nightLightBrightness: json['night_light_brightness'],
		digitLedEnable: json['digit_led_enable'],
		mode: json['mode'],
		currentTemperature: json['current_temperature'],
		radarInductionEnable: json['radar_induction_enable'],
		heatingDirection: json['heating_direction'],
		delayTime: json['delay_time'],
		anionEnable: json['anion_enable'],
		lightMode: json['light_mode'],
		bathTemperature: json['bath_temperature'],
		subpacketType: json['subpacket_type'],
		radarInductionClosingTime: json['radar_induction_closing_time'],
		bathDirection: json['bath_direction'],
		dryingTime: json['drying_time'],
		mainLightBrightness: json['main_light_brightness'],
		functionLedEnable: json['function_led_enable'],
		dryingDirection: json['drying_direction'],
		bathHeatingTime: json['bath_heating_time'],
		version: json['version'],
		heatingTemperature: json['heating_temperature'],
		smellyTrigger: json['smelly_trigger'],
		blowingDirection: json['blowing_direction'],
		currentRadarStatus: json['current_radar_status'],
		blowingSpeed: json['blowing_speed'],
		wifiLedEnable: json['wifi_led_enable'],
	);
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListBathHeatToJson(HomluxDeviceMzgdPropertyDTOListBathHeat entity) {
	return {
		'delay_enable': entity.delayEnable,
		'dehumidity_trigger': entity.dehumidityTrigger,
		'night_light_brightness': entity.nightLightBrightness,
		'digit_led_enable': entity.digitLedEnable,
		'mode': entity.mode,
		'current_temperature': entity.currentTemperature,
		'radar_induction_enable': entity.radarInductionEnable,
		'heating_direction': entity.heatingDirection,
		'delay_time': entity.delayTime,
		'anion_enable': entity.anionEnable,
		'light_mode': entity.lightMode,
		'bath_temperature': entity.bathTemperature,
		'subpacket_type': entity.subpacketType,
		'radar_induction_closing_time': entity.radarInductionClosingTime,
		'bath_direction': entity.bathDirection,
		'drying_time': entity.dryingTime,
		'main_light_brightness': entity.mainLightBrightness,
		'function_led_enable': entity.functionLedEnable,
		'drying_direction': entity.dryingDirection,
		'bath_heating_time': entity.bathHeatingTime,
		'version': entity.version,
		'heating_temperature': entity.heatingTemperature,
		'smelly_trigger': entity.smellyTrigger,
		'blowing_direction': entity.blowingDirection,
		'current_radar_status': entity.currentRadarStatus,
		'blowing_speed': entity.blowingSpeed,
		'wifi_led_enable': entity.wifiLedEnable,
	};
}


HomluxDeviceMzgdPropertyDTOListAirCondition $HomluxDeviceMzgdPropertyDTOListAirConditionFromJson(Map<String, dynamic> json) {
	return HomluxDeviceMzgdPropertyDTOListAirCondition(
		smallTemperature: double.parse(json["small_temperature"].toString()),
		indoorTemperature: json['indoor_temperature'],
		windSwingLrUnder: json['wind_swing_lr_under'],
		windSwingLr: json['wind_swing_lr'],
		powerOnTimeValue: json['power_on_time_value'],
		powerOffTimeValue: json['power_off_time_value'],
		kickQuilt: json['kick_quilt'],
		dustFullTime: json['dust_full_time'],
		mode: json['mode'],
		eco: json['eco'],
		purifier: json['purifier'],
		naturalWind: json['natural_wind'],
		faultTag: json['fault_tag'],
		pmv: json['pmv'],
		temperature: json['temperature'],
		aromOld: json['arom_old'],
		comfortSleep: json['comfort_sleep'],
		windSpeed: json['wind_speed'],
		power: json['power'],
		ptc: json['ptc'],
		preventCold: json['prevent_cold'],
		powerOnTimer: json['power_on_timer'],
		analysisValue: json['analysis_value'],
		screenDisplayNow: json['screen_display_now'],
		dry: json['dry'],
		version: json['version'],
		windSwingUd: json['wind_swing_ud'],
		powerSaving: json['power_saving'],
		strongWind: json['strong_wind'],
		freshFilterTimeUse: json['fresh_filter_time_use'],
		powerOffTimer: json['power_off_timer'],
		errorCode: json['error_code'],

	);
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListAirConditionToJson(HomluxDeviceMzgdPropertyDTOListAirCondition entity) {
	return {
		'small_temperature': entity.smallTemperature,
		'indoor_temperature': entity.indoorTemperature,
		'wind_swing_lr_under': entity.windSwingLrUnder,
		'wind_swing_lr': entity.windSwingLr,
		'power_on_time_value': entity.powerOnTimeValue,
		'power_off_time_value': entity.powerOffTimeValue,
		'kick_quilt': entity.kickQuilt,
		'dust_full_time': entity.dustFullTime,
		'mode': entity.mode,
		'eco': entity.eco,
		'purifier': entity.purifier,
		'natural_wind': entity.naturalWind,
		'fault_tag': entity.faultTag,
		'pmv': entity.pmv,
		'temperature': entity.temperature,
		'arom_old': entity.aromOld,
		'comfort_sleep': entity.comfortSleep,
		'wind_speed': entity.windSpeed,
		'power': entity.power,
		'ptc': entity.ptc,
		'prevent_cold': entity.preventCold,
		'power_on_timer': entity.powerOnTimer,
		'analysis_value': entity.analysisValue,
		'screen_display_now': entity.screenDisplayNow,
		'dry': entity.dry,
		'version': entity.version,
		'wind_swing_ud': entity.windSwingUd,
		'power_saving': entity.powerSaving,
		'strong_wind': entity.strongWind,
		'fresh_filter_time_use': entity.freshFilterTimeUse,
		'power_off_timer': entity.powerOffTimer,
		'error_code': entity.errorCode,
	};
}

HomluxDeviceMzgdPropertyDTOListClothesDryingRack $HomluxDeviceMzgdPropertyDTOListClothesDryingRackFromJson(Map<String, dynamic> json) {
	return HomluxDeviceMzgdPropertyDTOListClothesDryingRack(
			timingToTop: json['timing_to_top'],
			customHeight: json['custom_height'],
			bodyInduction: json['body_induction'],
			lightBrightness: json['light_brightness'],
			version: json['version'],
			swVersion: json['sw_version'],
			timingLightOff: json['timing_light_off'],
			customTiming: json['custom_timing'],
			deviceSubType: json['deviceSubType'],
			dryMode: json['dry_mode'],
			light: json['light'],
			laundry: json['laundry'],
			errorCode: json['error_code'],
			heightResetting: json['height_resetting'],
			offlineVoiceFunction: json['offline_voice_function'],
			timeAfterNobody: json['time_after_nobody'],
			sterilize: json['sterilize'],
			updown: json['updown'],
			setLightOff: json['set_light_off'],
			locationStatus: json['location_status'],
			setToTop: json['set_to_top']
	);
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListClothesDryingRackToJson(HomluxDeviceMzgdPropertyDTOListClothesDryingRack entity) {
	return {
		"timing_to_top": entity.timingToTop,
		"custom_height": entity.customHeight,
		"body_induction": entity.bodyInduction,
		"light_brightness": entity.lightBrightness,
		"version": entity.version,
		"sw_version": entity.swVersion,
		"timing_light_off": entity.timingLightOff,
		"custom_timing": entity.customTiming,
		"deviceSubType": entity.deviceSubType,
		"dry_mode": entity.dryMode,
		"light": entity.light,
		"laundry": entity.laundry,
		"error_code": entity.errorCode,
		"height_resetting": entity.heightResetting,
		"offline_voice_function": entity.offlineVoiceFunction,
		"time_after_nobody": entity.timeAfterNobody,
		"sterilize": entity.sterilize,
		"updown": entity.updown,
		"set_light_off": entity.setLightOff,
		"location_status": entity.locationStatus,
		"set_to_top": entity.setToTop
	};
}

HomluxDeviceMzgdPropertyDTOListFloorHeating $HomluxDeviceMzgdPropertyDTOListFloorHeatingFromJson(Map<String, dynamic> json) {
	HomluxDeviceMzgdPropertyDTOListFloorHeating entity = HomluxDeviceMzgdPropertyDTOListFloorHeating();
	entity.mode = json["mode"];
	entity.power = json["power"];
	entity.windSpeed = json['windSpeed'];
	entity.OnOff = json['OnOff'];
	entity.currentTemperature = json['currentTemperature'];
	entity.targetTemperature = json['targetTemperature'];
	return entity;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListFloorHeatingToJson(HomluxDeviceMzgdPropertyDTOListFloorHeating entity) {

	return {
		"mode": entity.mode,
		"power": entity.power,
		"OnOff": entity.OnOff,
		"currentTemperature": entity.currentTemperature,
		"targetTemperature": entity.targetTemperature,
		"windSpeed": entity.windSpeed
	};

}


HomluxDeviceMzgdPropertyDTOListAir $HomluxDeviceMzgdPropertyDTOListAirFromJson(Map<String, dynamic> json) {
	HomluxDeviceMzgdPropertyDTOListAir entity = HomluxDeviceMzgdPropertyDTOListAir();
	entity.mode = json["mode"];
	entity.power = json["power"];
	entity.windSpeed = json['windSpeed'];
	entity.OnOff = json['OnOff'];
	entity.currentTemperature = json['currentTemperature'];
	entity.targetTemperature = json['targetTemperature'];
	return entity;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListAirToJson(HomluxDeviceMzgdPropertyDTOListAir entity) {

	return {
		"mode": entity.mode,
		"power": entity.power,
		"OnOff": entity.OnOff,
		"currentTemperature": entity.currentTemperature,
		"targetTemperature": entity.targetTemperature,
		"windSpeed": entity.windSpeed
	};

}


HomluxDeviceMzgdPropertyDTOListFreshAir $HomluxDeviceMzgdPropertyDTOListFreshAirFromJson(Map<String, dynamic> json) {
	HomluxDeviceMzgdPropertyDTOListFreshAir entity = HomluxDeviceMzgdPropertyDTOListFreshAir();
	entity.mode = json["mode"];
	entity.power = json["power"];
	entity.windSpeed = json['windSpeed'];
	entity.OnOff = json['OnOff'];
	return entity;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListFreshAirToJson(HomluxDeviceMzgdPropertyDTOListFreshAir entity) {

	return {
		"mode": entity.mode,
		"power": entity.power,
		"OnOff": entity.OnOff,
		"windSpeed": entity.windSpeed
	};

}

RemainingTime $RemainingTimeFromJson(Map<String, dynamic> json) {
	return RemainingTime(
			ptcDryingRemainingTime: json['"ptc_drying_remaining_time'],
			sterilizeRemainingTime: json['"sterilize_remaining_time'],
			airDryingRemainingTime: json['"air_drying_remaining_time']

	);
}

Map<String, dynamic> $RemainingTimeToJson(RemainingTime entity) {
	return {
			"ptc_drying_remaining_time": entity.ptcDryingRemainingTime,
			"sterilize_remaining_time": entity.sterilizeRemainingTime,
			"air_drying_remaining_time": entity.airDryingRemainingTime
	};
}