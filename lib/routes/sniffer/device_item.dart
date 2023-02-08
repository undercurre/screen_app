import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

import '../../channel/models/manager_devic.dart';

class SelectDeviceModel {
  bool selected = false;
  IFindDeviceResult data;
  SelectDeviceModel.create(this.data);

  @override
  operator ==(Object other) {
    if(runtimeType != other.runtimeType) return false;
    return other is SelectDeviceModel && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

}

class DeviceItem extends StatelessWidget {
  final SelectDeviceModel device;
  final double boxSize;
  final double circleSize;
  final double fontSize;
  final void Function(SelectDeviceModel device)? onTap;

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
                  child: Image.network(
                      device.data.icon,
                      height: 50,
                      width: 50
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
              device.data.name,
              textAlign: TextAlign.justify,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'MideaType',
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
