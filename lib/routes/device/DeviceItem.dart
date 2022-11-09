import 'package:flutter/cupertino.dart';

class DeviceItem extends StatelessWidget {
  const DeviceItem({Key? key, required this.deviceName}) : super(key: key);
  final String deviceName;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF1a1a1a),
      ),
      child: Text(
        deviceName,
        style: const TextStyle(
          fontSize: 19.0,
          color: Color(0XFF8e8e8e),
        ),
      ),
    );
  }
}