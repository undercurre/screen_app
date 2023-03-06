import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/api/gateway_api.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/setting.dart';
import 'package:screen_app/models/index.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import '../../models/device_home_list_entity.dart';

/// 定义同步失败异常
class SyncError extends Error {
  String message;
  SyncError(this.message);

  @override
  String toString() {
    return "$message ${super.toString()}";
  }
}

/// 数据迁移页
class MigrationOldVersionDataPage extends StatefulWidget {
  const MigrationOldVersionDataPage({super.key});

  @override
  State<StatefulWidget> createState() => MigrationOldVersionDataState();
}

class MigrationOldVersionDataState extends State<MigrationOldVersionDataPage>
    with WidgetNetState {
  late Timer _timer;
  bool startMigrate = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(minutes: 2), () {
      if (!startMigrate) {
        TipsUtils.toast(content: '同步数据失败，请重新登录');
        System.loginOut();
        Navigator.popAndPushNamed(context, 'Login');
        aboutSystemChannel
            .getAppVersion()
            .then((value) => Setting.instant().saveVersionCompatibility(value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Center(child: Image.asset('assets/imgs/setting/ig_app_bg.png')),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CupertinoActivityIndicator(),
                  ),
                  Text('同步数据中...')
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void netChange(MZNetState? state) {
    /// 有网络连接的时候，开始迁移网关
    if (state != null && !startMigrate) {
      startMigrate = true;
      Future
          .delayed(const Duration(seconds: 5))
          .then((value) => migrationData());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  /// 迁移数据
  void migrationData() async {
    try {
      Map<String, dynamic>? token = await migrateChannel.syncToken();
      Map<String, dynamic>? userData = await migrateChannel.syncUserData();
      if (token == null || userData == null) {
        throw SyncError('token或者user为空');
      }

      /// 迁移token
      await migrateToken(
          token['userid'],
          token['iotUserId'],
          token['dataDecodeKey'],
          token['dataEncodeKey'],
          token['token']['accessToken'],
          token['token']['tokenPwd'],
          token['token']['expired'],
          token['deviceId']);

      /// 迁移家庭
      await migrateHome(
          userData['home']['homegroupId'],
          "",
          userData['roledId'] ?? "",
          "",
          userData['home']['name'],
          userData['nickName'],
          userData['home']['des'],
          userData['home']['address'],
          userData['home']['profilePicUrl'],
          userData['home']['coordinate'],
          "",
          userData['home']['createTime'],
          userData['home']['createUserUid'],
          userData['home']['roomCount'],
          userData['home']['applianceCount'],
          userData['home']['memberCount']);

      /// 迁移房间
      await migrateRoom(
          userData['room']['des'],
          userData['room']['icon'],
          userData['room']['isDefault'],
          userData['room']['name'],
          userData['room']['roomId']);

      /// 同步网关信息
      await migrateGateway(null, 3);

      /// 网络请求同步数据
      await migrateHomeFromCloud(userData['home']['homegroupId']);

      /// 保存当前的数据
      Global.saveProfile();
      TipsUtils.toast(content: "同步数据成功");
      Setting.instant().saveVersionCompatibility(
          await aboutSystemChannel.getAppVersion());
      Future.delayed(Duration.zero).then((value) {
        Navigator.popAndPushNamed(context, 'Home');
      });
    } catch (e) {
      logger.e(e);
      Setting.instant().saveVersionCompatibility(
          await aboutSystemChannel.getAppVersion());
      TipsUtils.toast(content: '同步数据失败，请重新登录');
      System.loginOut();
      Future.delayed(Duration.zero)
          .then((value) => Navigator.popAndPushNamed(context, 'Login'));
    }
  }

  Future<bool> migrateHomeFromCloud(String homeId) async {
    bool refreshHomeInfo = false;

    for (int i = 0; i < 3; i++) {
      try {
        var res = await UserApi.getHomeListFromMidea();
        if (res.isSuccess) {
          for (var element in res.data.homeList) {
            if (element.homegroupId == homeId) {
              Global.profile.homeInfo = element;
              refreshHomeInfo = true;
              break;
            }
          }
        }
      } catch (e) {
        logger.e(e);
      }
    }

    if (!refreshHomeInfo) {
      throw SyncError('同步家庭数据失败');
    }

    bool refershRoom = false;

    for (int i = 0; i < 3; i++) {
      try {
        var res = await UserApi.getHomeListWithDeviceList(homegroupId: homeId);
        if (res.isSuccess) {
          for (var element in res.data.homeList) {
            element.roomList?.forEach((element) {
              if (element.roomId == Global.profile.roomInfo?.roomId) {
                Global.profile.roomInfo = element;
                refershRoom = true;
              }
            });
          }
          if (refershRoom) {
            break;
          }
        }
      } catch (e) {
        logger.e(e);
      }
    }
    if (!refershRoom) {
      throw SyncError('同步房间列表失败');
    }

    return true;
  }

  Future<bool> migrateGateway([String? gatewaySn, int retryCount = 0]) async {
    if (gatewaySn == null) {
      gatewaySn = await aboutSystemChannel.getGatewaySn(false);
      if (gatewaySn == null) {
        throw SyncError("迁移网关失败");
      }
    }

    try {
      if (retryCount > 0) {
        final res = await GatewayApi.queryHomeList();
        if (res.isSuccess) {
          DeviceHomeListHomeListRoomListApplianceList? appliance;
          res.result.homeList?[0].roomList?.forEach((element1) {
            element1.applianceList?.forEach((element2) {
              if (element2.sn == gatewaySn) {
                appliance = element2;
              }
            });
          });

          if (appliance != null) {
            Global.profile.deviceSn = gatewaySn;
            Global.profile.applianceCode = appliance!.applianceCode;
            return true;
          }
        } else {
          return migrateGateway(gatewaySn, --retryCount);
        }
      }
    } catch (e) {
      logger.e(e);
    }

    throw SyncError("迁移网关失败");
  }

  Future<bool> migrateHome(
      String homegroupId,
      String number,
      String roleId,
      String isDefault,
      String name,
      String nickName,
      String des,
      String address,
      String profilePicUrl,
      String coordinate,
      String areaId,
      String createTime,
      String createUserUid,
      int roomCount,
      int applianceCount,
      int memberCount) async {
    HomeEntity entity = HomeEntity();
    entity.homegroupId = homegroupId;
    entity.number = number;
    entity.roleId = roleId;
    entity.isDefault = isDefault;
    entity.name = name;
    entity.nickname = nickName;
    entity.memberCount = memberCount.toString();
    entity.applianceCount = applianceCount.toString();
    entity.roomCount = roomCount.toString();
    entity.createUserUid = createUserUid;
    entity.createTime = createTime;
    entity.areaId = areaId;
    entity.des = des;
    entity.address = address;
    entity.profilePicUrl = profilePicUrl;
    entity.coordinate = coordinate;
    Global.profile.homeInfo = entity;

    return true;
  }

  Future<bool> migrateRoom(String des, String icon, String isDefault,
      String name, String roomId) async {
    RoomEntity entity = RoomEntity();
    entity.roomId = roomId;
    entity.name = name;
    entity.des = des;
    entity.isDefault = isDefault;
    entity.icon = icon;
    Global.profile.roomInfo = entity;
    return true;
  }

  Future<bool> migrateToken(
      String userId,
      String iotUserId,
      String key,
      String seed,
      String token,
      String tokenPwd,
      int expired,
      String deviceId) async {
    UserEntity userEntity = UserEntity();
    userEntity.accessToken = token;
    userEntity.tokenPwd = tokenPwd;
    userEntity.expired = expired;

    userEntity.deviceId = deviceId;
    userEntity.iotUserId = iotUserId;
    userEntity.uid = userId;
    userEntity.key = key;
    userEntity.seed = seed;
    userEntity.openId = '';
    userEntity.sessionId = '';

    Global.user = userEntity;
    Global.profile.deviceId = deviceId;

    int count = 5;

    while (count > 0) {
      try {
        MzResponseEntity mzEntity = await UserApi.authToken();
        if (mzEntity.isSuccess) {
          userEntity.mzAccessToken = mzEntity.result['accessToken'];
          break;
        }
      } catch (e) {
        logger.e(e);
      }
      count--;
    }

    if (userEntity.mzAccessToken == null) {
      throw SyncError('迁移Token失败');
    }

    return true;
  }
}
