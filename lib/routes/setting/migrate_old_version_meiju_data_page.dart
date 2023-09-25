import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/meiju/api/meiju_device_api.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:screen_app/common/setting.dart';
import 'package:screen_app/models/index.dart';
import 'package:screen_app/states/device_change_notifier.dart';
import 'package:screen_app/states/layout_notifier.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/api/meiju_user_api.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/meiju/models/meiju_login_home_entity.dart';
import '../../common/meiju/models/meiju_room_entity.dart';
import '../../common/meiju/models/meiju_user_entity.dart';
import '../../states/device_list_notifier.dart';
import '../home/device/layout_data.dart';

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
class MigrationOldVersionMeiJuDataPage extends StatefulWidget {
  const MigrationOldVersionMeiJuDataPage({super.key});

  @override
  State<StatefulWidget> createState() => MigrationOldVersionMeiJuDataState();
}

class MigrationOldVersionMeiJuDataState
    extends State<MigrationOldVersionMeiJuDataPage> with WidgetNetState {
  late Timer _timer;
  bool startMigrate = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(minutes: 2), () {
      if (!startMigrate) {
        System.logout("迁移数据，导致退出登录");
        Setting.instant().isAllowChangePlatform = false;
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
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
      Future.delayed(const Duration(seconds: 15))
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

      logger.i("迁移前token:$token");

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

      /// 网络请求同步数据
      await migrateHomeFromCloud(userData['home']['homegroupId']);

      /// 获取当前房间的设备数据
      var rooms = userData["room"];
      List<dynamic> devices =  rooms["applianceList"];
      List<DeviceEntity> devicesReal = [];

      devices.forEach((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e["name"];
        deviceObj.applianceCode = e["applianceCode"];
        deviceObj.type = e["type"];
        deviceObj.modelNumber = e["modelNumber"];
        deviceObj.sn8 = e["sn8"];
        deviceObj.roomName = e["roomName"];
        deviceObj.masterId = e["masterId"];
        deviceObj.onlineStatus = e["onlineStatus"];
        Log.i("设备名称:${deviceObj.name}");
        devicesReal.add(deviceObj);
      });

      List<Layout> layoutData = await context.read<DeviceInfoListModel>().transformLayoutFromDeviceList(devicesReal);


      await context.read<LayoutModel>().setLayouts(layoutData);


      Log.i('房间${userData['room']['name']}数据', layoutData.map((e) => e.grids));

      /// 保存当前的数据
      // Global.saveProfile();
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      await migrateChannel.setMeiJuIsMigrate();
      Future.delayed(Duration.zero).then((value) {
        Navigator.popAndPushNamed(context, 'Home');
      });
    } catch (e) {
      await migrateChannel.setMeiJuIsMigrate();
      logger.e(e);
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      System.logout("迁移数据，导致退出登录");
      Future.delayed(Duration.zero).then(
        (value) {
          Setting.instant().isAllowChangePlatform = false;
          Navigator.popAndPushNamed(context, 'Login');
          Log.i('报错', e);
        }
      );
    }
  }

  Future<bool> migrateHomeFromCloud(String homeId) async {
    bool refreshHomeInfo = false;

    for (int i = 0; i < 3; i++) {
      try {
        var res = await MeiJuUserApi.getHomeListFromMidea();
        if (res.isSuccess) {
          for (var element in res.data!.homeList!) {
            if (element.homegroupId == homeId) {
              MeiJuGlobal.homeInfo = element;
              refreshHomeInfo = true;
              break;
            }
          }
        }
        if (refreshHomeInfo) {
          break;
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
        var res = await MeiJuUserApi.getHomeDetail(homegroupId: homeId);
        if (res.isSuccess) {
          for (var element in res.data!.homeList!) {
            element.roomList?.forEach((element) {
              if (element.roomId == MeiJuGlobal.roomInfo?.roomId) {
                MeiJuGlobal.roomInfo = element;
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
    MeiJuLoginHomeEntity entity = MeiJuLoginHomeEntity();
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
    MeiJuGlobal.homeInfo = entity;
    return true;
  }

  Future<bool> migrateRoom(String des, String icon, String isDefault,
      String name, String roomId) async {
    MeiJuRoomEntity entity = MeiJuRoomEntity();
    entity.roomId = roomId;
    entity.name = name;
    entity.des = des;
    entity.isDefault = isDefault;
    entity.icon = icon;
    MeiJuGlobal.roomInfo = entity;
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
    Global.user = null;
    MeiJuTokenEntity userEntity = MeiJuTokenEntity();
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

    /// 防止重新刷新干扰[expired快要接近失效时间]
    Api.forceRefresh = expired - DateTime.now().millisecond <= 30 * 60 * 1000;

    int count = 5;

    while (count > 0) {
      try {
        MzResponseEntity mzEntity =
            await UserApi.authTokenWithParams(deviceId, token, userId);
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
    MeiJuGlobal.token = userEntity;
    Global.profile.deviceId = deviceId;

    return true;
  }
}
