import 'package:flutter/cupertino.dart';

class DeviceItem extends StatelessWidget {
  const DeviceItem({Key? key, required this.deviceName}) : super(key: key);
  final String deviceName;
  final String icon = "";
  final String value = "23";

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF979797), width: 0.8),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF393E43), Color(0xFF333135)]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            maxLines: 1,
            deviceName,
            style: const TextStyle(
              fontSize: 22.0,
              color: Color(0XFFFFFFFF),
            ),
          ),
          Image.asset(
            "assets/imgs/device/dengguang_icon_on.png",
            width: 50,
            height: 50,
          ),
          Text(
            "26",
            style: const TextStyle(
              fontSize: 23.0,
              color: Color(0XFF8e8e8e),
            ),
          ),
          GestureDetector(
            onTap: () => {},
            child: Image.asset(
              "assets/imgs/device/device_power.png",
              width: 150,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}
