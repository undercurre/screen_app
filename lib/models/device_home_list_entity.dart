import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/device_home_list_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class DeviceHomeListEntity {

	List<DeviceHomeListHomeList>? homeList;
  
  DeviceHomeListEntity();

  factory DeviceHomeListEntity.fromJson(Map<String, dynamic> json) => $DeviceHomeListEntityFromJson(json);

  Map<String, dynamic> toJson() => $DeviceHomeListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DeviceHomeListHomeList {

	String? roomCount;
	String? address;
	String? coordinate;
	String? roleId;
	String? applianceCount;
	String? memberCount;
	String? createUserUid;
	String? number;
	String? isDefault;
	dynamic des;
	String? areaid;
	dynamic profilePicUrl;
	String? roleTag;
	String? createTime;
	List<dynamic>? members;
	String? name;
	String? nickname;
	String? createUser;
	String? id;
	dynamic smartProductId;
	List<DeviceHomeListHomeListRoomList>? roomList;
  
  DeviceHomeListHomeList();

  factory DeviceHomeListHomeList.fromJson(Map<String, dynamic> json) => $DeviceHomeListHomeListFromJson(json);

  Map<String, dynamic> toJson() => $DeviceHomeListHomeListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DeviceHomeListHomeListRoomList {

	List<DeviceHomeListHomeListRoomListApplianceList>? applianceList;
	String? isDefault;
	dynamic code;
	String? des;
	String? name;
	String? icon;
	String? id;
	String? homegroupId;
  
  DeviceHomeListHomeListRoomList();

  factory DeviceHomeListHomeListRoomList.fromJson(Map<String, dynamic> json) => $DeviceHomeListHomeListRoomListFromJson(json);

  Map<String, dynamic> toJson() => $DeviceHomeListHomeListRoomListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DeviceHomeListHomeListRoomListApplianceList {

	dynamic templateOfTSL;
	String? isOtherEquipment;
	String? enterprise;
	String? onlineStatus;
	String? btMac;
	dynamic switchStatus;
	String? type;
	String? equipmentType;
	dynamic des;
	String? newAttrs;
	dynamic nfcLabels;
	String? id;
	String? sn;
	DeviceHomeListHomeListRoomListApplianceListAbility? ability;
	dynamic cardStatus;
	dynamic enterpriseCode;
	bool? supportWot;
	String? activeTime;
	String? bindType;
	String? applianceCode;
	String? roomName;
	dynamic command;
	String? attrs;
	String? btToken;
	String? hotspotName;
	String? masterId;
	dynamic nfcLabelInfos;
	String? activeStatus;
	String? name;
	String? wifiVersion;
	String? isSupportFetchStatus;
	String? modelNumber;
	dynamic smartProductId;
	String? isBluetooth;
	dynamic sn8;
	dynamic nameChanged;
	dynamic status;
	dynamic detail;
  
  DeviceHomeListHomeListRoomListApplianceList();

  factory DeviceHomeListHomeListRoomListApplianceList.fromJson(Map<String, dynamic> json) => $DeviceHomeListHomeListRoomListApplianceListFromJson(json);

  Map<String, dynamic> toJson() => $DeviceHomeListHomeListRoomListApplianceListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class DeviceHomeListHomeListRoomListApplianceListAbility {

	int? bleAppBindStatus;
	int? supportGateway;
	int? supportWot;
	int? supportBleMesh;
	int? schoolTime;
	int? supportADNS;
	int? supportBleDataTransfers;
	int? supportBindStatus;
	int? supportOfflineMsg;
	int? bleDeviceStatus;
	int? supportNewKeyVersion;
	int? domainSwitch;
	int? supportBindCode;
	int? supportBleOta;
	int? supportReset;
	int? supportRouterReportAndQuery;
	String? isBluetoothControl;
	String? distributionNetworkType;
	int? supportMedia;
	int? supportFindFriends;
	int? supportDiagnosis;
	int? supportQueryToken;
	int? supportNetworkBridge;
  
  DeviceHomeListHomeListRoomListApplianceListAbility();

  factory DeviceHomeListHomeListRoomListApplianceListAbility.fromJson(Map<String, dynamic> json) => $DeviceHomeListHomeListRoomListApplianceListAbilityFromJson(json);

  Map<String, dynamic> toJson() => $DeviceHomeListHomeListRoomListApplianceListAbilityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}