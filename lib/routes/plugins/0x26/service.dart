import './api.dart';
import './index.dart';
import './mode_list.dart';
import '../../../widgets/index.dart';

class BaseService {
  static void updateDeviceDetail(BathroomMasterState state) async {
    // 如果使用物模型进行查询
    if (state.controlType == 'wot') {
      final res = await BathroomMasterApi.getDetail(state.deviceId);
      final runMode = <String, bool>{};
      for (var key in (res.result['runMode'] as Map<String, dynamic>).keys) {
        runMode[key] = res.result['runMode'][key];
      }
      final mainLight = res.result['lightMode']['mainLight'];
      final nightLight = res.result['lightMode']['nightLight'];
      runMode['light'] = mainLight == true || nightLight == true;
      state.setStateCallBack(
        delayClose: res.result['delayClose'],
        delayTime: res.result['delayTime'],
        mainLight: mainLight,
        nightLight: nightLight,
        runMode: runMode,
      );
    }
  }

  static void toggleNightLight(BathroomMasterState state) {
    final newValue = !state.nightLight;
    final runMode = state.runMode;
    runMode['light'] = newValue || state.mainLight;
    state.setStateCallBack(nightLight: newValue, mainLight: false);
    if (state.controlType == 'wot') {
      BathroomMasterApi.wotControl(
        state.deviceId,
        'setLightMode',
        {
          'lightMode': {'nightLight': newValue, 'mainLight': state.mainLight}
        },
      );
    }
  }

  static void toggleDelayClose(BathroomMasterState state) async {
    if (state.controlType == 'wot') {
      if (!state.delayClose && state.delayTime != 15) {
        // 如果是打开延时关机而且延时时间不是15，那么先设置到15
        await BathroomMasterApi.wotControl(
            state.deviceId, 'setDelayTime', {'delayTime': 15});
        state.setStateCallBack(delayTime: 15);
      }
      state.setStateCallBack(delayClose: !state.delayClose);
      await BathroomMasterApi.wotControl(
        state.deviceId,
        'setDelayClose',
        {'delayClose': state.delayClose},
      );
    }
  }

  static void handleModeCardClick(BathroomMasterState state, Mode mode) {
    final runMode = state.runMode;
    if (mode.key == light.key) {
      // 如果主灯和夜灯都是关则打开主灯
      if (!state.mainLight && !state.nightLight) {
        runMode['light'] = true;
        state.setStateCallBack(mainLight: false, runMode: runMode);
        if (state.controlType == 'wot') {
          BathroomMasterApi.wotControl(
            state.deviceId,
            'setLightMode',
            {
              'lightMode': {'nightLight': false, 'mainLight': true}
            },
          );
        }
      } else {
        // 如果主灯或者夜灯打开则全部关闭
        runMode['light'] = false;
        state.setStateCallBack(
          mainLight: false,
          nightLight: false,
          runMode: runMode,
        );
        if (state.controlType == 'wot') {
          BathroomMasterApi.wotControl(
            state.deviceId,
            'setLightMode',
            {
              'lightMode': {'nightLight': false, 'mainLight': false}
            },
          );
        }
      }
      return;
    } else {
      runModeLogic(runMode, mode);
    }
    state.setStateCallBack(runMode: runMode);
    if (state.controlType == 'wot') {
      BathroomMasterApi.wotControl(
        state.deviceId,
        'setRunMode',
        {
          'runMode': runMode,
        },
      );
    }
  }
}

// todo: 有些逻辑互斥有问题，需要根据单电机和双电机进行确定
// 处理五种运行模式切换逻辑
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
  } else if(mode.key == bath.key) {
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