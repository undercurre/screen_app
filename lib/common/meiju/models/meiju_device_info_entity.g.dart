import 'package:screen_app/models/device_home_list_entity.dart';

import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_device_info_entity.dart';

Map<String, dynamic> $DeviceHomeListHomeListRoomListToJson(DeviceHomeListHomeListRoomList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['applianceList'] =  entity.applianceList?.map((v) => v.toJson()).toList();
	data['isDefault'] = entity.isDefault;
	data['code'] = entity.code;
	data['des'] = entity.des;
	data['name'] = entity.name;
	data['icon'] = entity.icon;
	data['id'] = entity.id;
	data['homegroupId'] = entity.homegroupId;
	return data;
}

MeiJuDeviceInfoEntity $MeijuDeviceInfoEntityFromJson(Map<String, dynamic> json) {
	final MeiJuDeviceInfoEntity device = MeiJuDeviceInfoEntity();
	final dynamic templateOfTSL = json['templateOfTSL'];
	if (templateOfTSL != null) {
		device.templateOfTSL = templateOfTSL;
	}
	final String? isOtherEquipment = meijuJsonConvert.convert<String>(json['isOtherEquipment']);
	if (isOtherEquipment != null) {
		device.isOtherEquipment = isOtherEquipment;
	}
	final String? enterprise = meijuJsonConvert.convert<String>(json['enterprise']);
	if (enterprise != null) {
		device.enterprise = enterprise;
	}
	final String? onlineStatus = meijuJsonConvert.convert<String>(json['onlineStatus']);
	if (onlineStatus != null) {
		device.onlineStatus = onlineStatus;
	}
	final String? btMac = meijuJsonConvert.convert<String>(json['btMac']);
	if (btMac != null) {
		device.btMac = btMac;
	}
	final dynamic switchStatus = meijuJsonConvert.convert<dynamic>(json['switchStatus']);
	if (switchStatus != null) {
		device.switchStatus = switchStatus;
	}
	final String? type = meijuJsonConvert.convert<String>(json['type']);
	if (type != null) {
		device.type = type;
	}
	final String? equipmentType = meijuJsonConvert.convert<String>(json['equipmentType']);
	if (equipmentType != null) {
		device.equipmentType = equipmentType;
	}
	final dynamic des = meijuJsonConvert.convert<dynamic>(json['des']);
	if (des != null) {
		device.des = des;
	}
	final String? newAttrs = meijuJsonConvert.convert<String>(json['newAttrs']);
	if (newAttrs != null) {
		device.newAttrs = newAttrs;
	}
	final dynamic nfcLabels = meijuJsonConvert.convert<dynamic>(json['nfcLabels']);
	if (nfcLabels != null) {
		device.nfcLabels = nfcLabels;
	}
	final String? id = meijuJsonConvert.convert<String>(json['id']);
	if (id != null) {
		device.id = id;
	}
	final String? sn = meijuJsonConvert.convert<String>(json['sn']);
	if (sn != null) {
		device.sn = sn;
	}
	final MeiJuDeviceInfoAbilityEntity? ability = meijuJsonConvert.convert<MeiJuDeviceInfoAbilityEntity>(json['ability']);
	if (ability != null) {
		device.ability = ability;
	}
	final dynamic cardStatus = meijuJsonConvert.convert<dynamic>(json['cardStatus']);
	if (cardStatus != null) {
		device.cardStatus = cardStatus;
	}
	final dynamic enterpriseCode = meijuJsonConvert.convert<dynamic>(json['enterpriseCode']);
	if (enterpriseCode != null) {
		device.enterpriseCode = enterpriseCode;
	}
	final bool? supportWot = meijuJsonConvert.convert<bool>(json['supportWot']);
	if (supportWot != null) {
		device.supportWot = supportWot;
	}
	final String? activeTime = meijuJsonConvert.convert<String>(json['activeTime']);
	if (activeTime != null) {
		device.activeTime = activeTime;
	}
	final String? bindType = meijuJsonConvert.convert<String>(json['bindType']);
	if (bindType != null) {
		device.bindType = bindType;
	}
	final String? applianceCode = meijuJsonConvert.convert<String>(json['applianceCode']);
	if (applianceCode != null) {
		device.applianceCode = applianceCode;
	}
	final String? roomName = meijuJsonConvert.convert<String>(json['roomName']);
	if (roomName != null) {
		device.roomName = roomName;
	}
	final String? roomId = meijuJsonConvert.convert<String>(json['roomId']);
	if (roomId != null) {
		device.roomId = roomId;
	}
	final dynamic command = meijuJsonConvert.convert<dynamic>(json['command']);
	if (command != null) {
		device.command = command;
	}
	final String? attrs = meijuJsonConvert.convert<String>(json['attrs']);
	if (attrs != null) {
		device.attrs = attrs;
	}
	final String? btToken = meijuJsonConvert.convert<String>(json['btToken']);
	if (btToken != null) {
		device.btToken = btToken;
	}
	final String? hotspotName = meijuJsonConvert.convert<String>(json['hotspotName']);
	if (hotspotName != null) {
		device.hotspotName = hotspotName;
	}
	final String? masterId = meijuJsonConvert.convert<String>(json['masterId']);
	if (masterId != null) {
		device.masterId = masterId;
	}
	final dynamic nfcLabelInfos = meijuJsonConvert.convert<dynamic>(json['nfcLabelInfos']);
	if (nfcLabelInfos != null) {
		device.nfcLabelInfos = nfcLabelInfos;
	}
	final String? activeStatus = meijuJsonConvert.convert<String>(json['activeStatus']);
	if (activeStatus != null) {
		device.activeStatus = activeStatus;
	}
	final String? name = meijuJsonConvert.convert<String>(json['name']);
	if (name != null) {
		device.name = name;
	}
	final String? wifiVersion = meijuJsonConvert.convert<String>(json['wifiVersion']);
	if (wifiVersion != null) {
		device.wifiVersion = wifiVersion;
	}
	final String? isSupportFetchStatus = meijuJsonConvert.convert<String>(json['isSupportFetchStatus']);
	if (isSupportFetchStatus != null) {
		device.isSupportFetchStatus = isSupportFetchStatus;
	}
	final String? modelNumber = meijuJsonConvert.convert<String>(json['modelNumber']);
	if (modelNumber != null) {
		device.modelNumber = modelNumber;
	}
	final dynamic smartProductId = meijuJsonConvert.convert<dynamic>(json['smartProductId']);
	if (smartProductId != null) {
		device.smartProductId = smartProductId;
	}
	final String? isBluetooth = meijuJsonConvert.convert<String>(json['isBluetooth']);
	if (isBluetooth != null) {
		device.isBluetooth = isBluetooth;
	}
	final dynamic sn8 = meijuJsonConvert.convert<dynamic>(json['sn8']);
	if (sn8 != null) {
		device.sn8 = sn8;
	}
	final dynamic nameChanged = meijuJsonConvert.convert<dynamic>(json['nameChanged']);
	if (nameChanged != null) {
		device.nameChanged = nameChanged;
	}
	final dynamic status = meijuJsonConvert.convert<dynamic>(json['status']);
	if (status != null) {
		device.status = status;
	}
	final dynamic detail = meijuJsonConvert.convert<dynamic>(json['detail']);
	if (detail != null) {
		device.detail = detail;
	}
	return device;
}

Map<String, dynamic> $MeijuDeviceInfoEntityToJson(MeiJuDeviceInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['templateOfTSL'] = entity.templateOfTSL;
	data['isOtherEquipment'] = entity.isOtherEquipment;
	data['enterprise'] = entity.enterprise;
	data['onlineStatus'] = entity.onlineStatus;
	data['btMac'] = entity.btMac;
	data['switchStatus'] = entity.switchStatus;
	data['type'] = entity.type;
	data['equipmentType'] = entity.equipmentType;
	data['des'] = entity.des;
	data['newAttrs'] = entity.newAttrs;
	data['nfcLabels'] = entity.nfcLabels;
	data['id'] = entity.id;
	data['sn'] = entity.sn;
	data['ability'] = entity.ability?.toJson();
	data['cardStatus'] = entity.cardStatus;
	data['enterpriseCode'] = entity.enterpriseCode;
	data['supportWot'] = entity.supportWot;
	data['activeTime'] = entity.activeTime;
	data['bindType'] = entity.bindType;
	data['applianceCode'] = entity.applianceCode;
	data['roomName'] = entity.roomName;
	data['roomId'] = entity.roomId;
	data['command'] = entity.command;
	data['attrs'] = entity.attrs;
	data['btToken'] = entity.btToken;
	data['hotspotName'] = entity.hotspotName;
	data['masterId'] = entity.masterId;
	data['nfcLabelInfos'] = entity.nfcLabelInfos;
	data['activeStatus'] = entity.activeStatus;
	data['name'] = entity.name;
	data['wifiVersion'] = entity.wifiVersion;
	data['isSupportFetchStatus'] = entity.isSupportFetchStatus;
	data['modelNumber'] = entity.modelNumber;
	data['smartProductId'] = entity.smartProductId;
	data['isBluetooth'] = entity.isBluetooth;
	data['sn8'] = entity.sn8;
	data['nameChanged'] = entity.nameChanged;
	data['status'] = entity.status;
	data['detail'] = entity.detail;
	return data;
}

MeiJuDeviceInfoAbilityEntity $MeijuDeviceInfoAbilityEntityFromJson(Map<String, dynamic> json) {
	final MeiJuDeviceInfoAbilityEntity deviceHomeListHomeListRoomListApplianceListAbility = MeiJuDeviceInfoAbilityEntity();
	final int? bleAppBindStatus = meijuJsonConvert.convert<int>(json['bleAppBindStatus']);
	if (bleAppBindStatus != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.bleAppBindStatus = bleAppBindStatus;
	}
	final int? supportGateway = meijuJsonConvert.convert<int>(json['supportGateway']);
	if (supportGateway != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportGateway = supportGateway;
	}
	final int? supportWot = meijuJsonConvert.convert<int>(json['supportWot']);
	if (supportWot != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportWot = supportWot;
	}
	final int? supportBleMesh = meijuJsonConvert.convert<int>(json['supportBleMesh']);
	if (supportBleMesh != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBleMesh = supportBleMesh;
	}
	final int? schoolTime = meijuJsonConvert.convert<int>(json['schoolTime']);
	if (schoolTime != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.schoolTime = schoolTime;
	}
	final int? supportADNS = meijuJsonConvert.convert<int>(json['supportADNS']);
	if (supportADNS != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportADNS = supportADNS;
	}
	final int? supportBleDataTransfers = meijuJsonConvert.convert<int>(json['supportBleDataTransfers']);
	if (supportBleDataTransfers != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBleDataTransfers = supportBleDataTransfers;
	}
	final int? supportBindStatus = meijuJsonConvert.convert<int>(json['supportBindStatus']);
	if (supportBindStatus != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBindStatus = supportBindStatus;
	}
	final int? supportOfflineMsg = meijuJsonConvert.convert<int>(json['supportOfflineMsg']);
	if (supportOfflineMsg != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportOfflineMsg = supportOfflineMsg;
	}
	final int? bleDeviceStatus = meijuJsonConvert.convert<int>(json['bleDeviceStatus']);
	if (bleDeviceStatus != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.bleDeviceStatus = bleDeviceStatus;
	}
	final int? supportNewKeyVersion = meijuJsonConvert.convert<int>(json['supportNewKeyVersion']);
	if (supportNewKeyVersion != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportNewKeyVersion = supportNewKeyVersion;
	}
	final int? domainSwitch = meijuJsonConvert.convert<int>(json['domainSwitch']);
	if (domainSwitch != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.domainSwitch = domainSwitch;
	}
	final int? supportBindCode = meijuJsonConvert.convert<int>(json['supportBindCode']);
	if (supportBindCode != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBindCode = supportBindCode;
	}
	final int? supportBleOta = meijuJsonConvert.convert<int>(json['supportBleOta']);
	if (supportBleOta != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBleOta = supportBleOta;
	}
	final int? supportReset = meijuJsonConvert.convert<int>(json['supportReset']);
	if (supportReset != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportReset = supportReset;
	}
	final int? supportRouterReportAndQuery = meijuJsonConvert.convert<int>(json['supportRouterReportAndQuery']);
	if (supportRouterReportAndQuery != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportRouterReportAndQuery = supportRouterReportAndQuery;
	}
	final String? isBluetoothControl = meijuJsonConvert.convert<String>(json['isBluetoothControl']);
	if (isBluetoothControl != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.isBluetoothControl = isBluetoothControl;
	}
	final String? distributionNetworkType = meijuJsonConvert.convert<String>(json['distributionNetworkType']);
	if (distributionNetworkType != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.distributionNetworkType = distributionNetworkType;
	}
	final int? supportMedia = meijuJsonConvert.convert<int>(json['supportMedia']);
	if (supportMedia != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportMedia = supportMedia;
	}
	final int? supportFindFriends = meijuJsonConvert.convert<int>(json['supportFindFriends']);
	if (supportFindFriends != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportFindFriends = supportFindFriends;
	}
	final int? supportDiagnosis = meijuJsonConvert.convert<int>(json['supportDiagnosis']);
	if (supportDiagnosis != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportDiagnosis = supportDiagnosis;
	}
	final int? supportQueryToken = meijuJsonConvert.convert<int>(json['supportQueryToken']);
	if (supportQueryToken != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportQueryToken = supportQueryToken;
	}
	final int? supportNetworkBridge = meijuJsonConvert.convert<int>(json['supportNetworkBridge']);
	if (supportNetworkBridge != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportNetworkBridge = supportNetworkBridge;
	}
	return deviceHomeListHomeListRoomListApplianceListAbility;
}

Map<String, dynamic> $MeijuDeviceInfoAbilityEntityToJson(MeiJuDeviceInfoAbilityEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['bleAppBindStatus'] = entity.bleAppBindStatus;
	data['supportGateway'] = entity.supportGateway;
	data['supportWot'] = entity.supportWot;
	data['supportBleMesh'] = entity.supportBleMesh;
	data['schoolTime'] = entity.schoolTime;
	data['supportADNS'] = entity.supportADNS;
	data['supportBleDataTransfers'] = entity.supportBleDataTransfers;
	data['supportBindStatus'] = entity.supportBindStatus;
	data['supportOfflineMsg'] = entity.supportOfflineMsg;
	data['bleDeviceStatus'] = entity.bleDeviceStatus;
	data['supportNewKeyVersion'] = entity.supportNewKeyVersion;
	data['domainSwitch'] = entity.domainSwitch;
	data['supportBindCode'] = entity.supportBindCode;
	data['supportBleOta'] = entity.supportBleOta;
	data['supportReset'] = entity.supportReset;
	data['supportRouterReportAndQuery'] = entity.supportRouterReportAndQuery;
	data['isBluetoothControl'] = entity.isBluetoothControl;
	data['distributionNetworkType'] = entity.distributionNetworkType;
	data['supportMedia'] = entity.supportMedia;
	data['supportFindFriends'] = entity.supportFindFriends;
	data['supportDiagnosis'] = entity.supportDiagnosis;
	data['supportQueryToken'] = entity.supportQueryToken;
	data['supportNetworkBridge'] = entity.supportNetworkBridge;
	return data;
}