import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/device_home_list_entity.dart';

DeviceHomeListEntity $DeviceHomeListEntityFromJson(Map<String, dynamic> json) {
	final DeviceHomeListEntity deviceHomeListEntity = DeviceHomeListEntity();
	final List<DeviceHomeListHomeList>? homeList = jsonConvert.convertListNotNull<DeviceHomeListHomeList>(json['homeList']);
	if (homeList != null) {
		deviceHomeListEntity.homeList = homeList;
	}
	return deviceHomeListEntity;
}

Map<String, dynamic> $DeviceHomeListEntityToJson(DeviceHomeListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['homeList'] =  entity.homeList?.map((v) => v.toJson()).toList();
	return data;
}

DeviceHomeListHomeList $DeviceHomeListHomeListFromJson(Map<String, dynamic> json) {
	final DeviceHomeListHomeList deviceHomeListHomeList = DeviceHomeListHomeList();
	final String? roomCount = jsonConvert.convert<String>(json['roomCount']);
	if (roomCount != null) {
		deviceHomeListHomeList.roomCount = roomCount;
	}
	final String? address = jsonConvert.convert<String>(json['address']);
	if (address != null) {
		deviceHomeListHomeList.address = address;
	}
	final String? coordinate = jsonConvert.convert<String>(json['coordinate']);
	if (coordinate != null) {
		deviceHomeListHomeList.coordinate = coordinate;
	}
	final String? roleId = jsonConvert.convert<String>(json['roleId']);
	if (roleId != null) {
		deviceHomeListHomeList.roleId = roleId;
	}
	final String? applianceCount = jsonConvert.convert<String>(json['applianceCount']);
	if (applianceCount != null) {
		deviceHomeListHomeList.applianceCount = applianceCount;
	}
	final String? memberCount = jsonConvert.convert<String>(json['memberCount']);
	if (memberCount != null) {
		deviceHomeListHomeList.memberCount = memberCount;
	}
	final String? createUserUid = jsonConvert.convert<String>(json['createUserUid']);
	if (createUserUid != null) {
		deviceHomeListHomeList.createUserUid = createUserUid;
	}
	final String? number = jsonConvert.convert<String>(json['number']);
	if (number != null) {
		deviceHomeListHomeList.number = number;
	}
	final String? isDefault = jsonConvert.convert<String>(json['isDefault']);
	if (isDefault != null) {
		deviceHomeListHomeList.isDefault = isDefault;
	}
	final dynamic? des = jsonConvert.convert<dynamic>(json['des']);
	if (des != null) {
		deviceHomeListHomeList.des = des;
	}
	final String? areaid = jsonConvert.convert<String>(json['areaid']);
	if (areaid != null) {
		deviceHomeListHomeList.areaid = areaid;
	}
	final dynamic? profilePicUrl = jsonConvert.convert<dynamic>(json['profilePicUrl']);
	if (profilePicUrl != null) {
		deviceHomeListHomeList.profilePicUrl = profilePicUrl;
	}
	final String? roleTag = jsonConvert.convert<String>(json['roleTag']);
	if (roleTag != null) {
		deviceHomeListHomeList.roleTag = roleTag;
	}
	final String? createTime = jsonConvert.convert<String>(json['createTime']);
	if (createTime != null) {
		deviceHomeListHomeList.createTime = createTime;
	}
	final List<dynamic>? members = jsonConvert.convertListNotNull<dynamic>(json['members']);
	if (members != null) {
		deviceHomeListHomeList.members = members;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		deviceHomeListHomeList.name = name;
	}
	final String? nickname = jsonConvert.convert<String>(json['nickname']);
	if (nickname != null) {
		deviceHomeListHomeList.nickname = nickname;
	}
	final String? createUser = jsonConvert.convert<String>(json['createUser']);
	if (createUser != null) {
		deviceHomeListHomeList.createUser = createUser;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		deviceHomeListHomeList.id = id;
	}
	final dynamic? smartProductId = jsonConvert.convert<dynamic>(json['smartProductId']);
	if (smartProductId != null) {
		deviceHomeListHomeList.smartProductId = smartProductId;
	}
	final List<DeviceHomeListHomeListRoomList>? roomList = jsonConvert.convertListNotNull<DeviceHomeListHomeListRoomList>(json['roomList']);
	if (roomList != null) {
		deviceHomeListHomeList.roomList = roomList;
	}
	return deviceHomeListHomeList;
}

Map<String, dynamic> $DeviceHomeListHomeListToJson(DeviceHomeListHomeList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['roomCount'] = entity.roomCount;
	data['address'] = entity.address;
	data['coordinate'] = entity.coordinate;
	data['roleId'] = entity.roleId;
	data['applianceCount'] = entity.applianceCount;
	data['memberCount'] = entity.memberCount;
	data['createUserUid'] = entity.createUserUid;
	data['number'] = entity.number;
	data['isDefault'] = entity.isDefault;
	data['des'] = entity.des;
	data['areaid'] = entity.areaid;
	data['profilePicUrl'] = entity.profilePicUrl;
	data['roleTag'] = entity.roleTag;
	data['createTime'] = entity.createTime;
	data['members'] =  entity.members;
	data['name'] = entity.name;
	data['nickname'] = entity.nickname;
	data['createUser'] = entity.createUser;
	data['id'] = entity.id;
	data['smartProductId'] = entity.smartProductId;
	data['roomList'] =  entity.roomList?.map((v) => v.toJson()).toList();
	return data;
}

DeviceHomeListHomeListRoomList $DeviceHomeListHomeListRoomListFromJson(Map<String, dynamic> json) {
	final DeviceHomeListHomeListRoomList deviceHomeListHomeListRoomList = DeviceHomeListHomeListRoomList();
	final List<DeviceHomeListHomeListRoomListApplianceList>? applianceList = jsonConvert.convertListNotNull<DeviceHomeListHomeListRoomListApplianceList>(json['applianceList']);
	if (applianceList != null) {
		deviceHomeListHomeListRoomList.applianceList = applianceList;
	}
	final String? isDefault = jsonConvert.convert<String>(json['isDefault']);
	if (isDefault != null) {
		deviceHomeListHomeListRoomList.isDefault = isDefault;
	}
	final dynamic? code = jsonConvert.convert<dynamic>(json['code']);
	if (code != null) {
		deviceHomeListHomeListRoomList.code = code;
	}
	final String? des = jsonConvert.convert<String>(json['des']);
	if (des != null) {
		deviceHomeListHomeListRoomList.des = des;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		deviceHomeListHomeListRoomList.name = name;
	}
	final String? icon = jsonConvert.convert<String>(json['icon']);
	if (icon != null) {
		deviceHomeListHomeListRoomList.icon = icon;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		deviceHomeListHomeListRoomList.id = id;
	}
	final String? homegroupId = jsonConvert.convert<String>(json['homegroupId']);
	if (homegroupId != null) {
		deviceHomeListHomeListRoomList.homegroupId = homegroupId;
	}
	return deviceHomeListHomeListRoomList;
}

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

DeviceHomeListHomeListRoomListApplianceList $DeviceHomeListHomeListRoomListApplianceListFromJson(Map<String, dynamic> json) {
	final DeviceHomeListHomeListRoomListApplianceList deviceHomeListHomeListRoomListApplianceList = DeviceHomeListHomeListRoomListApplianceList();
	final dynamic? templateOfTSL = jsonConvert.convert<dynamic>(json['templateOfTSL']);
	if (templateOfTSL != null) {
		deviceHomeListHomeListRoomListApplianceList.templateOfTSL = templateOfTSL;
	}
	final String? isOtherEquipment = jsonConvert.convert<String>(json['isOtherEquipment']);
	if (isOtherEquipment != null) {
		deviceHomeListHomeListRoomListApplianceList.isOtherEquipment = isOtherEquipment;
	}
	final String? enterprise = jsonConvert.convert<String>(json['enterprise']);
	if (enterprise != null) {
		deviceHomeListHomeListRoomListApplianceList.enterprise = enterprise;
	}
	final String? onlineStatus = jsonConvert.convert<String>(json['onlineStatus']);
	if (onlineStatus != null) {
		deviceHomeListHomeListRoomListApplianceList.onlineStatus = onlineStatus;
	}
	final String? btMac = jsonConvert.convert<String>(json['btMac']);
	if (btMac != null) {
		deviceHomeListHomeListRoomListApplianceList.btMac = btMac;
	}
	final dynamic? switchStatus = jsonConvert.convert<dynamic>(json['switchStatus']);
	if (switchStatus != null) {
		deviceHomeListHomeListRoomListApplianceList.switchStatus = switchStatus;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		deviceHomeListHomeListRoomListApplianceList.type = type;
	}
	final String? equipmentType = jsonConvert.convert<String>(json['equipmentType']);
	if (equipmentType != null) {
		deviceHomeListHomeListRoomListApplianceList.equipmentType = equipmentType;
	}
	final dynamic? des = jsonConvert.convert<dynamic>(json['des']);
	if (des != null) {
		deviceHomeListHomeListRoomListApplianceList.des = des;
	}
	final String? newAttrs = jsonConvert.convert<String>(json['newAttrs']);
	if (newAttrs != null) {
		deviceHomeListHomeListRoomListApplianceList.newAttrs = newAttrs;
	}
	final dynamic? nfcLabels = jsonConvert.convert<dynamic>(json['nfcLabels']);
	if (nfcLabels != null) {
		deviceHomeListHomeListRoomListApplianceList.nfcLabels = nfcLabels;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		deviceHomeListHomeListRoomListApplianceList.id = id;
	}
	final String? sn = jsonConvert.convert<String>(json['sn']);
	if (sn != null) {
		deviceHomeListHomeListRoomListApplianceList.sn = sn;
	}
	final DeviceHomeListHomeListRoomListApplianceListAbility? ability = jsonConvert.convert<DeviceHomeListHomeListRoomListApplianceListAbility>(json['ability']);
	if (ability != null) {
		deviceHomeListHomeListRoomListApplianceList.ability = ability;
	}
	final dynamic? cardStatus = jsonConvert.convert<dynamic>(json['cardStatus']);
	if (cardStatus != null) {
		deviceHomeListHomeListRoomListApplianceList.cardStatus = cardStatus;
	}
	final dynamic? enterpriseCode = jsonConvert.convert<dynamic>(json['enterpriseCode']);
	if (enterpriseCode != null) {
		deviceHomeListHomeListRoomListApplianceList.enterpriseCode = enterpriseCode;
	}
	final bool? supportWot = jsonConvert.convert<bool>(json['supportWot']);
	if (supportWot != null) {
		deviceHomeListHomeListRoomListApplianceList.supportWot = supportWot;
	}
	final String? activeTime = jsonConvert.convert<String>(json['activeTime']);
	if (activeTime != null) {
		deviceHomeListHomeListRoomListApplianceList.activeTime = activeTime;
	}
	final String? bindType = jsonConvert.convert<String>(json['bindType']);
	if (bindType != null) {
		deviceHomeListHomeListRoomListApplianceList.bindType = bindType;
	}
	final String? applianceCode = jsonConvert.convert<String>(json['applianceCode']);
	if (applianceCode != null) {
		deviceHomeListHomeListRoomListApplianceList.applianceCode = applianceCode;
	}
	final String? roomName = jsonConvert.convert<String>(json['roomName']);
	if (roomName != null) {
		deviceHomeListHomeListRoomListApplianceList.roomName = roomName;
	}
	final dynamic? command = jsonConvert.convert<dynamic>(json['command']);
	if (command != null) {
		deviceHomeListHomeListRoomListApplianceList.command = command;
	}
	final String? attrs = jsonConvert.convert<String>(json['attrs']);
	if (attrs != null) {
		deviceHomeListHomeListRoomListApplianceList.attrs = attrs;
	}
	final String? btToken = jsonConvert.convert<String>(json['btToken']);
	if (btToken != null) {
		deviceHomeListHomeListRoomListApplianceList.btToken = btToken;
	}
	final String? hotspotName = jsonConvert.convert<String>(json['hotspotName']);
	if (hotspotName != null) {
		deviceHomeListHomeListRoomListApplianceList.hotspotName = hotspotName;
	}
	final String? masterId = jsonConvert.convert<String>(json['masterId']);
	if (masterId != null) {
		deviceHomeListHomeListRoomListApplianceList.masterId = masterId;
	}
	final dynamic? nfcLabelInfos = jsonConvert.convert<dynamic>(json['nfcLabelInfos']);
	if (nfcLabelInfos != null) {
		deviceHomeListHomeListRoomListApplianceList.nfcLabelInfos = nfcLabelInfos;
	}
	final String? activeStatus = jsonConvert.convert<String>(json['activeStatus']);
	if (activeStatus != null) {
		deviceHomeListHomeListRoomListApplianceList.activeStatus = activeStatus;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		deviceHomeListHomeListRoomListApplianceList.name = name;
	}
	final String? wifiVersion = jsonConvert.convert<String>(json['wifiVersion']);
	if (wifiVersion != null) {
		deviceHomeListHomeListRoomListApplianceList.wifiVersion = wifiVersion;
	}
	final String? isSupportFetchStatus = jsonConvert.convert<String>(json['isSupportFetchStatus']);
	if (isSupportFetchStatus != null) {
		deviceHomeListHomeListRoomListApplianceList.isSupportFetchStatus = isSupportFetchStatus;
	}
	final String? modelNumber = jsonConvert.convert<String>(json['modelNumber']);
	if (modelNumber != null) {
		deviceHomeListHomeListRoomListApplianceList.modelNumber = modelNumber;
	}
	final dynamic? smartProductId = jsonConvert.convert<dynamic>(json['smartProductId']);
	if (smartProductId != null) {
		deviceHomeListHomeListRoomListApplianceList.smartProductId = smartProductId;
	}
	final String? isBluetooth = jsonConvert.convert<String>(json['isBluetooth']);
	if (isBluetooth != null) {
		deviceHomeListHomeListRoomListApplianceList.isBluetooth = isBluetooth;
	}
	final dynamic? sn8 = jsonConvert.convert<dynamic>(json['sn8']);
	if (sn8 != null) {
		deviceHomeListHomeListRoomListApplianceList.sn8 = sn8;
	}
	final dynamic? nameChanged = jsonConvert.convert<dynamic>(json['nameChanged']);
	if (nameChanged != null) {
		deviceHomeListHomeListRoomListApplianceList.nameChanged = nameChanged;
	}
	final dynamic? status = jsonConvert.convert<dynamic>(json['status']);
	if (status != null) {
		deviceHomeListHomeListRoomListApplianceList.status = status;
	}
	return deviceHomeListHomeListRoomListApplianceList;
}

Map<String, dynamic> $DeviceHomeListHomeListRoomListApplianceListToJson(DeviceHomeListHomeListRoomListApplianceList entity) {
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
	return data;
}

DeviceHomeListHomeListRoomListApplianceListAbility $DeviceHomeListHomeListRoomListApplianceListAbilityFromJson(Map<String, dynamic> json) {
	final DeviceHomeListHomeListRoomListApplianceListAbility deviceHomeListHomeListRoomListApplianceListAbility = DeviceHomeListHomeListRoomListApplianceListAbility();
	final int? bleAppBindStatus = jsonConvert.convert<int>(json['bleAppBindStatus']);
	if (bleAppBindStatus != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.bleAppBindStatus = bleAppBindStatus;
	}
	final int? supportGateway = jsonConvert.convert<int>(json['supportGateway']);
	if (supportGateway != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportGateway = supportGateway;
	}
	final int? supportWot = jsonConvert.convert<int>(json['supportWot']);
	if (supportWot != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportWot = supportWot;
	}
	final int? supportBleMesh = jsonConvert.convert<int>(json['supportBleMesh']);
	if (supportBleMesh != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBleMesh = supportBleMesh;
	}
	final int? schoolTime = jsonConvert.convert<int>(json['schoolTime']);
	if (schoolTime != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.schoolTime = schoolTime;
	}
	final int? supportADNS = jsonConvert.convert<int>(json['supportADNS']);
	if (supportADNS != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportADNS = supportADNS;
	}
	final int? supportBleDataTransfers = jsonConvert.convert<int>(json['supportBleDataTransfers']);
	if (supportBleDataTransfers != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBleDataTransfers = supportBleDataTransfers;
	}
	final int? supportBindStatus = jsonConvert.convert<int>(json['supportBindStatus']);
	if (supportBindStatus != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBindStatus = supportBindStatus;
	}
	final int? supportOfflineMsg = jsonConvert.convert<int>(json['supportOfflineMsg']);
	if (supportOfflineMsg != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportOfflineMsg = supportOfflineMsg;
	}
	final int? bleDeviceStatus = jsonConvert.convert<int>(json['bleDeviceStatus']);
	if (bleDeviceStatus != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.bleDeviceStatus = bleDeviceStatus;
	}
	final int? supportNewKeyVersion = jsonConvert.convert<int>(json['supportNewKeyVersion']);
	if (supportNewKeyVersion != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportNewKeyVersion = supportNewKeyVersion;
	}
	final int? domainSwitch = jsonConvert.convert<int>(json['domainSwitch']);
	if (domainSwitch != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.domainSwitch = domainSwitch;
	}
	final int? supportBindCode = jsonConvert.convert<int>(json['supportBindCode']);
	if (supportBindCode != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBindCode = supportBindCode;
	}
	final int? supportBleOta = jsonConvert.convert<int>(json['supportBleOta']);
	if (supportBleOta != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportBleOta = supportBleOta;
	}
	final int? supportReset = jsonConvert.convert<int>(json['supportReset']);
	if (supportReset != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportReset = supportReset;
	}
	final int? supportRouterReportAndQuery = jsonConvert.convert<int>(json['supportRouterReportAndQuery']);
	if (supportRouterReportAndQuery != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportRouterReportAndQuery = supportRouterReportAndQuery;
	}
	final String? isBluetoothControl = jsonConvert.convert<String>(json['isBluetoothControl']);
	if (isBluetoothControl != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.isBluetoothControl = isBluetoothControl;
	}
	final String? distributionNetworkType = jsonConvert.convert<String>(json['distributionNetworkType']);
	if (distributionNetworkType != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.distributionNetworkType = distributionNetworkType;
	}
	final int? supportMedia = jsonConvert.convert<int>(json['supportMedia']);
	if (supportMedia != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportMedia = supportMedia;
	}
	final int? supportFindFriends = jsonConvert.convert<int>(json['supportFindFriends']);
	if (supportFindFriends != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportFindFriends = supportFindFriends;
	}
	final int? supportDiagnosis = jsonConvert.convert<int>(json['supportDiagnosis']);
	if (supportDiagnosis != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportDiagnosis = supportDiagnosis;
	}
	final int? supportQueryToken = jsonConvert.convert<int>(json['supportQueryToken']);
	if (supportQueryToken != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportQueryToken = supportQueryToken;
	}
	final int? supportNetworkBridge = jsonConvert.convert<int>(json['supportNetworkBridge']);
	if (supportNetworkBridge != null) {
		deviceHomeListHomeListRoomListApplianceListAbility.supportNetworkBridge = supportNetworkBridge;
	}
	return deviceHomeListHomeListRoomListApplianceListAbility;
}

Map<String, dynamic> $DeviceHomeListHomeListRoomListApplianceListAbilityToJson(DeviceHomeListHomeListRoomListApplianceListAbility entity) {
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