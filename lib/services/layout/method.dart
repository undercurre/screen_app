import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/services/layout/var.dart';

import '../../common/logcat_helper.dart';
import '../../common/system.dart';
import '../../models/device_entity.dart';
import '../../models/scene_info_entity.dart';
import '../../routes/home/device/card_type_config.dart';
import '../../routes/home/device/layout_data.dart';
import '../../states/device_list_notifier.dart';
import '../../states/layout_notifier.dart';
import '../../states/scene_list_notifier.dart';

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
    List<DeviceEntity> deviceNeed =
        deviceHave.where((e) => !currDeviceIds.contains(e.applianceCode) && e.roomId == System.roomInfo?.id).toList();
    // 过滤出需要的场景
    List<SceneInfoEntity> sceneNeed = sceneHave.where((e) => !currSceneIds.contains(e.sceneId) && e.roomId == System.roomInfo?.id).toList();
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
      tempLayoutList.add(  Layout(
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
        getDeviceEntityTypeByTypeOrModelNumber(groupItem.type, groupItem.modelNumber),
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
        getDeviceEntityTypeByTypeOrModelNumber(panelItem.type, panelItem.modelNumber),
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
    List<DeviceEntity> singleLightNeed = deviceNeed
        .where((e) => singleLightModelNumbers.contains(e.modelNumber) || (e.type == '0x13' && e.modelNumber == 'homluxZigbeeLight'))
        .toList();
    tempLayoutList.addAll(singleLightNeed.map((singleLightItem) => Layout(
        singleLightItem.applianceCode,
        getDeviceEntityTypeByTypeOrModelNumber(singleLightItem.type, singleLightItem.modelNumber),
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
        getDeviceEntityTypeByTypeOrModelNumber(curtainItem.type, curtainItem.modelNumber),
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
    List<DeviceEntity> airConditionNeed = deviceNeed.where((e) => e.type == '0xAC').toList();
    tempLayoutList.addAll(airConditionNeed.map((airConditionItem) => Layout(
        airConditionItem.applianceCode,
        getDeviceEntityTypeByTypeOrModelNumber(airConditionItem.type, airConditionItem.modelNumber),
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
    // 地暖
    // 浴霸
    List<DeviceEntity> yubaNeed = deviceNeed.where((e) => e.type == '0x26').toList();
    tempLayoutList.addAll(yubaNeed.map((yubaItem) => Layout(
        yubaItem.applianceCode,
        getDeviceEntityTypeByTypeOrModelNumber(yubaItem.type, yubaItem.modelNumber),
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
        getDeviceEntityTypeByTypeOrModelNumber(liangyijiaItem.type, liangyijiaItem.modelNumber),
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

DeviceEntityTypeInP4 getDeviceEntityTypeByTypeOrModelNumber(String type, String? modelNum) {
  for (var deviceType in DeviceEntityTypeInP4.values) {
    if (type == '0x21') {
      List<String> shuidianqi = ['1114', '1113', '82', '83', '23'];
      if (shuidianqi.contains(modelNum)) {
        return DeviceEntityTypeInP4.Default;
      }
      if (deviceType.toString() == 'DeviceEntityTypeInP4.Zigbee_$modelNum') {
        return deviceType;
      }
      if (deviceType.name == modelNum) {
        return deviceType;
      }
    } else if (type.contains('localPanel1')) {
      return DeviceEntityTypeInP4.LocalPanel1;
    } else if (type.contains('localPanel2')) {
      return DeviceEntityTypeInP4.LocalPanel2;
    } else if (type == '0x13' && modelNum == 'homluxZigbeeLight') {
      return DeviceEntityTypeInP4.Zigbee_homluxZigbeeLight;
    } else if (type == '0x13' && modelNum == 'homluxLightGroup') {
      return DeviceEntityTypeInP4.homlux_lightGroup;
    } else if (type == '3017') {
      return DeviceEntityTypeInP4.Zigbee_3017;
    } else if (type == '3018') {
      return DeviceEntityTypeInP4.Zigbee_3018;
    } else if (type == '3018') {
      return DeviceEntityTypeInP4.Zigbee_3019;
    } else if (type == 'clock') {
      return DeviceEntityTypeInP4.Clock;
    } else if (type == 'weather') {
      return DeviceEntityTypeInP4.Weather;
    } else if (type == 'scene') {
      return DeviceEntityTypeInP4.Scene;
    } else {
      if (deviceType.toString() == 'DeviceEntityTypeInP4.Device$type') {
        return deviceType;
      }
    }
  }
  return DeviceEntityTypeInP4.Default;
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
