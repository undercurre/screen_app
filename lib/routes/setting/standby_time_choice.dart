import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';

import '../../widgets/mz_radio.dart';

class StandbyTimeChoicePage extends StatefulWidget {
  const StandbyTimeChoicePage({Key? key});

  @override
  _StandbyTimeChoicePage createState() => _StandbyTimeChoicePage();
}

class _StandbyTimeChoicePage extends State<StandbyTimeChoicePage> {
  late double po;
  late int groupValue;
  List optionsList = ['30秒后', '1分钟后', '3分钟后', '5分钟后', '永不'];

  @override
  void initState() {
    super.initState();

    groupValue = Provider.of<StandbyChangeNotifier>(context, listen: false).standbyTimeOpt.key;
    debugPrint('key: $groupValue');

    //初始化状态
    print("initState");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 480,
          height: 480,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF272F41),
                Color(0xFF080C14),
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 480,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 64,
                      icon: Image.asset(
                        "assets/newUI/back.png",
                      ),
                    ),
                    const Text("待机设置",
                        style: TextStyle(
                            color: Color(0XD8FFFFFF),
                            fontSize: 28,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)
                    ),
                    const SizedBox(
                      height: 64,
                      width: 64,
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 480,
                height: 10,
              ),

              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                        itemCount: optionsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: 432,
                            height: 72,
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.05),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(index == 0 ? 24 : 0),
                                  topRight: Radius.circular(index == 0 ? 24 : 0),
                                  bottomLeft: Radius.circular(index == optionsList.length - 1 ? 24 : 0),
                                  bottomRight: Radius.circular(index == optionsList.length - 1 ? 24 : 0),
                                )
                            ),
                            margin: EdgeInsets.fromLTRB(24, 0, 24, index == optionsList.length - 1 ? 104 : 0),
                            child: Stack(
                              children: [
                                if(index > 0) Positioned(
                                  top: 0,
                                  left: 20,
                                  child: Container(
                                    width: 392,
                                    height: 1,
                                    decoration: const BoxDecoration(
                                        color: Color(0x19FFFFFF)
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  left: 22,
                                  child: Text("${optionsList[index]}",
                                      style: const TextStyle(
                                          color: Color(0XD8FFFFFF),
                                          fontSize: 24,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none)
                                  ),
                                ),
                                Positioned(
                                  top: 22,
                                  right: 22,
                                  child: MzRadio<int>(
                                    activeColor: const Color(0XFF267AFF),
                                    groupValue: groupValue,
                                    value: index,
                                    onTap: (value) {
                                      setState((){
                                        groupValue = value!;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            width: 480,
                            height: 88,
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.1),
                            child: GestureDetector(
                              onTap: () {
                                Provider.of<StandbyChangeNotifier>(context, listen: false).setTimerByNum = groupValue;
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 240,
                                height: 56,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(28)),
                                  color: Color(0xFF267AFF),
                                ),
                                alignment: Alignment.center,
                                child: const Text('确定',
                                    style: TextStyle(
                                        color: Color(0XD8FFFFFF),
                                        fontSize: 24,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ),
            ],
          ),
      )),
    );
  }

  @override
  void didUpdateWidget(StandbyTimeChoicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget ");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    print("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }
}
