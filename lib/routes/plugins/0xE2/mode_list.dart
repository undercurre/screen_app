import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:screen_app/widgets/index.dart';

class ElectricWaterHeaterMode extends Mode {

  ElectricWaterHeaterMode(super.key, super.name, super.onIcon, super.offIcon);
}

var fastWash = ElectricWaterHeaterMode('fast_wash', '快速洗浴', 'assets/imgs/plugins/0xE2/fast_wash_on.png', 'assets/imgs/plugins/0xE2/fast_wash_off.png');

var eplus = ElectricWaterHeaterMode('eplus', ' e量增容', 'assets/imgs/plugins/0xE2/eplus_on.png', 'assets/imgs/plugins/0xE2/eplus_off.png');

var efficient = ElectricWaterHeaterMode('efficient', '节能模式', 'assets/imgs/plugins/0xE2/efficient_on.png', 'assets/imgs/plugins/0xE2/efficient_off.png');

var night = ElectricWaterHeaterMode('night', '峰谷夜电', 'assets/imgs/plugins/0xE2/night_on.png', 'assets/imgs/plugins/0xE2/night_off.png');

var summer = ElectricWaterHeaterMode('summer', '夏季模式', 'assets/imgs/plugins/0xE2/summer_on.png', 'assets/imgs/plugins/0xE2/summer_off.png');

var winter = ElectricWaterHeaterMode('winter', '冬季模式', 'assets/imgs/plugins/0xE2/winter_on.png', 'assets/imgs/plugins/0xE2/winter_off.png');

var sterilization = ElectricWaterHeaterMode('sterilization', '高温消毒', 'assets/imgs/plugins/0xE2/sterilization_on.png', 'assets/imgs/plugins/0xE2/sterilization_off.png');

var bath = ElectricWaterHeaterMode('bath', '普通模式', 'assets/imgs/plugins/0xE2/bath_on.png', 'assets/imgs/plugins/0xE2/bath_off.png');


var electricWaterHeaterModes = <Mode>[fastWash,eplus,efficient,night,summer,winter,sterilization,bath];


//下面的是根据json文件来判断支持的模式
// supportMode(String sn8) async {
//   List<EMode> models = await loadModes();
//   for (var element in models) {
//     if(element.sn8==sn8){
//       if(element.fastWash==1){
//         electricWaterHeaterModes.add(moon);
//       }
//       if(element.eplus==1){
//         electricWaterHeaterModes.add(eplus);
//       }
//     }
//
//   }
//   return electricWaterHeaterModes;
// }
//
// Future<List<EMode>> loadModes() async {
//   String jsonString = await rootBundle.loadString('assets/persons.json');
//   List<dynamic> jsonList = json.decode(jsonString);
//   return jsonList.map((json) => EMode.fromJson(json)).toList();
// }
//
// class EMode {
//   final String sn8;
//   final int fastWash,eplus,efficient,night,summer,winter,sterilization;
//
//   EMode({required this.sn8, required this.fastWash, required this.eplus, required this.efficient, required this.night, required this.summer, required this.winter, required this.sterilization});
//
//   factory EMode.fromJson(Map<String, dynamic> json) {
//     return EMode(
//       sn8: json['sn8'],
//       fastWash: json['fast_wash'],
//       eplus: json['eplus'],
//       efficient: json['efficient'],
//       night: json['night'],
//       summer: json['summer'],
//       winter: json['winter'],
//       sterilization: json['sterilization'],
//     );
//   }
// }
