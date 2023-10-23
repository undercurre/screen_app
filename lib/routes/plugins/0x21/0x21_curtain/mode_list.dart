import 'package:screen_app/widgets/index.dart';

var open = Mode('open', '打开', 'assets/imgs/plugins/0x14/all-open-on.png', 'assets/imgs/plugins/0x14/all-open-off.png');

var close = Mode('close', '关闭', 'assets/imgs/plugins/0x14/all-close-on.png', 'assets/imgs/plugins/0x14/all-close-off.png');

var running = Mode('stop', '暂停', 'assets/imgs/plugins/0x14/run.png', 'assets/imgs/plugins/0x14/pause.png');

var curtainModes = <Mode>[open, running, close];

var curtainPanelModes1 = <Mode>[open, close];

var curtainPanelModes2 = <Mode>[open, close];