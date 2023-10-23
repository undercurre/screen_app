
import 'package:flutter/material.dart';

class MzWiFiImage extends StatelessWidget {

  int level;// 0 - 3 范围
  Size? size;

  MzWiFiImage({super.key, required this.level, this.size});

  @override
  Widget build(BuildContext context) => Image.asset(parse(level), width: size?.width, height: size?.height,);

  String parse(int level) {
    if(level ==3) {
      return 'assets/imgs/icon/wifi-4.png';
    } else if(level ==2){
      return 'assets/imgs/icon/wifi-2.png';
    }else if(level ==1){
      return 'assets/imgs/icon/wifi-1.png';
    }else{
      return 'assets/imgs/icon/wifi-1.png';
    }
  }
}