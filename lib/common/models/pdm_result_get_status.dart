class PDMResultGetStatus {
  String deviceLatestVersion;
  String modelId;
  int guard;
  String msgId;
  List<EndPointStatus> endPointStatusList;
  String nodeId;

  PDMResultGetStatus({
    required this.deviceLatestVersion,
    required this.modelId,
    required this.guard,
    required this.msgId,
    required this.endPointStatusList,
    required this.nodeId,
  });

  factory PDMResultGetStatus.fromJson(Map<String, dynamic> json) {
    List<EndPointStatus> endPointStatusList = [];
    if (json['endPointStatusList'] != null) {
      var controlList = json['endPointStatusList'] as List;
      endPointStatusList = controlList
          .map((control) => EndPointStatus(
                endPoint: control['endPoint'],
                attribute: control['attribute'],
              ))
          .toList();
    }

    return PDMResultGetStatus(
      deviceLatestVersion: json['deviceLatestVersion'],
      modelId: json['modelId'],
      guard: json['guard'],
      msgId: json['msgId'],
      endPointStatusList: endPointStatusList,
      nodeId: json['nodeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceLatestVersion': deviceLatestVersion,
      'modelId': modelId,
      'guard': guard,
      'msgId': msgId,
      'endPointStatusList': endPointStatusList
          .map((control) => {
                'endPoint': control.endPoint,
                'attribute': control.attribute,
              })
          .toList(),
      'nodeId': nodeId,
    };
  }
}

class EndPointStatus {
  int endPoint;
  int attribute;

  EndPointStatus({
    required this.endPoint,
    required this.attribute,
  });
}
