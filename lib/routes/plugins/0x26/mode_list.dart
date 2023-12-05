import 'package:screen_app/widgets/index.dart';

var light = Mode('light', '照明', 'assets/newUI/yubamodel/light.png', 'assets/newUI/yubamodel/light_off.png');

var blowing = Mode('blowing', '吹风', 'assets/newUI/yubamodel/blowing.png', 'assets/newUI/yubamodel/blowing_off.png');

var heating = Mode('heating', '取暖', 'assets/newUI/yubamodel/heating.png', 'assets/newUI/yubamodel/heating_off.png');

var bath = Mode('bath', '安心沐浴', 'assets/newUI/yubamodel/bath.png', 'assets/newUI/yubamodel/bath_off.png');

var ventilation = Mode('ventilation', '换气', 'assets/newUI/yubamodel/ventilation.png', 'assets/newUI/yubamodel/ventilation_off.png');

var drying = Mode('drying', '干燥', 'assets/newUI/yubamodel/drying.png', 'assets/newUI/yubamodel/drying_off.png');

var bathroomMasterMode = <Mode>[light, blowing, heating, ventilation];
