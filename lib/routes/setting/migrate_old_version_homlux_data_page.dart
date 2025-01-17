import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/setting.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import '../../common/homlux/homlux_global.dart';
import '../../common/homlux/models/homlux_device_entity.dart';
import '../../common/homlux/models/homlux_family_entity.dart';
import '../../common/homlux/models/homlux_qr_code_auth_entity.dart';
import '../../common/homlux/models/homlux_room_list_entity.dart';
import '../../common/homlux/models/homlux_user_info_entity.dart';
import '../../common/logcat_helper.dart';
import '../../models/device_entity.dart';
import '../../states/device_list_notifier.dart';
import '../../states/layout_notifier.dart';
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
class MigrationOldVersionHomLuxDataPage extends StatefulWidget {
  const MigrationOldVersionHomLuxDataPage({super.key});

  @override
  State<StatefulWidget> createState() => MigrationOldVersionHomLuxDataState();
}

class MigrationOldVersionHomLuxDataState
    extends State<MigrationOldVersionHomLuxDataPage> with WidgetNetState {
  late Timer _timer;
  bool startMigrate = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(minutes: 2), () {
      if (!startMigrate) {
        System.logout("数据迁移失败");
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
          .then((value) => migrationHomluxData());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  /// 迁移数据
  void migrationHomluxData() async {
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
      var rooms = userData["room"];
      List<dynamic> devices =  rooms["applianceList"];
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

      devices.forEach((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e["deviceName"];
        deviceObj.applianceCode = e["deviceId"];
        deviceObj.type = e["proType"];
        int switchInfoDTOListLength = e["switchInfoDTOList"].length ?? 0;
        deviceObj.modelNumber = getModelNumber(e["proType"], e["deviceType"], switchInfoDTOListLength);
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.gatewayId ?? '';
        deviceObj.onlineStatus = e.onLineStatus.toString();
        devicesReal.add(deviceObj);
      });

      List<Layout> layoutData = await context.read<DeviceInfoListModel>().transformLayoutFromDeviceList(devicesReal);

      layoutData.forEach((element) {
        context.read<LayoutModel>().setLayouts(layoutData);
      });

      Log.i('房间数据', layoutData);

      /// 保存当前的数据
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      await migrateChannel.setHomluxIsMigrate();
      Future.delayed(Duration.zero).then((value) {
        Navigator.popAndPushNamed(context, 'Home');
      });
    } catch (e) {
      logger.e(e);
      await migrateChannel.setHomluxIsMigrate();
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      System.logout("数据迁移失败");
      Setting.instant().isAllowChangePlatform = false;
      Future.delayed(Duration.zero)
          .then((value) => Navigator.popAndPushNamed(context, 'Login'));
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
