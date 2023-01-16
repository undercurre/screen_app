import 'package:flutter/foundation.dart';

import '../common/index.dart';
import '../models/index.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  ProfileEntity get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners(); //通知依赖的Widget更新
  }
}

class UserModel extends ProfileChangeNotifier {
  UserEntity? get user => _profile.user;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
  set user(UserEntity? user) {
    debugPrint('UserModel-change');
    if (user?.uid != _profile.user?.uid) {
      _profile.user = user;

      logger.i("UserEntity: $user");
      notifyListeners();
    }
  }
}
