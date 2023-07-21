import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../common/global.dart';
import '../../common/models/city.dart';
import '../../common/models/district.dart';
import '../../common/models/province.dart';
import '../../states/weather_change_notifier.dart';

class AreaSelector extends StatefulWidget {
  const AreaSelector({super.key});

  @override
  _AreaSelectorState createState() => _AreaSelectorState();
}

class _AreaSelectorState extends State<AreaSelector> {
  // 假设这里有三个包含选择器选项的列表
  List<Province> provinces = [];
  List<City> cities = [];
  List<District> districts = [];

  // 选中的索引，默认为第一个选项
  int selectedProvinceIndex = 0;
  int selectedCityIndex = 0;
  int selectedDistrictIndex = 0;

  bool isInit = false;

  // 控制器
  FixedExtentScrollController provinceController =
      FixedExtentScrollController();
  FixedExtentScrollController cityController = FixedExtentScrollController();
  FixedExtentScrollController districtController =
      FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final weatherModel = Provider.of<WeatherModel>(context, listen: false);
    String jsonString =
        await rootBundle.loadString('assets/data/iot_city.json');
    List<dynamic> jsonList = json.decode(jsonString);

    provinces = jsonList.map((json) => Province.fromJson(json)).toList();

    logger.i('省', weatherModel.selectedProvince.province);
    logger.i('市', weatherModel.selectedCity.cityName);
    logger.i('区', weatherModel.selectedDistrict.cityName);

    setState(() {
      selectedProvinceIndex = provinces.indexWhere((element) =>
          element.province == weatherModel.selectedProvince.province);
      cities = provinces[selectedProvinceIndex].cityList;
      selectedCityIndex = cities.indexWhere(
          (element) => element.areaid == weatherModel.selectedCity.areaid);
      districts = cities[selectedCityIndex].areaList;
      selectedDistrictIndex = districts.indexWhere(
          (element) => element.areaid == weatherModel.selectedDistrict.areaid);
    });
    logger.i('省', selectedProvinceIndex);
    logger.i('市', selectedCityIndex);
    logger.i('区', selectedDistrictIndex);

    await provinceController.animateToItem(selectedProvinceIndex,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    await cityController.animateToItem(selectedCityIndex,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    await districtController.animateToItem(selectedDistrictIndex,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    final weatherModel = Provider.of<WeatherModel>(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF272F41), Color(0xFF080C14)],
        ),
      ),
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            width: 480,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.64),
                      fontSize: 22,
                    ),
                  ),
                ),
                const Text("选择地区",
                    style: TextStyle(
                        color: Color(0XD8FFFFFF),
                        fontSize: 28,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
                GestureDetector(
                  onTap: () {
                    weatherModel.updateSelectedProvince(
                        provinces[selectedProvinceIndex]);
                    weatherModel.updateSelectedCity(cities[selectedCityIndex]);
                    weatherModel.updateSelectedDistrict(
                        districts[selectedDistrictIndex]);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '完成',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.64),
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 173,
                  left: 20,
                  width: 440,
                  height: 64,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.32),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    height: 240, // 选择器的高度
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildSelector(
                            140,
                            27,
                            provinceController,
                            provinces.map((e) => e.province).toList(),
                            selectedProvinceIndex, (index) {
                          if (isInit) {
                            setState(() {
                              selectedProvinceIndex = index;
                              cities =
                                  provinces[selectedProvinceIndex].cityList;
                              districts = cities[selectedCityIndex].areaList;
                              selectedCityIndex = 0;
                            });
                            cityController.animateToItem(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                            districtController.animateToItem(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          }
                        }),
                        buildSelector(
                            140,
                            25,
                            cityController,
                            cities.map((e) => e.cityName).toList(),
                            selectedCityIndex, (index) {
                          if (isInit) {
                            setState(() {
                              selectedCityIndex = index;
                              districts = cities[selectedCityIndex].areaList;
                              selectedDistrictIndex = 0;
                            });
                            districtController.animateToItem(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          }
                        }),
                        buildSelector(
                            140,
                            25,
                            districtController,
                            districts.map((e) => e.cityName).toList(),
                            selectedDistrictIndex, (index) {
                          setState(() {
                            if (isInit) {
                              selectedDistrictIndex = index;
                            }
                          });
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelector(
      double width,
      double fontSize,
      FixedExtentScrollController controller,
      List<String> items,
      int selectedIndex,
      Function(int) onSelected) {
    return Container(
      width: width,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        physics: FixedExtentScrollPhysics(),
        // Use custom physics for snapping to center
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            double opacity = 1.0 - (0.5 * (selectedIndex - index).abs());

            return GestureDetector(
              onTap: () {
                onSelected(index);
              },
              child: Center(
                child: Opacity(
                  opacity: opacity.clamp(0.2, 1.0),
                  child: Text(
                    items[index],
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: items[index].length > 3
                          ? (fontSize - items[index].length) *
                              (1.0 - (0.1 * (selectedIndex - index).abs()))
                          : 24,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
        onSelectedItemChanged: (index) {
          onSelected(index);
        },
      ),
    );
  }
}
