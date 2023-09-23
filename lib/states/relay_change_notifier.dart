import 'package:flutter/cupertino.dart';

import '../channel/index.dart';
import '../widgets/event_bus.dart';

class RelayModel extends ChangeNotifier {
  bool localRelay1 = false;
  bool localRelay2 = false;

  RelayModel() {
    gatewayChannel.relay2IsOpen()
        .then((value) => localRelay2 = value);
    gatewayChannel.relay1IsOpen()
        .then((value) => localRelay1 = value);

    bus.off("relay1StateChange", relay1StateChange);
    bus.off("relay2StateChange", relay2StateChange);
    bus.on("relay1StateChange", relay1StateChange);
    bus.on("relay2StateChange", relay2StateChange);
  }

  void relay1StateChange(dynamic open) {
    localRelay1 = open as bool;
    notifyListeners();
  }

  void relay2StateChange(dynamic open) {
    localRelay2 = open as bool;
    notifyListeners();
  }

  // 控制Relay1
  void toggleRelay1() {
    localRelay1 = !localRelay1;
    gatewayChannel.controlRelay1Open(localRelay1);
    notifyListeners();
  }

  // 控制Relay2
  void toggleRelay2() {
    localRelay2 = !localRelay2;
    gatewayChannel.controlRelay2Open(localRelay2);
    notifyListeners();
  }
}
