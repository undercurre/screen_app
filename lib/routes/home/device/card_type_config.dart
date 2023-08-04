import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/adapter/panel_data_adapter.dart';
import 'package:screen_app/widgets/card/main/big_device_air.dart';
import 'package:screen_app/widgets/card/main/big_device_curtain.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/main/big_device_panel.dart';
import 'package:screen_app/widgets/card/main/local_relay.dart';
import 'package:screen_app/widgets/card/main/middle_device.dart';
import 'package:screen_app/widgets/card/main/middle_device_panel.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/card/main/small_panel.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/card/other/clock.dart';
import '../../../widgets/card/other/weather.dart';
import 'grid_container.dart';

enum DeviceEntityTypeInP4 {
  // 默认
  Default,
  // 时间组件
  Clock,
  // 天气组件
  Weather,
  // 情景
  Scene,
  // 本地线控器-1路
  LocalPanel1,
  // 本地线控器-2路
  LocalPanel2,
  // 空调组件
  Device0xAC,
  // wifi灯
  Device0x13,
  // wifi窗帘
  Device0x14,
  // 新风组件
  Device0xCE,
  // 地暖组件
  Device0xCF,
  // zigbee灯
  Zigbee_55,
  // zigbee窗帘
  Zigbee_1364,
  // zigbee面板
  Zigbee_1339,
  Zigbee_1340,
  Zigbee_1341,
  Zigbee_1342,
  Zigbee_1106,
  Zigbee_1100,
  Zigbee_1104,
  Zigbee_1102,
  Zigbee_1087,
  Zigbee_1085,
  Zigbee_1083,
  Zigbee_1081,
  Zigbee_1105,
  Zigbee_1103,
  Zigbee_1101,
  Zigbee_1099,
  Zigbee_67,
  Zigbee_68,
  Zigbee_69,
  Zigbee_70,
  Zigbee_71,
  Zigbee_72,
  Zigbee_73,
  Zigbee_74,
  Zigbee_75,
  Zigbee_76,
  Zigbee_43,
  Zigbee_42,
  Zigbee_41,
  Zigbee_37,
  Zigbee_36,
  Zigbee_35,
  Zigbee_34,
  Zigbee_17,
  Zigbee_18,
  Zigbee_19,
  Zigbee_16,
  Zigbee_1301,
  Zigbee_1302,
  Zigbee_1303,
  // zigbee窗帘面板
  Zigbee_1345,
  Zigbee_1346,
  Zigbee_1110,
  Zigbee_1108,
  Zigbee_1109,
  Zigbee_1107,
  Zigbee_84,
  Zigbee_85,
  Zigbee_86,
  Zigbee_87,
  Zigbee_45,
  Zigbee_40,
  Zigbee_39,
  Zigbee_32,
  Zigbee_31,
  // 多功能面板
  Zigbee_1347,
  Zigbee_1348,
  Zigbee_1349,
  Zigbee_1350,
  Zigbee_1360,
  Zigbee_1361,
  Zigbee_1362,
  Zigbee_1363,
  // 水电面板
  Zigbee_1344,
  Zigbee_1114,
  Zigbee_1112,
  Zigbee_1113,
  Zigbee_1111,
  Zigbee_80,
  Zigbee_81,
  Zigbee_82,
  Zigbee_83,
  Zigbee_23,
  Zigbee_22
}

class DataInputCard {
  String name;
  String roomName;
  String applianceCode;
  String isOnline;
  String? masterId;
  String? modelNumber;
  String? icon;
  String? sceneId;
  bool? disabled;

  DataInputCard({
    required this.name,
    this.icon,
    this.sceneId,
    this.disabled,
    required this.applianceCode,
    required this.roomName,
    this.masterId,
    this.modelNumber,
    required this.isOnline,
  });

  factory DataInputCard.fromJson(Map<String, dynamic> json) {
    return DataInputCard(
      name: json['name'] as String,
      isOnline: json['isOnline'] as String,
      roomName: json['roomName'] as String,
      applianceCode: json['applianceCode'] as String,
      masterId: json['masterId'] as String?,
      modelNumber: json['modelNumber'] as String?,
      sceneId: json['sceneId'] as String?,
      icon: json['icon'] as String?,
      disabled: json['disabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'roomName': roomName,
      'applianceCode': applianceCode,
      'isOnline': isOnline,
    };
    if (masterId != null) {
      data['masterId'] = masterId;
    }
    if (modelNumber != null) {
      data['modelNumber'] = modelNumber;
    }
    if (sceneId != null) {
      data['sceneId'] = sceneId;
    }
    if (icon != null) {
      data['icon'] = icon;
    }
    if (disabled != null) {
      data['disabled'] = disabled;
    }
    return data;
  }
}

Map<DeviceEntityTypeInP4, Map<CardType, Widget Function(DataInputCard params)>>
    buildMap = {
  DeviceEntityTypeInP4.Clock: {
    CardType.Other: (params) => DigitalClockWidget(),
  },
  DeviceEntityTypeInP4.Weather: {
    CardType.Other: (params) => DigitalWeatherWidget(),
  },
  DeviceEntityTypeInP4.Scene: {
    CardType.Small: (params) {
      return SmallSceneCardWidget(
          name: params.name,
          icon: params.icon!,
          sceneId: params.sceneId!,
          disabled: params.disabled!);
    },
  },
  DeviceEntityTypeInP4.LocalPanel1: {
    CardType.Small: (params) => const LocalRelayWidget(relayIndex: 1)
  },
  DeviceEntityTypeInP4.LocalPanel2: {
    CardType.Small: (params) => const LocalRelayWidget(relayIndex: 2)
  },
  DeviceEntityTypeInP4.Device0xAC: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '空调',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xAC.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '空调',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xAC.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceAirCardWidget(
          name: '空调',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          temperature: 26,
          min: 0,
          max: 32,
        ),
  },
  DeviceEntityTypeInP4.Device0x13: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '灯光',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x13.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '灯光',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x13.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceLightCardWidget(
          name: '灯光',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          brightness: 20,
          colorTemp: 20,
          colorPercent: 20,
        ),
  },
  DeviceEntityTypeInP4.Device0x14: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xAC.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xAC.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 30,
        ),
  },
  DeviceEntityTypeInP4.Device0xCE: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '新风',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCE.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '新风',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCE.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceAirCardWidget(
          name: '新风',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          temperature: 26,
          min: 0,
          max: 32,
        ),
  },
  DeviceEntityTypeInP4.Device0xCF: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '地暖',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCF.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '地暖',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCF.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceAirCardWidget(
          name: '地暖',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          temperature: 26,
          min: 0,
          max: 32,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1364: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '四路多功能面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3', '按键4'],
          buttonsOnOff: [true, false, false, true],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_55: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '调光调色灯',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_55.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '调光调色灯',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_55.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceLightCardWidget(
          name: '调光调色灯',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          brightness: 20,
          colorTemp: 20,
          colorPercent: 20,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1339: {
    CardType.Small: (params) => SmallPanelCardWidget(
      name: params.name,
      icon: Image(
        image: AssetImage(
            'assets/newUI/device/0x21_${params.modelNumber}.png'),
      ),
      roomName: params.roomName,
      adapter: PanelDataAdapter.create(
        params.applianceCode,
        params.masterId!,
      ), isOnline: params.isOnline,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1100: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1081: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1099: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_67: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_68: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_69: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_41: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_34: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_17: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1301: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1345: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1108: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1107: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_84: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_85: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_45: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_39: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_31: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1347: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1360: {
    CardType.Small: (params) => SmallPanelCardWidget(
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
          ), isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1361: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路多功能面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1348: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路多功能面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1344: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路多功能面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1112: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路多功能面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1111: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路多功能面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_22: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路多功能面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1346: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1110: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1109: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_86: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_87: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_40: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_32: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1302: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1340: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1102: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1083: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1101: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_70: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_71: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_72: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_42: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_35: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_18: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          name: '二路窗帘面板',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1346.png'),
          ),
          roomName: '卧室',
          characteristic: '',
          online: true,
          isFault: false,
          isNative: false,
          btn1Name: '按键1',
          btn1IsOn: true,
          btn2Name: '按键2',
          btn2IsOn: false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1341: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1104: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1085: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1103: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_73: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_74: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_43: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_36: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_19: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1114: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1113: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_82: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_83: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_23: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1362: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路多功能面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1349: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路多功能面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1303: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '三路多功能面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3'],
          buttonsOnOff: [true, false, false],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1342: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '四路灯光面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3', '按键4'],
          buttonsOnOff: [true, false, false, true],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1363: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          name: '四路多功能面板',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          buttonsName: ['按键1', '按键2', '按键3', '按键4'],
          buttonsOnOff: [true, false, false, true],
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1350: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1106: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1087: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1105: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_75: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_76: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_37: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_16: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '卧室',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
          adapter: null,
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '窗帘控制器',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1364.png'),
          ),
          onOff: true,
          roomName: '',
          characteristic: '',
          onTap: () => {},
          online: true,
          isFault: false,
          isNative: false,
        ),
    CardType.Big: (params) => const BigDeviceCurtainCardWidget(
          name: '窗帘控制器',
          onOff: true,
          roomName: '卧室',
          online: true,
          isFault: false,
          isNative: false,
          percent: 50,
        ),
  },
};
