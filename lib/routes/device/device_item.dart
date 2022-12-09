import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/routes/device/service.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/index.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../models/device_entity.dart';

class DeviceItem extends StatefulWidget {
  final DeviceEntity? deviceInfo;

  const DeviceItem({Key? key, this.deviceInfo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {
  void toSelectDevice() {
    if (widget.deviceInfo != null && widget.deviceInfo!.detail != null) {
      if (widget.deviceInfo!.detail!.keys.toList().isNotEmpty &&
          DeviceService.isSupport(widget.deviceInfo!)) {
        Navigator.pushNamed(context, widget.deviceInfo!.type,
            arguments: {"deviceId": widget.deviceInfo!.applianceCode});
      }
    }
  }

  void clickMethod(e) {
    if (widget.deviceInfo != null) {
      if (e.localPosition.dx > 40 &&
          e.localPosition.dx < 90 &&
          e.localPosition.dy > 140 &&
          e.localPosition.dy < 175) {
        DeviceService.setPower(
            widget.deviceInfo!, !DeviceService.isPower(widget.deviceInfo!));
      } else {
        toSelectDevice();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceListWatch = context.watch<DeviceListModel>();

    return Listener(
      onPointerDown: (e) => clickMethod(e),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF979797), width: 0.8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: (widget.deviceInfo != null
                    ? DeviceService.isOnline(widget.deviceInfo!)
                    : false)
                ? [const Color(0xFF393E43), const Color(0xFF333135)]
                : [const Color(0xFF000000), const Color(0xFF000000)],
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
                        ? widget.deviceInfo!.name!
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
              widget.deviceInfo != null
                  ? (DeviceService.isPower(widget.deviceInfo!)
                      ? DeviceService.getOnIcon(widget.deviceInfo!)
                      : DeviceService.getOffIcon(widget.deviceInfo!))
                  : 'assets/imgs/device/phone_off.png',
              width: 50,
              height: 50,
            ),
            SizedBox(
              height: 24,
              child: Text(
                widget.deviceInfo != null
                    ? (DeviceService.getAttr(widget.deviceInfo!) != ''
                        ? "${widget.deviceInfo != null ? (DeviceService.getAttr(widget.deviceInfo!)) : '0'}${widget.deviceInfo != null ? (DeviceService.getAttrUnit(widget.deviceInfo!)) : ''}"
                        : "")
                    : "",
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Color(0XFF8e8e8e),
                ),
              ),
            ),
            SizedBox(
              height: 30,
              child: Center(
                child: (widget.deviceInfo != null
                        ? (!DeviceService.isOnline(widget.deviceInfo!))
                        : false)
                    ? Image.asset(
                        "assets/imgs/device/offline.png",
                        width: 150,
                        height: 60,
                      )
                    : (widget.deviceInfo != null
                            ? (!DeviceService.isSupport(widget.deviceInfo!))
                            : false)
                        ? const Text(
                            "仅支持APP控制",
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0X80FFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'MideaType-Regular'),
                          )
                        : Image.asset(
                            (widget.deviceInfo != null
                                    ? (!DeviceService.isPower(
                                        widget.deviceInfo!))
                                    : false)
                                ? "assets/imgs/device/device_power_on.png"
                                : "assets/imgs/device/device_power_off.png",
                            width: 150,
                            height: 60,
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
