import 'package:screen_app/widgets/index.dart';

class ZigbeeLightMode extends Mode {
  num brightness;
  num colorTemperature;

  ZigbeeLightMode(super.key, super.name, super.onIcon, super.offIcon, this.brightness, this.colorTemperature);
}

var moon = ZigbeeLightMode('night', '小夜灯', 'assets/imgs/plugins/0x13/moon_on.png', 'assets/imgs/plugins/0x13/moon_off.png', 1, 0);

var read = ZigbeeLightMode('warm', '暖色', 'assets/imgs/plugins/0x13/read_on.png', 'assets/imgs/plugins/0x13/read_off.png', 100, 0);

var mild = ZigbeeLightMode('cold', '冷色', 'assets/imgs/plugins/0x13/mild_on.png', 'assets/imgs/plugins/0x13/mild_off.png', 100, 100);

var film = ZigbeeLightMode('sun', '日光', 'assets/imgs/plugins/0x13/film_on.png', 'assets/imgs/plugins/0x13/film_off.png', 100, 50);

var lightModes = <Mode>[moon, read, mild, film];