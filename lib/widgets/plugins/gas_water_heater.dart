import 'package:flutter/material.dart';

class GasWaterHeater extends StatefulWidget {

  const GasWaterHeater({super.key});

  @override
  State<GasWaterHeater> createState() => _GasWaterHeater();
}

class _GasWaterHeater extends State<GasWaterHeater> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [
      SizedBox(
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
              "",
              style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 56.0,
                fontFamily: "MideaType",
                fontWeight: FontWeight.w200,
                decoration: TextDecoration.none,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Text(
                "",
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

      Positioned(
          top: 150,
          left: 15,
          child: Text(
            "",
            style: TextStyle(
              color: Color(0x77ffffff),
              fontSize: 15.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w200,
              decoration: TextDecoration.none,
            ),
          )),
      Positioned(
        left: 0,
        top: 145,
        child: SizedBox(
          width: 200,
          height: 244,
            child:Image(
              image: AssetImage('assets/imgs/plugins/0xE3/gas_heater.png'),
            ),
        )
      ),
       Positioned(
          top: 380,
          left: 15,
          child: Text(
            "",
            style: TextStyle(
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
            "",
            style: TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 18.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w200,
              decoration: TextDecoration.none,
            ),
          )),
    ]);
  }

}
