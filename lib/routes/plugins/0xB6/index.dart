import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/range_hood_device_data_adapter.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_list_notifier.dart';

class RangeHoodPage extends StatefulWidget {
  final RangeHoodDeviceDataAdapter adapter;

  const RangeHoodPage({super.key, required this.adapter});

  @override
  State<RangeHoodPage> createState() => _RangeHoodPageState();
}

class _RangeHoodPageState extends State<RangeHoodPage> {
  String? modeTapKey;

  List<Mode> modes = [
    Mode("light_on", "开启", 'assets/imgs/plugins/0xB6/light_on_off.png', 'assets/imgs/plugins/0xB6/light_on_off.png'),
    Mode("light_off", "关闭", 'assets/imgs/plugins/0xB6/light_on_off.png', 'assets/imgs/plugins/0xB6/light_on_off.png'),
  ];

  @override
  void initState() {
    super.initState();
    widget.adapter.bindDataUpdateFunction(updateCallback);
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {});
  }

  void goBack() {
    Navigator.pop(context);
  }

  void powerOnOff() {
    widget.adapter.power(!widget.adapter.getData().onOff);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    for (var mode in modes) {
      selectKeys[mode.key] = false;
    }
    modeTapKey = widget.adapter.getData().lightOnOff == 1 ? "light_on" : "light_off";
    Log.file("烟机 开关状态  $modeTapKey");
    selectKeys[modeTapKey!] = true;
    return selectKeys;
  }

  Widget adjustSpeedCard() {
    return GearCard(
      disabled: !widget.adapter.getData().onOff,
      maxGear: widget.adapter.getData().maxSpeed,
      minGear: widget.adapter.getData().minSpeed,
      value: widget.adapter.getData().currentSpeed,
      onChanged: (gear) {
        widget.adapter.slider1To(gear as int);
      },
    );
  }

  Widget adjustLightCard() {
    return ModeCard(
      title: "灯光",
      modeList: modes,
      selectedKeys: getSelectedKeys(),
      spacing: 80,
      onTap: (mode) {
        modeTapKey = mode.key;
        widget.adapter.lightPower(mode.key == 'light_on');
      }
    );
  }

  String getDeviceName() {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: true);
    String nameInModel = deviceListModel.getDeviceName(
        deviceId: widget.adapter.applianceCode,
        maxLength: 6,
        startLength: 3,
        endLength: 2);

    if (deviceListModel.deviceListHomlux.isEmpty &&
        deviceListModel.deviceListMeiju.isEmpty) {
      return '加载中';
    }

    return nameInModel;
  }

  @override
  Widget build(BuildContext context) {
    return _PluginBackground(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            MzNavigationBar(
              title: getDeviceName(),
              hasPower: true,
              power: widget.adapter.getData().onOff,
              onLeftBtnTap: goBack,
              onRightBtnTap: powerOnOff,
            ),
            Expanded(
              child: _PluginContentSolt(
                  child: EasyRefresh(
                    header: const ClassicHeader(
                      dragText: '下拉刷新',
                      armedText: '释放执行刷新',
                      readyText: '正在刷新...',
                      processingText: '正在刷新...',
                      processedText: '刷新完成',
                      noMoreText: '没有更多信息',
                      failedText: '失败',
                      messageText: '上次更新 %T',
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    onRefresh: () async {
                      widget.adapter.fetchData();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          adjustSpeedCard(),
                          const SizedBox(height: 15),
                          adjustLightCard(),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ));
  }
}

Widget _PluginBackground(
    {Widget? child, required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: const BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF272F41),
        Color(0xFF080C14),
      ],
    )),
    child: child,
  );
}

Widget _PluginContentSolt({required Widget child}) {
  return Stack(
    children: [
      Positioned(
          top: 50,
          child: Image.asset("assets/newUI/bg_range_hood.png",
              width: 230, height: 307)),
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(150, 0, 0, 0)),
          Expanded(child: child)
        ],
      ),
    ],
  );
}
