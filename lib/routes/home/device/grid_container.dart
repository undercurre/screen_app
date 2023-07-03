import 'package:flutter/cupertino.dart';

import '../../../common/global.dart';
import '../../../widgets/card/main/big_device_light.dart';
import '../../../widgets/card/main/middle_device.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/card/other/clock.dart';
import '../../../widgets/card/other/weather.dart';

// 屏幕布局类
class Screen {
  // 十六进制位部署
  List<int> occupiedCells = [0];

  // 查看这个格子是否被占用
  bool isCellOccupied(int row, int col) {
    int mask = 0x1 << (row * 4 + col);
    return (occupiedCells[0] & mask) != 0;
  }

  // 设置这个格子是否被占用
  void setCellOccupied(int row, int col, bool isOccupied) {
    int mask = 0x1 << (row * 4 + col);
    if (isOccupied) {
      occupiedCells[0] |= mask;
    } else {
      occupiedCells[0] &= ~mask;
    }
  }

  // 重置所有格子
  void resetGrid() {
    occupiedCells[0] = 0;
  }

  // 查出所有被占用的格子
  List<int> getOccupiedGridIndices() {
    List<int> occupiedIndices = [];

    for (var i = 0; i < 16; i++) {
      var mask = 1 << i;
      if ((occupiedCells[0] & mask) != 0) {
        occupiedIndices.add(i);
      }
    }

    return occupiedIndices;
  }

  Map<String, int> getGridCoordinates(int index) {
    final int rindex = index - 1;
    final int row = rindex ~/ 4; // 使用~/进行整数除法，得到商作为行数
    final int col = rindex % 4; // 使用%获取余数作为列数
    return {'row': row, 'col': col};
  }

  List<int> checkAvailability(CardType type) {
    // 小卡片的摆放方式
    if (type == CardType.Small) {
      if (isCellOccupied(0, 0) || isCellOccupied(0, 1)) {
      } else {
        return [1, 2];
      }
      if (isCellOccupied(1, 0) || isCellOccupied(1, 1)) {
      } else {
        return [5, 6];
      }
      if (isCellOccupied(0, 2) || isCellOccupied(0, 3)) {
      } else {
        return [3, 4];
      }
      if (isCellOccupied(1, 2) || isCellOccupied(1, 3)) {
      } else {
        return [7, 8];
      }
      if (isCellOccupied(2, 0) || isCellOccupied(2, 1)) {
      } else {
        return [9, 10];
      }
      if (isCellOccupied(3, 0) || isCellOccupied(3, 1)) {
      } else {
        return [13, 14];
      }
      if (isCellOccupied(2, 2) || isCellOccupied(2, 3)) {
      } else {
        return [11, 12];
      }
      if (isCellOccupied(3, 2) || isCellOccupied(3, 3)) {
      } else {
        return [15, 16];
      }
    }
    // 中卡片的摆放方式
    if (type == CardType.Middle || type == CardType.Other) {
      if (
      isCellOccupied(0, 0) ||
          isCellOccupied(0, 1) ||
          isCellOccupied(1, 0) ||
          isCellOccupied(1, 1)
      ) {
      } else {
        return [1, 2, 5, 6];
      }
      if (
      isCellOccupied(0, 2) ||
          isCellOccupied(0, 3) ||
          isCellOccupied(1, 2) ||
          isCellOccupied(1, 3)
      ) {
      } else {
        return [3, 4, 7, 8];
      }
      if (
      isCellOccupied(1, 0) ||
          isCellOccupied(1, 1) ||
          isCellOccupied(2, 0) ||
          isCellOccupied(2, 1)
      ) {
      } else {
        return [5, 6, 9, 10];
      }
      if (
      isCellOccupied(1, 2) ||
          isCellOccupied(1, 3) ||
          isCellOccupied(2, 2) ||
          isCellOccupied(2, 3)
      ) {
      } else {
        return [7, 8, 11, 12];
      }
      if (
      isCellOccupied(2, 0) ||
          isCellOccupied(2, 1) ||
          isCellOccupied(3, 0) ||
          isCellOccupied(3, 1)
      ) {
      } else {
        return [9, 10, 13, 14];
      }
      if (
      isCellOccupied(2, 2) ||
          isCellOccupied(2, 3) ||
          isCellOccupied(3, 2) ||
          isCellOccupied(3, 3)
      ) {
      } else {
        return [11, 12, 15, 16];
      }
    }
    // 大卡片的摆放方式
    if (type == CardType.Big) {
      if (
      isCellOccupied(0, 0) ||
          isCellOccupied(0, 1) ||
          isCellOccupied(1, 0) ||
          isCellOccupied(1, 1) ||
          isCellOccupied(0, 2) ||
          isCellOccupied(0, 3) ||
          isCellOccupied(1, 2) ||
          isCellOccupied(1, 3)
      ) {
      } else {
        return [1, 2, 3, 4, 5, 6, 7, 8];
      }
      if (
      isCellOccupied(1, 0) ||
          isCellOccupied(1, 1) ||
          isCellOccupied(2, 0) ||
          isCellOccupied(2, 1) ||
          isCellOccupied(1, 2) ||
          isCellOccupied(1, 3) ||
          isCellOccupied(2, 2) ||
          isCellOccupied(2, 3)
      ) {
      } else {
        return [5, 6, 7, 8, 9, 10, 11, 12];
      }
      if (
      isCellOccupied(2, 0) ||
          isCellOccupied(2, 1) ||
          isCellOccupied(3, 0) ||
          isCellOccupied(3, 1) ||
          isCellOccupied(2, 2) ||
          isCellOccupied(2, 3) ||
          isCellOccupied(3, 2) ||
          isCellOccupied(3, 3)
      ) {
      } else {
        return [9, 10, 11, 12, 13, 14, 15, 16];
      }
    }
    return [];
  }
}

Map<CardType, Map<String, double>> sizeMap = {
  CardType.Small: {'width': 210, 'height': 88},
  CardType.Middle: {'width': 210, 'height': 196},
  CardType.Other: {'width': 210, 'height': 196},
  CardType.Big: {'width': 440, 'height': 196},
};

Map<CardType, Map<String, Widget Function(dynamic params)>> buildMap = {
  CardType.Small: {
    'scene': (params) {
      return SmallSceneCardWidget(
          name: params['name'],
          icon: params['icon'],
          onOff: params['onOff']
      );
    },
    '0x13': (params) => SmallDeviceCardWidget(
          name: '灯光1',
          icon: const Image(
            image: AssetImage('assets/newUI/device/light.png'),
          ),
          onOff: true,
          roomName: '客厅',
          characteristic: '40%',
          onTap: () => {logger.i('点击卡片')},
          online: true,
          isFault: true,
          isNative: false,
        )
  },
  CardType.Big: {
    '0x13': (params) => const BigDeviceLightCardWidget(
        name: '灯1',
        onOff: true,
        roomName: '卧室',
        online: true,
        isFault: true,
        isNative: true,
        brightness: 100,
        colorTemp: 99,
        colorPercent: 99)
  },
  CardType.Middle: {
    '0x13': (params) => const MiddleDeviceCardWidget(
        name: '灯2',
        icon: Image(image: AssetImage('assets/newUI/device/light.png')),
        onOff: true,
        roomName: '卧室',
        characteristic: '99',
        online: true,
        isFault: false,
        isNative: false)
  },
  CardType.Other: {
    'clock': (params) => DigitalClockWidget(),
    'weather': (params) => DigitalWeatherWidget()
  }
};

enum CardType { Small, Middle, Big, Other }
