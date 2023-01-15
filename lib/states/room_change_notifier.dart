import 'package:screen_app/common/global.dart';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../models/index.dart';

// todo: 合并deviceModelList
class RoomModel extends ProfileChangeNotifier {
  RoomEntity _roomInfo = Global.profile.roomInfo!;

  RoomEntity get roomInfo => _roomInfo;

  set roomInfo(RoomEntity newRoom) {
    _roomInfo = newRoom;
    logger.i("RoomModelChange: $roomInfo");
    notifyListeners();
  }
}
