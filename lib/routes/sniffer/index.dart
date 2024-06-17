import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/channel/models/manager_devic.dart';
import 'package:screen_app/channel/models/net_state.dart';
import 'package:screen_app/common/adapter/bind_gateway_data_adapter.dart';
import 'package:screen_app/common/adapter/select_family_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/utils.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/life_cycle_state.dart';
import 'package:screen_app/widgets/safe_state.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../common/logcat_helper.dart';
import '../../common/meiju/api/meiju_user_api.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/meiju/models/meiju_room_entity.dart';
import '../../common/system.dart';
import '../../widgets/mz_buttion.dart';
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
  Future<List<MeiJuRoomEntity>?> getHomeData() async {
    if (MeiJuGlobal.homeInfo?.homegroupId == null) {
      throw Exception("查询房间列表，家庭ID为空");
    }

    var res = await MeiJuUserApi.getHomeDetail(
        homegroupId: MeiJuGlobal.homeInfo?.homegroupId);

    if (res.isSuccess) {
      return res.data?.homeList?[0].roomList;
    }

    return null;
  }

  SnifferViewModel(this._state);

  /// 当页面在前台时，自动进行扫描
  void onStateResume(BuildContext context) {
    debugPrint('开始扫描设备');
    if (MeiJuGlobal.token?.accessToken != null) {
      deviceManagerChannel.updateToken(MeiJuGlobal.token!.accessToken);
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

  num selectCnt() {
    num cnt = 0;
    for (var element in combineList) {
      if (element.selected) cnt++;
    }
    return cnt;
  }

  void allSelect() {
    if (hasSelected()) {
      for (var element in combineList) {
        element.selected = false;
      }
    } else {
      for (var element in combineList) {
        element.selected = true;
      }
    }
  }

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

    BindGatewayAdapter(MideaRuntimePlatform.platform).checkGatewayBindState(
        SelectFamilyItem.fromMeiJu(MeiJuGlobal.homeInfo!), (bind, _) {
      if (!bind) {
        TipsUtils.toast(content: '智慧屏已删除，请重新登录');
        System.logout("检查网关未绑定，并退出登录");
      }
    }, () {});

    /// 探测zigbee类型设备
    _snifferZigbee();

    /// 探测wifi类型设备
    _snifferWiFi();
  }

  /// 跳转到连接页
  void toDeviceConnect(BuildContext context) {
    if (!hasSelected()) {
      settingMethodChannel.dismissLoading();
      TipsUtils.toast(content: '请选择要绑定的设备');
      return;
    }

    NetUtils.checkConnectedWiFiRecord().then((value) {
      if (value == null) {
        settingMethodChannel.dismissLoading();
        _state.showIgnoreWiFiDialog(value);
      } else {
        getHomeData().then((value) {
          if (value != null) {
            settingMethodChannel.dismissLoading();
            Navigator.pushNamed(context, 'DeviceConnectPage', arguments: {
              'devices': combineList
                  .where((element) => element.selected)
                  .map((e) => e.data)
                  .toList(),
              'rooms': value
            });
          } else {
            settingMethodChannel.dismissLoading();
            TipsUtils.toast(content: '获取房间失败');
          }
        }, onError: (e) {
          settingMethodChannel.dismissLoading();
          TipsUtils.toast(content: '获取房间失败');
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
    deviceManagerChannel.setFindZigbeeListener((result) {
      debugPrint('zigbeeList: $result');
      zigbeeList.addAll(
          result.where((element) => !zigbeeList.contains(element)).toList());

      combineList.addAll(zigbeeList
          .where((element1) =>
              !combineList.any((element2) => element2.data == element1))
          .map((e) => SelectDeviceModel.create(e,true)));
      notifyStateChange(() {});
    });

    deviceManagerChannel.findZigbee(MeiJuGlobal.homeInfo?.homegroupId ?? "",
        MeiJuGlobal.gatewayApplianceCode ?? "");
  }

  void _stopSnifferZigbee() {
    deviceManagerChannel.stopFindZigbee(MeiJuGlobal.homeInfo?.homegroupId ?? "",
        MeiJuGlobal.gatewayApplianceCode ?? "");
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

class SnifferState extends SafeState<SnifferPage>
    with LifeCycleStateMixin, WidgetNetState {
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
                    child: Image.asset("assets/imgs/icon/wifi-3.png",
                        width: 24.0)),
                Text(
                  _currentNetState == null
                      ? '暂未连接'
                      : _currentNetState!.isWifi
                          ? NetUtils.getRawNetState().wiFiScanResult!.ssid
                          : '暂未连接',
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
          Log.i('$index: $item');
          if (index == 0) {
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          } else {
            if (NetUtils.getNetState()?.isWifi) {
              Navigator.pop(dialogContext);
            } else {
              TipsUtils.toast(content: '请先连接wifi，然后再尝试');
            }
          }
        });

    mzDialog.show(context);
  }

  void showIgnoreWiFiDialog(ConnectedWiFiRecord? value) {
    MzDialog mzDialog = MzDialog(
        title: '提示',
        btns: ['取消', '确认'],
        contentSlot: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('请重新连接WiFi',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: 'MideaType'))
          ],
        ),
        maxWidth: 425,
        contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 50),
        onPressed: (String item, int index, dialogContext) async {
          if (index == 0) {
            Navigator.pop(dialogContext);
          } else {
            NetState state = netMethodChannel.currentNetState;
            if (state.wiFiScanResult != null) {
              await netMethodChannel.forgetWiFi(
                  state.wiFiScanResult!.ssid, state.wiFiScanResult!.bssid);
            }
            Navigator.popAndPushNamed(dialogContext, 'NetSettingPage');
          }
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
            sideBtnWidth: 100,
            rightSlot: GestureDetector(
              onTap: () {
                setState(() {
                  viewModel.allSelect();
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: 120,
                child: const Text(
                  "全选",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
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
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: GridView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(bottom: 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, //横轴5个子widget
                    childAspectRatio: 1.0 //宽高比为1
                    ),
                children: _listView()),
          ),

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

          // 底部按钮
          if (viewModel.combineList.isNotEmpty)
            Positioned(
              left: 0,
              bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 72,
                    color: const Color(0x19FFFFFF),
                    alignment: Alignment.center,
                    child: MzButton(
                      width: 240,
                      height: 56,
                      borderRadius: 29,
                      backgroundColor: viewModel.selectCnt() > 0
                          ? const Color(0xFF267AFF)
                          : const Color(0xFF4E77BD),
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      text: viewModel.selectCnt() > 0
                          ? "确认选择(${viewModel.selectCnt()})"
                          : "选择设备",
                      onPressed: () {
                        settingMethodChannel.showLoading("加载中");
                        viewModel.toDeviceConnect(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
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
