import 'package:flutter/cupertino.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/device/service.dart';

import '../../models/device_entity.dart';

class DeviceCard extends StatefulWidget {
  final DeviceEntity? deviceInfo;

  const DeviceCard({super.key, this.deviceInfo});

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  void toSelectDevice() {
    debugPrint('选择了设备卡片${widget.deviceInfo}');
    if (widget.deviceInfo != null && widget.deviceInfo?.detail != null) {
      if (widget.deviceInfo!.detail!.keys.toList().isNotEmpty &&
          DeviceService.isSupport(widget.deviceInfo!)) {
        var type = getControllerRoute(widget.deviceInfo!);
        Navigator.pushNamed(context, type,
            arguments: {"deviceId": widget.deviceInfo!.applianceCode});
      }
    }
  }

  void clickMethod(TapDownDetails e) {
    if (widget.deviceInfo != null) {
      if (e.localPosition.dx > 40 &&
          e.localPosition.dx < 90 &&
          e.localPosition.dy > 140 &&
          e.localPosition.dy < 175) {
        if (DeviceService.isPower(widget.deviceInfo!)) {
          DeviceService.setPower(
              widget.deviceInfo!, !DeviceService.isPower(widget.deviceInfo!));
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
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      height: 190,
      child: GestureDetector(
        onTapDown: (e) => clickMethod(e),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 17, 0, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF979797), width: 0.8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getContainerBgc(),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 136,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widget.deviceInfo != null
                          ? widget.deviceInfo!.name
                          : '加载中',
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Color(0XFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                _getDeviceIconPath(),
                width: 50,
                height: 50,
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
        ? (DeviceService.isPower(widget.deviceInfo!)
            ? DeviceService.getOnIcon(widget.deviceInfo!)
            : DeviceService.getOffIcon(widget.deviceInfo!))
        : 'assets/imgs/device/phone_off.png';
  }

  /// 卡片背景色
  List<Color> _getContainerBgc() {
    return widget.deviceInfo != null &&
            DeviceService.isPower(widget.deviceInfo!)
        ? [const Color(0xFF393E43), const Color(0xFF333135)]
        : [const Color(0xFF000000), const Color(0xFF000000)];
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
      if (!DeviceService.isOnline(widget.deviceInfo!)) {
        return Image.asset(
          "assets/imgs/device/offline.png",
          width: 150,
          height: 60,
        );
      } else {
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
          return Image.asset(
            DeviceService.isPower(widget.deviceInfo!)
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
