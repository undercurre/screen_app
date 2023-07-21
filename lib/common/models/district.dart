class District {
  String areaid;
  String cityName;
  String longitude;
  String latitude;
  String adCode;

  District(
      {required this.areaid,
        required this.cityName,
        required this.longitude,
        required this.latitude,
        required this.adCode});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      areaid: json['areaid'],
      cityName: json['cityName'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      adCode: json['adCode'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'areaid': areaid,
      'cityName': cityName,
      'longitude': longitude,
      'latitude': latitude,
      'adCode': adCode,
    };
  }
}