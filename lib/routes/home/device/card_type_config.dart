import 'package:flutter/cupertino.dart';
import 'package:screen_app/widgets/card/main/big_device_air.dart';
import 'package:screen_app/widgets/card/main/big_device_curtain.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/main/middle_device.dart';
import '../../../widgets/card/main/small_device.dart';
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
  // zigbee窗帘面板
  Zigbee_1345,
  Zigbee_1346,
  // 多功能面板
  Zigbee_1360,
  Zigbee_1361,
  Zigbee_1362,
  Zigbee_1363
}

Map<DeviceEntityTypeInP4, Map<CardType, Widget Function(dynamic params)>>
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
          name: params['name'], icon: params['icon'], onOff: params['onOff']);
    },
  },
  DeviceEntityTypeInP4.LocalPanel1: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '开关1',
          icon: const Image(
            image: AssetImage('assets/newUI/device/localPanel1.png'),
          ),
          onOff: params['onOff'],
          roomName: '',
          characteristic: '',
          onTap: () => params['onTap'],
          online: true,
          isFault: false,
          isNative: false,
        ),
  },
  DeviceEntityTypeInP4.LocalPanel2: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '开关2',
          icon: const Image(
            image: AssetImage('assets/newUI/device/localPanel2.png'),
          ),
          onOff: params['onOff'],
          roomName: '',
          characteristic: '',
          onTap: () => params['onTap'],
          online: true,
          isFault: false,
          isNative: false,
        ),
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
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          name: '灯光',
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x13.png'),
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
  DeviceEntityTypeInP4.Zigbee_1364: {
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
  DeviceEntityTypeInP4.Zigbee_1339: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '一路灯光面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1339.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1340: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '二路灯光面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1340.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1341: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '三路灯光面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1341.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1342: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '四路灯光面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1342.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1345: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '一路窗帘面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1345.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1346: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '二路窗帘面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1346.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1360: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '一路多功能面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1360.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1361: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '二路多功能面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1361.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1362: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '三路多功能面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1362.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
  DeviceEntityTypeInP4.Zigbee_1363: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '四路多功能面板',
      icon: const Image(
        image: AssetImage('assets/newUI/device/0x21_1363.png'),
      ),
      onOff: true,
      roomName: '卧室',
      characteristic: '',
      onTap: () => {},
      online: true,
      isFault: false,
      isNative: false,
    ),
  },
};
