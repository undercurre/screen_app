import 'package:flutter/cupertino.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/card/other/clock.dart';
import '../../../widgets/card/other/weather.dart';
import 'grid_container.dart';

enum DeviceEntityTypeInP4 {
  // 默认
  Default,
  // 情景
  Scene,
  // wifi灯
  Device0x13,
  // 本地线控器-1路
  LocalPanelOne,
  // 本地线控器-2路
  LocalPanelTwo,
  // 时间组件
  Clock,
  // 天气组件
  Weather
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
  DeviceEntityTypeInP4.LocalPanelOne: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          name: '开关1',
          icon: const Image(
            image: AssetImage('assets/newUI/device/localPanel.png'),
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
  DeviceEntityTypeInP4.LocalPanelTwo: {
    CardType.Small: (params) => SmallDeviceCardWidget(
      name: '开关2',
      icon: const Image(
        image: AssetImage('assets/newUI/device/localPanel.png'),
      ),
      onOff: params['onOff'],
      roomName: '',
      characteristic: '',
      onTap: () => params['onTap'],
      online: true,
      isFault: false,
      isNative: false,
    ),
  }
};
