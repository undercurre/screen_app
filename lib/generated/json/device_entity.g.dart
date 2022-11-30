import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/device_entity.dart';

DeviceEntity $DeviceEntityFromJson(Map<String, dynamic> json) {
	final DeviceEntity deviceEntity = DeviceEntity();
	final dynamic? bindType = jsonConvert.convert<dynamic>(json['bindType']);
	if (bindType != null) {
		deviceEntity.bindType = bindType;
	}
	final String? applianceCode = jsonConvert.convert<String>(json['applianceCode']);
	if (applianceCode != null) {
		deviceEntity.applianceCode = applianceCode;
	}
	final String? sn = jsonConvert.convert<String>(json['sn']);
	if (sn != null) {
		deviceEntity.sn = sn;
	}
	final String? onlineStatus = jsonConvert.convert<String>(json['onlineStatus']);
	if (onlineStatus != null) {
		deviceEntity.onlineStatus = onlineStatus;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		deviceEntity.type = type;
	}
	final String? modelNumber = jsonConvert.convert<String>(json['modelNumber']);
	if (modelNumber != null) {
		deviceEntity.modelNumber = modelNumber;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		deviceEntity.name = name;
	}
	final String? des = jsonConvert.convert<String>(json['des']);
	if (des != null) {
		deviceEntity.des = des;
	}
	final String? activeStatus = jsonConvert.convert<String>(json['activeStatus']);
	if (activeStatus != null) {
		deviceEntity.activeStatus = activeStatus;
	}
	final String? activeTime = jsonConvert.convert<String>(json['activeTime']);
	if (activeTime != null) {
		deviceEntity.activeTime = activeTime;
	}
	final String? isSupportFetchStatus = jsonConvert.convert<String>(json['isSupportFetchStatus']);
	if (isSupportFetchStatus != null) {
		deviceEntity.isSupportFetchStatus = isSupportFetchStatus;
	}
	final String? cardStatus = jsonConvert.convert<String>(json['cardStatus']);
	if (cardStatus != null) {
		deviceEntity.cardStatus = cardStatus;
	}
	final String? hotspotName = jsonConvert.convert<String>(json['hotspotName']);
	if (hotspotName != null) {
		deviceEntity.hotspotName = hotspotName;
	}
	final String? masterId = jsonConvert.convert<String>(json['masterId']);
	if (masterId != null) {
		deviceEntity.masterId = masterId;
	}
	final String? attrs = jsonConvert.convert<String>(json['attrs']);
	if (attrs != null) {
		deviceEntity.attrs = attrs;
	}
	final String? btMac = jsonConvert.convert<String>(json['btMac']);
	if (btMac != null) {
		deviceEntity.btMac = btMac;
	}
	final String? btToken = jsonConvert.convert<String>(json['btToken']);
	if (btToken != null) {
		deviceEntity.btToken = btToken;
	}
	final String? sn8 = jsonConvert.convert<String>(json['sn8']);
	if (sn8 != null) {
		deviceEntity.sn8 = sn8;
	}
	final String? isOtherEquipment = jsonConvert.convert<String>(json['isOtherEquipment']);
	if (isOtherEquipment != null) {
		deviceEntity.isOtherEquipment = isOtherEquipment;
	}
	final Map<String, dynamic>? ability = jsonConvert.convert<Map<String, dynamic>>(json['ability']);
	if (ability != null) {
		deviceEntity.ability = ability;
	}
	final String? moduleType = jsonConvert.convert<String>(json['moduleType']);
	if (moduleType != null) {
		deviceEntity.moduleType = moduleType;
	}
	return deviceEntity;
}

Map<String, dynamic> $DeviceEntityToJson(DeviceEntity entity) {
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
	return data;
}