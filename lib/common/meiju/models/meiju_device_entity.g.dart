import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_device_entity.dart';

MeiJuDeviceEntity $MeiJuDeviceEntityFromJson(Map<String, dynamic> json) {
	final MeiJuDeviceEntity deviceEntity = MeiJuDeviceEntity();
	final dynamic bindType = meijuJsonConvert.convert<dynamic>(json['bindType']);
	if (bindType != null) {
		deviceEntity.bindType = bindType;
	}
	final String? applianceCode = meijuJsonConvert.convert<String>(json['applianceCode']);
	if (applianceCode != null) {
		deviceEntity.applianceCode = applianceCode;
	}
	final String? sn = meijuJsonConvert.convert<String>(json['sn']);
	if (sn != null) {
		deviceEntity.sn = sn;
	}
	final String? onlineStatus = meijuJsonConvert.convert<String>(json['onlineStatus']);
	if (onlineStatus != null) {
		deviceEntity.onlineStatus = onlineStatus;
	}
	final String? type = meijuJsonConvert.convert<String>(json['type']);
	if (type != null) {
		deviceEntity.type = type;
	}
	final String? modelNumber = meijuJsonConvert.convert<String>(json['modelNumber']);
	if (modelNumber != null) {
		deviceEntity.modelNumber = modelNumber;
	}
	final String? name = meijuJsonConvert.convert<String>(json['name']);
	if (name != null) {
		deviceEntity.name = name;
	}
	final String? des = meijuJsonConvert.convert<String>(json['des']);
	if (des != null) {
		deviceEntity.des = des;
	}
	final String? activeStatus = meijuJsonConvert.convert<String>(json['activeStatus']);
	if (activeStatus != null) {
		deviceEntity.activeStatus = activeStatus;
	}
	final String? activeTime = meijuJsonConvert.convert<String>(json['activeTime']);
	if (activeTime != null) {
		deviceEntity.activeTime = activeTime;
	}
	final String? isSupportFetchStatus = meijuJsonConvert.convert<String>(json['isSupportFetchStatus']);
	if (isSupportFetchStatus != null) {
		deviceEntity.isSupportFetchStatus = isSupportFetchStatus;
	}
	final String? cardStatus = meijuJsonConvert.convert<String>(json['cardStatus']);
	if (cardStatus != null) {
		deviceEntity.cardStatus = cardStatus;
	}
	final String? hotspotName = meijuJsonConvert.convert<String>(json['hotspotName']);
	if (hotspotName != null) {
		deviceEntity.hotspotName = hotspotName;
	}
	final String? masterId = meijuJsonConvert.convert<String>(json['masterId']);
	if (masterId != null) {
		deviceEntity.masterId = masterId;
	}
	final String? attrs = meijuJsonConvert.convert<String>(json['attrs']);
	if (attrs != null) {
		deviceEntity.attrs = attrs;
	}
	final String? btMac = meijuJsonConvert.convert<String>(json['btMac']);
	if (btMac != null) {
		deviceEntity.btMac = btMac;
	}
	final String? btToken = meijuJsonConvert.convert<String>(json['btToken']);
	if (btToken != null) {
		deviceEntity.btToken = btToken;
	}
	final String? sn8 = meijuJsonConvert.convert<String>(json['sn8']);
	if (sn8 != null) {
		deviceEntity.sn8 = sn8;
	}
	final String? isOtherEquipment = meijuJsonConvert.convert<String>(json['isOtherEquipment']);
	if (isOtherEquipment != null) {
		deviceEntity.isOtherEquipment = isOtherEquipment;
	}
	final Map<String, dynamic>? ability = meijuJsonConvert.convert<Map<String, dynamic>>(json['ability']);
	if (ability != null) {
		deviceEntity.ability = ability;
	}
	final String? moduleType = meijuJsonConvert.convert<String>(json['moduleType']);
	if (moduleType != null) {
		deviceEntity.moduleType = moduleType;
	}
	final Map<String, dynamic>? detail = meijuJsonConvert.convert<Map<String, dynamic>>(json['detail']);
	if (detail != null) {
		deviceEntity.detail = detail;
	}
	return deviceEntity;
}

Map<String, dynamic> $MeiJuDeviceEntityToJson(MeiJuDeviceEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['bindType'] = entity.bindType;
	data['applianceCode'] = entity.applianceCode;
	data['sn'] = entity.sn;
	data['onlineStatus'] = entity.onlineStatus;
	data['type'] = entity.type;
	data['modelNumber'] = entity.modelNumber;
	data['name'] = entity.name;
	data['des'] = entity.des;
	data['activeStatus'] = entity.activeStatus;
	data['activeTime'] = entity.activeTime;
	data['isSupportFetchStatus'] = entity.isSupportFetchStatus;
	data['cardStatus'] = entity.cardStatus;
	data['hotspotName'] = entity.hotspotName;
	data['masterId'] = entity.masterId;
	data['attrs'] = entity.attrs;
	data['btMac'] = entity.btMac;
	data['btToken'] = entity.btToken;
	data['sn8'] = entity.sn8;
	data['isOtherEquipment'] = entity.isOtherEquipment;
	data['ability'] = entity.ability;
	data['moduleType'] = entity.moduleType;
	data['detail'] = entity.detail;
	return data;
}