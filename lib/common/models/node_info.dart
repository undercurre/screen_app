import 'endpoint.dart';

class NodeInfo<T extends Endpoint> {
  String devId;
  List<String> registerUsers;
  int masterId;
  String nodeName;
  String idType;
  String modelId;
  List<T> endList;
  int guard;
  String isAlarmDevice;
  String nodeId;
  int status;

  NodeInfo({
    required this.devId,
    required this.registerUsers,
    required this.masterId,
    required this.nodeName,
    required this.idType,
    required this.modelId,
    required this.endList,
    required this.guard,
    required this.isAlarmDevice,
    required this.nodeId,
    required this.status,
  });

  factory NodeInfo.fromJson(Map<String, dynamic> json, Endpoint Function(Map<String, dynamic>) endpointFromJson) {
    return NodeInfo(
      devId: json['devId'],
      registerUsers: List<String>.from(json['register_users']),
      masterId: json['masterId'],
      nodeName: json['nodename'],
      idType: json['idType'],
      modelId: json['modelid'],
      endList: List<T>.from(
        json['endlist'].map((endpointJson) => endpointFromJson(endpointJson)),
      ),
      guard: json['guard'],
      isAlarmDevice: json['is_alarm_device'],
      nodeId: json['nodeid'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'devId': devId,
      'register_users': registerUsers,
      'masterId': masterId,
      'nodename': nodeName,
      'idType': idType,
      'modelid': modelId,
      'endlist': endList.map((endpoint) => endpoint.toJson()).toList(),
      'guard': guard,
      'is_alarm_device': isAlarmDevice,
      'nodeid': nodeId,
      'status': status,
    };
  }
}
