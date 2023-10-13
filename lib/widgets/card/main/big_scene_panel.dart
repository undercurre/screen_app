import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/scene_panel_data_adapter.dart';
import 'package:screen_app/widgets/mz_buttion.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/adapter/panel_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../models/scene_info_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../../states/scene_list_notifier.dart';
import '../../event_bus.dart';
import '../../mz_dialog.dart';
import '../../util/nameFormatter.dart';

class BigScenePanelCardWidget extends StatefulWidget {
  final String applianceCode;
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  final bool disabled;
  final bool disableOnOff;
  final bool discriminative;
  List<bool> sceneOnOff = [false, false, false, false];
  AdapterGenerateFunction<ScenePanelDataAdapter> adapterGenerateFunction;

  BigScenePanelCardWidget({
    super.key,
    required this.icon,
    required this.adapterGenerateFunction,
    required this.roomName,
    required this.isOnline,
    required this.name,
    this.disableOnOff = true,
    required this.disabled,
    this.discriminative = false,
    required this.applianceCode,
  });

  @override
  _BigScenePanelCardWidgetState createState() =>
      _BigScenePanelCardWidgetState();
}

class _BigScenePanelCardWidgetState extends State<BigScenePanelCardWidget> {

  late ScenePanelDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if (!widget.disabled) {
      adapter.bindDataUpdateFunction(updateData);
    }
  }

  void updateData() {
    if (mounted) {
      setState(() {
        adapter.data.statusList = adapter.data.statusList;
        adapter.data.modeList = adapter.data.modeList;
        adapter.data.sceneList = adapter.data.sceneList;
      });
      // Log.i('更新数据', adapter.data.nameList);
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
      if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
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

    List<SceneInfoEntity> sceneListCache = sceneModel.getCacheSceneList();

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: adapter.applianceCode,
          maxLength: 6,
          startLength: 3,
          endLength: 2);
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
      String BigCardName = '';

      List<DeviceEntity> curOne = deviceListModel.deviceCacheList
          .where((element) => element.applianceCode == widget.applianceCode)
          .toList();
      if (curOne.isNotEmpty) {
        BigCardName = NameFormatter.formatName(curOne[0].roomName!, 6);
      } else {
        BigCardName = '未知区域';
      }
      if (widget.disabled) {
        return BigCardName;
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return BigCardName;
    }

    return GestureDetector(
      onTap: () {
        if (adapter.dataState != DataState.SUCCESS) {
          adapter.fetchData();
          // TipsUtils.toast(content: '数据缺失，控制设备失败');
          return;
        }
        if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) &&
            !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing:
        (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) || adapter.dataState != DataState.SUCCESS),
        child: Container(
          width: 440,
          height: 196,
          decoration: _getBoxDecoration(),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 24,
                child: Image(
                    width: 40, height: 40, image: AssetImage(_getIconSrc())),
              ),
              Positioned(
                top: 10,
                left: 88,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(getDeviceName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: 22,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 90),
                      child: Text(getRoomName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0XA3FFFFFF),
                              fontSize: 16,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 90),
                      child: Text(" | ${_getRightText()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0XA3FFFFFF),
                              fontSize: 16,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 68,
                left: 32,
                child: SizedBox(
                  height: 120,
                  width: 376,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (adapter.data.nameList.isNotEmpty)
                        _panelItem(0, sceneModel, sceneListCache),
                      if (adapter.data.nameList.length >= 2)
                        _panelItem(1, sceneModel, sceneListCache),
                      if (adapter.data.nameList.length >= 3)
                        _panelItem(2, sceneModel, sceneListCache),
                      if (adapter.data.nameList.length >= 4)
                        _panelItem(3, sceneModel, sceneListCache),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelItem(int index, SceneListModel sceneModel,
      List<SceneInfoEntity> sceneListCache) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
    return SizedBox(
      width: 84,
      height: 120,
      child: GestureDetector(
        onTap: () async {
          Log.i('disabled', widget.disabled);
          if (!widget.disabled &&
              adapter.dataState == DataState.SUCCESS) {
            if (!deviceListModel.getOnlineStatus(
                deviceId: widget.applianceCode)) {
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
              if (adapter.data.modeList[index] == '2') {
                sceneModel.sceneExec(adapter.data.sceneList[index]);
                setState(() {
                  widget.sceneOnOff[index] = true;
                });
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    widget.sceneOnOff[index] = false;
                  });
                });
              } else {
                await adapter.fetchOrderPower(index + 1);
                bus.emit('operateDevice', adapter.nodeId.isEmpty ? widget.applianceCode : adapter.nodeId);

              }
            }
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              height: 120,
              width: 84,
              image: _isPanelItemOn(index)
                  ? const AssetImage("assets/newUI/panel_btn_on.png")
                  : const AssetImage("assets/newUI/panel_btn_off.png"),
            ),
            Text(
              adapter.data.modeList[index] == '2'
                  ? _getSceneName(index, sceneListCache)
                  : adapter.data.nameList[index],
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Color(0XFFFFFFFF),
                  fontSize: 16,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            )
          ],
        ),
      ),
    );
  }

  String _getIconSrc() {
    if (adapter.data.nameList.length == 1) {
      return "assets/newUI/device/0x21_1339.png";
    }
    if (adapter.data.nameList.length == 2) {
      return "assets/newUI/device/0x21_1340.png";
    }
    if (adapter.data.nameList.length == 3) {
      return "assets/newUI/device/0x21_1341.png";
    }
    return "assets/newUI/device/0x21_1342.png";
  }

  bool _isPanelItemOn(int index) {
    if (!widget.disabled) {
      if (index < 0 || index > adapter.data.statusList.length - 1) {
        return false;
      } else {
        if (adapter.data.modeList[index] == '2') {
          return widget.sceneOnOff[index];
        } else {
          return adapter.data.statusList[index];
        }
      }
    } else {
      return false;
    }
  }

  String _getRightText() {
    if (widget.disabled) {
      return '';
    }
    if (adapter.dataState == DataState.LOADING ||
        adapter.dataState == DataState.NONE) {
      return '在线';
    }
    if (widget.isOnline == '0') {
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

  String _getSceneName(int panelIndex, List<SceneInfoEntity> sceneListCache) {
    if (sceneListCache.isEmpty) return '加载中';

    if (panelIndex >= 0 && panelIndex < adapter.data.sceneList.length) {
      String sceneIdToCompare = adapter.data.sceneList[panelIndex];
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
    } else {
      return '加载中';
    }
  }

  BoxDecoration _getBoxDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          widget.discriminative
              ? Colors.white.withOpacity(0.12)
              : const Color(0x33616A76),
          widget.discriminative
              ? Colors.white.withOpacity(0.12)
              : const Color(0x33434852),
        ],
      ),
    );
  }
  
}
