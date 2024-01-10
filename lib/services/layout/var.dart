import '../../common/api/api.dart';
import '../../routes/home/device/card_type_config.dart';
import '../../routes/home/device/grid_container.dart';
import '../../routes/home/device/layout_data.dart';

// 时钟-中，天气-中，线控器1-小，线控器2-小，空填充，空填充
List<Layout> defaultConfigPage = [
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