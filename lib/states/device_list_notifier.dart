import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';

import '../common/gateway_platform.dart';
import '../common/homlux/models/homlux_485_device_list_entity.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/homlux/models/homlux_device_entity.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/api/meiju_device_api.dart';
import '../common/meiju/models/meiju_device_info_entity.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/system.dart';
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

      tempList.addAll(getLocalPanelDevices());

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

      tempList.addAll(getLocalPanelDevices());

      deviceCacheList = tempList;

      return tempList;
    }
  }

  List<DeviceEntity> getLocalPanelDevices() {
    String roomID = System.roomInfo?.id ?? '';
    String roomName = System.roomInfo?.name ?? '';

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

  Future<List<DeviceEntity>> getDeviceList() async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      final familyInfo = System.familyInfo;
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> MeijuRes =
          await MeiJuDeviceApi.queryDeviceListByHomeId(
              MeiJuGlobal.token!.uid, familyInfo!.familyId);

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

        tempList.addAll(getLocalPanelDevices());

        Log.i('网表', tempList.map((e) => e.name).toList());

        deviceCacheList = tempList;

        return tempList;
      }
    } else {
      final familyInfo = System.familyInfo;
      HomluxResponseEntity<List<HomluxDeviceEntity>> HomluxRes =
          await HomluxDeviceApi.queryDeviceListByHomeId(familyInfo!.familyId);
      if (HomluxRes.isSuccess) {
        deviceListHomlux = HomluxRes.data!;
        notifyListeners();

        ///homlux添加本地485设备
        Homlux485DeviceListEntity? deviceList =
            HomluxGlobal.getHomlux485DeviceList;

        ///homlux添加本地485空调设备
        for (int i = 0; i < deviceList!.nameValuePairs!.airConditionList!.length; i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName =
              "空调${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
          device.deviceId =
              "${(deviceList!.nameValuePairs!.airConditionList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
          device.proType = "0x21";
          device.deviceType = 3017;
          device.roomName = System.roomInfo?.name;
          device.roomId = System.roomInfo?.id;
          device.gatewayId = HomluxGlobal.gatewayApplianceCode;
          String? online =
              deviceList!.nameValuePairs!.airConditionList![i].onlineState;
          device.onLineStatus = int.parse(online!);
          deviceListHomlux.add(device);
        }

        ///homlux添加本地485新风设备
        for (int i = 0; i < deviceList!.nameValuePairs!.freshAirList!.length; i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName =
              "新风${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
          device.deviceId =
              "${(deviceList!.nameValuePairs!.freshAirList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
          device.proType = "0x21";
          device.deviceType = 3018;
          device.roomName = System.roomInfo?.name;
          device.roomId = System.roomInfo?.id;
          device.gatewayId = HomluxGlobal.gatewayApplianceCode;
          String? online =
              deviceList!.nameValuePairs!.freshAirList![i].onlineState;
          device.onLineStatus = int.parse(online!);
          deviceListHomlux.add(device);
        }

        ///homlux添加本地485地暖设备
        for (int i = 0; i < deviceList!.nameValuePairs!.floorHotList!.length; i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName =
              "地暖${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
          device.deviceId =
              "${(deviceList!.nameValuePairs!.floorHotList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
          device.proType = "0x21";
          device.deviceType = 3019;
          device.roomName = System.roomInfo?.name;
          device.roomId = System.roomInfo?.id;
          device.gatewayId = HomluxGlobal.gatewayApplianceCode;
          String? online =
              deviceList!.nameValuePairs!.floorHotList![i].onlineState;
          device.onLineStatus = int.parse(online!);
          deviceListHomlux.add(device);
        }


        List<DeviceEntity> tempList = deviceListHomlux.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.deviceName!;
          deviceObj.applianceCode = e.deviceId!;
          deviceObj.type = e.proType!;
          deviceObj.modelNumber = getModelNumber(e);
          deviceObj.roomName = e.roomName!;
          deviceObj.roomId = System.roomInfo?.id;
          deviceObj.masterId = e.gatewayId ?? '';
          deviceObj.onlineStatus = e.onLineStatus.toString();
          return deviceObj;
        }).toList();

        tempList.addAll(getLocalPanelDevices());

        deviceCacheList = tempList;

        return tempList;
      }
    }
    return [];
  }

  String getDeviceName({String? deviceId}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        return NameFormatter.formatName(curOne[0].name!, 4);
      } else {
        return '未知设备';
      }
    } else {
      return '未知id';
    }
  }

  String getDeviceRoomName({String? deviceId}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        return NameFormatter.formatName(curOne[0].roomName!, 3);
      } else {
        return '未知区域';
      }
    } else {
      return '未知id';
    }
  }

  bool getOnlineStatus({String? deviceId}) {
    if (deviceId != null) {
      List<DeviceEntity> curOne = deviceCacheList
          .where((element) => element.applianceCode == deviceId)
          .toList();
      if (curOne.isNotEmpty) {
        Log.i('获取设备$deviceId在线状态 ${curOne[0]}');
        return curOne[0].onlineStatus == '1';
      } else {
        Log.i('获取设备$deviceId在线状态 离线');
        return false;
      }
    } else {
      Log.i('获取设备$deviceId在线状态 离线');
      return false;
    }
  }

  List<Layout> transformLayoutFromDeviceList(List<DeviceEntity> devices) {
    List<Layout> transformList = [];
    // 初始化布局占位器
    Screen screenLayer = Screen();
    // 页数
    int page = 0;
    for (int i = 0; i < devices.length; i++) {
      // 当前设备的映射type
      DeviceEntityTypeInP4 curDeviceEntity =
          DeviceEntityTypeInP4Handle.getDeviceEntityType(
              devices[i].type, devices[i].modelNumber);
      // 检查当前设备是否是面板的标志
      bool isPanel = _isPanel(devices[i].modelNumber, devices[i].type);
      // 当前容器集中的最大页数
      int maxPage = getMaxPageIndex(transformList);
      // 当前设备构造Layout模型的cardType
      CardType curCardType = CardType.Small;
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
            curDevice.pageIndex = 1;
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
  List<int> ac485List = [3017, 3018, 3019];
  if (e.proType == '0x21' && ac485List.contains(e.deviceType)) {
    return e.deviceType.toString();
  } else if (e.proType == '0x21') {
    return 'homlux${e.switchInfoDTOList?.length}';
  }

  if (e.proType == '0x13' && e.deviceType == 2) {
    return 'homluxZigbeeLight';
  }

  if (e.proType == '0x13' && e.deviceType == 4) {
    return 'homluxLightGroup';
  }

  return e.deviceType.toString();
}
