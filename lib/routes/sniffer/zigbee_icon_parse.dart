
class ZigbeeIcon {
  ZigbeeIcon._();

  /// 门锁
  static final lock = ['48','52','49','92','93','109','106','1019','122','116','1027','1059', '1250', '1039', '1043', '1063'];
  /// 调色灯带
  static final lampStrik = ['1263'];
  /// 轨道灯
  static final traceLight = ['1262'];
  /// 调光调色灯
  static final controlLight = ['55','56'];
  /// 开关面板
  static final switchDevice = ['68','71','74','76','85','87','78','81','83','111','88','1081', '1083', '1085', '1087', '1099'
      ,'1101','1103','1105','1107','1109','1115','1111','1113','1258','1259','1248','1249', '1255', '1256', '1257', '1243'
    ,'1100','1102','1104','1106','1112','1114', '1267', '1108', '1110', '1145'];
  /// 窗帘电机
  static final curtain = ['47', '51'];
  /// 传感器
  static final sensor = ['50','98','97','101','1260','1261', '15', '1268', '1270' ,'103'];
  /// 门磁
  static final mc = ['100'];

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
      return 'assets/imgs/zigbee/icon_switch.png';
    } else if(curtain.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_curtain.png';
    } else if(sensor.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_sensor.png';
    } else if(mc.any((element) => element == modelNum)) {
      return 'assets/imgs/zigbee/icon_mx.png';
    }
    return 'assets/imgs/zigbee/icon_mx.png';
  }


}