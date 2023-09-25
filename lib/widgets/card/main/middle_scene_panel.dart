import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/scene_panel_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
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

class MiddleScenePanelCardWidget extends StatefulWidget {
  final Widget icon;
  final String name;
  final String roomName;
  final String isOnline;
  final bool disableOnOff;
  final bool disabled;
  final bool discriminative;
  List<bool> sceneOnOff = [false, false];
  ScenePanelDataAdapter adapter; // 数据适配器

  MiddleScenePanelCardWidget({
    super.key,
    required this.icon,
    required this.adapter,
    required this.roomName,
    required this.isOnline,
    required this.name,
    this.disableOnOff = true,
    required this.disabled,
    this.discriminative = false,
  });

  @override
  _MiddleScenePanelCardWidgetState createState() =>
      _MiddleScenePanelCardWidgetState();
}

class _MiddleScenePanelCardWidgetState
    extends State<MiddleScenePanelCardWidget> {
  bool _isFetching = false;
  Timer? _debounceTimer;

  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
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
      widget.adapter.bindDataUpdateFunction(updateData);
      widget.adapter.init();
    }
  }

  void updateData() {
    if (mounted) {
      setState(() {
        widget.adapter.data.statusList = widget.adapter.data.statusList;
        widget.adapter.data.modeList = widget.adapter.data.modeList;
        widget.adapter.data.sceneList = widget.adapter.data.sceneList;
      });
      // Log.i('更新数据', widget.adapter.data.nameList);
    }
  }

  @override
  void didUpdateWidget(covariant MiddleScenePanelCardWidget oldWidget) {
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

    return Container(
      width: 210,
      height: 196,
      decoration: _getBoxDecoration(),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: widget.icon,
          ),
          Positioned(
            top: 0,
            left: 72,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(getDeviceName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 20,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
            ),
          ),
          Positioned(
            top: 32,
            left: 72,
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 50),
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
                  constraints: const BoxConstraints(maxWidth: 50),
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
            left: 16,
            child: GestureDetector(
              onTap: () async {
                Log.i('disabled', widget.disabled);
                if (!widget.disabled &&
                    widget.adapter.dataState == DataState.SUCCESS) {
                  if (widget.isOnline == '0') {
                    MzDialog(
                        title: '该设备已离线',
                        titleSize: 28,
                        maxWidth: 432,
                        backgroundColor: const Color(0xFF494E59),
                        contentPadding:
                            const EdgeInsets.fromLTRB(33, 24, 33, 0),
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
                        widget.sceneOnOff[0] = true;
                      });
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          widget.sceneOnOff[0] = false;
                        });
                      });
                    } else {
                      await widget.adapter.fetchOrderPower(1);
                    }
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(_getIconOnOff(0)
                          ? 'assets/newUI/panel_btn_on.png'
                          : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain),
                ),
                child: SizedBox(
                  width: 84,
                  child: Center(
                    child: Text(
                      widget.adapter.data.modeList[0] == '2'
                          ? _getSceneName(0, sceneListCache)
                          : widget.adapter.data.nameList[0],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 68,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                Log.i('disabled', widget.disabled);
                if (!widget.disabled) {
                  if (widget.isOnline == '0') {
                    MzDialog(
                        title: '该设备已离线',
                        titleSize: 28,
                        maxWidth: 432,
                        backgroundColor: const Color(0xFF494E59),
                        contentPadding:
                            const EdgeInsets.fromLTRB(33, 24, 33, 0),
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
                    if (widget.adapter.data.modeList[1] == '2') {
                      sceneModel.sceneExec(widget.adapter.data.sceneList[1]);
                      setState(() {
                        widget.sceneOnOff[1] = true;
                      });
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          widget.sceneOnOff[1] = false;
                        });
                      });
                    } else {
                      await widget.adapter.fetchOrderPower(2);
                    }
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: 84,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(_getIconOnOff(1)
                          ? 'assets/newUI/panel_btn_on.png'
                          : 'assets/newUI/panel_btn_off.png'),
                      fit: BoxFit.contain),
                ),
                child: SizedBox(
                  width: 84,
                  child: Center(
                    child: Text(
                      widget.adapter.data.modeList[1] == '2'
                          ? _getSceneName(1, sceneListCache)
                          : widget.adapter.data.nameList[1],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRightText() {
    if (widget.disabled) {
      return '';
    }
    if (widget.adapter.dataState == DataState.LOADING ||
        widget.adapter.dataState == DataState.NONE) {
      return '离线';
    }
    if (widget.isOnline == '0') {
      return '离线';
    }
    if (widget.adapter.dataState == DataState.ERROR) {
      return '离线';
    }
    if (widget.adapter.data!.statusList.isNotEmpty) {
      return '在线';
    } else {
      return '离线';
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

  String _getSceneName(int panelIndex, List<SceneInfoEntity> sceneListCache) {
    if (sceneListCache.isEmpty) return '加载中';

    if (panelIndex >= 0 && panelIndex < widget.adapter.data.sceneList.length) {
      String sceneIdToCompare = widget.adapter.data.sceneList[panelIndex];
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

  bool _getIconOnOff(int panelIndex) {
    // 禁用——关闭
    if (widget.disabled) return false;

    // 普通开关模式
    if (widget.adapter.data.modeList[panelIndex] != '2') {
      return widget.adapter.data.statusList[panelIndex];
    } else {
      // 场景模式
      return widget.sceneOnOff[panelIndex];
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
