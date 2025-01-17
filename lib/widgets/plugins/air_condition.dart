import 'package:flutter/material.dart';

class AirCondition extends StatefulWidget {
  final String? mode;
  String? temperature;
  final num? windSpeed;

  AirCondition({super.key, this.mode, this.temperature, this.windSpeed});

  @override
  State<AirCondition> createState() => _AirCondition();
}

class _AirCondition extends State<AirCondition> {

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
              widget.temperature??"26",
              style: const TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 66.0,
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
          top: 175,
          left: 15,
          child: Text(
            "室内温度",
            style: TextStyle(
              color: Color(0x77ffffff),
              fontSize: 18.0,
              fontFamily: "MideaType",
              fontWeight: FontWeight.w200,
              decoration: TextDecoration.none,
            ),
          )),
      const Positioned(
        left: 0,
        top: 135,
        child: Image(
          image: AssetImage('assets/newUI/acmodel/AC.png'),
        ),
      ),
    ]);
  }
}
