import '../mode.dart';

var light = Mode('light', '照明', 'assets/imgs/plugins/0x26/light_on_icon.png', 'assets/imgs/plugins/0x26/light_off_icon.png');

var blow = Mode('blow', '吹风', 'assets/imgs/plugins/0x26/blow_on_icon.png', 'assets/imgs/plugins/0x26/blow_off_icon.png');

var warm = Mode('warm', '暖风', 'assets/imgs/plugins/0x26/warm_on_icon.png', 'assets/imgs/plugins/0x26/warm_off_icon.png');

var bath = Mode('bath', '安心沐浴', 'assets/imgs/plugins/0x26/bath_on_icon.png', 'assets/imgs/plugins/0x26/bath_off_icon.png');

var aeration = Mode('aeration', '换气', 'assets/imgs/plugins/0x26/aeration_on_icon.png', 'assets/imgs/plugins/0x26/aeration_off_icon.png');

var drying = Mode('drying', '干燥', 'assets/imgs/plugins/0x26/drying_on_icon.png', 'assets/imgs/plugins/0x26/drying_off_icon.png');

var bathroomMasterMode = <Mode>[light, blow, warm, bath, aeration, drying];