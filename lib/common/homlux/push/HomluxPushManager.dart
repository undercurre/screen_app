import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomluxPushManager {
  static WebSocket? webSocket;

  static initConnect(
      {required String token,
      required String houseId,
      int retrySeconds = 2}) async {
    var reconnectScheduled = false;
    webSocket =
        await WebSocket.connect(dotenv.get('HOMLUX_PUSH_WSS') + houseId);

    void scheduleReconnect() {
      if (!reconnectScheduled) {
        Timer(
            Duration(seconds: retrySeconds),
            () => initConnect(
                token: token,
                houseId: houseId,
                retrySeconds: retrySeconds * 2));
      }
    }

    webSocket?.listen((event) {

            }, onError: () {

            }, onDone: () {

            }, cancelOnError: true);

  }
}
