import 'package:flutter/cupertino.dart';
import 'package:screen_app/routes/device/config.dart';

import '../../models/device_entity.dart';

class DeviceItem extends StatefulWidget {
  DeviceEntity? deviceInfo;

  DeviceItem({Key? key, this.deviceInfo}) : super(key: key);

  @override
  _DeviceItemState createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {
  DeviceEntity? deviceInfo;

  void toSelectDevice() {
    if (widget.deviceInfo != null) {
      Navigator.pushNamed(context, widget.deviceInfo!.type, arguments: {
        "deviceId": widget.deviceInfo!.applianceCode,
        "deviceName": widget.deviceInfo!.name
      });
    }
  }

  void controlPower() {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => toSelectDevice(),
      child: Container(
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
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
            ),
            Image.asset(
              deviceConfig
                  .where((element) =>
                      element.type == (widget.deviceInfo?.type ?? '0x09'))
                  .toList()[0]
                  .onIcon,
              width: 50,
              height: 50,
            ),
            // const Text(
            //   "26",
            //   style: TextStyle(
            //     fontSize: 23.0,
            //     color: Color(0XFF8e8e8e),
            //   ),
            // ),
            // const Text(
            //   "仅APP控制",
            //   style: TextStyle(
            //     fontSize: 23.0,
            //     color: Color(0XFF8e8e8e),
            //   ),
            // ),
            GestureDetector(
              onTap: () => controlPower,
              child: Image.asset(
                "assets/imgs/device/device_power.png",
                width: 150,
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
