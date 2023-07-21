import 'city.dart';

class Province {
  String province;
  List<City> cityList;

  Province({required this.province, required this.cityList});

  factory Province.fromJson(Map<String, dynamic> json) {
    List<dynamic> cityListJson = json['cityList'];
    List<City> cityList =
    cityListJson.map((cityJson) => City.fromJson(cityJson)).toList();

    return Province(
      province: json['province'],
      cityList: cityList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> cityListJson =
    cityList.map((city) => city.toJson()).toList();

    return {
      'province': province,
      'cityList': cityListJson,
    };
  }
}