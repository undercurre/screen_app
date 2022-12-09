import 'package:screen_app/widgets/index.dart';

var light = Mode('light', '照明', 'assets/imgs/plugins/0x26/light_on.png', 'assets/imgs/plugins/0x26/light_off.png');

var blowing = Mode('blowing', '吹风', 'assets/imgs/plugins/0x26/blowing_on.png', 'assets/imgs/plugins/0x26/blowing_off.png');

var heating = Mode('heating', '暖风', 'assets/imgs/plugins/0x26/heating_on.png', 'assets/imgs/plugins/0x26/heating_off.png');

var bath = Mode('bath', '安心沐浴', 'assets/imgs/plugins/0x26/bath_on.png', 'assets/imgs/plugins/0x26/bath_off.png');

var ventilation = Mode('ventilation', '换气', 'assets/imgs/plugins/0x26/ventilation_on.png', 'assets/imgs/plugins/0x26/ventilation_off.png');

var drying = Mode('drying', '干燥', 'assets/imgs/plugins/0x26/drying_on.png', 'assets/imgs/plugins/0x26/drying_off.png');

var bathroomMasterMode = <Mode>[light, blowing, heating, bath, ventilation, drying];
