import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_panel/panel_data_adapter.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_entity.dart';

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
import '../method.dart';

class SmallScenePanelCardWidget extends StatefulWidget {
  final String applianceCode;
  final Widget icon;
  final String name;
  final String roomName;
  final bool disableOnOff;
  final String isOnline;
  final bool disabled;
  final bool discriminative;
  bool sceneOnOff = false;
  AdapterGenerateFunction<ScenePanelDataAdapter> adapterGenerateFunction;

  SmallScenePanelCardWidget({
    super.key,
    required this.icon,
    required this.roomName,
    required this.isOnline,
    required this.name,
    required this.disabled,
    this.disableOnOff = true,
    this.discriminative = false, required this.applianceCode,
    required this.adapterGenerateFunction
  });

  @override
  _SmallScenePanelCardWidgetState createState() =>
      _SmallScenePanelCardWidgetState();
}

class _SmallScenePanelCardWidgetState extends State<SmallScenePanelCardWidget> {
  
  late ScenePanelDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    adapter.bindDataUpdateFunction(updateData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void updateData() {
    if (mounted) {
      setState(() {
        adapter.data.statusList[0] = adapter.data.statusList[0];
        adapter.data.modeList = adapter.data.modeList;
        adapter.data.sceneList = adapter.data.sceneList;
      });
      // Log.i('更新数据', adapter.data.nameList);
    }
  }

  @override
  void didUpdateWidget(covariant SmallScenePanelCardWidget oldWidget) {
    if (!widget.disabled) {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    adapter.unBindDataUpdateFunction(updateData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceneModel = Provider.of<SceneListModel>(context);
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
    List<SceneInfoEntity> sceneListCache = sceneModel.getCacheSceneList();

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.applianceCode, maxLength: 4, startLength: 1, endLength: 2);

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

    String _getRightText() {
      if (widget.discriminative) {
        return '';
      }
      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }
      if (widget.disabled) {
        return '';
      }
      // if (adapter.dataState == DataState.LOADING ||
      //     adapter.dataState == DataState.NONE) {
      //   return '在线';
      // }
      if (!deviceListModel.getOnlineStatus(
          deviceId: widget.applianceCode)) {
        return '离线';
      }
      if (adapter.dataState == DataState.ERROR) {
        return '离线';
      }
      if (adapter.data!.statusList.isNotEmpty) {
        return '在线';
      } else {
        return '离线';
      }
    }

    bool _getOnOff() {
      // 禁用
      if (widget.disabled) {
        return false;
      }
      // 离线
      if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
        return false;
      }
      // 模式
      if (adapter.data.modeList[0] == '2') {
        // 场景模式
        return widget.sceneOnOff;
      } else {
        Log.i('普通模式开关状态');
        // 普通模式
        return adapter.data!.statusList.isNotEmpty &&
            adapter.data!.statusList[0] &&
            adapter.dataState == DataState.SUCCESS;
      }
    }

    BoxDecoration _getBoxDecoration() {
      if (widget.disabled) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled')
        );
      }
      if (_getOnOff()) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: getBigCardColorBg('open'),
        );
      }
      return BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'),
      );
    }

    String getRoomName() {
      String nameInModel = deviceListModel.getDeviceRoomName(
          deviceId: adapter.applianceCode);
      if (widget.disabled) {
        return nameInModel;
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return nameInModel;
    }

    String _getName(BuildContext context) {
      List<SceneInfoEntity> sceneListCache = context.read<SceneListModel>().getCacheSceneList();
      String nameInModel = deviceListModel.getDeviceName(deviceId: widget.applianceCode, maxLength: 4, startLength: 1, endLength: 2);
      if (sceneListCache.isEmpty) {
        return nameInModel;
      }
      String sceneIdToCompare = adapter.data.sceneList[0];
      SceneInfoEntity curScene = sceneListCache.firstWhere((element) {
        return element.sceneId.toString() == sceneIdToCompare;
      }, orElse: () {
        SceneInfoEntity sceneObj = SceneInfoEntity();
        sceneObj.name = nameInModel;
        return sceneObj;
      });

      if (curScene != null) {
        return curScene.name;
      } else {
        return nameInModel;
      }
    }

    return GestureDetector(
        onTap: () {
          if (adapter.dataState != DataState.SUCCESS) {
            adapter.fetchData();
            // TipsUtils.toast(content: '数据缺失，控制设备失败');
            return;
          }
          if (!deviceListModel.getOnlineStatus(
              deviceId: widget.applianceCode) && !widget.disabled) {
            TipsUtils.toast(content: '设备已离线，请检查连接状态');
            return;
          }
        },
        child: AbsorbPointer(absorbing: (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) || adapter.dataState != DataState.SUCCESS), child: GestureDetector(
      onTap: () async {
        Log.i('disabled', widget.disabled);
        if (!widget.disabled && adapter.dataState == DataState.SUCCESS) {
          if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
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
            if (adapter.data.modeList[0] == '2') {
              sceneModel.sceneExec(adapter.data.sceneList[0]);
              setState(() {
                widget.sceneOnOff = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  widget.sceneOnOff = false;
                });
              });
            } else {
              await adapter.fetchOrderPower(1);
              bus.emit('operateDevice', adapter.nodeId.isEmpty ? widget.applianceCode : adapter.nodeId);
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
                      adapter.data.modeList[0] == '0'
                          ? getDeviceName()
                          : _getName(context),
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
                  if (deviceListModel.deviceListHomlux.isNotEmpty ||
                      deviceListModel.deviceListMeiju.isNotEmpty)
                  Text(
                    '${getRoomName()}${_getRightText().isEmpty ? '' : ' | '}${_getRightText()}',
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
    ),),);
  }
}
