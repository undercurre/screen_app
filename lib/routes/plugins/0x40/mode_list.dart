import 'package:screen_app/widgets/index.dart';

var strong = Mode('strong', '强风', 'assets/imgs/plugins/0x40/strong_wind_on.png', 'assets/imgs/plugins/0x40/strong_wind_off.png');

var weak = Mode('weak', '弱风', 'assets/imgs/plugins/0x40/weak_wind_on.png', 'assets/imgs/plugins/0x40/weak_wind_off.png');

var light = Mode('light', '照明', 'assets/imgs/plugins/0x40/light_on.png', 'assets/imgs/plugins/0x40/light_off.png');

var ventilation = Mode('ventilation', '换气', 'assets/imgs/plugins/0x40/ventilation_on.png', 'assets/imgs/plugins/0x40/ventilation_off.png');

var coolMasterMode = <Mode>[strong, weak, light, ventilation];