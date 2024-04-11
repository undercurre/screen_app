
import 'package:screen_app/widgets/index.dart';

class GasWaterHeaterMode extends Mode {

  GasWaterHeaterMode(super.key, super.name, super.onIcon, super.offIcon);
}

var kitchen = GasWaterHeaterMode('kitchen', '厨房模式', 'assets/imgs/plugins/0xE3/kitchen_on.png', 'assets/imgs/plugins/0xE3/kitchen_off.png');

var invalid = GasWaterHeaterMode('invalid', ' 普通模式', 'assets/imgs/plugins/0xE3/invalid_on.png', 'assets/imgs/plugins/0xE3/invalid_off.png');

var shower = GasWaterHeaterMode('shower', '洗浴模式', 'assets/imgs/plugins/0xE3/shower_on.png', 'assets/imgs/plugins/0xE3/shower_off.png');

var thalposis = GasWaterHeaterMode('night', '随温模式', 'assets/imgs/plugins/0xE3/thalposis_on.png', 'assets/imgs/plugins/0xE3/thalposis_off.png');

var highTemperature = GasWaterHeaterMode('high_temperature', '高温模式', 'assets/imgs/plugins/0xE3/high_temperature_on.png', 'assets/imgs/plugins/0xE3/high_temperature_off.png');

var baby = GasWaterHeaterMode('baby', '婴儿模式', 'assets/imgs/plugins/0xE3/baby_on.png', 'assets/imgs/plugins/0xE3/baby_off.png');

var old = GasWaterHeaterMode('sterilization', '老人模式', 'assets/imgs/plugins/0xE3/old_on.png', 'assets/imgs/plugins/0xE3/old_off.png');

var adult = GasWaterHeaterMode('adult', '成人模式', 'assets/imgs/plugins/0xE3/bath_on.png', 'assets/imgs/plugins/0xE3/bath_off.png');


var gasWaterHeaterModes = <Mode>[kitchen,invalid,shower,thalposis,highTemperature,baby,old,adult];


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
