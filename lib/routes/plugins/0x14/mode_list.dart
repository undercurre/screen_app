import 'package:screen_app/widgets/index.dart';

var open = Mode('open', '全开', 'assets/imgs/plugins/0x14/all-open-on.png', 'assets/imgs/plugins/0x14/all-open-off.png');

var close = Mode('close', '全关', 'assets/imgs/plugins/0x14/all-close-on.png', 'assets/imgs/plugins/0x14/all-close-off.png');

var stop = Mode('stop', '暂停', 'assets/imgs/plugins/0x14/run.png', 'assets/imgs/plugins/0x14/pause.png');

var curtainModes = <Mode>[open, stop, close];