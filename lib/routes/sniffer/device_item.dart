import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class Device extends Mode {
  String icon;
  bool selected = false;

  Device({key, name, required this.icon, required this.selected})
      : super(key, name, icon, icon);
}

class DeviceItem extends StatelessWidget {
  final Device device;
  final double boxSize;
  final double circleSize;
  final double fontSize;
  final void Function(Device device)? onTap;

  const DeviceItem(
      {Key? key,
      required this.device,
      this.onTap,
      this.fontSize = 14.0,
      this.boxSize = 96,
      this.circleSize = 60})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(device),
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: device.selected
                          ? Colors.white
                          : const Color.fromRGBO(255, 255, 255, 0.6),
                      shape: BoxShape.circle,
                      border: device.selected
                          ? Border.all(
                              strokeAlign: StrokeAlign.outside,
                              color: const Color.fromRGBO(0, 145, 255, 1),
                              width: 3,
                              style: BorderStyle.solid)
                          : null,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 4,
                          spreadRadius: 2,
                        )
                      ]),
                  child: Image(
                    height: 50,
                    width: 50,
                    image: AssetImage(device.onIcon),
                  ),
                ),
                if (device.selected)
                  const Positioned(
                    right: 0,
                    bottom: 8,
                    child: Image(
                      height: 22,
                      width: 22,
                      image: AssetImage('assets/imgs/scene/choose.png'),
                    ),
                  )
              ],
            ),
            Text(
              device.name,
              style: TextStyle(
                fontFamily: 'MideaType',
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                decoration: TextDecoration.none,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
