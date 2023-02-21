import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/delete_device_result_entity.dart';

DeleteDeviceResultEntity $DeleteDeviceResultEntityFromJson(Map<String, dynamic> json) {
	final DeleteDeviceResultEntity deleteDeviceResultEntity = DeleteDeviceResultEntity();
	final List<String>? errorList = jsonConvert.convertListNotNull<String>(json['errorList']);
	if (errorList != null) {
		deleteDeviceResultEntity.errorList = errorList;
	}
	return deleteDeviceResultEntity;
}

Map<String, dynamic> $DeleteDeviceResultEntityToJson(DeleteDeviceResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['errorList'] =  entity.errorList;
	return data;
}