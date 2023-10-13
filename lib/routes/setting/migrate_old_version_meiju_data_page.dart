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
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/homlux/api/homlux_device_api.dart';
import '../../common/homlux/homlux_global.dart';
import '../../common/homlux/models/homlux_device_entity.dart';
import '../../common/homlux/models/homlux_family_entity.dart';
import '../../common/homlux/models/homlux_qr_code_auth_entity.dart';
import '../../common/homlux/models/homlux_room_list_entity.dart';
import '../../common/homlux/models/homlux_user_info_entity.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/api/meiju_user_api.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/meiju/models/meiju_login_home_entity.dart';
import '../../common/meiju/models/meiju_room_entity.dart';
import '../../common/meiju/models/meiju_user_entity.dart';
import '../../states/device_list_notifier.dart';
import '../../widgets/util/deviceEntityTypeInP4Handle.dart';
import '../home/device/card_type_config.dart';
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
        Navigator.pop(context, true);
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

  bool meiju = false;
  bool homlux = false;

  @override
  void netChange(MZNetState? state) {
    /// 有网络连接的时候，开始迁移网关
    if (state != null && !startMigrate) {
      startMigrate = true;
      Future.delayed(const Duration(seconds: 15))
          .then((value) {migrationData((){
            meiju = true;
            if(homlux) {
              Navigator.pop(context, true);
            }
      });migrationHomluxData((){
        homlux = true;
        if(meiju) {
          Navigator.pop(context, true);
        }
      });});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  /// 迁移数据
  void migrationData(void Function() callback) async {
    try {
      await SharedPreferences.getInstance();
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
          token['deviceId'],
          token['gatewayApplicationCode']);

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
        if (DeviceEntityTypeInP4Handle.getDeviceEntityType(
            e["type"], e["modelNumber"]) !=
            DeviceEntityTypeInP4.Default) {
          devicesReal.add(deviceObj);
        }
      });

      List<Layout> layoutData = await context.read<DeviceInfoListModel>().transformLayoutFromDeviceList(devicesReal);

       Log.i('生成数据', layoutData.map((e) => e.grids));
      final layoutModel = context.read<LayoutModel>();
      await Future.delayed(const Duration(seconds: 3), () async {
        if(layoutData.isNotEmpty){
          await layoutModel.setLayouts(layoutData);
        }
      });
       Log.i('最终数据', context.read<LayoutModel>().layouts.map((e) => e.grids));

      /// 保存当前的数据
      // Global.saveProfile();
      Setting.instant().saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      await migrateChannel.setMeiJuIsMigrate();
      Setting.instant().isAllowChangePlatform = false;
      // logger.i("迁移完成token:${MeiJuGlobal.token}---homeInfo:${MeiJuGlobal.homeInfo}-----roomInfo:${MeiJuGlobal.roomInfo}----gatewayApplianceCode:${MeiJuGlobal.gatewayApplianceCode}");
      callback.call();
    } catch (e) {
      logger.e("迁移失败$e");
      await migrateChannel.setMeiJuIsMigrate();
      callback.call();

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
      String deviceId,String gatewayApplicationCode) async {
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
    System.deviceId = deviceId;
    Global.profile.deviceId = deviceId;
    MeiJuGlobal.gatewayApplianceCode=gatewayApplicationCode;

    return true;
  }




  /// 迁移数据
  void migrationHomluxData(void Function() callback) async {
    try {
      Map<String, dynamic>? token = await migrateChannel.syncHomluxToken();
      Map<String, dynamic>? userData =
      await migrateChannel.syncHomluxUserInfo();
      Map<String, dynamic>? familyData =
      await migrateChannel.syncHomluxFamily();
      Map<String, dynamic>? roomData = await migrateChannel.syncHomluxRoom();

      Map<String, dynamic>? gatewayApplianceCode = await migrateChannel.syncGatewayApplianceCode();

      if (token == null || userData == null || roomData == null||familyData==null ||gatewayApplianceCode==null) {
        throw SyncError('迁移信息为空');
      }

      /// 迁移token
      await migrateHomluxToken(token['token']['refreshToken'], token['token']['token']);

      /// 迁移用户信息
      await migrateHomluxUserData(
          userData['headImageUrl'],
          userData['mobilePhone'],
          userData['name'] ?? "",
          userData['nickName']?? "",
          userData['sex']?? 1,
          userData['userId'],
          userData['wxId']);

      /// 迁移房间
      await migrateHomluxRoom(
          roomData['roomId'],
          roomData['roomName'],
          roomData['roomIcon'],
          roomData['deviceLightOnNum'],
          roomData['deviceNum']);

      /// 迁移家庭
      await migrateHomluxFamily(
          familyData['houseId'],
          familyData['houseName'],
          familyData['houseCreatorFlag'],
          familyData['defaultHouseFlag'],
          familyData['roomNum'],
          familyData['deviceNum'],
          familyData['userNum']);

      /// 迁移网关ApplianceCode
      await migrateHomluxGateWayApplianceCode(gatewayApplianceCode['deviceId']);

      /// 获取当前房间的设备数据

      var res  = await HomluxDeviceApi.queryDeviceListByRoomId(roomData['roomId']);
      List<HomluxDeviceEntity>? devices = res.data;

      List<DeviceEntity> devicesReal = [];

      String getModelNumber(String proType,int deviceType, int switchInfoDTOListLength) {
        List<int> ac485List = [3017, 3018, 3019];
        if (proType == '0x21' && ac485List.contains(deviceType)) {
          return deviceType.toString();
        } else if (proType == '0x21') {
          return 'homlux${switchInfoDTOListLength}';
        }

        if (proType == '0x13' && deviceType == 2) {
          return 'homluxZigbeeLight';
        }

        if (proType == '0x13' && deviceType == 4) {
          return 'homluxLightGroup';
        }

        return deviceType.toString();
      }

      for (HomluxDeviceEntity e in devices!) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.deviceName!;
        deviceObj.applianceCode = e.deviceId!;
        deviceObj.type = e.proType!;
        int switchInfoDTOListLength = e.switchInfoDTOList?.length ?? 0;
        deviceObj.modelNumber = getModelNumber(e.proType!, e.deviceType!, switchInfoDTOListLength);
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.gatewayId ?? '';
        deviceObj.onlineStatus = e.onLineStatus.toString();
        if (DeviceEntityTypeInP4Handle.getDeviceEntityType(
            deviceObj.type, deviceObj.modelNumber) !=
            DeviceEntityTypeInP4.Default) {
          devicesReal.add(deviceObj);
        }
      }

      List<Layout> layoutData = await context.read<DeviceInfoListModel>().transformLayoutFromDeviceList(devicesReal);

      final layoutModel = context.read<LayoutModel>();
      await Future.delayed(const Duration(seconds: 3), () async {
        if(layoutData.isNotEmpty){
          await layoutModel.setLayouts(layoutData);
        }
      });

      Log.i('房间数据', layoutData);

      /// 保存当前的数据
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      await migrateChannel.setMeiJuIsMigrate();
      Setting.instant().isAllowChangePlatform = false;
      callback.call();
    } catch (e) {
      logger.e(e);
      Setting.instant().isAllowChangePlatform = false;
      await migrateChannel.setMeiJuIsMigrate();
      callback.call();
    }
  }

  Future<bool> migrateHomluxUserData(String headImageUrl, String mobilePhone,
      String name, String nickName, int sex, String userId, String wxId) async {
    HomluxUserInfoEntity entity = HomluxUserInfoEntity(name:name,headImageUrl:headImageUrl,mobilePhone:mobilePhone,nickName:nickName,sex:sex,userId:userId,wxId:wxId);
    HomluxGlobal.homluxUserInfo = entity;
    return true;
  }

  Future<bool> migrateHomluxRoom(String roomId, String roomName, String roomIcon,
      int deviceLightOnNum, int deviceNum) async {
    RealHomluxRoomInfo entity = RealHomluxRoomInfo(roomId:roomId,roomName:roomName,deviceLightOnNum:deviceLightOnNum,deviceNum:deviceNum);
    HomluxGlobal.homluxRoomInfo = HomluxRoomInfo(roomInfo: entity);
    return true;
  }

  Future<bool> migrateHomluxFamily(
      String houseId,
      String houseName,
      bool houseCreatorFlag,
      bool defaultHouseFlag,
      int roomNum,
      int deviceNum,
      int userNum) async {
    HomluxFamilyEntity entity = HomluxFamilyEntity(
        houseId: houseId,
        houseName: houseName,
        houseCreatorFlag: houseCreatorFlag,
        defaultHouseFlag: defaultHouseFlag,
        roomNum: roomNum,
        deviceNum: deviceNum,
        userNum: userNum);
    HomluxGlobal.homluxHomeInfo = entity;
    return true;
  }

  Future<bool> migrateHomluxToken(String refreshToken, String token) async {
    HomluxQrCodeAuthEntity mHomluxQrCodeAuthEntity = HomluxQrCodeAuthEntity(
        authorizeStatus: 1, refreshToken: refreshToken, token: token);
    HomluxGlobal.homluxQrCodeAuthEntity = mHomluxQrCodeAuthEntity;
    return true;
  }

  Future<bool> migrateHomluxGateWayApplianceCode(String gateWayApplianceCode) async {
    HomluxGlobal.gatewayApplianceCode=gateWayApplianceCode;
    return true;
  }
}
