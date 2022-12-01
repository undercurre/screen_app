import 'package:flutter/cupertino.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/routes/device/service.dart';

import '../../models/device_entity.dart';

class DeviceItem extends StatefulWidget {
  DeviceHomeListHomeListRoomListApplianceList? deviceInfo;

  DeviceItem({Key? key, this.deviceInfo}) : super(key: key);

  @override
  _DeviceItemState createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {
  DeviceEntity? deviceInfo;

  void toSelectDevice() {
    if (widget.deviceInfo != null) {
      if (!DeviceService.supportDeviceFilter(widget.deviceInfo)) {
        Navigator.pushNamed(context, widget.deviceInfo!.type!, arguments: {
          "deviceId": widget.deviceInfo!.applianceCode,
          "deviceName": widget.deviceInfo!.name
        });
      }
    }
  }

  void clickMethod(e) {
    var config = DeviceService.configFinder(widget.deviceInfo);
    if (e.localPosition.dx > 40 &&
        e.localPosition.dx < 90 &&
        e.localPosition.dy > 140 &&
        e.localPosition.dy < 175) {
      DeviceService.setPower(
          config.apiCode, widget.deviceInfo?.applianceCode!, true);
    } else {
      toSelectDevice();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var config = DeviceService.configFinder(widget.deviceInfo);

    return Listener(
      onPointerDown: (e) => clickMethod(e),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF979797), width: 0.8),
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF393E43), Color(0xFF333135)]),
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
              config.onIcon,
              width: 50,
              height: 50,
            ),
            SizedBox(
              height: 24,
              child: Text(
                DeviceService.hasStatus(widget.deviceInfo)
                    ? "${DeviceService.getAttr()}${config.attrUnit!}"
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
                child: DeviceService.supportDeviceFilter(widget.deviceInfo)
                    ? const Text(
                        "仅支持APP控制",
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0X80FFFFFF),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'MideaType-Regular'),
                      )
                    : GestureDetector(
                        child: Image.asset(
                          DeviceService.isPower()
                              ? "assets/imgs/device/device_power_on.png"
                              : "assets/imgs/device/device_power_off.png",
                          width: 150,
                          height: 60,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
