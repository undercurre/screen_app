import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StandbyTimeChoicePage extends StatefulWidget {
  const StandbyTimeChoicePage({Key? key});

  @override
  _StandbyTimeChoicePage createState() => _StandbyTimeChoicePage();
}

class _StandbyTimeChoicePage extends State<StandbyTimeChoicePage> {
  late double po;
  num groupValue = 1;
  @override
  void initState() {
    super.initState();
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
          color: Colors.black,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 480,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                    child: const Text("待机设置",
                        style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 30.0,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 60.0,
                    icon: Image.asset(
                      "assets/imgs/icon/tuichu.png",
                    ),
                  ),
                ],
              ),
            ),
            Row(
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
                  child:  Radio<num>(
                    activeColor: const Color(0XFF267AFF),
                    groupValue: groupValue,
                    value: 1,
                    onChanged: (value){
                      setState((){
                        groupValue=value!;
                      });
                    },
                  ),
                ),
              ],
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
                  child:  Radio<num>(
                    activeColor: const Color(0XFF267AFF),
                    groupValue: groupValue,
                    value: 2,
                    onChanged: (value){
                      setState((){
                        groupValue=value!;
                      });
                    },
                  ),
                ),
              ],
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
                  child:  Radio<num>(
                    activeColor: const Color(0XFF267AFF),
                    groupValue: groupValue,
                    value: 3,
                    onChanged: (value){
                      setState((){
                        groupValue=value!;
                      });
                    },
                  ),
                ),
              ],
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
                  child:  Radio<num>(
                    activeColor: const Color(0XFF267AFF),
                    groupValue: groupValue,
                    value: 4,
                    onChanged: (value){
                      setState((){
                        groupValue=value!;
                      });
                    },
                  ),
                ),
              ],
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
                  child:  Radio<num>(
                    activeColor: const Color(0XFF267AFF),
                    groupValue: groupValue,
                    value: 5,
                    onChanged: (value){
                      setState((){
                        groupValue=value!;
                      });
                    },
                  ),
                ),
              ],
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
                  onTap: () => Navigator.pop(context),
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
