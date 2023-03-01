import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../widgets/event_bus.dart';

class DeviceCard extends StatefulWidget {
  late DeviceEntity? deviceInfo;

  DeviceCard({super.key, this.deviceInfo});

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool power = false;
  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;

  void toSelectDevice() {
    debugPrint('选择了设备卡片${widget.deviceInfo}');
    if (widget.deviceInfo != null &&
        widget.deviceInfo?.detail != null &&
        !isVistual(widget.deviceInfo!)) {
      if (widget.deviceInfo!.detail!.keys.toList().isNotEmpty &&
          DeviceService.isSupport(widget.deviceInfo!)) {
        var type = getControllerRoute(widget.deviceInfo!);
        Navigator.pushNamed(context, type,
            arguments: {"deviceId": widget.deviceInfo!.applianceCode});
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
      setDate();
    });
    Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
      String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
      Map<String,dynamic> eventMap = json.decode(event);
      String nodeId = eventMap['nodeId'] ?? "";

      if (nodeId.isEmpty) {
        if (widget.deviceInfo?.applianceCode == arg['applianceCode']) {
          setDate();
        }
      } else {
        if (widget.deviceInfo?.type == '0x21' && widget.deviceInfo?.detail?['nodeId'] == nodeId) {
          setDate();
        }
      }
    }));

    Push.listen("appliance/status/report", _reportCallback = ((arg) {
        if (arg.containsKey('applianceId')) {
          if (widget.deviceInfo?.applianceCode == arg['applianceId']) {
            setDate();
          }
        }
    }));
  }


  @override
  void dispose() {
    super.dispose();
    Push.dislisten("gemini/appliance/event", _eventCallback);
    Push.dislisten("appliance/status/report",_reportCallback);
  }

  setDate() async {
    if (widget.deviceInfo != null && mounted) {
      await context
          .read<DeviceListModel>()
          .updateDeviceDetail(widget.deviceInfo!);
      setState(() {
        power = DeviceService.isPower(widget.deviceInfo!);
      });
    }
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
                width: 112,
                child: Center(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widget.deviceInfo != null ? widget.deviceInfo!.name : '加载中',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Color(0XFFFFFFFF),
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
      if (zigbeeControllerList[widget.deviceInfo!.modelNumber] ==
              '0x21_curtain_panel_two' ||
          (widget.deviceInfo!.type == '0x17' &&
              widget.deviceInfo!.sn8 != '127PD03G')) {
        return Container();
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
          return Image.asset(
            power
                ? "assets/imgs/device/device_power_on.png"
                : "assets/imgs/device/device_power_off.png",
            width: 150,
            height: 60,
          );
        }
      }
    }
  }
}
