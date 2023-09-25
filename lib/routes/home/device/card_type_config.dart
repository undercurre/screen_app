import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/panel_data_adapter.dart';
import 'package:screen_app/common/adapter/scene_panel_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/routes/plugins/lightGroup/data_adapter.dart';
import 'package:screen_app/widgets/card/main/big_device_air.dart';
import 'package:screen_app/widgets/card/main/big_device_curtain.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/main/big_device_panel.dart';
import 'package:screen_app/widgets/card/main/big_device_panel_three.dart';
import 'package:screen_app/widgets/card/main/big_scene_panel.dart';
import 'package:screen_app/widgets/card/main/local_relay.dart';
import 'package:screen_app/widgets/card/main/middle_device.dart';
import 'package:screen_app/widgets/card/main/middle_device_panel.dart';
import 'package:screen_app/widgets/card/main/small_scene_panel.dart';
import '../../../widgets/card/edit.dart';
import '../../../widgets/card/main/big_485Air_device.dart';
import '../../../widgets/card/main/big_485CAC_device.dart';
import '../../../widgets/card/main/big_485Floor_device.dart';
import '../../../widgets/card/main/big_scene_panel_three.dart';
import '../../../widgets/card/main/middle_485Air_device.dart';
import '../../../widgets/card/main/middle_485CAC_device.dart';
import '../../../widgets/card/main/middle_485Floor_device.dart';
import '../../../widgets/card/main/middle_scene_panel.dart';
import '../../../widgets/card/main/small_485Air_device.dart';
import '../../../widgets/card/main/small_485CAC_device.dart';
import '../../../widgets/card/main/small_485Floor_device.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/card/main/small_panel.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/card/other/clock.dart';
import '../../../widgets/card/other/weather.dart';
import '../../plugins/0x13/data_adapter.dart';
import '../../plugins/0x14/data_adapter.dart';
import '../../plugins/0x21/0x21_485_air/air_data_adapter.dart';
import '../../plugins/0x21/0x21_485_cac/cac_data_adapter.dart';
import '../../plugins/0x21/0x21_485_floor/floor_data_adapter.dart';
import '../../plugins/0x21/0x21_light/data_adapter.dart';
import '../../plugins/0xAC/data_adapter.dart';
import 'grid_container.dart';

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
  // wifi灯
  Device0x13,
  // wifi窗帘
  Device0x14,
  // 新风组件
  Device0xCE,
  // 地暖组件
  Device0xCF,
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
  Zigbee_1112,
  Zigbee_1111,
  Zigbee_80,
  Zigbee_81,
  Zigbee_22,
  // 485空调
  Zigbee_3017,
  // 485新风
  Zigbee_3018,
  // 485地暖
  Zigbee_3019,
  // homlux面板
  Zigbee_homlux1,
  Zigbee_homlux2,
  Zigbee_homlux3,
  Zigbee_homlux4,
  // homluxZigbee灯
  Zigbee_homluxZigbeeLight,
  // homlux灯组
  homlux_lightGroup
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
    );
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
  DeviceEntityTypeInP4.Zigbee_homlux1: {
    CardType.Small: (params) => SmallScenePanelCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          disabled: params.disabled!,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId ?? '',
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_homlux2: {
    CardType.Middle: (params) => MiddleScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_homlux3: {
    CardType.Big: (params) => BigScenePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_homlux4: {
    CardType.Big: (params) => BigScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          discriminative: params.discriminative ?? false,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: LightGroupDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: LightGroupDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: LightGroupDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  // 编辑条
  DeviceEntityTypeInP4.DeviceEdit: {
    CardType.Edit: (params) => const EditCardWidget()
  },
  // 空组件
  DeviceEntityTypeInP4.DeviceNull: {
    CardType.Small: (params) =>
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
          hasMore: params.hasMore ?? true,
          adapter: LightGroupDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: LightGroupDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: LightGroupDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: WIFILightDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.sn8 ?? '', params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: WIFILightDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.sn8 ?? '', params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: WIFILightDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.sn8 ?? '', params.applianceCode ?? ''),
        ),
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
          adapter: WIFICurtainDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.applianceCode ?? ''),
        ),
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
          adapter: WIFICurtainDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: WIFICurtainDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: WIFIAirDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: WIFIAirDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceAirCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: WIFIAirDataAdapter(MideaRuntimePlatform.platform,
              params.context!, params.applianceCode ?? ''),
        ),
  },
  // Zigbee灯
  DeviceEntityTypeInP4.Zigbee_54: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_54.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_55: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_55.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_56: {
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_57: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_57.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          hasMore: params.hasMore ?? true,
          disableOnOff: params.disableOnOff ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1254: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1254.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          hasMore: params.hasMore ?? true,
          disableOnOff: params.disableOnOff ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1262: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1262.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1263: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1263.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          hasMore: params.hasMore ?? true,
          disableOnOff: params.disableOnOff ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1276: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1276.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1351: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1351.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Middle: (params) => MiddleDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1351.png'),
          ),
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          hasMore: params.hasMore ?? true,
          disableOnOff: params.disableOnOff ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1352: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1352.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1353: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1353.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1359: {
    CardType.Small: (params) => SmallDeviceCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1359.png'),
          ),
          roomName: params.roomName,
          onTap: () => params.onTap,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? false,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
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
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
    CardType.Big: (params) => BigDeviceLightCardWidget(
          applianceCode: params.applianceCode,
          name: params.name,
          roomName: params.roomName,
          online: params.isOnline == '1',
          isFault: params.isFault ?? false,
          isNative: params.isNative ?? false,
          disabled: params.disabled ?? false,
          disableOnOff: params.disableOnOff ?? true,
          hasMore: params.hasMore ?? true,
          adapter: ZigbeeLightDataAdapter(
              MideaRuntimePlatform.platform,
              params.context!,
              params.masterId ?? '',
              params.applianceCode ?? ''),
        ),
  },
  // 485空调
  DeviceEntityTypeInP4.Zigbee_3017: {
    CardType.Small: (params) => Small485CACDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          onOff: true,
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          online: params.isOnline,
          isFault: false,
          isNative: false,
          adapter: CACDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
    CardType.Middle: (params) => Middle485CACDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          onOff: true,
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          online: params.isOnline == "0" ? false : true,
          isFault: false,
          isNative: false,
          adapter: CACDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
    CardType.Big: (params) => Big485CACDeviceAirCardWidget(
          name: params.name,
          onOff: true,
          roomName: params.roomName,
          online: params.isOnline == "0" ? false : true,
          isFault: false,
          isNative: false,
          temperature: 26,
          min: 16,
          max: 30,
          adapter: CACDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_3018: {
    CardType.Small: (params) => Small485AirDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          onOff: true,
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          online: params.isOnline,
          isFault: false,
          isNative: false,
          adapter: AirDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
    CardType.Middle: (params) => Middle485AirDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          onOff: true,
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          online: params.isOnline == "0" ? false : true,
          isFault: false,
          isNative: false,
          adapter: AirDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
    CardType.Big: (params) => Big485AirDeviceAirCardWidget(
          name: params.name,
          onOff: true,
          roomName: params.roomName,
          online: params.isOnline == "0" ? false : true,
          isFault: false,
          isNative: false,
          adapter: AirDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_3019: {
    CardType.Small: (params) => Small485FloorDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          onOff: true,
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          online: params.isOnline,
          isFault: false,
          isNative: false,
          adapter: FloorDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
    CardType.Middle: (params) => Middle485FloorDeviceCardWidget(
          name: params.name,
          applianceCode: params.applianceCode,
          modelNumber: params.modelNumber,
          masterId: params.masterId,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          onOff: true,
          roomName: params.roomName,
          characteristic: '',
          onTap: () => {},
          onMoreTap: () => {},
          online: params.isOnline == "0" ? false : true,
          isFault: false,
          isNative: false,
          adapter: FloorDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
    CardType.Big: (params) => Big485FloorDeviceAirCardWidget(
          name: params.name,
          onOff: true,
          roomName: params.roomName,
          online: params.isOnline == "0" ? false : true,
          isFault: false,
          isNative: false,
          temperature: 30,
          min: 5,
          max: 90,
          adapter: FloorDataAdapter(
            MideaRuntimePlatform.platform,
            params.name,
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  // 一路面板
  DeviceEntityTypeInP4.Zigbee_1339: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1100: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1081: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1099: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_67: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_68: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_69: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_41: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_34: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_17: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  // 三路面板
  DeviceEntityTypeInP4.Zigbee_1341: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1104: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1103: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_73: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_74: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_43: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_36: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_19: {
    CardType.Big: (params) => BigDevicePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  // 四路面板
  DeviceEntityTypeInP4.Zigbee_1342: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1106: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1087: {
    CardType.Big: (params) => BigDevicePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
          discriminative: params.discriminative ?? false,
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  // 一路多功能面板
  DeviceEntityTypeInP4.Zigbee_1347: {
    CardType.Small: (params) => SmallScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1360: {
    CardType.Small: (params) => SmallScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  // 二路多功能面板
  DeviceEntityTypeInP4.Zigbee_1361: {
    CardType.Middle: (params) => MiddleScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1348: {
    CardType.Middle: (params) => MiddleScenePanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: const Image(
            image: AssetImage('assets/newUI/device/0x21_1361.png'),
          ),
          roomName: params.roomName,
          isOnline: params.isOnline,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
        ),
  },
  // 三路多功能面板
  DeviceEntityTypeInP4.Zigbee_1362: {
    CardType.Big: (params) => BigScenePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1349: {
    CardType.Big: (params) => BigScenePanelCardWidgetThree(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: ScenePanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  // 一路窗帘面板
  DeviceEntityTypeInP4.Zigbee_1345: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1108: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_1107: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_84: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_85: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_45: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_39: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled!,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
          isOnline: params.isOnline,
        ),
  },
  DeviceEntityTypeInP4.Zigbee_31: {
    CardType.Small: (params) => SmallPanelCardWidget(
          applianceCode: params.applianceCode,
          disabled: params.disabled ?? false,
          discriminative: params.discriminative ?? false,
          name: params.name,
          icon: Image(
            image: AssetImage(
                'assets/newUI/device/0x21_${params.modelNumber}.png'),
          ),
          roomName: params.roomName,
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId!,
            params.modelNumber!,
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId ?? '',
            params.modelNumber ?? '',
          ),
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
          adapter: PanelDataAdapter.create(
            params.applianceCode,
            params.masterId ?? '',
            params.modelNumber ?? '',
          ),
          isOnline: params.isOnline,
        ),
  },
};
