import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x14/api.dart';
import 'package:screen_app/widgets/index.dart';

class CurtainPageState extends State<CurtainPage> {
  String deviceId = '0';
  String deviceName = '窗帘';

  bool power = true;
  num brightness = 0;
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
    await WIFILightApi.modePDM(deviceId, mode.key);
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    setState(() {
      brightness = value;
    });
    await WIFILightApi.brightnessPDM(deviceId, value);
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
      WIFILightApi.getLightDetail(deviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              child: AnimationCurtain(
                brightness: brightness,
                colorTemperature: 100 - colorTemperature,
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
                              AdjustCard(
                                value: brightness,
                                activeColors: const [
                                  Color(0xFF267AFF),
                                  Color(0xFF267AFF)
                                ],
                                onChanged: brightnessHandle,
                                onChanging: brightnessHandle,
                              ),
                              ModeCard(
                                title: "模式",
                                spacing: 40,
                                modeList: curtainModes,
                                selectedKeys: getSelectedKeys(),
                                onTap: modeHandle,
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
