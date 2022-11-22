import 'package:screen_app/widgets/index.dart';

var light = Mode('light', '照明', 'assets/imgs/plugins/0x26/light_on.png', 'assets/imgs/plugins/0x26/light_off.png');

var blow = Mode('blow', '吹风', 'assets/imgs/plugins/0x26/blow_on.png', 'assets/imgs/plugins/0x26/blow_off.png');

var warm = Mode('warm', '暖风', 'assets/imgs/plugins/0x26/warm_on.png', 'assets/imgs/plugins/0x26/warm_off.png');

var bath = Mode('bath', '安心沐浴', 'assets/imgs/plugins/0x26/bath_on.png', 'assets/imgs/plugins/0x26/bath_off.png');

var aeration = Mode('aeration', '换气', 'assets/imgs/plugins/0x26/aeration_on.png', 'assets/imgs/plugins/0x26/aeration_off.png');

var drying = Mode('drying', '干燥', 'assets/imgs/plugins/0x26/drying_on.png', 'assets/imgs/plugins/0x26/drying_off.png');

var bathroomMasterMode = <Mode>[light, blow, warm, bath, aeration, drying];