import 'package:flutter/material.dart';

class ElectricWaterHeater extends StatefulWidget {
  final String? hour;
  final String? temperature;
  final String? minute;
  final String? workState;
  final bool? standby;

  const ElectricWaterHeater({super.key, this.hour, this.temperature, this.minute,this.workState,this.standby});

  @override
  State<ElectricWaterHeater> createState() => _ElectricWaterHeater();
}

class _ElectricWaterHeater extends State<ElectricWaterHeater> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const SizedBox(
        width: 150,
        height: 600,
      ),
      Positioned(
        top: 65,
        left: 10,
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.temperature??"35",
              style: const TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 56.0,
                fontFamily: "MideaType",
                fontWeight: FontWeight.w200,
                decoration: TextDecoration.none,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Text(
                "℃",
                style: TextStyle(
                  color: Color(0xff959595),
                  fontSize: 20.0,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.w200,
                  decoration: TextDecoration.none,
                ),
              ),
            )

          ],
        ),
      ),

      const Positioned(
          top: 150,
          left: 15,
          child: Text(
            "当前水温",
            style: TextStyle(
              color: Color(0x77ffffff),
              fontSize: 15.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w200,
              decoration: TextDecoration.none,
            ),
          )),
      const Positioned(
        left: 0,
        top: 145,
        child: SizedBox(
          width: 150,
          height: 244,
            child:Image(
              image: AssetImage('assets/imgs/plugins/0xE2/electric_heater.png'),
            ),
        )
      ),
       Positioned(
          top: 380,
          left: 15,
          child: Text(
            getDesText(),
            style: const TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 18.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w200,
              decoration: TextDecoration.none,
            ),
          )),
       Positioned(
          top: 410,
          left: 5,
          child: Text(
            getHotText(),
            style: const TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 18.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w200,
              decoration: TextDecoration.none,
            ),
          )),
    ]);
  }

  getDesText(){
    if(widget.standby==true){
      return "待机中";
    }else if(widget.workState=="hot"){
      return "加热中";
    }else{
      return "保温中";
    }
  }

  getHotText(){
    if(widget.workState=="hot"&&widget.standby==false){
      if(widget.hour=="0"&&widget.minute!="0"){
        return '还需${widget.minute}分钟';
      }else{
        return '还需 ${widget.hour}小时${widget.minute}分钟';
      }
    }else {
      return "";
    }

  }
}
