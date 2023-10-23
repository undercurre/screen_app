import 'package:screen_app/common/meiju/generated/json/base/meiju_json_convert_content.dart';

import 'meiju_delete_device_result_entity.dart';

MeiJuDeleteDeviceResultEntity $MeiJuDeleteDeviceResultEntityFromJson(Map<String, dynamic> json) {
	final MeiJuDeleteDeviceResultEntity deleteDeviceResultEntity = MeiJuDeleteDeviceResultEntity();
	final List<String>? errorList = meijuJsonConvert.convertListNotNull<String>(json['errorList']);
	if (errorList != null) {
		deleteDeviceResultEntity.errorList = errorList;
	}
	return deleteDeviceResultEntity;
}

Map<String, dynamic> $MeiJuDeleteDeviceResultEntityToJson(MeiJuDeleteDeviceResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['errorList'] =  entity.errorList;
	return data;
}