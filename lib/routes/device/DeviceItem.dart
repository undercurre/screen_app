import 'package:flutter/cupertino.dart';

import '../../models/device.dart';

class DeviceItem extends StatefulWidget {
  Device? deviceInfo;

  DeviceItem({Key? key, this.deviceInfo}) : super(key: key);

  @override
  _DeviceItemState createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {

  void toSelectDevice() {
    Navigator.pushNamed(context, '0x13',
        arguments: {"deviceId": "178120883713033", "deviceName": "测试用灯"});
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
                      widget.deviceInfo != null ? widget.deviceInfo!.name : '加载中',
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Color(0XFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Image.asset(
            //   "assets/imgs/device/dengguang_icon_on.png",
            //   width: 50,
            //   height: 50,
            // ),
            const Text(
              "26",
              style: TextStyle(
                fontSize: 23.0,
                color: Color(0XFF8e8e8e),
              ),
            ),
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
