import './mode_list.dart';
import '../../../widgets/index.dart';

// 通用逻辑处理，根据sn8判断后转wot控制或者lua控制
class BaseService {
  // static void updateDeviceDetail(BathroomMasterState state) async {
  //   final runMode = <String, bool>{};
  //   if (state.controlType == 'wot') {
  //     final res = await BaseApi.getDetail(state.deviceId);
  //     if (res.success) {
  //       for (var key in (res.result['runMode'] as Map<String, dynamic>).keys) {
  //         runMode[key] = res.result['runMode'][key];
  //       }
  //       runMode['light'] = res.result['lightMode']['mainLight'] || res.result['lightMode']['nightLight'];
  //       state.setStateCallBack(
  //         delayClose: res.result['delayClose'],
  //         delayTime: res.result['delayTime'],
  //         mainLight: res.result['lightMode']['mainLight'],
  //         nightLight: res.result['lightMode']['nightLight'],
  //         runMode: runMode,
  //       );
  //     }
  //   } else {
  //     final res = await BaseApi.getDetailByLua(state.deviceId);
  //     if (res.success) {
  //       final activeModeList = (res.result['mode'] as String).split(',');
  //       for (var mode in bathroomMasterMode) {
  //         runMode[mode.key] = activeModeList.contains(mode.key);
  //       }
  //       runMode['light'] = res.result['light_mode'] == 'main_light' ||
  //           res.result['light_mode'] == 'night_light';
  //       state.setStateCallBack(
  //         delayClose: res.result['delay_enable'] == 'on',
  //         delayTime: int.parse(res.result['delay_time']),
  //         mainLight: res.result['light_mode'] == 'main_light',
  //         nightLight: res.result['light_mode'] == 'night_light',
  //         runMode: runMode,
  //       );
  //     }
  //   }
  // }

}

// 处理五种运行模式切换通用逻辑
void runModeLogic(Map<String, bool> runMode, Mode mode) {
  if (mode.key == blowing.key) {
    if (runMode['blowing'] != null && runMode['blowing']!) {
      // 如果取暖已经打开
      runMode['blowing'] = false;
    } else {
      // 如果打开取暖，会关闭安心沐浴、干燥、取暖
      runMode['blowing'] = true;
      runMode['bath'] = false;
      runMode['drying'] = false;
      runMode['heating'] = false;
    }
  } else if (mode.key == heating.key) {
    if (runMode['heating'] != null && runMode['heating']!) {
      // 如果取暖已经打开
      runMode['heating'] = false;
    } else {
      // 如果打开取暖，会关闭安心沐浴、干燥、吹风
      runMode['heating'] = true;
      runMode['bath'] = false;
      runMode['drying'] = false;
      runMode['blowing'] = false;
    }
  } else if (mode.key == bath.key) {
    if (runMode['bath'] != null && runMode['bath']!) {
      // 如果安心沐浴已经打开
      runMode['bath'] = false;
    } else {
      // 如果打开安心沐浴，会关闭换气、干燥、取暖、吹风
      runMode['bath'] = true;
      runMode['ventilation'] = false;
      runMode['drying'] = false;
      runMode['heating'] = false;
      runMode['blowing'] = false;
    }
  } else if (mode.key == ventilation.key) {
    if (runMode['ventilation'] != null && runMode['ventilation']!) {
      // 如果换气已经打开
      runMode['ventilation'] = false;
    } else {
      // 如果打开换气，会关闭干燥、安心沐浴
      runMode['ventilation'] = true;
      runMode['drying'] = false;
      runMode['bath'] = false;
    }
  } else if (mode.key == drying.key) {
    if (runMode['drying'] != null && runMode['drying']!) {
      // 如果干燥已经打开
      runMode['drying'] = false;
    } else {
      // 如果打开干燥，会关闭换气、安心沐浴、取暖、吹风
      runMode['drying'] = true;
      runMode['ventilation'] = false;
      runMode['bath'] = false;
      runMode['heating'] = false;
      runMode['blowing'] = false;
    }
  }
}

// 物模型和lua一起
// class BaseService {
//   static void updateDeviceDetail(BathroomMasterState state) async {
//     // 如果使用物模型进行查询
//     if (state.controlType == 'wot') {
//       final res = await BaseApi.getDetail(state.deviceId);
//       final runMode = <String, bool>{};
//       for (var key in (res.result['runMode'] as Map<String, dynamic>).keys) {
//         runMode[key] = res.result['runMode'][key];
//       }
//       final mainLight = res.result['lightMode']['mainLight'];
//       final nightLight = res.result['lightMode']['nightLight'];
//       runMode['light'] = mainLight == true || nightLight == true;
//       state.setStateCallBack(
//         delayClose: res.result['delayClose'],
//         delayTime: res.result['delayTime'],
//         mainLight: mainLight,
//         nightLight: nightLight,
//         runMode: runMode,
//       );
//     }
//   }
//
//   static void toggleNightLight(BathroomMasterState state) {
//     final newValue = !state.nightLight;
//     final runMode = state.runMode;
//     runMode['light'] = newValue || state.mainLight;
//     state.setStateCallBack(nightLight: newValue, mainLight: false);
//     if (state.controlType == 'wot') {
//       BaseApi.wotControl(
//         state.deviceId,
//         'setLightMode',
//         {
//           'lightMode': {'nightLight': newValue, 'mainLight': state.mainLight}
//         },
//       );
//     } else {
//       BaseApi.luaControl(
//         state.deviceId,
//         {'light_mode': newValue ? 'night_light' : 'close_all'},
//       );
//     }
//   }
//
//   static void toggleDelayClose(BathroomMasterState state) async {
//     state.setStateCallBack(delayClose: !state.delayClose);
//     if (state.controlType == 'wot') {
//       await BaseApi.wotControl(
//         state.deviceId,
//         'setDelayClose',
//         {'delayClose': state.delayClose, 'delayTime': 15},
//       );
//     } else {
//       if (state.delayClose) {
//         BaseApi.luaControl(state.deviceId, {
//           'delay_enable': 'on',
//           'delay_time': '15',
//         });
//       } else {
//         BaseApi.luaControl(state.deviceId, {
//           'delay_enable': 'off',
//         });
//       }
//     }
//   }
//
//   static void handleModeCardClick(BathroomMasterState state, Mode mode) {
//     final runMode = state.runMode;
//     if (mode.key == light.key) {
//       // 如果主灯和夜灯都是关则打开主灯
//       if (!state.mainLight && !state.nightLight) {
//         runMode['light'] = true;
//         state.setStateCallBack(mainLight: true, runMode: runMode);
//         if (state.controlType == 'wot') {
//           BaseApi.wotControl(
//             state.deviceId,
//             'setLightMode',
//             {
//               'lightMode': {'nightLight': false, 'mainLight': true}
//             },
//           );
//         } else {
//           BaseApi.luaControl(
//             state.deviceId,
//             {'light_mode': 'main_light'},
//           );
//         }
//       } else {
//         // 如果主灯或者夜灯打开则全部关闭
//         runMode['light'] = false;
//         state.setStateCallBack(
//           mainLight: false,
//           nightLight: false,
//           runMode: runMode,
//         );
//         if (state.controlType == 'wot') {
//           BaseApi.wotControl(
//             state.deviceId,
//             'setLightMode',
//             {
//               'lightMode': {'nightLight': false, 'mainLight': false}
//             },
//           );
//         } else {
//           BaseApi.luaControl(
//             state.deviceId,
//             {'light_mode': 'close_all'},
//           );
//         }
//       }
//       return;
//     } else {
//       if (state.controlType == 'wot') {
//         // 物模型支持多种模式同时运行
//         runModeLogic(runMode, mode);
//       } else {
//         // lua只支持一种模式
//         for (var modeInList in bathroomMasterMode) {
//           if (modeInList.key == mode.key) {
//             // 如果当前是处于某个mode，则关闭那个mode，否则打开某个mode
//             runMode[modeInList.key] = runMode[modeInList.key] != null && runMode[modeInList.key]! ? false : true;
//           } else {
//             // 其他mode都设置成关闭
//             runMode[modeInList.key] = false;
//           }
//         }}
//     }
//     state.setStateCallBack(runMode: runMode);
//     if (state.controlType == 'wot') {
//       BaseApi.wotControl(
//         state.deviceId,
//         'setRunMode',
//         {
//           'runMode': runMode,
//         },
//       );
//     } else {
//       BaseApi.luaControl(
//         state.deviceId,
//         {'mode': runMode[mode.key]! ? mode.key : 'close_all'},
//       );
//     }
//   }
// }

// 单独物模型
// class BaseService {
//   static void updateDeviceDetail(BathroomMasterState state) async {
//     // 如果使用物模型进行查询
//     final res = await BaseApi.getDetail(state.deviceId);
//     final runMode = <String, bool>{};
//     for (var key in (res.result['runMode'] as Map<String, dynamic>).keys) {
//       runMode[key] = res.result['runMode'][key];
//     }
//     final mainLight = res.result['lightMode']['mainLight'];
//     final nightLight = res.result['lightMode']['nightLight'];
//     runMode['light'] = mainLight == true || nightLight == true;
//     state.setStateCallBack(
//       delayClose: res.result['delayClose'],
//       delayTime: res.result['delayTime'],
//       mainLight: mainLight,
//       nightLight: nightLight,
//       runMode: runMode,
//     );
//   }
//
//   static void toggleNightLight(BathroomMasterState state) {
//     final newValue = !state.nightLight;
//     final runMode = state.runMode;
//     runMode['light'] = newValue || state.mainLight;
//     state.setStateCallBack(nightLight: newValue, mainLight: false);
//     BaseApi.wotControl(
//       state.deviceId,
//       'setLightMode',
//       {
//         'lightMode': {'nightLight': newValue, 'mainLight': state.mainLight}
//       },
//     );
//   }
//
//   static void toggleDelayClose(BathroomMasterState state) async {
//     state.setStateCallBack(delayClose: !state.delayClose);
//     await BaseApi.wotControl(
//       state.deviceId,
//       'setDelayClose',
//       {'delayClose': state.delayClose, 'delayTime': 15},
//     );
//   }
//
//   static void handleModeCardClick(BathroomMasterState state, Mode mode) {
//     final runMode = state.runMode;
//     if (mode.key == light.key) {
//       // 如果主灯和夜灯都是关则打开主灯
//       if (!state.mainLight && !state.nightLight) {
//         runMode['light'] = true;
//         state.setStateCallBack(mainLight: true, runMode: runMode);
//         BaseApi.wotControl(
//           state.deviceId,
//           'setLightMode',
//           {
//             'lightMode': {'nightLight': false, 'mainLight': true}
//           },
//         );
//       } else {
//         // 如果主灯或者夜灯打开则全部关闭
//         runMode['light'] = false;
//         state.setStateCallBack(
//           mainLight: false,
//           nightLight: false,
//           runMode: runMode,
//         );
//         BaseApi.wotControl(
//           state.deviceId,
//           'setLightMode',
//           {
//             'lightMode': {'nightLight': false, 'mainLight': false}
//           },
//         );
//       }
//       return;
//     } else {
//       runModeLogic(runMode, mode);
//     }
//     state.setStateCallBack(runMode: runMode);
//     BaseApi.wotControl(
//       state.deviceId,
//       'setRunMode',
//       {
//         'runMode': runMode,
//       },
//     );
//   }
// }
