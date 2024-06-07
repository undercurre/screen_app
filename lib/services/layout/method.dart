import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/services/layout/var.dart';

import '../../common/api/api.dart';
import '../../common/gateway_platform.dart';
import '../../common/homlux/api/homlux_user_api.dart';
import '../../common/logcat_helper.dart';
import '../../common/system.dart';
import '../../models/device_entity.dart';
import '../../models/scene_info_entity.dart';
import '../../routes/home/device/card_type_config.dart';
import '../../routes/home/device/layout_data.dart';
import '../../states/device_list_notifier.dart';
import '../../states/layout_notifier.dart';
import '../../states/scene_list_notifier.dart';
import '../../widgets/util/deviceEntityTypeInP4Handle.dart';

Future<bool> auto2Layout(BuildContext context) async {
  try {
    final layoutModel = context.read<LayoutModel>();
    final deviceModel = context.read<DeviceInfoListModel>();
    final sceneModel = context.read<SceneListModel>();
    // 取出现有布局
    List<String> currDeviceIds = layoutModel.layouts
        .where((element) =>
            element.type != DeviceEntityTypeInP4.Scene &&
            element.type != DeviceEntityTypeInP4.Default &&
            element.type != DeviceEntityTypeInP4.DeviceNull &&
            element.type != DeviceEntityTypeInP4.DeviceEdit &&
            element.type != DeviceEntityTypeInP4.Clock &&
            element.type != DeviceEntityTypeInP4.Weather)
        .map((e) => e.deviceId)
        .toList();
    List<String> currSceneIds =
        layoutModel.layouts.where((element) => element.type == DeviceEntityTypeInP4.Scene).map((e) => e.deviceId).toList();
    // 取出现有设备列表
    List<DeviceEntity> deviceHave = await deviceModel.getDeviceList("查询设备列表进行自动布局");
    // 取出现有场景列表
    List<SceneInfoEntity> sceneHave = await sceneModel.getSceneList();
    // 过滤出需要的设备
    List<DeviceEntity> deviceNeed = deviceHave.where((e) {
      // Log.i('数据本身', e);
      // Log.i('房间', System.roomInfo?.id);
      // Log.i('智慧屏网关id', System.gatewayApplianceCode);
      bool isHad = currDeviceIds.contains(e.applianceCode);
      // Log.i('是否已有', isHad);
      bool isInRoom = e.roomId == System.roomInfo?.id;
      // Log.i('是否在房间', isInRoom);
      bool isSelf = e.applianceCode == 'G-${System.gatewayApplianceCode}';
      // Log.i('是否本身', isSelf);
      return !isHad && isInRoom && !isSelf;
    }).toList();
    // 过滤出需要的场景
    List<SceneInfoEntity> sceneNeed = [];
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      sceneNeed = sceneHave.where((e) => !currSceneIds.contains(e.sceneId)).toList();
    } else {
      sceneNeed = sceneHave.where((e) => !currSceneIds.contains(e.sceneId) && e.roomId == System.roomInfo?.id).toList();
    }
    // 排序
    List<Layout> tempLayoutList = [];
    // 原有布局-剔除空位
    tempLayoutList.addAll(layoutModel.layouts.where((element) => element.cardType != CardType.Null).toList());
    // 时间-天气-继电器
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.Clock).isEmpty) {
      tempLayoutList.add(Layout(
          'clock',
          DeviceEntityTypeInP4.Clock,
          CardType.Other,
          -1,
          [],
          DataInputCard(
              name: '时钟',
              applianceCode: 'clock',
              roomName: '屏内',
              isOnline: '',
              type: 'clock',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.Weather).isEmpty) {
      tempLayoutList.add(Layout(
          'weather',
          DeviceEntityTypeInP4.Weather,
          CardType.Other,
          -1,
          [],
          DataInputCard(
              name: '天气',
              applianceCode: 'weather',
              roomName: '屏内',
              isOnline: '',
              type: 'weather',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.LocalPanel1).isEmpty) {
      tempLayoutList.add(Layout(
          'localPanel1',
          DeviceEntityTypeInP4.LocalPanel1,
          CardType.Small,
          -1,
          [],
          DataInputCard(
              name: '灯1',
              applianceCode: 'localPanel1',
              roomName: '屏内',
              isOnline: '',
              type: 'localPanel1',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.LocalPanel2).isEmpty) {
      tempLayoutList.add(Layout(
          'localPanel2',
          DeviceEntityTypeInP4.LocalPanel2,
          CardType.Small,
          -1,
          [],
          DataInputCard(
              name: '灯2',
              applianceCode: 'localPanel2',
              roomName: '屏内',
              isOnline: '',
              type: 'localPanel2',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    // 场景-小卡片
    tempLayoutList.addAll(sceneNeed.map((sceneItem) => Layout(
          sceneItem.sceneId,
          DeviceEntityTypeInP4.Scene,
          CardType.Small,
          -1,
          [],
          DataInputCard(
            name: sceneItem.name,
            applianceCode: sceneItem.sceneId,
            roomName: '',
            sceneId: sceneItem.sceneId,
            icon: sceneItem.image,
            isOnline: '',
            disabled: true,
            type: 'scene',
            masterId: '',
            modelNumber: '',
            onlineStatus: '1',
          ),
        )));
    // 灯组-大卡片
    List<DeviceEntity> groupNeed = deviceNeed
        .where((e) => (e.type == '0x21' && e.modelNumber == 'lightGroup') || (e.type == '0x13' && e.modelNumber == 'homluxLightGroup'))
        .toList();
    tempLayoutList.addAll(groupNeed.map((groupItem) => Layout(
        groupItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(groupItem.type, groupItem.modelNumber),
        CardType.Big,
        -1,
        [],
        DataInputCard(
          name: groupItem.name,
          applianceCode: groupItem.applianceCode,
          roomName: groupItem.roomName!,
          modelNumber: groupItem.modelNumber,
          masterId: groupItem.masterId,
          isOnline: groupItem.onlineStatus,
          sn8: groupItem.sn8,
          disabled: true,
          type: groupItem.type,
          onlineStatus: groupItem.onlineStatus,
        ))));
    // 智能开关
    List<DeviceEntity> panelNeed = deviceNeed.where((e) => panelCardTypeList.containsKey(e.modelNumber)).toList();
    tempLayoutList.addAll(panelNeed.map((panelItem) => Layout(
        panelItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(panelItem.type, panelItem.modelNumber),
        panelCardTypeList[panelItem.modelNumber] ?? CardType.Small,
        -1,
        [],
        DataInputCard(
          name: panelItem.name,
          applianceCode: panelItem.applianceCode,
          roomName: panelItem.roomName!,
          modelNumber: panelItem.modelNumber,
          masterId: panelItem.masterId,
          isOnline: panelItem.onlineStatus,
          sn8: panelItem.sn8,
          disabled: true,
          type: panelItem.type,
          onlineStatus: panelItem.onlineStatus,
        ))));
    // 单灯
    List<DeviceEntity> singleLightNeed = [];
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      singleLightNeed = deviceNeed.where((e) => singleLightModelNumbers.contains(e.modelNumber) || e.type == '0x13').toList();
    } else {
      singleLightNeed = deviceNeed
          .where((e) => (e.type == '0x13' && e.modelNumber == '3') || (e.type == '0x13' && e.modelNumber == 'homluxZigbeeLight'))
          .toList();
    }
    tempLayoutList.addAll(singleLightNeed.map((singleLightItem) => Layout(
        singleLightItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(singleLightItem.type, singleLightItem.modelNumber),
        CardType.Small,
        -1,
        [],
        DataInputCard(
          name: singleLightItem.name,
          applianceCode: singleLightItem.applianceCode,
          roomName: singleLightItem.roomName!,
          modelNumber: singleLightItem.modelNumber,
          masterId: singleLightItem.masterId,
          isOnline: singleLightItem.onlineStatus,
          sn8: singleLightItem.sn8,
          disabled: true,
          type: singleLightItem.type,
          onlineStatus: singleLightItem.onlineStatus,
        ))));
    // 窗帘
    List<DeviceEntity> curtainNeed = deviceNeed.where((e) => e.type == '0x14').toList();
    tempLayoutList.addAll(curtainNeed.map((curtainItem) => Layout(
        curtainItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(curtainItem.type, curtainItem.modelNumber),
        CardType.Big,
        -1,
        [],
        DataInputCard(
          name: curtainItem.name,
          applianceCode: curtainItem.applianceCode,
          roomName: curtainItem.roomName!,
          modelNumber: curtainItem.modelNumber,
          masterId: curtainItem.masterId,
          isOnline: curtainItem.onlineStatus,
          sn8: curtainItem.sn8,
          disabled: true,
          type: curtainItem.type,
          onlineStatus: curtainItem.onlineStatus,
        ))));
    // 空调
    List<DeviceEntity> airConditionNeed = deviceNeed
        .where((e) => e.type == '0xAC' || (e.type == '0x21' && e.modelNumber == '3017') || (e.type == '0xCC' && e.modelNumber == '3017'))
        .toList();
    tempLayoutList.addAll(airConditionNeed.map((airConditionItem) => Layout(
        airConditionItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(airConditionItem.type, airConditionItem.modelNumber),
        CardType.Small,
        -1,
        [],
        DataInputCard(
          name: airConditionItem.name,
          applianceCode: airConditionItem.applianceCode,
          roomName: airConditionItem.roomName!,
          modelNumber: airConditionItem.modelNumber,
          masterId: airConditionItem.masterId,
          isOnline: airConditionItem.onlineStatus,
          sn8: airConditionItem.sn8,
          disabled: true,
          type: airConditionItem.type,
          onlineStatus: airConditionItem.onlineStatus,
        ))));
    // 新风
    List<DeviceEntity> freshAirNeed =
        deviceNeed.where((e) => (e.type == '0x21' && e.modelNumber == '3018') || (e.type == '0xCE' && e.modelNumber == '3018')).toList();
    tempLayoutList.addAll(freshAirNeed.map((freshAirItem) => Layout(
        freshAirItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(freshAirItem.type, freshAirItem.modelNumber),
        CardType.Small,
        -1,
        [],
        DataInputCard(
          name: freshAirItem.name,
          applianceCode: freshAirItem.applianceCode,
          roomName: freshAirItem.roomName!,
          modelNumber: freshAirItem.modelNumber,
          masterId: freshAirItem.masterId,
          isOnline: freshAirItem.onlineStatus,
          sn8: freshAirItem.sn8,
          disabled: true,
          type: freshAirItem.type,
          onlineStatus: freshAirItem.onlineStatus,
        ))));
    // 地暖
    List<DeviceEntity> floorHeatNeed =
        deviceNeed.where((e) => (e.type == '0x21' && e.modelNumber == '3019') || (e.type == '0xCF' && e.modelNumber == '3019')).toList();
    tempLayoutList.addAll(floorHeatNeed.map((floorHeatItem) => Layout(
        floorHeatItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(floorHeatItem.type, floorHeatItem.modelNumber),
        CardType.Small,
        -1,
        [],
        DataInputCard(
          name: floorHeatItem.name,
          applianceCode: floorHeatItem.applianceCode,
          roomName: floorHeatItem.roomName!,
          modelNumber: floorHeatItem.modelNumber,
          masterId: floorHeatItem.masterId,
          isOnline: floorHeatItem.onlineStatus,
          sn8: floorHeatItem.sn8,
          disabled: true,
          type: floorHeatItem.type,
          onlineStatus: floorHeatItem.onlineStatus,
        ))));
    // 浴霸
    List<DeviceEntity> yubaNeed = deviceNeed.where((e) => e.type == '0x26').toList();
    tempLayoutList.addAll(yubaNeed.map((yubaItem) => Layout(
        yubaItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(yubaItem.type, yubaItem.modelNumber),
        CardType.Big,
        -1,
        [],
        DataInputCard(
          name: yubaItem.name,
          applianceCode: yubaItem.applianceCode,
          roomName: yubaItem.roomName!,
          modelNumber: yubaItem.modelNumber,
          masterId: yubaItem.masterId,
          isOnline: yubaItem.onlineStatus,
          sn8: yubaItem.sn8,
          disabled: true,
          type: yubaItem.type,
          onlineStatus: yubaItem.onlineStatus,
        ))));
    // 晾衣机
    List<DeviceEntity> liangyijiaNeed = deviceNeed.where((e) => e.type == '0x17').toList();
    tempLayoutList.addAll(liangyijiaNeed.map((liangyijiaItem) => Layout(
        liangyijiaItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(liangyijiaItem.type, liangyijiaItem.modelNumber),
        CardType.Big,
        -1,
        [],
        DataInputCard(
          name: liangyijiaItem.name,
          applianceCode: liangyijiaItem.applianceCode,
          roomName: liangyijiaItem.roomName!,
          modelNumber: liangyijiaItem.modelNumber,
          masterId: liangyijiaItem.masterId,
          isOnline: liangyijiaItem.onlineStatus,
          sn8: liangyijiaItem.sn8,
          disabled: true,
          type: liangyijiaItem.type,
          onlineStatus: liangyijiaItem.onlineStatus,
        ))));
    // 开始对layoutList进行布局排列
    // 初始化布局占位器
    Screen screenLayer = Screen();
    // 页数
    for (int i = 0; i < tempLayoutList.length; i++) {
      // 躲开对屏自身的布局，因为继电器已经在默认布局中渲染
      if (tempLayoutList[i].deviceId == System.gatewayApplianceCode) continue;
      if (tempLayoutList[i].deviceId == 'G-${System.gatewayApplianceCode}') continue;

      // 已经有布局的数据直接跳过
      if (tempLayoutList[i].grids != [] && tempLayoutList[i].pageIndex != -1) continue;

      // 当前容器集中的最大页数
      int maxPage = getMaxPageIndexOfLayoutList(tempLayoutList);

      if (tempLayoutList[i].type != DeviceEntityTypeInP4.Default) {
        // 当前没有页
        if (maxPage == -1) {
          // 直接占位
          List<int> fillCells = screenLayer.checkAvailability(tempLayoutList[i].cardType);
          tempLayoutList[i].pageIndex = 0;
          tempLayoutList[i].grids = fillCells;
        } else {
          // 遍历每一页已有的进行补充
          for (int k = 0; k <= maxPage; k++) {
            // 找到当前页的布局数据并填充布局器
            screenLayer.resetGrid();
            List<Layout> curPageLayoutList = getLayoutsByPageIndex(k, tempLayoutList);
            for (int j = 0; j < curPageLayoutList.length; j++) {
              List<int> grids = curPageLayoutList[j].grids;
              for (int l = 0; l < grids.length; l++) {
                int grid = grids[l];
                int row = (grid - 1) ~/ 4;
                int col = (grid - 1) % 4;
                screenLayer.setCellOccupied(row, col, true);
              }
            }
            // 尝试占位
            List<int> fillCells = screenLayer.checkAvailability(tempLayoutList[i].cardType);
            Log.i('自动布局——尝试布局$k', fillCells);
            if (fillCells.isEmpty) {
              // 占位没有成功，说明这一页已经没有适合的位置了
              // 如果最后一页也没有合适的位置就新增一页
              if (k == maxPage) {
                tempLayoutList[i].pageIndex = maxPage + 1;
                screenLayer.resetGrid();
                List<int> fillCellsAgain = screenLayer.checkAvailability(tempLayoutList[i].cardType);
                tempLayoutList[i].grids = fillCellsAgain;
              }
            } else {
              // 占位成功
              tempLayoutList[i].pageIndex = k;
              tempLayoutList[i].grids = fillCells;
              break;
            }
          }
        }
        Log.i('自动布局——生成布局${tempLayoutList[i].pageIndex}', tempLayoutList[i].grids);
      }
    }

    // 轮询填充空缺
    int lastPageIndex = getMaxPageIndexOfLayoutList(tempLayoutList);
    for (int l = 0; l <= lastPageIndex; l++) {
      // 取得当前页布局
      List<Layout> waitForFillPageLayouts = tempLayoutList.where((element) => element.pageIndex == l).toList();
      // 填充
      List<Layout> lastPageLayoutsAfterFilled = Layout.filledLayout(waitForFillPageLayouts);
      for (int o = 0; o < lastPageLayoutsAfterFilled.length; o++) {
        if (lastPageLayoutsAfterFilled[o].cardType == CardType.Null) {
          tempLayoutList.add(lastPageLayoutsAfterFilled[o]);
        }
      }
    }
    await layoutModel.setLayouts(tempLayoutList);
    // 完成布局，抛出
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> auto2LayoutNew(BuildContext context) async {
  try {
    final layoutModel = context.read<LayoutModel>();
    final deviceModel = context.read<DeviceInfoListModel>();
    final sceneModel = context.read<SceneListModel>();
    // 取出现有布局
    List<String> currDeviceIds = layoutModel.layouts
        .where((element) =>
            element.type != DeviceEntityTypeInP4.Scene &&
            element.type != DeviceEntityTypeInP4.LocalPanel1 &&
            element.type != DeviceEntityTypeInP4.LocalPanel2 &&
            element.type != DeviceEntityTypeInP4.Default &&
            element.type != DeviceEntityTypeInP4.DeviceNull &&
            element.type != DeviceEntityTypeInP4.DeviceEdit &&
            element.type != DeviceEntityTypeInP4.Clock &&
            element.type != DeviceEntityTypeInP4.Weather)
        .map((e) => e.deviceId)
        .toList();
    // 取出现有设备列表
    List<DeviceEntity> deviceHave = await deviceModel.getDeviceList("查询设备列表进行自动布局");
    // 取出现有场景列表
    List<SceneInfoEntity> sceneHave = await sceneModel.getSceneList();
    if (System.inHomluxPlatform()) {
      sceneHave = sceneHave.where((scene) => scene.roomId == System.roomInfo?.id).toList();
    }
    // 过滤出需要的设备
    List<DeviceEntity> deviceNeed = deviceHave.where((e) {
      bool isHad = currDeviceIds.contains(e.applianceCode);
      bool isLightGroup = (e.type == '0x21' && e.modelNumber == 'lightGroup') || (e.type == '0x13' && e.modelNumber == 'homluxLightGroup');
      bool isInRoom = e.roomId == System.roomInfo?.id;
      bool isSelf = e.applianceCode == 'G-${System.gatewayApplianceCode}';
      return (!isHad && isInRoom && !isSelf) || (isLightGroup && isInRoom);
    }).toList();
    // 过滤出需要的场景
    List<SceneInfoEntity> sceneNeed = sceneHave;
    // 排序
    List<Layout> tempLayoutList = [];
    // 时间-天气
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.Clock).isEmpty) {
      tempLayoutList.add(Layout(
          'clock',
          DeviceEntityTypeInP4.Clock,
          CardType.Other,
          -1,
          [],
          DataInputCard(
              name: '时钟',
              applianceCode: 'clock',
              roomName: '屏内',
              isOnline: '',
              type: 'clock',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.Weather).isEmpty) {
      tempLayoutList.add(Layout(
          'weather',
          DeviceEntityTypeInP4.Weather,
          CardType.Other,
          -1,
          [],
          DataInputCard(
              name: '天气',
              applianceCode: 'weather',
              roomName: '屏内',
              isOnline: '',
              type: 'weather',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    // 场景-小卡片
    for (var sceneItem in sceneNeed) {
      tempLayoutList.add(Layout(
        sceneItem.sceneId,
        DeviceEntityTypeInP4.Scene,
        CardType.Small,
        -1,
        [],
        DataInputCard(
          name: sceneItem.name,
          applianceCode: sceneItem.sceneId,
          roomName: '',
          sceneId: sceneItem.sceneId,
          icon: sceneItem.image,
          isOnline: '',
          disabled: true,
          type: 'scene',
          masterId: '',
          modelNumber: '',
          onlineStatus: '1',
        ),
      ));
    }
    if (sceneNeed.length % 2 == 1) {
      tempLayoutList.add(Layout(
          uuid.v4(),
          DeviceEntityTypeInP4.DeviceNull,
          CardType.Null,
          -1,
          [],
          DataInputCard(
              name: '', type: '', applianceCode: '', roomName: '', masterId: '', modelNumber: '', isOnline: '', onlineStatus: '')));
    }
    // 默认灯组-大卡片
    if (System.inHomluxPlatform() && deviceHave.where((element) => element.type == '0x13').toList().isNotEmpty) {
      var roomList = await HomluxUserApi.queryRoomList(System.familyInfo!.familyId);
      String curGroupId = roomList.data?.roomInfoWrap?.firstWhere((element) => element.roomId == System.roomInfo?.id).groupId;
      Log.i('当前的默认灯组', curGroupId);
      tempLayoutList.add(Layout(
          curGroupId,
          DeviceEntityTypeInP4.homlux_default_lightGroup,
          CardType.Big,
          -1,
          [],
          DataInputCard(
            name: '灯光管理模块',
            applianceCode: curGroupId,
            roomName: System.roomInfo!.name ?? '',
            modelNumber: '',
            masterId: '',
            isOnline: '1',
            sn8: '',
            disabled: true,
            type: '',
            onlineStatus: '1',
          )));
    }
    // 灯组-大卡片
    List<DeviceEntity> groupNeed = deviceNeed
        .where((e) => (e.type == '0x21' && e.modelNumber == 'lightGroup') || (e.type == '0x13' && e.modelNumber == 'homluxLightGroup'))
        .toList();
    tempLayoutList.addAll(groupNeed.map((groupItem) => Layout(
        groupItem.applianceCode,
        DeviceEntityTypeInP4Handle.getDeviceEntityType(groupItem.type, groupItem.modelNumber),
        CardType.Big,
        -1,
        [],
        DataInputCard(
          name: groupItem.name,
          applianceCode: groupItem.applianceCode,
          roomName: groupItem.roomName!,
          modelNumber: groupItem.modelNumber,
          masterId: groupItem.masterId,
          isOnline: groupItem.onlineStatus,
          sn8: groupItem.sn8,
          disabled: true,
          type: groupItem.type,
          onlineStatus: groupItem.onlineStatus,
        ))));
    // 继电器
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.LocalPanel1).isEmpty) {
      tempLayoutList.add(Layout(
          'localPanel1',
          DeviceEntityTypeInP4.LocalPanel1,
          CardType.Small,
          -1,
          [],
          DataInputCard(
              name: '灯1',
              applianceCode: 'localPanel1',
              roomName: '屏内',
              isOnline: '',
              type: 'localPanel1',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    if (tempLayoutList.where((element) => element.type == DeviceEntityTypeInP4.LocalPanel2).isEmpty) {
      tempLayoutList.add(Layout(
          'localPanel2',
          DeviceEntityTypeInP4.LocalPanel2,
          CardType.Small,
          -1,
          [],
          DataInputCard(
              name: '灯2',
              applianceCode: 'localPanel2',
              roomName: '屏内',
              isOnline: '',
              type: 'localPanel2',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')));
    }
    // 原有设备
    List<Layout> currentDeviceLayout = layoutModel.layouts
        .where((element) =>
            element.type != DeviceEntityTypeInP4.Scene &&
            element.type != DeviceEntityTypeInP4.LocalPanel1 &&
            element.type != DeviceEntityTypeInP4.LocalPanel2 &&
            element.type != DeviceEntityTypeInP4.homlux_lightGroup &&
            element.type != DeviceEntityTypeInP4.Zigbee_lightGroup &&
            element.type != DeviceEntityTypeInP4.Default &&
            element.type != DeviceEntityTypeInP4.DeviceNull &&
            element.type != DeviceEntityTypeInP4.DeviceEdit &&
            element.type != DeviceEntityTypeInP4.homlux_default_lightGroup &&
            element.type != DeviceEntityTypeInP4.Clock &&
            element.type != DeviceEntityTypeInP4.Weather)
        .toList();
    for (var layout in currentDeviceLayout) {
      layout.pageIndex = -1;
      layout.grids = [];
    }

    List<Layout> currentDeviceLayoutBig = currentDeviceLayout.where((element) => element.cardType == CardType.Big).toList();

    List<Layout> currentDeviceLayoutMiddle = currentDeviceLayout.where((element) => element.cardType == CardType.Middle).toList();

    List<Layout> currentDeviceLayoutSmall = currentDeviceLayout.where((element) => element.cardType == CardType.Small).toList();

    tempLayoutList.addAll(currentDeviceLayoutBig);

    tempLayoutList.addAll(currentDeviceLayoutMiddle);

    tempLayoutList.addAll(currentDeviceLayoutSmall);

    Screen screenLayer = Screen();

    int originLength = tempLayoutList.length;

    // 当前容器集中的最大页数
    int maxPage = 0;

    // 页数
    for (int i = 0; i < tempLayoutList.length; i++) {
      // 躲开对屏自身的布局，因为继电器已经在默认布局中渲染
      if (tempLayoutList[i].deviceId == System.gatewayApplianceCode) continue;
      if (tempLayoutList[i].deviceId == 'G-${System.gatewayApplianceCode}') continue;

      // 已经有布局的数据直接跳过
      if (tempLayoutList[i].grids != [] && tempLayoutList[i].pageIndex != -1) continue;

      // 尝试占位
      List<int> fillCells = screenLayer.checkAvailability(tempLayoutList[i].cardType);

      if (fillCells.isEmpty) {
        // 不成功，填充剩余空缺
        List<int> fillNullCells = screenLayer.checkAvailability(CardType.Null);
        while (fillNullCells.isNotEmpty) {
          for (int l = 0; l < fillNullCells.length; l++) {
            int grid = fillNullCells[l];
            int row = (grid - 1) ~/ 4;
            int col = (grid - 1) % 4;
            screenLayer.setCellOccupied(row, col, true);
          }
          tempLayoutList.add(Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceNull,
              CardType.Null,
              maxPage,
              fillNullCells,
              DataInputCard(
                  name: '', type: '', applianceCode: '', roomName: '', masterId: '', modelNumber: '', isOnline: '', onlineStatus: '')));
          fillNullCells = screenLayer.checkAvailability(CardType.Null);
          Log.i('计算空缺1', fillNullCells);
        }
        // 待定空格无法填充后就重置布局器
        screenLayer.resetGrid();
        maxPage = maxPage + 1;
        // 重新占位
        fillCells = screenLayer.checkAvailability(tempLayoutList[i].cardType);
        for (int l = 0; l < fillCells.length; l++) {
          int grid = fillCells[l];
          int row = (grid - 1) ~/ 4;
          int col = (grid - 1) % 4;
          screenLayer.setCellOccupied(row, col, true);
        }
        tempLayoutList[i].pageIndex = maxPage;
        tempLayoutList[i].grids = fillCells;
      } else {
        // 成功，填充数据
        for (int l = 0; l < fillCells.length; l++) {
          int grid = fillCells[l];
          int row = (grid - 1) ~/ 4;
          int col = (grid - 1) % 4;
          screenLayer.setCellOccupied(row, col, true);
        }
        tempLayoutList[i].pageIndex = maxPage;
        tempLayoutList[i].grids = fillCells;
      }
      if (i + 1 == originLength) {
        // 占位结束，最后一页填空
        List<int> fillNullCells = screenLayer.checkAvailability(CardType.Null);
        while (fillNullCells.isNotEmpty) {
          tempLayoutList.add(Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceNull,
              CardType.Null,
              maxPage,
              fillNullCells,
              DataInputCard(
                  name: '', type: '', applianceCode: '', roomName: '', masterId: '', modelNumber: '', isOnline: '', onlineStatus: '')));
          for (int l = 0; l < fillNullCells.length; l++) {
            int grid = fillNullCells[l];
            int row = (grid - 1) ~/ 4;
            int col = (grid - 1) % 4;
            screenLayer.setCellOccupied(row, col, true);
          }
          fillNullCells = screenLayer.checkAvailability(CardType.Null);
          Log.i('计算空缺2', fillNullCells);
        }
      }
    }

    await layoutModel.setLayouts(tempLayoutList);
    // 完成布局，抛出
    return true;
  } catch (e) {
    Log.i('一键布局抛出错误', e);
    return false;
  }
}

int getMaxPageIndexOfLayoutList(List<Layout> layouts) {
  int maxPageIndex = -1;
  for (Layout layout in layouts) {
    if (layout.pageIndex > maxPageIndex) {
      maxPageIndex = layout.pageIndex;
    }
  }
  return maxPageIndex;
}

// 用于根据页面索引获取相关的布局对象列表
List<Layout> getLayoutsByPageIndex(int pageIndex, List<Layout> layouts) {
  return layouts.where((item) => item.pageIndex == pageIndex).toList();
}
