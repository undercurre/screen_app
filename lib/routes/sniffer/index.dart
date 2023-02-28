import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/channel/models/manager_devic.dart';
import 'package:screen_app/common/api/gateway_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/utils.dart';
import 'package:screen_app/models/index.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/life_cycle_state.dart';
import 'package:screen_app/widgets/safe_state.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../common/api/user_api.dart';
import '../../common/system.dart';
import 'device_item.dart';

class SnifferViewModel {

  final SnifferState _state;
  /// 探测到的zigbee设备
  List<FindZigbeeResult> zigbeeList = <FindZigbeeResult>[];
  /// 探测到的wifi设备
  List<FindWiFiResult> wifiList = <FindWiFiResult>[];
  /// 整合的设备列表
  List<SelectDeviceModel> combineList = <SelectDeviceModel>[];

  /// 获取指定家庭信息
  Future<List<RoomEntity>?> getHomeData() async {
    var res = await UserApi.getHomeListWithDeviceList(
        homegroupId: Global.profile.homeInfo?.homegroupId);

    if (res.isSuccess) {
      return res.data.homeList[0].roomList;
    }
  }

  SnifferViewModel(this._state);

  /// 当页面在前台时，自动进行扫描
  void onStateResume(BuildContext context) {
    debugPrint('开始扫描设备');
    if(Global.user?.accessToken != null) {
      deviceManagerChannel.updateToken(Global.user!.accessToken);
    }

    // _state.setSafeState(() {
    //   combineList.clear();
    //   wifiList.clear();
    //   zigbeeList.clear();
    // });

    sniffer(context);
  }

  /// 当页面在后台时，暂停自动扫描
  void onStatePause(BuildContext context) {
    debugPrint('停止扫描设备');
    stopSniffer(context);
  }

  /// 是否存在已经选中的Model
  bool hasSelected() => combineList.any((e) => e.selected);

  /// 开始探测设备
  void sniffer(BuildContext context) {
    debugPrint('NetUtils.getNetState(): ${NetUtils.getNetState()}');
    if (NetUtils.getNetState() == null || !NetUtils.getNetState()?.isWifi) {
      debugPrint('showWiFiDialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _state.showWifiDialog();
      });
      return;
    }
    /// 判定当前网关是否已经绑定
    GatewayApi.check((bind) {
      if(!bind) {
        TipsUtils.toast(content: '智慧屏已删除，请重新登录');
        System.loginOut();
        Navigator.pushNamedAndRemoveUntil(context, "Login", (route) => route.settings.name == "/");
      }
    }, () {
      //接口请求报错
    });

    /// 探测zigbee类型设备
    _snifferZigbee();
    /// 探测wifi类型设备
    _snifferWiFi();
  }

  /// 跳转到连接页
  void toDeviceConnect(BuildContext context) {

    if (!hasSelected()) {
      TipsUtils.toast(content: '请选择要绑定的设备');
      return;
    }

    NetUtils.checkConnectedWiFiRecord().then((value) {
      if(value == null) {
        _state.showIgnoreWiFiDialog();
      } else {
        getHomeData().then((value) {
          if(value != null) {
            Navigator.pushNamed(context, 'DeviceConnectPage',
                arguments: {
                  'devices': combineList.where((element) => element.selected).map((e) => e.data).toList(),
                  'rooms': value
                });
          } else {
            TipsUtils.toast(content: '获取房间失败');
          }
        });

      }
    });

  }

  /// 停止探测设备
  void stopSniffer(BuildContext context) {
    _stopSnifferZigbee();
    _stopSnifferWiFi();
  }

  void _snifferZigbee() {
    /// 播报允许连入语音
    gatewayChannel.broadcastAllowLink();

    deviceManagerChannel.setFindZigbeeListener((result) {
      debugPrint('zigbeeList: $result');
      zigbeeList.addAll(result.where((element) => !zigbeeList.contains(element)).toList());
      combineList.addAll(zigbeeList.where((element1) => !combineList.any((element2) => element2.data == element1)).map((e) => SelectDeviceModel.create(e)));
      notifyStateChange(() { });
    });

    deviceManagerChannel.findZigbee(
        Global.profile.homeInfo?.homegroupId ?? "",
        Global.profile.applianceCode ?? ""
    );

  }

  void _stopSnifferZigbee() {
    deviceManagerChannel.stopFindZigbee(Global.profile.homeInfo?.homegroupId ?? "", Global.profile.applianceCode ?? "");
    deviceManagerChannel.setFindZigbeeListener(null);
  }

  void _snifferWiFi() {
    deviceManagerChannel.setFindWiFiCallback((result) {
      debugPrint('wifiList: $result');
      wifiList.addAll(result.where((element) => !wifiList.contains(element)));
      combineList.addAll(wifiList.where((element1) => !combineList.any((element2) => element2.data == element1)).map((e) => SelectDeviceModel.create(e)));
      notifyStateChange(() { });
    });
    deviceManagerChannel.findWiFi();
  }

  void _stopSnifferWiFi() {
    deviceManagerChannel.stopFindWiFi();
    deviceManagerChannel.setFindWiFiCallback(null);
  }

  void notifyStateChange(VoidCallback fun) {
    _state.setSafeState(fun);
  }

}

class SnifferState extends SafeState<SnifferPage> with LifeCycleState, WidgetNetState {
  double turns = 0; // 控制扫描动画圈数
  final int timeout = 90000; // 设备查找时间
  final int timePerTurn = 3; // 转一圈所需时间
  late SnifferViewModel viewModel;
  MZNetState? _currentNetState;

  Widget selectWifi() {

    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, 'NetSettingPage'),
        child: Container(
            width: 356,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: const Color(0xff282828),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: Image.asset(
                        "assets/imgs/icon/wifi-3.png",
                        width: 24.0)),
                Text(
                  _currentNetState == null ? '暂未连接': _currentNetState!.isWifi ? NetUtils.getRawNetState().wiFiScanResult!.ssid : '暂未连接',
                  style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.w400),
                ),
                const Expanded(
                    child: Text(
                  '进入网络设置',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.w400,
                      color: Color(0xff267AFF)),
                ))
              ],
            )));
  }

  void showWifiDialog() {
    MzDialog mzDialog = MzDialog(
        title: '连接家庭网络',
        desc: '请确认当前网络是2.4GHZ',
        btns: ['取消', '确认'],
        contentSlot: selectWifi(),
        maxWidth: 425,
        contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 50),
        onPressed: (String item, int index, dialogContext) {
          logger.i('$index: $item');
          if(index == 0) {
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          } else {
            if(NetUtils.getNetState()?.isWifi) {
              Navigator.pop(dialogContext);
            } else {
              TipsUtils.toast(content: '请先连接wifi，然后再尝试');
            }
          }
        });

    mzDialog.show(context);
  }

  void showIgnoreWiFiDialog() {
    MzDialog mzDialog = MzDialog(
        title: '抱歉',
        desc: '请忘记当前网络，然后进行重新连接',
        btns: ['取消', '确认'],
        contentSlot: selectWifi(),
        maxWidth: 425,
        contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 50),
        onPressed: (String item, int index, dialogContext) {
          Navigator.pushNamed(context, 'NetSettingPage');
          Navigator.pop(dialogContext);
        });

    mzDialog.show(context);
  }

  // 生成设备列表
  List<Widget> _listView() {
    return viewModel.combineList
        .map((device) => DeviceItem(
            device: device,
            onTap: (d) {
              setState(() => d.selected = !d.selected);
            }))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // 页面加载完成，即开始执行扫描动画
    // HACK 0.5 使扫描光线图片恰好转到视图下方，无法看到
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => turns -= timeout / timePerTurn - 0.5);
    });
  }

  @override
  void onCreate() {
    super.onCreate();
    viewModel = SnifferViewModel(this);
  }

  @override
  void onResume() {
    super.onResume();
    viewModel.onStateResume(context);
  }

  @override
  void onPause() {
    super.onPause();
    viewModel.onStatePause(context);
  }

  @override
  void onDestroy() {
    super.onDestroy();
  }

  @override
  void netChange(MZNetState? state) {
    _currentNetState = state;
  }

  @override
  Widget saveBuild(BuildContext context) {
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/imgs/device/sniffer_01.png")),
      ),
      child: Stack(
        children: [
          // 顶部导航
          MzNavigationBar(
            onLeftBtnTap: () => Navigator.pop(context),
            title: '发现设备',
          ),

          // 扫描动画
          Positioned(
              left: MediaQuery.of(context).size.width / 2,
              bottom: 0,
              child: AnimatedRotation(
                turns: turns,
                alignment: Alignment.bottomLeft,
                duration: Duration(seconds: timeout),
                child: const Image(
                  height: 296,
                  width: 349,
                  image: AssetImage("assets/imgs/device/sniffer_02.png"),
                ),
              )),

          // 设备阵列
          Positioned(
              top: 100,
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  runSpacing: 6,
                  children: _listView())),

          if (viewModel.combineList.isEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              left: 0,
              child: const Center(
                child: Text('正在搜索设备',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'MideaType')),
              ),
            ),

          if (viewModel.combineList.isNotEmpty)
            Positioned(
                left: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                        style: viewModel.hasSelected() ? buttonStyleOn : buttonStyle,
                        onPressed: () => viewModel.toDeviceConnect(context),
                        child: Text(viewModel.hasSelected() ? '添加设备' : '选择设备',
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: 'MideaType'))),
                  ),
                ])),
        ],
      ),
    );
  }

}

class SnifferPage extends StatefulWidget {
  const SnifferPage({super.key});

  @override
  SnifferState createState() => SnifferState();
}
