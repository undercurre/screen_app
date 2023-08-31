import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/setting.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import '../../common/homlux/homlux_global.dart';
import '../../common/homlux/models/homlux_family_entity.dart';
import '../../common/homlux/models/homlux_qr_code_auth_entity.dart';
import '../../common/homlux/models/homlux_room_list_entity.dart';
import '../../common/homlux/models/homlux_user_info_entity.dart';

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
        System.logout();
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
      await migrateToken(token['refreshToken'], token['token']);

      /// 迁移用户信息
      await migrateUserData(
          userData['headImageUrl'],
          userData['mobilePhone'],
          userData['name'],
          userData['nickName'],
          userData['sex'],
          userData['userId'],
          userData['wxId']);

      /// 迁移房间
      await migrateRoom(
          roomData['roomId'],
          roomData['roomName'],
          roomData['roomIcon'],
          roomData['deviceLightOnNum'],
          roomData['deviceNum']);

      /// 迁移家庭
      await migrateFamily(
          familyData['houseId'],
          familyData['houseName'],
          familyData['houseCreatorFlag'],
          familyData['defaultHouseFlag'],
          familyData['roomNum'],
          familyData['deviceNum'],
          familyData['userNum']);

      /// 迁移网关ApplianceCode
      await migrateGateWayApplianceCode(gatewayApplianceCode['deviceId']);

      /// 保存当前的数据
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      Future.delayed(Duration.zero).then((value) {
        Navigator.popAndPushNamed(context, 'Home');
      });
    } catch (e) {
      logger.e(e);
      Setting.instant()
          .saveVersionCompatibility(await aboutSystemChannel.getAppVersion());
      System.logout();
      Future.delayed(Duration.zero)
          .then((value) => Navigator.popAndPushNamed(context, 'Login'));
    }
  }

  Future<bool> migrateUserData(String headImageUrl, String mobilePhone,
      String name, String nickName, int sex, String userId, String wxId) async {
    HomluxUserInfoEntity entity = HomluxUserInfoEntity(name:name,headImageUrl:headImageUrl,mobilePhone:mobilePhone,nickName:nickName,sex:sex,userId:userId,wxId:wxId);
    HomluxGlobal.homluxUserInfo = entity;
    return true;
  }

  Future<bool> migrateRoom(String roomId, String roomName, String roomIcon,
      int deviceLightOnNum, int deviceNum) async {
    RealHomluxRoomInfo entity = RealHomluxRoomInfo(roomId:roomId,roomName:roomName,deviceLightOnNum:deviceLightOnNum,deviceNum:deviceNum);
    HomluxGlobal.homluxRoomInfo = HomluxRoomInfo(roomInfo: entity);
    return true;
  }

  Future<bool> migrateFamily(
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

  Future<bool> migrateToken(String refreshToken, String token) async {
    HomluxQrCodeAuthEntity mHomluxQrCodeAuthEntity = HomluxQrCodeAuthEntity(
        authorizeStatus: 1, refreshToken: refreshToken, token: token);
    HomluxGlobal.homluxQrCodeAuthEntity = mHomluxQrCodeAuthEntity;
    return true;
  }

  Future<bool> migrateGateWayApplianceCode(String gateWayApplianceCode) async {
    HomluxGlobal.gatewayApplianceCode=gateWayApplianceCode;
    return true;
  }
}
