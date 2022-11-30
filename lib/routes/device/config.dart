import 'package:screen_app/routes/device/power_api.dart';
import 'package:screen_app/routes/device/status_api.dart';
import 'package:screen_app/routes/plugins/0x26/mode_list.dart';

import '../../common/api/api.dart';

class DeviceOnList {
  String name;
  String onIcon;
  String offIcon;
  String type;
  List<String>? disabled;
  List<String>? modelNum;
  List<String>? sn8s;
  Function? powerApi;
  Function? statusApi;
  String? paramName;

  DeviceOnList(this.name, this.onIcon, this.offIcon, this.type, {this.disabled, this.modelNum, this.powerApi, this.statusApi, this.paramName});
}

DeviceOnList wifiLight = DeviceOnList('吸顶灯', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x13', powerApi: PowerApi.power0x13, statusApi: StatusApi.detailOf0x13);
DeviceOnList zigbeeLightHasColor = DeviceOnList('调光调色灯', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x13', modelNum: ["57", "1262", "1263", "56"]);
DeviceOnList zigbeeLightNoColor = DeviceOnList('调光调色灯', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x13', modelNum: ["55", "1254", "54"]);
DeviceOnList wifiCurtain = DeviceOnList('智能窗帘', 'assets/imgs/device/chuanglian_icon_on.png', 'assets/imgs/device/chuanglian_icon_off.png', '0x14');
DeviceOnList zigbeeCurtain = DeviceOnList('智能窗帘', 'assets/imgs/device/chuanglian_icon_on.png', 'assets/imgs/device/chuanglian_icon_off.png', '0x14', modelNum: []);
DeviceOnList curtainPanelOne = DeviceOnList('一路窗帘面板', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x21', modelNum: []);
DeviceOnList curtainPanelTwo = DeviceOnList('二路窗帘面板', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x21', modelNum: []);
DeviceOnList lock = DeviceOnList('智能门锁', 'assets/imgs/device/lock_on.png', 'assets/imgs/device/lock_off.png', '0x09');
DeviceOnList airCondition = DeviceOnList('空调', 'assets/imgs/device/air_conditioner_on.png', 'assets/imgs/device/air_conditioner_off.png', '0xac');
DeviceOnList bathHeater = DeviceOnList('浴霸', 'assets/imgs/device/bath_heater_on.png', 'assets/imgs/device/bath_heater_off.png', '0x26');
DeviceOnList liangBa = DeviceOnList('凉霸', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x40');
DeviceOnList xinFeng = DeviceOnList('新风', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0xce');
DeviceOnList diNuan = DeviceOnList('地暖', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0xcf');
DeviceOnList chouYouYan = DeviceOnList('抽油烟机', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0xb6');
DeviceOnList liangYiJia = DeviceOnList('晾衣架', 'assets/imgs/device/clothes_hanger_on.png', 'assets/imgs/device/clothes_hanger_off.png', '0x17');
DeviceOnList maoJinJia = DeviceOnList('毛巾架', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x49');
DeviceOnList camera = DeviceOnList('摄像头', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x2B');
DeviceOnList smartScreen = DeviceOnList('智慧屏', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0x44');
DeviceOnList electricHeater = DeviceOnList('电热水器', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0xe2');
DeviceOnList gasHeater = DeviceOnList('燃热水器', 'assets/imgs/device/dengguang_icon_on.png', 'assets/imgs/device/dengguang_icon_off.png', '0xe3');
DeviceOnList lightGroup = DeviceOnList('灯组', 'assets/imgs/device/dengzu_icon_on.png', 'assets/imgs/device/dengzu_icon_off.png', 'lightGroup');
DeviceOnList gateway = DeviceOnList('智能网关', 'assets/imgs/device/dengzu_icon_on.png', 'assets/imgs/device/dengzu_icon_off.png', '0x16');
DeviceOnList doorMagnetic = DeviceOnList('门磁传感器', 'assets/imgs/device/door_magnetic_sensor_on.png', 'assets/imgs/device/door_magnetic_sensor_off.png', '0x21', modelNum: ['3']);

List<DeviceOnList> deviceConfig = [
  wifiLight,
  zigbeeLightHasColor,
  zigbeeLightNoColor,
  wifiCurtain,
  zigbeeCurtain,
  curtainPanelOne,
  curtainPanelTwo,
  lock,
  airCondition,
  bathHeater,
  liangBa,
  xinFeng,
  diNuan,
  chouYouYan,
  liangYiJia,
  maoJinJia,
  camera,
  smartScreen,
  electricHeater,
  gasHeater,
  lightGroup,
  doorMagnetic
];