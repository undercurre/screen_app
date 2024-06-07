import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/widgets/card/method.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/system.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../event_bus.dart';
import '../../mz_slider.dart';
import '../../util/nameFormatter.dart';

class LightControl extends StatefulWidget {
  final String groupId;
  final bool disableOnOff;
  final bool discriminative;
  final bool hasMore;
  final bool disabled;

  AdapterGenerateFunction<DeviceCardDataAdapter> adapterGenerateFunction;

  LightControl(
      {super.key,
      required this.adapterGenerateFunction,
      required this.groupId,
      this.hasMore = true,
      this.disabled = false,
      this.discriminative = false,
      this.disableOnOff = true});

  @override
  _LightControlState createState() => _LightControlState();
}

class _LightControlState extends State<LightControl> {
  late DeviceCardDataAdapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.groupId);
    adapter.init();
    if (!widget.disabled) {
      adapter.bindDataUpdateFunction(updateCallback);
    }
  }

  @override
  void dispose() {
    super.dispose();
    adapter.unBindDataUpdateFunction(updateCallback);
  }

  bool onlineState() {
    return true;
  }

  void updateCallback() {
    setState(() {
      Log.i('大卡片状态更新');
      setState(() {
        adapter.data = adapter.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);

    String _getRightText() {
      if (widget.discriminative) {
        return '';
      }
      if (deviceListModel.deviceListHomlux.isEmpty && deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      if (widget.disabled) {
        return '';
      }

      // if (widget.isFault) {
      //   return '故障';
      // }

      if (!onlineState()) {
        return '离线';
      }
      //
      // if (adapter.dataState == DataState.LOADING) {
      //   return '';
      // }
      //
      // if (adapter.dataState == DataState.NONE) {
      //   return '离线';
      // }

      if (adapter.dataState == DataState.ERROR) {
        return '离线';
      }

      return adapter.getCharacteristic() ?? '';
    }

    String getRoomName() {
      if (MideaRuntimePlatform.platform.inHomlux()) {
        return System.roomInfo?.name ?? '未登录';
      } else {
        return '非Homlux平台';
      }
    }

    String getDeviceName() {
      return '灯光管控中心';
    }

    BoxDecoration _getBoxDecoration() {
      bool curPower = adapter.getPowerStatus() ?? false;
      bool online = onlineState();
      if (widget.disabled) {
        return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: getBigCardColorBg('disabled'));
      }
      if (!online) {
        return BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'));
      }
      if (!curPower) {
        return BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'));
      } else {
        return BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: getBigCardColorBg('open'));
      }
    }

    return GestureDetector(
      onTap: () {
        if (adapter.dataState != DataState.SUCCESS) {
          adapter.fetchDataAndCheckWaitLockAuth(widget.groupId);
          // TipsUtils.toast(content: '数据缺失，控制设备失败');
          return;
        }
        if (!onlineState() && !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing: (!onlineState() || adapter.dataState != DataState.SUCCESS),
        child: Container(
          width: 440,
          height: 196,
          decoration: _getBoxDecoration(),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    Log.i('disabled: ${widget.disabled}');
                    if (!widget.disabled && onlineState()) {
                      adapter.power(
                        adapter.getPowerStatus(),
                      );
                      bus.emit('operateDevice', adapter.getCardStatus()!["nodeId"] ?? widget.groupId);
                    }
                  },
                  child: Image(
                      width: 40,
                      height: 40,
                      image: AssetImage(
                          adapter.getPowerStatus() ?? false ? 'assets/newUI/card_power_on.png' : 'assets/newUI/card_power_off.png')),
                ),
              ),
              // Positioned(
              //   top: 16,
              //   right: 16,
              //   child: GestureDetector(
              //     onTap: () {
              //       if (adapter.dataState != DataState.SUCCESS) {
              //         adapter.fetchData();
              //         // TipsUtils.toast(content: '数据缺失，控制设备失败');
              //         return;
              //       }
              //       if (!onlineState()) {
              //         TipsUtils.toast(content: '设备已离线，请检查连接状态');
              //         return;
              //       }
              //       if (!widget.disabled) {
              //         if (adapter.type == AdapterType.wifiLight) {
              //           Navigator.pushNamed(context, '0x13', arguments: {"name": getDeviceName(), "adapter": adapter});
              //         } else if (adapter.type == AdapterType.zigbeeLight) {
              //           Navigator.pushNamed(context, '0x21_light_colorful', arguments: {"name": getDeviceName(), "adapter": adapter});
              //         } else if (adapter.type == AdapterType.lightGroup) {
              //           Navigator.pushNamed(context, 'lightGroup', arguments: {"name": getDeviceName(), "adapter": adapter});
              //         }
              //       }
              //     },
              //     child: widget.hasMore ? const Image(width: 32, height: 32, image: AssetImage('assets/newUI/to_plugin.png')) : Container(),
              //   ),
              // ),
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
                        child: Text("${_getRightText().isNotEmpty ? ' | ' : ''}${_getRightText()}",
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
                  )),
              Positioned(
                top: 62,
                left: 25,
                child: Text("亮度 | ${widget.disabled ? '1' : adapter.getCardStatus()?['brightness'] ?? ''}%",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0XA3FFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
              Positioned(
                top: 80,
                left: 4,
                child: MzSlider(
                  value: widget.disabled ? 1 : adapter.getCardStatus()?['brightness'] ?? '',
                  width: 390,
                  height: 16,
                  min: 0,
                  max: 100,
                  disabled: !(adapter.getPowerStatus() ?? false) || widget.disabled || !onlineState(),
                  activeColors: const [Color(0xFFCE8F31), Color(0xFFFFFFFF)],
                  onChanging: (val, color) {
                    adapter.slider1ToFaker(val.toInt());
                  },
                  onChanged: (val, color) {
                    adapter.slider1To(val.toInt());
                    bus.emit('operateDevice', adapter.getCardStatus()?["nodeId"] ?? widget.groupId);
                  },
                ),
              ),
              Positioned(
                top: 124,
                left: 25,
                child: Text("色温 | ${_getColorK()}K",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0XA3FFFFFF),
                        fontSize: 16,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
              Positioned(
                top: 140,
                left: 4,
                child: MzSlider(
                  value: widget.disabled ? 0 : adapter.getCardStatus()?['colorTemp'] ?? '',
                  width: 390,
                  height: 16,
                  min: 0,
                  max: 100,
                  disabled: !(adapter.getPowerStatus() ?? false) || widget.disabled || !onlineState(),
                  activeColors: const [Color(0xFFFFCC71), Color(0xFF55A2FA)],
                  isBarColorKeepFull: false,
                  onChanging: (val, color) {
                    adapter.slider2ToFaker(val.toInt());
                  },
                  onChanged: (val, color) {
                    adapter.slider2To(val.toInt());
                    bus.emit('operateDevice', adapter.getCardStatus()?["nodeId"] ?? widget.groupId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getColorK() {
    if (adapter != null) {
      if (adapter.getCardStatus()?['maxColorTemp'] != null) {
        return ((adapter.getCardStatus()?['colorTemp'] as int) /
                    100 *
                    ((adapter.getCardStatus()?['maxColorTemp'] as int) - (adapter.getCardStatus()?['minColorTemp'] as int)) +
                (adapter.getCardStatus()?['minColorTemp'] as int))
            .toInt();
      }
    }

    return ((adapter.getCardStatus()?['colorTemp'] as int) / 100 * (6500 - 2700) + 2700).toInt();
  }
}
