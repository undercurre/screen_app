import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_panel/panel_data_adapter.dart';
import 'package:screen_app/common/adapter/range_hood_device_data_adapter.dart';
import 'package:screen_app/common/adapter/scene_panel_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/routes/plugins/lightGroup/data_adapter.dart';
import 'package:screen_app/widgets/card/main/big_device_air.dart';
import 'package:screen_app/widgets/card/main/big_device_curtain.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/main/big_device_panel.dart';
import 'package:screen_app/widgets/card/main/big_device_panel_three.dart';
import 'package:screen_app/widgets/card/main/big_device_yuba.dart';
import 'package:screen_app/widgets/card/main/big_scene_panel.dart';
import 'package:screen_app/widgets/card/main/local_relay.dart';
import 'package:screen_app/widgets/card/main/middle_device.dart';
import 'package:screen_app/widgets/card/main/middle_device_panel.dart';
import 'package:screen_app/widgets/card/main/small_scene_panel.dart';
import 'package:screen_app/widgets/card/other/light_center.dart';
import '../../../common/adapter/default_lightGroup_adapter.dart';
import '../../../common/adapter/knob_panel_data_adapter.dart';
import '../../../widgets/card/edit.dart';
import '../../../widgets/card/main/big_485Air_device.dart';
import '../../../widgets/card/main/big_485CAC_device.dart';
import '../../../widgets/card/main/big_485Floor_device.dart';
import '../../../widgets/card/main/big_device_electric_water_heater.dart';
import '../../../widgets/card/main/big_device_gas_water_heater.dart';
import '../../../widgets/card/main/big_device_liangyi.dart';
import '../../../widgets/card/main/big_device_light_fun.dart';
import '../../../widgets/card/main/big_range_hood_device.dart';
import '../../../widgets/card/main/big_scene_panel_three.dart';
import '../../../widgets/card/main/middle_485Air_device.dart';
import '../../../widgets/card/main/middle_485CAC_device.dart';
import '../../../widgets/card/main/middle_485Floor_device.dart';
import '../../../widgets/card/main/middle_scene.dart';
import '../../../widgets/card/main/middle_scene_panel.dart';
import '../../../widgets/card/main/small_485Air_device.dart';
import '../../../widgets/card/main/small_485CAC_device.dart';
import '../../../widgets/card/main/small_485Floor_device.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/card/main/small_knob_panel.dart';
import '../../../widgets/card/main/small_panel.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/card/other/clock.dart';
import '../../../widgets/card/other/weather.dart';
import '../../plugins/0x13/data_adapter.dart';
import '../../plugins/0x13_fan/data_adapter.dart';
import '../../plugins/0x14/data_adapter.dart';
import '../../plugins/0x17/data_adapter.dart';
import '../../plugins/0x21/0x21_485_air/air_data_adapter.dart';
import '../../plugins/0x21/0x21_485_cac/cac_data_adapter.dart';
import '../../plugins/0x21/0x21_485_floor/floor_data_adapter.dart';
import '../../plugins/0x21/0x21_curtain/data_adapter.dart';
import '../../plugins/0x21/0x21_curtain_elemachine/data_adapter.dart';
import '../../plugins/0x21/0x21_light/data_adapter.dart';
import '../../plugins/0x26/data_adapter.dart';
import '../../plugins/0xAC/data_adapter.dart';
import '../../plugins/0xE2/data_adapter.dart';
import '../../plugins/0xE3/data_adapter.dart';
import 'grid_container.dart';


/// zigbee窗帘配置
Map<CardType, Widget Function(DataInputCard)> zigbeeCurtain(String icon) {
  return {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: Image(
          image: AssetImage(icon),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        discriminative: params.discriminative ?? false,
        disableOnOff: params.disableOnOff ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x21_curtain',
              arguments: {"name": params.name, "adapter": adapter});
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => ZigbeeCurtainDataAdapter(MideaRuntimePlatform.platform, params.applianceCode, params.masterId));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: Image(
          image: AssetImage(icon),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x21_curtain',
              arguments: {"name": params.name, "adapter": adapter});
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => ZigbeeCurtainDataAdapter(MideaRuntimePlatform.platform, params.applianceCode, params.masterId));
        }),
    CardType.Big: (params) => BigDeviceCurtainCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        icon: icon,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x21_curtain',
              arguments: {"name": params.name, "adapter": adapter});
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => ZigbeeCurtainDataAdapter(MideaRuntimePlatform.platform, params.applianceCode, params.masterId));
        }),
  };
}
/// zigbee灯具配置
Map<CardType, Widget Function(DataInputCard)> zigbeeLight(String icon) {
  return {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: Image(
          image: AssetImage(icon),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ZigbeeLightDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: Image(
          image: AssetImage(icon),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? true,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(
              context, '0x21_light_colorful', arguments: {
            "name": params.name,
            "adapter": adapter
          });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ZigbeeLightDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceLightCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? true,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ZigbeeLightDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
  };
}

enum DeviceEntityTypeInP4 {
  // 编辑
  DeviceEdit,
  // 空位
  DeviceNull,
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
  // 电热水器组件
  Device0xE2,
  // 燃热水器组件
  Device0xE3,
  // wifi灯
  Device0x13,
  // 风扇灯
  Device0x13_fan,
  // wifi窗帘
  Device0x14,
  // Zigbee窗帘
  Zigbee_3057,
  // 浴霸
  Device0x26,
  // 晾衣机
  Device0x17,
  // 抽油烟机
  Device0xB6,
  // 灯组
  Zigbee_lightGroup,
  // zigbee灯
  Zigbee_54,
  Zigbee_55,
  Zigbee_56,
  Zigbee_57,
  Zigbee_1352,
  Zigbee_1353,
  Zigbee_1351,
  Zigbee_1276,
  Zigbee_1359,
  Zigbee_1254,
  Zigbee_1262,
  Zigbee_1263,
  Zigbee_3037,
  // zigbee窗帘
  Zigbee_47,
  Zigbee_51,
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
  Zigbee_1112,
  Zigbee_1111,
  Zigbee_80,
  Zigbee_81,
  Zigbee_22,
  // homlux面板
  Zigbee_homlux1,
  Zigbee_homlux2,
  Zigbee_homlux3,
  Zigbee_homlux4,
  // homlux旋钮调光面板
  Zigbee_homluxKonbDimmingPanel,
  // homluxZigbee灯
  Zigbee_homluxZigbeeLight,
  // homlux灯组
  homlux_lightGroup,
  // homlux房间默认灯组
  homlux_default_lightGroup,
  // 485空调
  Zigbee_3017,
  // 485新风
  Zigbee_3018,
  // 485地暖
  Zigbee_3019,
}

class DataInputCard {
  String name;
  String type;
  String roomName;
  String applianceCode;
  String isOnline;
  BuildContext? context;
  String? sn8;
  String masterId;
  String modelNumber;
  String onlineStatus;
  String? icon;
  String? sceneId;
  bool? disabled;
  bool? hasMore;
  bool? isFault;
  bool? isNative;
  bool? disableOnOff;
  bool? discriminative;
  Function? onTap;

  DataInputCard(
      {required this.name,
      required this.type,
      required this.applianceCode,
      required this.roomName,
      required this.masterId,
      required this.modelNumber,
      required this.isOnline,
      required this.onlineStatus,
      this.context,
      this.icon,
      this.sceneId,
      this.disabled,
      this.hasMore,
      this.isFault,
      this.isNative,
      this.sn8,
      this.disableOnOff,
      this.onTap,
      this.discriminative});

  factory DataInputCard.fromJson(Map<String, dynamic> json) {
    return DataInputCard(
        name: json['name'] as String,
        type: json['type'] as String,
        isOnline: json['isOnline'] as String,
        roomName: json['roomName'] as String,
        applianceCode: json['applianceCode'] as String,
        masterId: json['masterId'] as String,
        modelNumber: json['modelNumber'] as String,
        onlineStatus: json['onlineStatus'] as String,
        sceneId: json['sceneId'] as String?,
        icon: json['icon'] as String?,
        disabled: json['disabled'] as bool?,
        hasMore: json['hasMore'] as bool?,
        isFault: json['isFault'] as bool?,
        isNative: json['isNative'] as bool?,
        disableOnOff: json['disableOnOff'] as bool?,
        sn8: json['sn8'] as String?);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'type': type,
      'roomName': roomName,
      'applianceCode': applianceCode,
      'isOnline': isOnline,
      'masterId': masterId,
      'modelNumber': modelNumber,
      'onlineStatus': onlineStatus,
    };
    if (sceneId != null) {
      data['sceneId'] = sceneId;
    }
    if (icon != null) {
      data['icon'] = icon;
    }
    if (disabled != null) {
      data['disabled'] = disabled;
    }
    if (sn8 != null) {
      data['sn8'] = sn8;
    }
    if (hasMore != null) {
      data['hasMore'] = hasMore;
    }
    if (isFault != null) {
      data['isFault'] = isFault;
    }
    if (isNative != null) {
      data['isNative'] = isNative;
    }
    if (disableOnOff != null) {
      data['disableOnOff'] = disableOnOff;
    }
    return data;
  }
}

Map<DeviceEntityTypeInP4, Map<CardType, Widget Function(DataInputCard params)>>
    buildMap = {
  // 抽油烟机
  DeviceEntityTypeInP4.Device0xB6: {
    CardType.Big: (params) => BigRangeHoodDeviceCardWidget(
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          name: params.name,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => RangeHoodDeviceDataAdapter.create(
                      params.applianceCode,
                      params.masterId ?? '',
                      params.modelNumber,
                    ));
          },
          online: params.isOnline == '1',
          roomName: params.roomName,
        ),
  },
  // 其他组件
  DeviceEntityTypeInP4.Clock: {
    CardType.Other: (params) => DigitalClockWidget(
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Weather: {
    CardType.Other: (params) => DigitalWeatherWidget(
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
        ),
  },
  // homlux面板
  DeviceEntityTypeInP4.Zigbee_homluxKonbDimmingPanel: {
    CardType.Small: (params) => SmallKnobPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage(
                'assets/newUI/device/0x21_homluxKonbDimmingPanel.png'),
          ),
          roomName: params.roomName,
          disabled: params.disabled!,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => KnobPanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId ?? '',
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_homlux1: {
    CardType.Small: (params) => SmallScenePanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          disabled: params.disabled!,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId ?? '',
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_homlux2: {
    CardType.Middle: (params) => MiddleScenePanelCardWidget(
        discriminative: params.discriminative ?? false,
        applianceCode: params.applianceCode,
        disabled: params.disabled!,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_1361.png'),
        ),
        roomName: params.roomName,
        isOnline: params.isOnline,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ScenePanelDataAdapter.create(
                    params.applianceCode,
                    params.masterId,
                    params.modelNumber,
                  ));
        }),
  },
  DeviceEntityTypeInP4.Zigbee_homlux3: {
    CardType.Big: (params) => BigScenePanelCardWidgetThree(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_homlux4: {
    CardType.Big: (params) => BigScenePanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // homluxZigbee灯
  DeviceEntityTypeInP4.Zigbee_homluxZigbeeLight: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_56.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(
              context, '0x21_light_colorful', arguments: {
            "name": params.name,
            "adapter": adapter
          });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ZigbeeLightDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_54.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? true,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(
              context, '0x21_light_colorful', arguments: {
            "name": params.name,
            "adapter": adapter
          });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ZigbeeLightDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceLightCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? true,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ZigbeeLightDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
  },
  // homlux灯组
  DeviceEntityTypeInP4.homlux_lightGroup: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_lightGroup.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, 'lightGroup',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => LightGroupDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_55.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, 'lightGroup',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => LightGroupDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceLightCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => LightGroupDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
  },
  // homlux默认灯组
  DeviceEntityTypeInP4.homlux_default_lightGroup: {
    CardType.Big: (params) => LightControl(
        groupId: params.applianceCode,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => DefaultLightGroupDataAdapter(MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
  },
  // 编辑条
  DeviceEntityTypeInP4.DeviceEdit: {
    CardType.Edit: (params) => const EditCardWidget()
  },
  // 空组件
  DeviceEntityTypeInP4.DeviceNull: {
    CardType.Null: (params) =>
        Container(width: 210, height: 88, color: Colors.transparent)
  },
  // 场景组件
  DeviceEntityTypeInP4.Scene: {
    CardType.Small: (params) {
      return SmallSceneCardWidget(
        name: params.name,
        icon: params.icon ?? '1',
        sceneId: params.sceneId ?? '0000',
        discriminative: params.discriminative ?? false,
        disabled: params.disabled ?? false,
      );
    },
    CardType.Middle: (params) {
      return MiddleSceneCardWidget(
        name: params.name,
        icon: params.icon ?? '1',
        sceneId: params.sceneId ?? '0000',
        discriminative: params.discriminative ?? false,
        disabled: params.disabled ?? false,
      );
    }
  },
  // 本地线控器
  DeviceEntityTypeInP4.LocalPanel1: {
    CardType.Small: (params) => LocalRelayWidget(
          relayIndex: 1,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
        )
  },
  DeviceEntityTypeInP4.LocalPanel2: {
    CardType.Small: (params) => LocalRelayWidget(
          relayIndex: 2,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
        )
  },
  // 灯组
  DeviceEntityTypeInP4.Zigbee_lightGroup: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_lightGroup.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, 'lightGroup',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => LightGroupDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_55.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, 'lightGroup',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => LightGroupDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceLightCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => LightGroupDataAdapter(MideaRuntimePlatform.platform,
                  params.masterId ?? '', params.applianceCode ?? ''));
        }),
  },
  // WIFI灯
  DeviceEntityTypeInP4.Device0x13: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_56.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x13',
              arguments: {
                "name": params.name,
                "adapter": adapter
          });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFILightDataAdapter(MideaRuntimePlatform.platform,
                  params.sn8 ?? '', params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_55.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x13',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFILightDataAdapter(MideaRuntimePlatform.platform,
                  params.sn8 ?? '', params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceLightCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFILightDataAdapter(MideaRuntimePlatform.platform,
                  params.sn8 ?? '', params.applianceCode ?? ''));
        }),
  },
  // WIFI风扇灯
  DeviceEntityTypeInP4.Device0x13_fan: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x13_fan.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x13_fan',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => WIFILightFunDataAdapter(MideaRuntimePlatform.platform, params.applianceCode));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          width: 65,
          height: 65,
          image: AssetImage('assets/newUI/device/0x13_fan.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x13_fan',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => WIFILightFunDataAdapter(MideaRuntimePlatform.platform, params.applianceCode));
        }),
    CardType.Big: (params) => BigDeviceLightFunCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => WIFILightFunDataAdapter(MideaRuntimePlatform.platform, params.applianceCode));
        }),
  },
  // Zigbee窗帘
  DeviceEntityTypeInP4.Zigbee_47: zigbeeCurtain('assets/newUI/device/0x21_47.png'),
  DeviceEntityTypeInP4.Zigbee_51: zigbeeCurtain('assets/newUI/device/0x21_51.png'),
  DeviceEntityTypeInP4.Zigbee_3057: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_3057.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        discriminative: params.discriminative ?? false,
        disableOnOff: params.disableOnOff ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x21_curtain_ele_machine',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => ZigbeeEleMachineCurtainDataAdapter(
              MideaRuntimePlatform.platform,
              params.applianceCode ?? '',
              params.masterId));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_3057.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x21_curtain_ele_machine',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,(id) => ZigbeeEleMachineCurtainDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.applianceCode ?? '',
                      params.masterId));
        }),
    CardType.Big: (params) => BigDeviceCurtainCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        icon: "assets/newUI/device/0x21_3057.png",
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x21_curtain_ele_machine',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id, (id) => ZigbeeEleMachineCurtainDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.applianceCode ?? '',
                      params.masterId));
        }),
  },
  // WIFI窗帘
  DeviceEntityTypeInP4.Device0x14: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x14.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        discriminative: params.discriminative ?? false,
        disableOnOff: params.disableOnOff ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x14',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFICurtainDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x14.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0x14',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFICurtainDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceCurtainCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        icon: "assets/newUI/device/0x14.png",
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFICurtainDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
  },
  // WIFI空调
  DeviceEntityTypeInP4.Device0xAC: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0xAC.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0xAC',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFIAirDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0xAC.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0xAC',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFIAirDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceAirCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFIAirDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
  },
  // 电热水器
  DeviceEntityTypeInP4.Device0xE2: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0xE2.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0xE2',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ElectricWaterHeaterDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0xE2.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0xE2',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ElectricWaterHeaterDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceElectricWaterHeaterWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ElectricWaterHeaterDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
  },
  // 燃热水器
  DeviceEntityTypeInP4.Device0xE3: {
    CardType.Small: (params) => SmallDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0xE3.png'),
        ),
        roomName: params.roomName,
        onTap: () => params.onTap,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0xE3',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => GasWaterHeaterDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0xE3.png'),
        ),
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        goToPageDetailFunction: (context, adapter) {
          Navigator.pushNamed(context, '0xE3',
              arguments: {
                "name": params.name,
                "adapter": adapter
              });
        },
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => GasWaterHeaterDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
    CardType.Big: (params) => BigDeviceGasWaterHeaterWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => GasWaterHeaterDataAdapter(
                  MideaRuntimePlatform.platform, params.applianceCode ?? ''));
        }),
  },
  // 浴霸
  DeviceEntityTypeInP4.Device0x26: {
    CardType.Big: (params) => BigDeviceYubaCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFIYubaDataAdapter(MideaRuntimePlatform.platform,
                  params.sn8 ?? '', params.applianceCode ?? ''));
        }),
  },
  // 晾衣机
  DeviceEntityTypeInP4.Device0x17: {
    CardType.Big: (params) => BigDeviceLiangyiCardWidget(
        applianceCode: params.applianceCode,
        name: params.name,
        roomName: params.roomName,
        online: params.isOnline == '1',
        isFault: params.isFault ?? false,
        isNative: params.isNative ?? false,
        disabled: params.disabled ?? false,
        disableOnOff: params.disableOnOff ?? false,
        discriminative: params.discriminative ?? false,
        hasMore: params.hasMore ?? true,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => WIFILiangyiDataAdapter(MideaRuntimePlatform.platform,
                  params.sn8 ?? '', params.applianceCode ?? ''));
        }),
  },
  // Zigbee灯
  DeviceEntityTypeInP4.Zigbee_54: zigbeeLight('assets/newUI/device/0x21_54.png'),
  DeviceEntityTypeInP4.Zigbee_55: zigbeeLight('assets/newUI/device/0x21_55.png'),
  DeviceEntityTypeInP4.Zigbee_56: zigbeeLight('assets/newUI/device/0x21_56.png'),
  DeviceEntityTypeInP4.Zigbee_57: zigbeeLight('assets/newUI/device/0x21_57.png'),
  DeviceEntityTypeInP4.Zigbee_1254: zigbeeLight('assets/newUI/device/0x21_1254.png'),
  DeviceEntityTypeInP4.Zigbee_1262: zigbeeLight('assets/newUI/device/0x21_1262.png'),
  DeviceEntityTypeInP4.Zigbee_1263: zigbeeLight('assets/newUI/device/0x21_1263.png'),
  DeviceEntityTypeInP4.Zigbee_3037: zigbeeLight('assets/newUI/device/0x21_55.png'),
  DeviceEntityTypeInP4.Zigbee_1276: zigbeeLight('assets/newUI/device/0x21_1276.png'),
  DeviceEntityTypeInP4.Zigbee_1351: zigbeeLight('assets/newUI/device/0x21_1351.png'),
  DeviceEntityTypeInP4.Zigbee_1352: zigbeeLight('assets/newUI/device/0x21_1352.png'),
  DeviceEntityTypeInP4.Zigbee_1353: zigbeeLight('assets/newUI/device/0x21_1353.png'),
  DeviceEntityTypeInP4.Zigbee_1359: zigbeeLight('assets/newUI/device/0x21_1359.png'),
  // 485空调
  DeviceEntityTypeInP4.Zigbee_3017: {
    CardType.Small: (params) => Small485CACDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCC.png'),
          ),
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          isFault: false,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => CACDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
        ),
    CardType.Middle: (params) => Middle485CACDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCC.png'),
          ),
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          isFault: false,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => CACDataAdapter(
                    MideaRuntimePlatform.platform,
                    params.name,
                    params.applianceCode,
                    params.masterId,
                    params.modelNumber));
          },
        ),
    CardType.Big: (params) => Big485CACDeviceAirCardWidget(
          name: params.name,
          roomName: params.roomName,
          isFault: false,
          min: 16,
          max: 30,
          applianceCode: params.applianceCode,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => CACDataAdapter(
                    MideaRuntimePlatform.platform,
                    params.name,
                    params.applianceCode,
                    params.masterId,
                    params.modelNumber));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_3018: {
    CardType.Small: (params) => Small485AirDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCE.png'),
          ),
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          isFault: false,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => AirDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
    CardType.Middle: (params) => Middle485AirDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCE.png'),
          ),
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          isFault: false,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => AirDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
    CardType.Big: (params) => Big485AirDeviceAirCardWidget(
          name: params.name,
          roomName: params.roomName,
          isFault: false,
          applianceCode: params.applianceCode,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => AirDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_3019: {
    CardType.Small: (params) => Small485FloorDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCF.png'),
          ),
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          isFault: false,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => FloorDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
    CardType.Middle: (params) => Middle485FloorDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0xCF.png'),
          ),
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          isFault: false,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => FloorDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
    CardType.Big: (params) => Big485FloorDeviceAirCardWidget(
          name: params.name,
          roomName: params.roomName,
          isFault: false,
          min: 5,
          max: 90,
          applianceCode: params.applianceCode,
          disable: params.disabled ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => FloorDataAdapter(
                      MideaRuntimePlatform.platform,
                      params.name,
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  // 一路面板
  DeviceEntityTypeInP4.Zigbee_1339: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1100: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1081: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1099: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_67: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_68: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_69: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_41: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_34: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_17: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // 二路面板
  DeviceEntityTypeInP4.Zigbee_1340: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1102: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1083: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1101: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_70: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_71: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_72: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_42: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_35: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_18: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  // 三路面板
  DeviceEntityTypeInP4.Zigbee_1341: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          discriminative: params.discriminative ?? false,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1104: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          discriminative: params.discriminative ?? false,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1085: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          discriminative: params.discriminative ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1103: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_73: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_74: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          discriminative: params.discriminative ?? false,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_43: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          discriminative: params.discriminative ?? false,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_36: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          discriminative: params.discriminative ?? false,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_19: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          discriminative: params.discriminative ?? false,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // 四路面板
  DeviceEntityTypeInP4.Zigbee_1342: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1106: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1087: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1105: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_75: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_76: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_37: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_16: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  // 水电面板
  DeviceEntityTypeInP4.Zigbee_1344: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1112: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1111: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_80: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_81: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_22: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  // 一路多功能面板
  DeviceEntityTypeInP4.Zigbee_1347: {
    CardType.Small: (params) => SmallScenePanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId ?? '',
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1360: {
    CardType.Small: (params) => SmallScenePanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId ?? '',
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // 二路多功能面板
  DeviceEntityTypeInP4.Zigbee_1361: {
    CardType.Middle: (params) => MiddleScenePanelCardWidget(
        discriminative: params.discriminative ?? false,
        applianceCode: params.applianceCode,
        disabled: params.disabled!,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_1361.png'),
        ),
        roomName: params.roomName,
        isOnline: params.isOnline,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ScenePanelDataAdapter.create(
                    params.applianceCode,
                    params.masterId,
                    params.modelNumber,
                  ));
        }),
  },
  DeviceEntityTypeInP4.Zigbee_1348: {
    CardType.Middle: (params) => MiddleScenePanelCardWidget(
        discriminative: params.discriminative ?? false,
        applianceCode: params.applianceCode,
        disabled: params.disabled!,
        name: params.name,
        icon: const Image(
          image: AssetImage('assets/newUI/device/0x21_1361.png'),
        ),
        roomName: params.roomName,
        isOnline: params.isOnline,
        adapterGenerateFunction: (id) {
          return MideaDataAdapter.getOrCreateAdapter(
              id,
              (id) => ScenePanelDataAdapter.create(
                    params.applianceCode,
                    params.masterId!,
                    params.modelNumber!,
                  ));
        }),
  },
  // 三路多功能面板
  DeviceEntityTypeInP4.Zigbee_1362: {
    CardType.Big: (params) => BigScenePanelCardWidgetThree(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1349: {
    CardType.Big: (params) => BigScenePanelCardWidgetThree(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // 四路多功能面板
  DeviceEntityTypeInP4.Zigbee_1363: {
    CardType.Big: (params) => BigScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1350: {
    CardType.Big: (params) => BigScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => ScenePanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // 一路窗帘面板
  DeviceEntityTypeInP4.Zigbee_1345: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1108: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1107: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_84: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_85: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_45: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_39: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_31: {
    CardType.Small: (params) => SmallPanelCardWidget(
          discriminative: params.discriminative ?? false,
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
  // 二路窗帘面板
  DeviceEntityTypeInP4.Zigbee_1346: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1110: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1109: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_86: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_87: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_40: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  DeviceEntityTypeInP4.Zigbee_32: {
    CardType.Middle: (params) => MiddleDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId!,
                      params.modelNumber!,
                    ));
          },
        ),
  },
  // 一路单火面板
  DeviceEntityTypeInP4.Zigbee_1301: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          discriminative: params.discriminative ?? false,
          adapterGenerateFunction: (id) {
            return MideaDataAdapter.getOrCreateAdapter(
                id,
                (id) => PanelDataAdapter.create(
                      params.applianceCode,
                      params.masterId,
                      params.modelNumber,
                    ));
          },
          isOnline: params.isOnline,
        ),
  },
};
