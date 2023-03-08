import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../widgets/event_bus.dart';
import '../../plugins/smartControl/api.dart';

class DeviceCard extends StatefulWidget {
  late DeviceEntity? deviceInfo;

  DeviceCard({super.key, this.deviceInfo});

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool power = false;
  Function(Map<String, dynamic> arg)? _eventCallback;
  Function(Map<String, dynamic> arg)? _reportCallback;
  Function(Map<String, dynamic> arg)? _onlineCallback;
  Function(Map<String, dynamic> arg)? _offlineCallback;

  void toSelectDevice() {
    debugPrint('选择了设备卡片${widget.deviceInfo}');
    if (widget.deviceInfo != null &&
        widget.deviceInfo?.detail != null &&
        !isVistual(widget.deviceInfo!)) {
      if (widget.deviceInfo!.detail!.keys.toList().isNotEmpty &&
          DeviceService.isSupport(widget.deviceInfo!)) {
        var type = getControllerRoute(widget.deviceInfo!);
        Navigator.pushNamed(context, type, arguments: {
          "deviceId": widget.deviceInfo!.applianceCode,
          "power": power
        });
      }
    }
  }

  bool isVistual(DeviceEntity deviceInfo) {
    if (deviceInfo.type == 'smartControl') {
      return true;
    }

    return false;
  }

  Future<void> clickMethod(TapUpDetails e) async {
    if (!DeviceService.isSupport(widget.deviceInfo!)) {
      return;
    }
    if (!DeviceService.isOnline(widget.deviceInfo!)) {
      TipsUtils.toast(content: '设备离线');
      return;
    }
    if (widget.deviceInfo != null) {
      if (e.localPosition.dx > 40 &&
          e.localPosition.dx < 90 &&
          e.localPosition.dy > 140 &&
          e.localPosition.dy < 175) {
        if (!DeviceService.isSupport(widget.deviceInfo!)) return;
        setState(() {
          power = !power;
        });
        var res = await DeviceService.setPower(widget.deviceInfo!, power);
        if (res) {
          Future.delayed(const Duration(seconds: 3)).then((_) async {
            await context
                .read<DeviceListModel>()
                .updateDeviceDetail(widget.deviceInfo!);
          });
        } else {
          setState(() {
            power = !power;
          });
          TipsUtils.toast(content: '执行失败');
        }
      } else {
        // 过滤网关
        if (widget.deviceInfo!.type != '0x16') {
          toSelectDevice();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setDate();
    bus.on('updateDeviceCardState', (arg) async {
      logger.i('卡片重新加载');
      setDate();
    });
    bus.on("relay1StateChange", relaySmartStateChange);
    bus.on("relay2StateChange", relaySmartStateChange);
    Push.listen(
        "gemini/appliance/event",
        _eventCallback = ((arg) async {
          String event =
              (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
          Map<String, dynamic> eventMap = json.decode(event);
          String nodeId = eventMap['nodeId'] ?? "";

          if (nodeId.isEmpty) {
            if (widget.deviceInfo?.applianceCode == arg['applianceCode']) {
              setDate();
            }
          } else {
            if ((widget.deviceInfo?.type == '0x21' ||
                    (widget.deviceInfo?.type ?? "").contains("singlePanel")) &&
                widget.deviceInfo?.detail?['nodeId'] == nodeId) {
              setDate();
            }
          }
        }));

    Push.listen(
        "appliance/status/report",
        _reportCallback = ((arg) {
          if (arg.containsKey('applianceId')) {
            if (widget.deviceInfo?.applianceCode == arg['applianceId']) {
              setDate();
            }
          }
        }));

    Push.listen(
        'appliance/online/status/on',
        _onlineCallback = ((arg) {
          if (widget.deviceInfo?.applianceCode == arg['applianceId']) {
            setState(() {
              widget.deviceInfo?.onlineStatus = "1";
            });
          }
        }));

    Push.listen(
        'appliance/online/status/off',
        _offlineCallback = ((arg) {
          if (widget.deviceInfo?.applianceCode == arg['applianceId']) {
            setState(() {
              widget.deviceInfo?.onlineStatus = "0";
            });
          }
        }));
  }

  void relaySmartStateChange(dynamic status) {
    logger.i('智慧屏推送回调');
    if (widget.deviceInfo!.applianceCode == Global.profile.deviceId) {
      if (widget.deviceInfo!.type == 'smartControl-1') {
        setState(() {
          WrapSmartControl.localRelay1 = status;
          power = status as bool;
        });
      } else {
        setState(() {
          WrapSmartControl.localRelay2 = status;
          power = status as bool;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    Push.dislisten("gemini/appliance/event", _eventCallback);
    Push.dislisten("appliance/status/report", _reportCallback);
    Push.dislisten("appliance/online/status/on", _onlineCallback);
    Push.dislisten("appliance/online/status/off", _offlineCallback);
  }

  setDate() async {
        await context
            .read<DeviceListModel>()
            .updateDeviceDetail(widget.deviceInfo!);
        setState(() {
          power = DeviceService.isPower(widget.deviceInfo!);
        });
  }

  // @override
  // void didUpdateWidget(covariant DeviceCard oldWidget) {
  //   // TODO: implement didUpdateWidget
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.deviceInfo?.detail != null &&
  //       widget.deviceInfo!.detail!.isNotEmpty) {
  //     Timer(const Duration(seconds: 5), ()
  //     {
  //       setState(() {
  //         power = DeviceService.isPower(widget.deviceInfo!) ? true : false;
  //       });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      height: 190,
      child: GestureDetector(
        onTapUp: (e) => clickMethod(e),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 17, 0, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF979797), width: 0.4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getContainerBgc(),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                child: Center(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widget.deviceInfo != null
                        ? widget.deviceInfo!.name.replaceAll('', '\u200B')
                        : '加载中',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'MideaType',
                      color: Color(0XFFFFFFFF),
                    ),
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      leading: 1.0,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 6),
                child: Image.asset(
                  _getDeviceIconPath(),
                  width: 50,
                  height: 50,
                ),
              ),
              SizedBox(
                height: 24,
                child: Text(
                  _getAttrString(),
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Color(0XFF8e8e8e),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
                child: Center(
                  child: _buildBottomWidget(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 设备图片
  String _getDeviceIconPath() {
    return widget.deviceInfo != null
        ? (power
            ? DeviceService.getOnIcon(widget.deviceInfo!)
            : DeviceService.getOffIcon(widget.deviceInfo!))
        : 'assets/imgs/device/phone_off.png';
  }

  /// 卡片背景色
  List<Color> _getContainerBgc() {
    return widget.deviceInfo != null &&
            power &&
            DeviceService.isOnline(widget.deviceInfo!)
        ? [const Color(0xFF3B3E41), const Color(0xFF3B3E41)]
        : [const Color(0x5A393E43), const Color(0x5A393E43)];
  }

  /// attr文字
  String _getAttrString() {
    return widget.deviceInfo != null &&
            DeviceService.isSupport(widget.deviceInfo!) &&
            DeviceService.isOnline(widget.deviceInfo!)
        ? (DeviceService.getAttr(widget.deviceInfo!) != ''
            ? "${widget.deviceInfo != null ? (DeviceService.getAttr(widget.deviceInfo!)) : '0'}${widget.deviceInfo != null ? (DeviceService.getAttrUnit(widget.deviceInfo!)) : ''}"
            : "")
        : "";
  }

  Widget _buildBottomWidget() {
    if (widget.deviceInfo == null) {
      return Image.asset(
        "assets/imgs/device/offline.png",
        width: 150,
        height: 60,
      );
    } else {
      if ((widget.deviceInfo!.type == '0x17' &&
          widget.deviceInfo!.sn8 != '127PD03G')) {
        if (DeviceService.isOnline(widget.deviceInfo!)) {
          return Container();
        } else {
          Image.asset(
            "assets/imgs/device/offline.png",
            width: 150,
            height: 60,
          );
        }
      }
      if (!DeviceService.isSupport(widget.deviceInfo!) ||
          DeviceService.isVistual(widget.deviceInfo!)) {
        return const Text(
          "仅支持APP控制",
          style: TextStyle(
              fontSize: 14.0,
              color: Color(0X80FFFFFF),
              fontWeight: FontWeight.w400,
              fontFamily: 'MideaType-Regular'),
        );
      } else {
        if (!DeviceService.isOnline(widget.deviceInfo!)) {
          return Image.asset(
            "assets/imgs/device/offline.png",
            width: 150,
            height: 60,
          );
        } else {
          if (widget.deviceInfo?.detail != null &&
              widget.deviceInfo!.detail!.isNotEmpty) {
            return Image.asset(
              power
                  ? "assets/imgs/device/device_power_on.png"
                  : "assets/imgs/device/device_power_off.png",
              width: 150,
              height: 60,
            );
          } else {
            return const Text(
              "加载中",
              style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0X80FFFFFF),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'MideaType-Regular'),
            );
          }
        }
      }
    }
  }
}
