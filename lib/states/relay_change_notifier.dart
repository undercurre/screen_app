import 'package:flutter/cupertino.dart';

import '../channel/index.dart';

class RelayModel extends ChangeNotifier {
  bool localRelay1 = false;
  bool localRelay2 = false;

  RelayModel() {
    gatewayChannel.relay2IsOpen()
        .then((value) => localRelay2 = value);
    gatewayChannel.relay1IsOpen()
        .then((value) => localRelay1 = value);
  }

  // 控制Relay1
  void toggleRelay1() {
    localRelay1 = !localRelay1;
    gatewayChannel.controlRelay1Open(!localRelay1);
    notifyListeners();
  }

  // 控制Relay2
  void toggleRelay2() {
    localRelay2 = !localRelay2;
    gatewayChannel.controlRelay2Open(!localRelay2);
    notifyListeners();
  }
}
