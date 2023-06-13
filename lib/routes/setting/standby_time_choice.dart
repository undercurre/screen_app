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
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  setState(() {
                    groupValue = 0;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                      child: const Text("30秒后",
                          style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 18.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          )),
                    ),

                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 18, 10, 0),
                      child:  MzRadio<int>(
                        activeColor: const Color(0XFF267AFF),
                        groupValue: groupValue,
                        value: 0,
                        onTap: (value) {
                          setState((){
                            groupValue=value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 9, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  setState(() {
                    groupValue = 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(28, 9, 0, 0),
                      child: const Text("1分钟后",
                          style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 18.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 9, 10, 0),
                      child:  MzRadio<int>(
                        activeColor: const Color(0XFF267AFF),
                        groupValue: groupValue,
                        value: 1,
                        onTap: (value) {
                          setState((){
                            groupValue=value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 9, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  setState(() {
                    groupValue = 2;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(28, 9, 0, 0),
                      child: const Text("3分钟后",
                          style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 18.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 9, 10, 0),
                      child:  MzRadio<int>(
                        activeColor: const Color(0XFF267AFF),
                        groupValue: groupValue,
                        value: 2,
                        onTap: (value){
                          setState((){
                            groupValue=value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 464,
              height: 2,
              margin: const EdgeInsets.fromLTRB(0, 9, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  setState(() {
                    groupValue = 3;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(28, 9, 0, 0),
                      child: const Text("5分钟后",
                          style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 18.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 9, 10, 0),
                      child:  MzRadio<int>(
                        activeColor: const Color(0XFF267AFF),
                        groupValue: groupValue,
                        value: 3,
                        onTap: (value){
                          setState((){
                            groupValue=value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 9, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  setState(() {
                    groupValue = 4;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(28, 9, 0, 0),
                      child: const Text("永不",
                          style: TextStyle(
                            color: Color(0XFFFFFFFF),
                            fontSize: 18.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 9, 10, 0),
                      child:  MzRadio<int>(
                        activeColor: const Color(0XFF267AFF),
                        groupValue: groupValue,
                        value: 4,
                        onTap: (value) {
                          setState((){
                            groupValue=value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 9, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      width: 240,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0xFF282828),
                      ),
                      child: const Center(
                        child: Text("取消",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 18.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Provider.of<StandbyChangeNotifier>(context, listen: false).setTimerByNum = groupValue;
                    Navigator.pop(context);
                  },
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      width: 240,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0xFF267AFF),
                      ),
                      child: const Center(
                        child: Text("确认",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 18.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      )),
                ),

              ],
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
