import '../mode.dart';

var strong = Mode('strong', '强风', 'assets/imgs/plugins/0x40/strong_wind_on.png', 'assets/imgs/plugins/0x40/strong_wind_off.png');

var weak = Mode('weak', '弱风', 'assets/imgs/plugins/0x40/weak_wind_on.png', 'assets/imgs/plugins/0x40/weak_wind_off.png');

var light = Mode('light', '照明', 'assets/imgs/plugins/0x40/light_on.png', 'assets/imgs/plugins/0x40/light_off.png');

var refresh = Mode('refresh', '换气', 'assets/imgs/plugins/0x40/refresh_on.png', 'assets/imgs/plugins/0x40/refresh_off.png');

var coolMasterMode = <Mode>[strong, weak, light, refresh];