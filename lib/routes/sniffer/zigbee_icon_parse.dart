
class ZigbeeIcon {
  ZigbeeIcon._();

  /// 门锁
  static final lock = ['48','52','49','92','93','109','106','1019','122','116','1027','1059', '1250', '1039', '1043', '1063'];
  /// 调色灯带
  static final lampStrik = ['1263', '1276', '1351'];
  /// 轨道灯
  static final traceLight = ['1262'];
  /// 调光调色灯
  static final controlLight = ["56", "57", "58", "1359", "1352", "1353"];
  /// 开关面板
  static final switchDevice = ['68','71','74','76','85','87','78','81','83','88','1081', '1083', '1085', '1087', '1099'
      ,'1101','1103','1105','1107','1109','1115','1111','1113','1248','1249', '1255', '1256', '1257', '1243'
    ,'1100','1102','1104','1106','1112','1114', '1267', '1108', '1110', '1145', "1347", "1360", "1348", "1361",
    "1349", "1362", "1350", "1363"];
  /// 窗帘电机
  static final curtain = ['47', '51'];
  /// 传感器
  static final sensor = ['98','97','15', '1268', '1270' ,'103'];
  /// 门磁
  static final mc = ['100'];
  /// 气感
  static final air = ['101', '1260'];
  /// 烟感
  static final smoke = ['1261'];
  /// 门窗
  static final door = ['100'];
  /// 温湿度
  static final humidity = ['50'];
  /// 报警
  static final alarm = ['79', '1243'];
  /// 水浸
  static final water = ['96'];
  ///红外
  static final infrared = ['25'];
  /// 插座
  static final socket = ['111', '1258', '1259'];
  /// 空调
  static final aircondition = ['3017'];
  /// 新风
  static final airconditionXf = ['3018'];
  /// 地暖
  static final fool = ['3019'];

  static String parse(String modelNum) {
    if(lock.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_lock.png';
    } else if(lampStrik.any((element) => element == modelNum)){
      return 'assets/imgs/zigbee/icon_lamp_strick.png';
    } else if(traceLight.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_track.png';
    } else if(controlLight.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_td.png';
    } else if(switchDevice.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_one_switch.png';
    } else if(curtain.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_curtain.png';
    } else if(sensor.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_sensor.png';
    } else if(mc.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_mx.png';
    } else if(air.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_sessor_air.png';
    } else if(smoke.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_sessor_smoke.png';
    } else if(door.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_sessor_door.png';
    } else if(humidity.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_sessor_humidity.png';
    } else if(alarm.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_alarm.png';
    } else if(water.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_water.png';
    } else if(infrared.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_infrared.png';
    } else if(socket.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_socket.png';
    }  else if(aircondition.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_air_condition.png';
    }  else if(airconditionXf.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_air_condition_xf.png';
    } else if(fool.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_fool.png';
    }
    return 'assets/imgs/zigbee/icon_default.png';
  }


}