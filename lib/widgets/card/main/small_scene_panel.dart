import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/panel_data_adapter.dart';
import 'package:screen_app/common/global.dart';

import '../../../common/adapter/scene_panel_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../common/utils.dart';
import '../../../models/scene_info_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../../states/scene_list_notifier.dart';
import '../../event_bus.dart';
import '../../mz_dialog.dart';
import '../../util/nameFormatter.dart';

class SmallScenePanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String name;
  final String roomName;
  final bool disableOnOff;
  final String isOnline;
  final bool disabled;
  final bool discriminative;
  bool sceneOnOff = false;
  ScenePanelDataAdapter adapter; // 数据适配器

  SmallScenePanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    required this.isOnline,
    required this.name,
    required this.disabled,
    this.disableOnOff = true,
    this.discriminative = false,
  });

  @override
  _SmallScenePanelCardWidgetState createState() =>
      _SmallScenePanelCardWidgetState();
}

class _SmallScenePanelCardWidgetState extends State<SmallScenePanelCardWidget> {
  bool _isFetching = false;
  Timer? _debounceTimer;

  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(Duration(milliseconds: 2000), () async {
        Log.i('触发更新');
        await widget.adapter.fetchData();
        _isFetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.disabled) {
      _startPushListen();
      widget.adapter.init();
      widget.adapter.bindDataUpdateFunction(updateData);
    }
  }

  void updateData() {
    if (mounted) {
      setState(() {
        widget.adapter.data.statusList[0] = widget.adapter.data.statusList[0];
        widget.adapter.data.modeList = widget.adapter.data.modeList;
        widget.adapter.data.sceneList = widget.adapter.data.sceneList;
      });
      // Log.i('更新数据', widget.adapter.data.nameList);
    }
  }

  @override
  void didUpdateWidget(covariant SmallScenePanelCardWidget oldWidget) {
    if (!widget.disabled) {
      widget.adapter.init();
      widget.adapter.bindDataUpdateFunction(updateData);
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    _stopPushListen();
    widget.adapter.unBindDataUpdateFunction(updateData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceneModel = Provider.of<SceneListModel>(context);
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);
    final layoutModel = context.read<LayoutModel>();
    List<SceneInfoEntity> sceneListCache = sceneModel.getCacheSceneList();
    if (sceneListCache.isEmpty) {
      sceneModel.getSceneList().then((value) {
        sceneListCache = sceneModel.getCacheSceneList();
      });
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.adapter.applianceCode);

      if (nameInModel == '未知id' || nameInModel == '未知设备') {
        layoutModel.deleteLayout(widget.adapter.applianceCode);
        TipsUtils.toast(content: '已删除$nameInModel');
      }

      if (widget.disabled) {
        return (nameInModel == '未知id' || nameInModel == '未知设备')
            ? NameFormatter.formatName(widget.name, 4)
            : nameInModel;
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return nameInModel;
    }

    String getRoomName() {
      String nameInModel = deviceListModel.getDeviceRoomName(
          deviceId: widget.adapter.applianceCode);
      if (widget.disabled) {
        return NameFormatter.formatName(widget.roomName, 3);
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    return GestureDetector(
      onTap: () async {
        Log.i('disabled', widget.disabled);
        if (!widget.disabled && widget.adapter.dataState == DataState.SUCCESS) {
          if (widget.isOnline == '0') {
            MzDialog(
                title: '该设备已离线',
                titleSize: 28,
                maxWidth: 432,
                backgroundColor: const Color(0xFF494E59),
                contentPadding: const EdgeInsets.fromLTRB(33, 24, 33, 0),
                contentSlot: const Text("设备离线，请检查网络是否正常",
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                      color: Color(0xFFB6B8BC),
                      fontSize: 24,
                      height: 1.6,
                      fontFamily: "MideaType",
                      decoration: TextDecoration.none,
                    )),
                btns: ['确定'],
                onPressed: (_, position, context) {
                  Navigator.pop(context);
                }).show(context);
          } else {
            if (widget.adapter.data.modeList[0] == '2') {
              sceneModel.sceneExec(widget.adapter.data.sceneList[0]);
              setState(() {
                widget.sceneOnOff = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  widget.sceneOnOff = false;
                });
              });
            } else {
              await widget.adapter.fetchOrderPower(1);
            }
          }
        }
      },
      child: Container(
        width: 210,
        height: 88,
        padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
        decoration: _getBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              child: widget.icon,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.adapter.data.modeList[0] == '0'
                          ? getDeviceName()
                          : _getName(sceneListCache),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  Text(
                    '${getRoomName()} | ${_getRightText()}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.64),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Object? _getRightText() {
    if (widget.disabled) {
      return '';
    }
    if (widget.adapter.dataState == DataState.LOADING ||
        widget.adapter.dataState == DataState.NONE) {
      return '在线';
    }
    if (widget.isOnline == '0') {
      return '离线';
    }
    if (widget.adapter.dataState == DataState.ERROR) {
      return '离线';
    }
    return '在线';
  }

  BoxDecoration _getBoxDecoration() {
    if (widget.disabled) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF767B86),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
          stops: [0, 0.24, 1],
          transform: GradientRotation(194 * (3.1415926 / 360.0)),
        ),
      );
    }
    if (_getOnOff()) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF767B86),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
          stops: [0, 0.24, 1],
          transform: GradientRotation(194 * (3.1415926 / 360.0)),
        ),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33616A76),
          widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33434852),
        ],
        stops: const [0.06, 1.0],
        transform: const GradientRotation(213 * (3.1415926 / 360.0)),
      ),
    );
  }

  bool _getOnOff() {
    // 禁用
    if (widget.disabled) {
      return false;
    }
    // 离线
    if (widget.isOnline == '0') {
      return false;
    }
    // 模式
    if (widget.adapter.data.modeList[0] == '2') {
      // 场景模式
      return widget.sceneOnOff;
    } else {
      // 普通模式
      return widget.adapter.data!.statusList.isNotEmpty &&
          widget.adapter.data!.statusList[0] &&
          widget.adapter.dataState == DataState.SUCCESS;
    }
  }

  String _getName(List<SceneInfoEntity> sceneListCache) {
    if (sceneListCache.isEmpty) return '加载中';

    String sceneIdToCompare = widget.adapter.data.sceneList[0];
    SceneInfoEntity curScene = sceneListCache.firstWhere((element) {
      return element.sceneId.toString() == sceneIdToCompare;
    }, orElse: () {
      SceneInfoEntity sceneObj = SceneInfoEntity();
      sceneObj.name = '加载中';
      return sceneObj;
    });

    if (curScene != null) {
      return curScene.name;
    } else {
      return '加载中';
    }
  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    if (args.nodeId == widget.adapter.nodeId) {
      _throttledFetchData();
    }
  }

  void homluxPush(HomluxDevicePropertyChangeEvent arg) {
    if (arg.deviceInfo.eventData?.deviceId == widget.adapter.applianceCode) {
      _throttledFetchData();
    }
  }

  void _startPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush);
    } else {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush);
    } else {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }
}
