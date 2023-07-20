import 'district.dart';

class City {
  String areaid;
  String cityName;
  String longitude;
  String latitude;
  String adCode;
  List<District> areaList;

  City(
      {required this.areaid,
      required this.cityName,
      required this.longitude,
      required this.latitude,
      required this.adCode,
      required this.areaList});

  factory City.fromJson(Map<String, dynamic> json) {
    List<dynamic> districtListJson = json['areaList'];
    List<District> districtList = districtListJson
        .map((districtJson) => District.fromJson(districtJson))
        .toList();

    return City(
        areaid: json['areaid'] ?? '',
        cityName: json['cityName'],
        longitude: json['longitude'] ?? '',
        latitude: json['latitude'] ?? '',
        adCode: json['adCode'] ?? '',
        areaList: districtList);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> districtListJson =
    areaList.map((district) => district.toJson()).toList();

    return {
      'areaid': areaid,
      'cityName': cityName,
      'longitude': longitude,
      'latitude': latitude,
      'adCode': adCode,
      'areaList': districtListJson,
    };
  }
}
