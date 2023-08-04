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
	final HomluxDeviceMzgdPropertyDTOList1? x1 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList1>(json['1']);
	if (x1 != null) {
		homluxDeviceMzgdPropertyDTOList.x1 = x1;
	}
	final HomluxDeviceMzgdPropertyDTOList2? x2 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList2>(json['2']);
	if (x2 != null) {
		homluxDeviceMzgdPropertyDTOList.x2 = x2;
	}
	final HomluxDeviceMzgdPropertyDTOList3? x3 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList3>(json['3']);
	if (x3 != null) {
		homluxDeviceMzgdPropertyDTOList.x3 = x3;
	}
	final HomluxDeviceMzgdPropertyDTOList4? x4 = homluxJsonConvert.convert<HomluxDeviceMzgdPropertyDTOList4>(json['4']);
	if (x4 != null) {
		homluxDeviceMzgdPropertyDTOList.x4 = x4;
	}
	return homluxDeviceMzgdPropertyDTOList;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOListToJson(HomluxDeviceMzgdPropertyDTOList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['1'] = entity.x1?.toJson();
	data['2'] = entity.x2?.toJson();
	data['3'] = entity.x3?.toJson();
	data['4'] = entity.x4?.toJson();
	return data;
}

HomluxDeviceMzgdPropertyDTOList1 $HomluxDeviceMzgdPropertyDTOList1FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList1 homluxDeviceMzgdPropertyDTOList1 = HomluxDeviceMzgdPropertyDTOList1();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['ButtonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList1.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['ButtonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList1.buttonMode = buttonMode;
	}
	final int? onOff = homluxJsonConvert.convert<int>(json['OnOff']);
	if (onOff != null) {
		homluxDeviceMzgdPropertyDTOList1.onOff = onOff;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList1.startUpOnOff = startUpOnOff;
	}
	final int? colorTemp = homluxJsonConvert.convert<int>(json['ColorTemp']);
	if (colorTemp != null) {
		homluxDeviceMzgdPropertyDTOList1.colorTemp = colorTemp;
	}
	final int? level = homluxJsonConvert.convert<int>(json['Level']);
	if (level != null) {
		homluxDeviceMzgdPropertyDTOList1.level = level;
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
	return homluxDeviceMzgdPropertyDTOList1;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList1ToJson(HomluxDeviceMzgdPropertyDTOList1 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['ButtonScene'] = entity.buttonScene;
	data['ButtonMode'] = entity.buttonMode;
	data['OnOff'] = entity.onOff;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['ColorTemp'] = entity.colorTemp;
	data['Level'] = entity.level;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	return data;
}

HomluxDeviceMzgdPropertyDTOList2 $HomluxDeviceMzgdPropertyDTOList2FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList2 homluxDeviceMzgdPropertyDTOList2 = HomluxDeviceMzgdPropertyDTOList2();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['ButtonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList2.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['ButtonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList2.buttonMode = buttonMode;
	}
	final int? onOff = homluxJsonConvert.convert<int>(json['OnOff']);
	if (onOff != null) {
		homluxDeviceMzgdPropertyDTOList2.onOff = onOff;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList2.startUpOnOff = startUpOnOff;
	}
	final int? colorTemp = homluxJsonConvert.convert<int>(json['ColorTemp']);
	if (colorTemp != null) {
		homluxDeviceMzgdPropertyDTOList2.colorTemp = colorTemp;
	}
	final int? level = homluxJsonConvert.convert<int>(json['Level']);
	if (level != null) {
		homluxDeviceMzgdPropertyDTOList2.level = level;
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
	return homluxDeviceMzgdPropertyDTOList2;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList2ToJson(HomluxDeviceMzgdPropertyDTOList2 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['ButtonScene'] = entity.buttonScene;
	data['ButtonMode'] = entity.buttonMode;
	data['OnOff'] = entity.onOff;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['ColorTemp'] = entity.colorTemp;
	data['Level'] = entity.level;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	return data;
}

HomluxDeviceMzgdPropertyDTOList3 $HomluxDeviceMzgdPropertyDTOList3FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList3 homluxDeviceMzgdPropertyDTOList3 = HomluxDeviceMzgdPropertyDTOList3();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['ButtonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList3.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['ButtonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList3.buttonMode = buttonMode;
	}
	final int? onOff = homluxJsonConvert.convert<int>(json['OnOff']);
	if (onOff != null) {
		homluxDeviceMzgdPropertyDTOList3.onOff = onOff;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList3.startUpOnOff = startUpOnOff;
	}
	final int? colorTemp = homluxJsonConvert.convert<int>(json['ColorTemp']);
	if (colorTemp != null) {
		homluxDeviceMzgdPropertyDTOList3.colorTemp = colorTemp;
	}
	final int? level = homluxJsonConvert.convert<int>(json['Level']);
	if (level != null) {
		homluxDeviceMzgdPropertyDTOList3.level = level;
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
	return homluxDeviceMzgdPropertyDTOList3;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList3ToJson(HomluxDeviceMzgdPropertyDTOList3 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['ButtonScene'] = entity.buttonScene;
	data['ButtonMode'] = entity.buttonMode;
	data['OnOff'] = entity.onOff;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['ColorTemp'] = entity.colorTemp;
	data['Level'] = entity.level;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	return data;
}

HomluxDeviceMzgdPropertyDTOList4 $HomluxDeviceMzgdPropertyDTOList4FromJson(Map<String, dynamic> json) {
	final HomluxDeviceMzgdPropertyDTOList4 homluxDeviceMzgdPropertyDTOList4 = HomluxDeviceMzgdPropertyDTOList4();
	final int? buttonScene = homluxJsonConvert.convert<int>(json['ButtonScene']);
	if (buttonScene != null) {
		homluxDeviceMzgdPropertyDTOList4.buttonScene = buttonScene;
	}
	final int? buttonMode = homluxJsonConvert.convert<int>(json['ButtonMode']);
	if (buttonMode != null) {
		homluxDeviceMzgdPropertyDTOList4.buttonMode = buttonMode;
	}
	final int? onOff = homluxJsonConvert.convert<int>(json['OnOff']);
	if (onOff != null) {
		homluxDeviceMzgdPropertyDTOList4.onOff = onOff;
	}
	final int? startUpOnOff = homluxJsonConvert.convert<int>(json['StartUpOnOff']);
	if (startUpOnOff != null) {
		homluxDeviceMzgdPropertyDTOList4.startUpOnOff = startUpOnOff;
	}
	final int? colorTemp = homluxJsonConvert.convert<int>(json['ColorTemp']);
	if (colorTemp != null) {
		homluxDeviceMzgdPropertyDTOList4.colorTemp = colorTemp;
	}
	final int? level = homluxJsonConvert.convert<int>(json['Level']);
	if (level != null) {
		homluxDeviceMzgdPropertyDTOList4.level = level;
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
	return homluxDeviceMzgdPropertyDTOList4;
}

Map<String, dynamic> $HomluxDeviceMzgdPropertyDTOList4ToJson(HomluxDeviceMzgdPropertyDTOList4 entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['ButtonScene'] = entity.buttonScene;
	data['ButtonMode'] = entity.buttonMode;
	data['OnOff'] = entity.onOff;
	data['StartUpOnOff'] = entity.startUpOnOff;
	data['ColorTemp'] = entity.colorTemp;
	data['Level'] = entity.level;
	data['Duration'] = entity.duration;
	data['BcReportTime'] = entity.bcReportTime;
	data['DelayClose'] = entity.delayClose;
	data['curtain_position'] = entity.curtainPosition;
	data['curtain_status'] = entity.curtainStatus;
	data['curtain_direction'] = entity.curtainDirection;
	return data;
}