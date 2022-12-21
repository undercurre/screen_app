import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x14/api.dart';
import 'package:screen_app/widgets/index.dart';

class CurtainPageState extends State<CurtainPage> {
  String deviceId = '0';
  String deviceName = '窗帘';

  bool power = true;
  num position = 1;
  num colorTemperature = 0;
  String screenModel = 'manual';
  String timeOff = '0';

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> modeHandle(Mode mode) async {
    setState(() {
      screenModel = mode.key;
    });
    // await CurtainApi.modePDM(deviceId, mode.key);
  }

  Future<void> curtainHandle(num value) async {
    setState(() {
      position = value;
    });
    // await CurtainApi.brightnessPDM(deviceId, value);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[screenModel] = true;
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
      deviceName = args['deviceName'];
      CurtainApi.getLightDetail(deviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black
      ),
      child: Stack(
        children: [
          Positioned(
              left: -16, // 向左偏移
              top: 0,
              child: AnimationCurtain(
                position: position,
              )),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    maxHeight: 60.0,
                  ),
                  child: MzNavigationBar(
                    onLeftBtnTap: goBack,
                    title: deviceName,
                    power: power,
                    hasPower: false,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    const Align(
                      widthFactor: 1,
                      heightFactor: 2,
                      alignment: Alignment(-1.0, -0.63),
                      child: SizedBox(
                        width: 152,
                        height: 303,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView(
                            children: [
                              SliderButtonCard(
                                unit: '%',
                                value: position,
                                min: 1,
                                max: 100,
                                onChanged: curtainHandle
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurtainPage extends StatefulWidget {
  const CurtainPage({super.key});

  @override
  State<CurtainPage> createState() => CurtainPageState();
}
