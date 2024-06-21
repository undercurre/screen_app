import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/device_card_data_adapter.dart';
import 'package:screen_app/common/adapter/panel_data_adapter.dart';
import 'package:screen_app/common/adapter/scene_panel_data_adapter.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/states/relay_change_notifier.dart';
import 'package:screen_app/widgets/util/compare.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';

import '../common/adapter/midea_data_adapter.dart';
import '../common/gateway_platform.dart';
import '../common/homlux/models/homlux_485_device_list_entity.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/homlux/models/homlux_device_entity.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/api/meiju_device_api.dart';
import '../common/meiju/models/meiju_device_info_entity.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/system.dart';
import '../main.dart';
import '../models/device_entity.dart';
import '../routes/home/device/card_type_config.dart';
import '../routes/home/device/layout_data.dart';
import '../routes/home/device/grid_container.dart';
import '../widgets/card/main/panelNum.dart';
import '../widgets/util/deviceEntityTypeInP4Handle.dart';

class DeviceInfoListModel extends ChangeNotifier {
  List<MeiJuDeviceInfoEntity> deviceListMeiju = [];
  List<HomluxDeviceEntity> deviceListHomlux = [];
  List<DeviceEntity> deviceCacheList = [];
  List<DeviceEntity> MeijuGroup = [];

  DeviceListModel() {}

  List<DeviceEntity> getCacheDeviceList() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      List<DeviceEntity> tempList = deviceListMeiju.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.name!;
        deviceObj.applianceCode = e.applianceCode!;
        deviceObj.type = e.type!;
        deviceObj.modelNumber = e.modelNumber!;
        deviceObj.sn8 = e.sn8;
        deviceObj.roomName = e.roomName!;
        deviceObj.roomId = e.roomId!;
        deviceObj.masterId = e.masterId!;
        deviceObj.onlineStatus = e.onlineStatus!;
        return deviceObj;
      }).toList();

      tempList.addAll(MeijuGroup);

      tempList.addAll(getMeiJuLocalPanelDevices(deviceListMeiju));

      deviceCacheList = tempList;

      return tempList;
    } else {
      List<DeviceEntity> tempList = deviceListHomlux.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.deviceName!;
        deviceObj.applianceCode = e.deviceId!;
        deviceObj.type = e.proType!;
        deviceObj.modelNumber = getModelNumber(e);
        deviceObj.roomName = e.roomName!;
        deviceObj.roomId = e.roomId!;
        deviceObj.masterId = e.gatewayId ?? '';
        deviceObj.onlineStatus = e.onLineStatus.toString();
        return deviceObj;
      }).toList();

      tempList.addAll(getHomluxLocalPanelDevices(deviceListHomlux));

      deviceCacheList = tempList;

      return tempList;
    }
  }

  List<DeviceEntity> getMeiJuLocalPanelDevices(List<MeiJuDeviceInfoEntity> deviceList) {
    String roomID = System.roomInfo?.id ?? '';
    String roomName = System.roomInfo?.name ?? '';

    String? gatewayApplianceCode = System.gatewayApplianceCode;
    if(deviceList.isNotEmpty && gatewayApplianceCode != null) {
      for (var value in deviceList) {
        if(value.applianceCode == gatewayApplianceCode) {
          roomID = value.roomId ?? roomID;
          roomName = value.roomName ?? roomName;
          break;
        }
      }
    }

    DeviceEntity vLocalPanel1 = DeviceEntity();
    vLocalPanel1.name = '灯1';
    vLocalPanel1.applianceCode = 'localPanel1';
    vLocalPanel1.type = 'localPanel1';
    vLocalPanel1.modelNumber = 'xx';
    vLocalPanel1.roomName = roomName;
    vLocalPanel1.roomId = roomID;
    vLocalPanel1.masterId = uuid.v4();
    vLocalPanel1.onlineStatus = '1';

    DeviceEntity vLocalPanel2 = DeviceEntity();
    vLocalPanel2.name = '灯2';
    vLocalPanel2.applianceCode = 'localPanel2';
    vLocalPanel2.type = 'localPanel2';
    vLocalPanel2.modelNumber = 'xx';
    vLocalPanel2.roomName = roomName;
    vLocalPanel2.roomId = roomID;
    vLocalPanel2.masterId = uuid.v4();
    vLocalPanel2.onlineStatus = '1';
    return [vLocalPanel1, vLocalPanel2];
  }


  List<DeviceEntity> getHomluxLocalPanelDevices(List<HomluxDeviceEntity> deviceList) {
    String roomID = System.roomInfo?.id ?? '';
    String roomName = System.roomInfo?.name ?? '';
    final relayModel =  navigatorKey.currentContext!.read<RelayModel>();

    String? gatewayApplianceCode = System.gatewayApplianceCode;
    if(deviceList.isNotEmpty && gatewayApplianceCode != null) {
      for (var value in deviceList) {
        if(value.deviceId == gatewayApplianceCode) {
          roomID = value.roomId ?? roomID;
          roomName = value.roomName ?? roomName;
          break;
        }
      }
    }

    DeviceEntity vLocalPanel1 = DeviceEntity();
    vLocalPanel1.name = relayModel.localRelay1Name;
    vLocalPanel1.applianceCode = 'localPanel1';
    vLocalPanel1.type = 'localPanel1';
    vLocalPanel1.modelNumber = 'xx';
    vLocalPanel1.roomName = roomName;
    vLocalPanel1.roomId = roomID;
    vLocalPanel1.masterId = uuid.v4();
    vLocalPanel1.onlineStatus = '1';

    DeviceEntity vLocalPanel2 = DeviceEntity();
    vLocalPanel2.name = relayModel.localRelay2Name;
    vLocalPanel2.applianceCode = 'localPanel2';
    vLocalPanel2.type = 'localPanel2';
    vLocalPanel2.modelNumber = 'xx';
    vLocalPanel2.roomName = roomName;
    vLocalPanel2.roomId = roomID;
    vLocalPanel2.masterId = uuid.v4();
    vLocalPanel2.onlineStatus = '1';
    return [vLocalPanel1, vLocalPanel2];
  }

  Future<List<DeviceEntity>> getDeviceList(String reason) async {
    Log.d(reason);
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      final familyInfo = System.familyInfo;
      if(MeiJuGlobal.token==null||familyInfo==null){
        return [];
      }
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> MeijuRes =
          await MeiJuDeviceApi.queryDeviceListByHomeId(
              MeiJuGlobal.token!.uid, familyInfo.familyId);

      MeiJuResponseEntity<Map<String, dynamic>> MeijuGroups =
          await MeiJuDeviceApi.getGroupList();
      if (MeijuRes.isSuccess && MeijuGroups.isSuccess) {
        deviceListMeiju = MeijuRes.data!;
        notifyListeners();

        List<DeviceEntity> tempList = deviceListMeiju.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.name!;
          deviceObj.applianceCode = e.applianceCode!;
          deviceObj.type = e.type!;
          deviceObj.modelNumber = e.modelNumber!;
          deviceObj.sn8 = e.sn8;
          deviceObj.roomName = e.roomName!;
          deviceObj.roomId = e.roomId!;
          deviceObj.masterId = e.masterId!;
          deviceObj.onlineStatus = e.onlineStatus!;
          return deviceObj;
        }).toList();

        MeijuGroup = (MeijuGroups.data!["applianceGroupList"] as List<dynamic>)
            .map<DeviceEntity>((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e["name"];
          deviceObj.applianceCode = e["groupId"].toString();
          deviceObj.type = "0x21";
          deviceObj.modelNumber = "lightGroup";
          deviceObj.roomName = e["roomName"];
          deviceObj.roomId = e["roomId"].toString();
          deviceObj.masterId =
              e["applianceList"][0]["parentApplianceCode"].toString();
          deviceObj.onlineStatus = "1";
          return deviceObj;
        }).toList();

        tempList.addAll(MeijuGroup);

        tempList.addAll(getMeiJuLocalPanelDevices(deviceListMeiju));

        Log.i('网表', tempList.map((e) => '${e.name}${e.type}${e.onlineStatus}').toList());

        deviceCacheList = tempList;

        updateAllAdapter(tempList.map((e) => e.applianceCode).toList());

        return tempList;
      }
    } else {
      final familyInfo = System.familyInfo;
      if(familyInfo==null){
        return [];
      }
      HomluxResponseEntity<List<HomluxDeviceEntity>> HomluxRes = await HomluxDeviceApi.queryDeviceListByHomeId(familyInfo.familyId);

      if (HomluxRes.isSuccess) {
        deviceListHomlux = HomluxRes.data!;

        List<DeviceEntity> tempList = deviceListHomlux.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.deviceName!;
          deviceObj.applianceCode = e.deviceId!;
          deviceObj.type = e.proType!;
          deviceObj.modelNumber = getModelNumber(e);
          deviceObj.roomName = e.roomName!;
          deviceObj.roomId = e.roomId ?? System.roomInfo?.id;
          deviceObj.masterId = e.gatewayId ?? '';
          deviceObj.onlineStatus = e.onLineStatus.toString();
          Log.i('填充临时列表', deviceObj);
          return deviceObj;
        }).toList();

        tempList.addAll(getHomluxLocalPanelDevices(deviceListHomlux));

        updateAllAdapter(tempList.map((e) => e.applianceCode).toList());

        deviceCacheList = tempList;

        Log.i('网表', tempList.map((e) => '${e.name}${e.onlineStatus}').toList());

        notifyListeners();

        return tempList;
      }
    }
    Log.i('更新列表数据——美居', deviceListMeiju.length);
    Log.i('更新列表数据——homlux', deviceListHomlux.length);
    return [];
  }

  void updateAllAdapter(List<String> existingApplianceCodes) {
    List<String> lastedApplianceCodes = MideaDataAdapter.adapterMap.keys.toList();
    existingApplianceCodes.forEach((element) {
      if (MideaDataAdapter.getAdapter(element) is DeviceCardDataAdapter) {
        // 普通设备Adapter
        if((MideaDataAdapter.getAdapter(element) as DeviceCardDataAdapter).isContainUpdateUIFunction()) {
          (MideaDataAdapter.getAdapter(element) as DeviceCardDataAdapter).fetchData();
        }
      } else if (MideaDataAdapter.getAdapter(element) is PanelDataAdapter) {
        if((MideaDataAdapter.getAdapter(element) as PanelDataAdapter).isContainUpdateUIFunction()) {
          (MideaDataAdapter.getAdapter(element) as PanelDataAdapter).fetchData();
        }
        // 面板设备Adapter
      } else if (MideaDataAdapter.getAdapter(element) is ScenePanelDataAdapter) {
        // 面板设备Adapter
        if((MideaDataAdapter.getAdapter(element) as ScenePanelDataAdapter).isContainUpdateUIFunction()) {
          (MideaDataAdapter.getAdapter(element) as ScenePanelDataAdapter).fetchData();
        }
      }
    });
    List<List<String>> compareDevice = Compare.compareData<String>(lastedApplianceCodes, existingApplianceCodes);
    // 删除了的
    compareDevice[1].forEach((element) {
      MideaDataAdapter.removeAdapter(element);
    });
  }

  String getDeviceName(
      {String? deviceId,
      int maxLength = 4,
      int startLength = 1,
      int endLength = 2,
      bool acronym = true}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        if (acronym) {
          return NameFormatter.formLimitString(
              curOne[0].name, maxLength, startLength, endLength);
        } else {
          return curOne[0].name;
        }
      } else {
        return '未知设备';
      }
    } else {
      return '未知id';
    }
  }

  String getDeviceNameNormal(
      {String? deviceId}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        return curOne[0].name;
      } else {
        return '未知设备';
      }
    } else {
      return '未知id';
    }
  }

  String getDeviceRoomName(
      {String? deviceId,
      int maxLength = 4,
      int startLength = 1,
      int endLength = 2}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        return NameFormatter.formLimitString(
            curOne[0].roomName!, maxLength, startLength, endLength);
      } else {
        return '未知区域';
      }
    } else {
      return '未知id';
    }
  }

  @Deprecated("此方法已经过期，请勿再使用。后续不再保证此方法的返回状态正确性。"
      "查询设备的离在线状态请使用[DeviceCardDataAdapter的fetchOnlineState方法]")
  bool getOnlineStatus({String? deviceId}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        return curOne[0].onlineStatus == '1';
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  List<Layout> transformLayoutFromDeviceList(List<DeviceEntity> devices) {
    List<Layout> transformList = [
      Layout(
          'clock',
          DeviceEntityTypeInP4.Clock,
          CardType.Other,
          0,
          [1, 2, 5, 6],
          DataInputCard(
              name: '时钟',
              applianceCode: 'clock',
              roomName: '屏内',
              isOnline: '',
              type: 'clock',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')),
      Layout(
          'weather',
          DeviceEntityTypeInP4.Weather,
          CardType.Other,
          0,
          [3, 4, 7, 8],
          DataInputCard(
              name: '天气',
              applianceCode: 'weather',
              roomName: '屏内',
              isOnline: '',
              type: 'weather',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')),
      Layout(
          'localPanel1',
          DeviceEntityTypeInP4.LocalPanel1,
          CardType.Small,
          0,
          [9, 10],
          DataInputCard(
              name: '灯1',
              applianceCode: 'localPanel1',
              roomName: '屏内',
              isOnline: '',
              type: 'localPanel1',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')),
      Layout(
          'localPanel2',
          DeviceEntityTypeInP4.LocalPanel2,
          CardType.Small,
          0,
          [11, 12],
          DataInputCard(
              name: '灯2',
              applianceCode: 'localPanel2',
              roomName: '屏内',
              isOnline: '',
              type: 'localPanel2',
              masterId: '',
              modelNumber: '',
              onlineStatus: '1')),
    ];
    // 初始化布局占位器
    Screen screenLayer = Screen();
    // 页数
    int page = 0;
    for (int i = 0; i < devices.length; i++) {
      if (devices[i].applianceCode == System.gatewayApplianceCode) continue;
      if (devices[i].applianceCode == 'G-${System.gatewayApplianceCode}') continue;
      // 当前设备的映射type
      DeviceEntityTypeInP4 curDeviceEntity = DeviceEntityTypeInP4Handle.getDeviceEntityType(devices[i].type, devices[i].modelNumber,devices[i].sn8);

      // 检查当前设备是否是面板的标志
      bool isPanel = _isPanel(devices[i].modelNumber, devices[i].type);
      // 当前容器集中的最大页数
      int maxPage = getMaxPageIndex(transformList);
      // 当前设备构造Layout模型的cardType
      CardType curCardType = CardType.Small;
      for (CardType type in CardType.values) {
        if (buildMap[curDeviceEntity]?[type] != null) {
          curCardType = type;
          break;
        }
      }
      if (isPanel) {
        curCardType =
            _getPanelCardType(devices[i].modelNumber, devices[i].type);
      }
      // 构造当前设备的Layout模型
      if (curDeviceEntity != DeviceEntityTypeInP4.Default) {
        Layout curDevice = Layout(
          devices[i].applianceCode,
          curDeviceEntity,
          curCardType,
          page,
          [],
          DataInputCard(
            name: devices[i].name,
            applianceCode: devices[i].applianceCode,
            roomName: devices[i].roomName ?? '未知区域',
            modelNumber: devices[i].modelNumber,
            masterId: devices[i].masterId,
            sn8: devices[i].sn8,
            isOnline: devices[i].onlineStatus,
            disabled: false,
            type: devices[i].type,
            onlineStatus: devices[i].onlineStatus,
          ),
        );
        // 当前没有页
        if (maxPage == -1) {
          // 直接占位
          List<int> fillCells = screenLayer.checkAvailability(curCardType);
          if (fillCells.isEmpty) {
            curDevice.pageIndex = 0;
            screenLayer.resetGrid();
            curDevice.grids = screenLayer.checkAvailability(curCardType);
          } else {
            curDevice.grids = fillCells;
          }
        } else {
          // 遍历每一页已有的进行补充
          for (int k = 0; k <= maxPage; k++) {
            // 找到当前页的布局数据并填充布局器
            screenLayer.resetGrid();
            List<Layout> curPageLayoutList =
                getLayoutsByPageIndex(k, transformList);
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
            List<int> fillCells = screenLayer.checkAvailability(curCardType);
            Log.i('尝试布局$k', fillCells);
            if (fillCells.isEmpty) {
              // 占位没有成功，说明这一页已经没有适合的位置了
              // 如果最后一页也没有合适的位置就新增一页
              if (k == maxPage) {
                curDevice.pageIndex = maxPage + 1;
                screenLayer.resetGrid();
                List<int> fillCellsAgain =
                    screenLayer.checkAvailability(curCardType);
                curDevice.grids = fillCellsAgain;
              }
            } else {
              // 占位成功
              curDevice.pageIndex = k;
              curDevice.grids = fillCells;
              break;
            }
          }
        }
        Log.i('生成布局${curDevice.pageIndex}', curDevice.grids);
        transformList.add(curDevice);
      }
    }

    if (transformList.isEmpty) {
      List<Layout> defaultList = [
        Layout(
            'clock',
            DeviceEntityTypeInP4.Clock,
            CardType.Other,
            0,
            [1, 2, 5, 6],
            DataInputCard(
                name: '时钟',
                applianceCode: 'clock',
                roomName: '屏内',
                isOnline: '',
                type: 'clock',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'weather',
            DeviceEntityTypeInP4.Weather,
            CardType.Other,
            0,
            [3, 4, 7, 8],
            DataInputCard(
                name: '天气',
                applianceCode: 'weather',
                roomName: '屏内',
                isOnline: '',
                type: 'weather',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'localPanel1',
            DeviceEntityTypeInP4.LocalPanel1,
            CardType.Small,
            0,
            [9, 10],
            DataInputCard(
                name: '灯1',
                applianceCode: 'localPanel1',
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel1',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'localPanel2',
            DeviceEntityTypeInP4.LocalPanel2,
            CardType.Small,
            0,
            [11, 12],
            DataInputCard(
                name: '灯2',
                applianceCode: 'localPanel2',
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel2',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            0,
            [13, 14],
            DataInputCard(
                name: '',
                applianceCode: '',
                roomName: '',
                isOnline: '',
                type: '',
                masterId: '',
                modelNumber: '',
                onlineStatus: '')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            0,
            [15, 16],
            DataInputCard(
                name: '',
                applianceCode: '',
                roomName: '',
                isOnline: '',
                type: '',
                masterId: '',
                modelNumber: '',
                onlineStatus: ''))
      ];
      transformList.addAll(defaultList);
    }

    // 轮询填充空缺
    int lastPageIndex = getMaxPageIndex(transformList);
    for (int l = 0; l <= lastPageIndex; l ++) {
      // 取得当前页布局
      List<Layout> waitForFillPageLayouts = transformList.where((element) => element.pageIndex == l).toList();
      // 填充
      List<Layout> lastPageLayoutsAfterFilled = Layout.filledLayout(waitForFillPageLayouts);
      for (int o = 0; o < lastPageLayoutsAfterFilled.length; o++) {
        if (lastPageLayoutsAfterFilled[o].cardType == CardType.Null) {
          transformList.add(lastPageLayoutsAfterFilled[o]);
        }
      }
    }

    return transformList;
  }

  CardType _getPanelCardType(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return CardType.Small;
    }
    return panelList[modelNum] ?? CardType.Small;
  }

  bool _isPanel(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return true;
    }

    return panelList.containsKey(modelNum);
  }

  int getMaxPageIndex(List<Layout> layouts) {
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
}

String getModelNumber(HomluxDeviceEntity e) {
  if (e.proType == '0x21') {
    if(e.productId == "midea.knob.001.003") {
      return "homluxKonbDimmingPanel";
    } else {
      return 'homlux${e.switchInfoDTOList?.length}';
    }
  }

  if (e.proType == '0x13' && e.deviceType == 2) {
    return 'homluxZigbeeLight';
  }

  if (e.proType == '0x13' && e.deviceType == 4) {
    return 'homluxLightGroup';
  }

  if(e.proType == '0xCF' && e.deviceType == 2) {
    return '3019';
  }

  if(e.proType == '0xCE' && e.deviceType == 2) {
    return '3018';
  }

  if(e.proType == '0xCC' && e.deviceType == 2) {
    return '3017';
  }

  return e.deviceType.toString();
}
