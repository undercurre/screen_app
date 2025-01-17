import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/models/homlux_device_entity.dart';
import 'package:screen_app/common/meiju/api/meiju_device_api.dart';
import 'package:screen_app/widgets/mz_buttion.dart';
import 'package:uuid/uuid.dart';

import '../../channel/index.dart';
import '../../common/adapter/bind_gateway_data_adapter.dart';
import '../../common/adapter/select_family_data_adapter.dart';
import '../../common/adapter/select_room_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/index.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/setting.dart';
import '../../models/device_entity.dart';
import '../../states/device_list_notifier.dart';
import '../../states/layout_notifier.dart';
import '../../widgets/business/net_connect.dart';
import '../../widgets/business/select_home.dart';
import '../../widgets/business/select_room.dart';
import '../../widgets/mz_dialog.dart';
import '../../widgets/util/deviceEntityTypeInP4Handle.dart';
import '../../widgets/util/net_utils.dart';
import '../home/device/card_type_config.dart';
import '../home/device/grid_container.dart';
import '../home/device/layout_data.dart';
import 'chose_platform.dart';
import 'scan_code.dart';

class Step {
  String title;
  Widget view;

  Step(this.title, this.view);
}

class _LoginPage extends State<LoginPage> with WidgetNetState {
  /// 当前步骤，1-4
  var stepNum = 1;
  bool isNeedChoosePlatform = false;
  BindGatewayAdapter? bindGatewayAd;
  bool isNeedShowClearAlert = false;
  String routeFrom = "";
  GlobalKey<SelectHomeState> selectHomeKey = GlobalKey<SelectHomeState>();
  GlobalKey<SelectRoomState> selectRoomKey = GlobalKey<SelectRoomState>();
  GlobalKey<LinkNetworkState> networkKey = GlobalKey<LinkNetworkState>();
  GlobalKey<_BindingDialogState> bindingKey = GlobalKey<_BindingDialogState>();

  String? selectFamilyId;
  Uuid uuid = Uuid();

  void showBindingDialog(String tip) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return BindingDialog(
          key: bindingKey,
          tip: tip,
        );
      },
    );
  }

  /// 上一步
  void prevStep() {
    /// 从选择家庭返回的时候，需重置为空
    if (stepNum <= 3) {
      selectFamilyId = null;
    }
    if (stepNum == 1) {
      return;
    }
    setState(() {
      --stepNum;
    });
    if (stepNum == 3) {
      System.familyInfo = null;
      System.roomInfo = null;
      isNeedShowClearAlert = false;
    }
  }

  /// 下一步
  void nextStep() async {
    if (Platform.isAndroid && stepNum == 1 && !(networkKey.currentState?.isNetworkConnected() ?? false)) {
      TipsUtils.toast(content: '请连接网络');
      return;
    }

    if (stepNum == 3) {
      if (System.familyInfo == null) {
        // 必须选择家庭信息才能进行下一步
        // 检查家庭是否有权限
        selectHomeKey.currentState?.checkAndSelect();
        return;
      }
    }

    if (stepNum == 4) {
      // 必须选择房间信息才能进行下一步
      if (System.roomInfo == null) {
        TipsUtils.toast(content: '请选择房间');
        return;
      }
      // todo: linux运行屏蔽，push前解放
      if (Platform.isLinux) {
        // 运行在 Linux 平台上
      } else {
        // 运行在其他平台上
        TipsUtils.showLoading();
        // 判断是否绑定网关
        bindGatewayAd?.destroy();
        bindGatewayAd = BindGatewayAdapter(MideaRuntimePlatform.platform);
        bindGatewayAd?.checkGatewayBindState(System.familyInfo!, (isBind, device) {
          TipsUtils.hideLoading();
          if (!isBind) {
            callback() {
              // 绑定网关
              showBindingDialog('正在绑定中，请稍后');
              bindGatewayAd?.bindGateway(System.familyInfo!, System.roomInfo!).then((isSuccess) {
                if (isSuccess) {
                  prepare2goHome(true);
                  Setting.instant().lastBindHomeName = System.familyInfo?.familyName ?? "";
                  Setting.instant().lastBindHomeId = System.familyInfo?.familyId ?? "";
                  Setting.instant().lastBindRoomId = System.roomInfo?.id ?? "";
                  Setting.instant().lastBindRoomName = System.roomInfo?.name ?? '';
                  Setting.instant().isAllowChangePlatform = false;
                  gatewayChannel.resetRelayModel();
                  Log.i("绑定网关");
                } else {
                  assert(bindingKey.currentState != null);
                  bindingKey.currentState?.showErrorStyle();
                  selectRoomKey.currentState?.refreshList();
                }
              });
            }

            if (StrUtils.isNotNullAndEmpty(Setting.instant().lastBindHomeId) &&
                Setting.instant().lastBindHomeId != System.familyInfo!.familyId) {
              showClearAlert(
                  context,
                  '绑定至新家庭',
                  "智慧屏已绑定在家庭“${Setting.instant().lastBindHomeName}”，"
                      "绑定至新家庭将清除所有本地数据，是否继续？", () {
                callback();
              });
            } else {
              callback();
            }
          } else {
            assert(System.roomInfo != null);
            callback() {
              showBindingDialog('正在登录中，请稍后');
              bindGatewayAd?.modifyDevice(System.familyInfo!, System.roomInfo!, device!).then((value) {
                if (value) {
                  Log.i('当前网关已绑定到房间${System.roomInfo!.name}');
                  prepare2goHome(false);
                  Setting.instant().lastBindHomeName = System.familyInfo?.familyName ?? "";
                  Setting.instant().lastBindHomeId = System.familyInfo?.familyId ?? "";
                  Setting.instant().lastBindRoomId = System.roomInfo?.id ?? "";
                  Setting.instant().lastBindRoomName = System.roomInfo?.name ?? '';
                } else {
                  assert(bindingKey.currentState != null);
                  bindingKey.currentState?.showErrorStyle();
                  selectRoomKey.currentState?.refreshList();
                }
              });
            }

            if (StrUtils.isNotNullAndEmpty(Setting.instant().lastBindRoomId) && Setting.instant().lastBindRoomId != System.roomInfo!.id) {
              showClearAlert(context, '迁移至新房间', "智慧屏将迁移至${System.roomInfo!.name}房间，是否继续？", () {
                callback.call();
              });
            } else {
              callback.call();
            }
          }
        }, () {
          TipsUtils.hideLoading();
          TipsUtils.toast(content: "请求异常，请重试");
          selectRoomKey.currentState?.refreshList();
        });
      }
      return;
    }
    setState(() {
      ++stepNum;
    });
  }

  void prepare2goHome(bool needBind) {
    prepareLayout(needBind);
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        assert(bindingKey.currentState != null);
        if (needBind) {
          bindingKey.currentState?.showBindSucStyle();
        } else {
          bindingKey.currentState?.showLoginSucStyle();
        }
      }
    });
    Timer(const Duration(seconds: 6), () {
      //导航到新路由
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, 'GuidePage', ModalRoute.withName('/'));
        System.login();
      }
    });
  }

  void prepareLayout(bool isBinding) async {
    final deviceInfoListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
    final layoutModel = Provider.of<LayoutModel>(context, listen: false);
    if (isBinding) {
      List<Layout> defaultList = [
        Layout(
            'clock',
            DeviceEntityTypeInP4.Clock,
            CardType.Other,
            0,
            [1, 2, 5, 6],
            DataInputCard(
                name: '时钟',
                applianceCode: 'clock',
                roomName: '屏内',
                isOnline: '',
                type: 'clock',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'weather',
            DeviceEntityTypeInP4.Weather,
            CardType.Other,
            0,
            [3, 4, 7, 8],
            DataInputCard(
                name: '天气',
                applianceCode: 'weather',
                roomName: '屏内',
                isOnline: '',
                type: 'weather',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'localPanel1',
            DeviceEntityTypeInP4.LocalPanel1,
            CardType.Small,
            0,
            [9, 10],
            DataInputCard(
                name: '灯1',
                applianceCode: 'localPanel1',
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel1',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'localPanel2',
            DeviceEntityTypeInP4.LocalPanel2,
            CardType.Small,
            0,
            [11, 12],
            DataInputCard(
                name: '灯2',
                applianceCode: 'localPanel2',
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel2',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            0,
            [13, 14],
            DataInputCard(
                name: '', applianceCode: '', roomName: '', isOnline: '', type: '', masterId: '', modelNumber: '', onlineStatus: '')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            0,
            [15, 16],
            DataInputCard(
                name: '', applianceCode: '', roomName: '', isOnline: '', type: '', masterId: '', modelNumber: '', onlineStatus: ''))
      ];
      await layoutModel.setLayouts(defaultList);
      return;
    }
    if (Setting.instant().lastBindHomeId != System.familyInfo?.familyId) {
      // 换房间，重新初始布局该房间
      await layoutModel.removeLayouts();
      await layoutModel.loadLayouts();
      // if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      // var res = await HomluxDeviceApi.queryDeviceListByRoomId(System.roomInfo!.id!);
      // List<HomluxDeviceEntity>? devices = res.data;
      // if (devices != null) {
      //   List<DeviceEntity> devicesReal = [];
      //
      //   devices.forEach((e) {
      //     DeviceEntity deviceObj = DeviceEntity();
      //     deviceObj.name = e.deviceName!;
      //     deviceObj.applianceCode = e.deviceId!;
      //     deviceObj.type = e.proType!;
      //     deviceObj.modelNumber = getModelNumber(e);
      //     deviceObj.roomName = e.roomName!;
      //     deviceObj.roomId = System.roomInfo?.id;
      //     deviceObj.masterId = e.gatewayId ?? '';
      //     deviceObj.onlineStatus = e.onLineStatus.toString();
      //     if (DeviceEntityTypeInP4Handle.getDeviceEntityType(deviceObj.type, deviceObj.modelNumber) != DeviceEntityTypeInP4.Default) {
      //       devicesReal.add(deviceObj);
      //     }
      //   });
      //   if (devicesReal.isNotEmpty) {
      //     List<Layout> layoutData = deviceInfoListModel.transformLayoutFromDeviceList(devicesReal);
      //     await layoutModel.setLayouts(layoutData);
      //   } else {
      //     await layoutModel.loadLayouts();
      //   }
      // }
      // } else {
      // List<dynamic> devices =
      //     await MeiJuDeviceApi.queryDeviceListByRoomId(
      //     MeiJuGlobal.token!.uid,
      //     System.familyInfo!.familyId,
      //     System.roomInfo!.id!);
      // List<DeviceEntity> devicesReal = [];
      //
      // devices.forEach((e) {
      //   DeviceEntity deviceObj = DeviceEntity();
      //   deviceObj.name = e["name"];
      //   deviceObj.applianceCode = e["applianceCode"];
      //   deviceObj.type = e["type"];
      //   deviceObj.modelNumber = e["modelNumber"];
      //   deviceObj.sn8 = e["sn8"];
      //   deviceObj.roomName = e["roomName"];
      //   deviceObj.masterId = e["masterId"];
      //   deviceObj.onlineStatus = e["onlineStatus"];
      //   if (DeviceEntityTypeInP4Handle.getDeviceEntityType(
      //       e["type"], e["modelNumber"]) !=
      //       DeviceEntityTypeInP4.Default) {
      //     devicesReal.add(deviceObj);
      //   }
      // });
      // Log.i('有效布局', devicesReal);
      // if (devicesReal.isNotEmpty) {
      //   List<Layout> layoutData = deviceInfoListModel
      //       .transformLayoutFromDeviceList(devicesReal);
      //   await layoutModel.setLayouts(layoutData);
      // } else {
      //   List<Layout> defaultList = [
      //     Layout(
      //         'clock',
      //         DeviceEntityTypeInP4.Clock,
      //         CardType.Other,
      //         0,
      //         [1, 2, 5, 6],
      //         DataInputCard(
      //             name: '时钟',
      //             applianceCode: 'clock',
      //             roomName: '屏内',
      //             isOnline: '',
      //             type: 'clock',
      //             masterId: '',
      //             modelNumber: '',
      //             onlineStatus: '1')),
      //     Layout(
      //         'weather',
      //         DeviceEntityTypeInP4.Weather,
      //         CardType.Other,
      //         0,
      //         [3, 4, 7, 8],
      //         DataInputCard(
      //             name: '天气',
      //             applianceCode: 'weather',
      //             roomName: '屏内',
      //             isOnline: '',
      //             type: 'weather',
      //             masterId: '',
      //             modelNumber: '',
      //             onlineStatus: '1')),
      //     Layout(
      //         'localPanel1',
      //         DeviceEntityTypeInP4.LocalPanel1,
      //         CardType.Small,
      //         0,
      //         [9, 10],
      //         DataInputCard(
      //             name: '灯1',
      //             applianceCode: 'localPanel1',
      //             roomName: '屏内',
      //             isOnline: '',
      //             type: 'localPanel1',
      //             masterId: '',
      //             modelNumber: '',
      //             onlineStatus: '1')),
      //     Layout(
      //         'localPanel2',
      //         DeviceEntityTypeInP4.LocalPanel2,
      //         CardType.Small,
      //         0,
      //         [11, 12],
      //         DataInputCard(
      //             name: '灯2',
      //             applianceCode: 'localPanel2',
      //             roomName: '屏内',
      //             isOnline: '',
      //             type: 'localPanel2',
      //             masterId: '',
      //             modelNumber: '',
      //             onlineStatus: '1')),
      //     Layout(
      //         uuid.v4(),
      //         DeviceEntityTypeInP4.DeviceNull,
      //         CardType.Null,
      //         0,
      //         [13, 14],
      //         DataInputCard(
      //             name: '',
      //             applianceCode: '',
      //             roomName: '',
      //             isOnline: '',
      //             type: '',
      //             masterId: '',
      //             modelNumber: '',
      //             onlineStatus: '')),
      //     Layout(
      //         uuid.v4(),
      //         DeviceEntityTypeInP4.DeviceNull,
      //         CardType.Null,
      //         0,
      //         [15, 16],
      //         DataInputCard(
      //             name: '',
      //             applianceCode: '',
      //             roomName: '',
      //             isOnline: '',
      //             type: '',
      //             masterId: '',
      //             modelNumber: '',
      //             onlineStatus: ''))
      //   ];
      //   await layoutModel.setLayouts(defaultList);
      //   Log.i('插入默认布局');
      // }
      //}
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化
    if (!System.inNonePlatform()) {
      if (System.isLogin()) {
        stepNum = 3;
      } else if (Platform.isAndroid && isConnected()) {
        stepNum = 2;
      }
    }

    isNeedChoosePlatform = System.inNonePlatform();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        routeFrom = args["from"] ?? "";
        if (routeFrom == "changePlatform") {
          setState(() {
            isNeedChoosePlatform = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var stepList = [
      Step(
          '连接网络',
          Container(
            width: 480,
            height: 340,
            alignment: AlignmentDirectional.centerStart,
            child: LinkNetwork(key: networkKey),
          )),
      Step(
          '扫码登录',
          Column(children: [
            Container(margin: const EdgeInsets.only(top: 5), child: ScanCode(onSuccess: nextStep)),
          ])),
      Step(
          '选择家庭',
          SelectHome(
              key: selectHomeKey,
              defaultFamilyId: selectFamilyId ?? Setting.instant().lastBindHomeId,
              onChange: (SelectFamilyItem? home) {
                debugPrint('Select: ${home?.toJson()}');
                selectFamilyId = home?.familyId;
                System.familyInfo = home;
                checkIsNeedShowClearAlert();
                nextStep();
              })),
      Step(
          '选择房间',
          SelectRoom(
              key: selectRoomKey,
              defaultRoomId: Setting.instant().lastBindRoomId,
              onChange: (SelectRoomItem room) {
                debugPrint('SelectRoom: ${room.toJson()}');
                System.roomInfo = room;
              })),
    ];

    var stepItem = stepNum > stepList.length ? null : stepList[stepNum - 1];

    return Stack(
      children: [
        if (isNeedChoosePlatform)
          ChosePlatform(
            isChose: routeFrom == "changePlatform",
            onFinished: () {
              setState(() {
                isNeedChoosePlatform = false;
              });
            },
          ),
        if (!isNeedChoosePlatform)
          DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF272F41), Color(0xFF080C14)],
                ),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LoginHeader(stepSum: stepList.length, stepNum: stepNum, title: stepItem?.title ?? ''),
                  if (stepItem?.view != null)
                    Container(
                      child: stepItem?.view,
                    ),
                ],
              ))),
        if (stepNum == 1 && !isNeedChoosePlatform)
          Positioned(
              bottom: 0,
              child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        width: MediaQuery.of(context).size.width,
                        height: 72,
                        child: Center(
                            child: MzButton(
                          width: 240,
                          height: 56,
                          borderRadius: 29,
                          backgroundColor: const Color(0xFF267AFF),
                          borderColor: Colors.transparent,
                          borderWidth: 1,
                          text: '下一步',
                          onPressed: () {
                            nextStep();
                          },
                        )),
                      ))))
        else if (stepNum == 2 && !isNeedChoosePlatform)
          Positioned(
              bottom: 0,
              child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        width: MediaQuery.of(context).size.width,
                        height: 72,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (Setting.instant().isAllowChangePlatform)
                              MzButton(
                                width: 168,
                                height: 56,
                                borderRadius: 29,
                                backgroundColor: const Color(0xFF949CA8),
                                borderColor: Colors.transparent,
                                borderWidth: 1,
                                text: '切换平台',
                                onPressed: () {
                                  setState(() {
                                    isNeedChoosePlatform = true;
                                    routeFrom = "";
                                  });
                                },
                              ),
                            MzButton(
                              width: Setting.instant().isAllowChangePlatform ? 168 : 240,
                              height: 56,
                              borderRadius: 29,
                              backgroundColor: const Color(0xFF267AFF),
                              borderColor: Colors.transparent,
                              borderWidth: 1,
                              text: '上一步',
                              onPressed: () {
                                prevStep();
                              },
                            )
                          ],
                        ),
                      ))))
        else if (!isNeedChoosePlatform)
          Positioned(
              bottom: 0,
              child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                          color: Colors.white.withOpacity(0.05),
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          width: MediaQuery.of(context).size.width,
                          height: 72,
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MzButton(
                                width: 168,
                                height: 56,
                                borderRadius: 29,
                                backgroundColor: const Color(0xFF949CA8),
                                borderColor: Colors.transparent,
                                borderWidth: 1,
                                text: '上一步',
                                onPressed: () {
                                  prevStep();
                                },
                              ),
                              MzButton(
                                width: 168,
                                height: 56,
                                borderRadius: 29,
                                backgroundColor: const Color(0xFF267AFF),
                                borderColor: Colors.transparent,
                                borderWidth: 1,
                                text: stepNum == 4 ? '完成' : '下一步',
                                onPressed: () {
                                  nextStep();
                                },
                              )
                            ],
                          ))))))
      ],
    );
  }

  void checkIsNeedShowClearAlert() {
    int lenDiff = (Setting.instant().lastBindHomeId.length - (System.familyInfo?.familyId.length ?? 0)).abs();
    if (Setting.instant().lastBindHomeId.isNotEmpty && Setting.instant().lastBindHomeId != System.familyInfo?.familyId && lenDiff < 3) {
      isNeedShowClearAlert = true;
    }
  }

  void showClearAlert(BuildContext context, String title, String tip, VoidCallback callback) async {
    var name = Setting.instant().lastBindHomeName;
    MzDialog(
        title: title,
        titleSize: 28,
        maxWidth: 432,
        backgroundColor: const Color(0xFF494E59),
        contentPadding: const EdgeInsets.fromLTRB(33, 24, 33, 0),
        contentSlot: Text(tip,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(
              color: Color(0xFFB6B8BC),
              fontSize: 24,
              height: 1.6,
              fontFamily: "MideaType",
              decoration: TextDecoration.none,
            )),
        btns: ['取消', '确定'],
        onPressed: (_, position, context) {
          Navigator.pop(context);
          if (position == 1) {
            callback.call();
          }
        }).show(context);
  }

  @override
  void netChange(MZNetState? state) {
    debugPrint('netChange: $state');
  }

  @override
  void dispose() {
    super.dispose();
    bindGatewayAd?.destroy();
    bindGatewayAd = null;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class LoginHeader extends StatelessWidget {
  /// 当前索引
  final int stepNum;

  /// 步骤总数
  final int stepSum;

  /// 标题
  final String title;

  const LoginHeader({super.key, required this.stepSum, required this.stepNum, required this.title});

  @override
  Widget build(BuildContext context) {
    var titleView = Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Text(title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            height: 1,
            fontFamily: "MideaType",
            decoration: TextDecoration.none,
          )),
    );

    const stepActiveImg = Image(image: AssetImage("assets/imgs/login/step-active.png"));
    const stepFinishedImg = Image(image: AssetImage("assets/imgs/login/step-finished.png"));
    const stepPassiveImg = Image(image: AssetImage("assets/imgs/login/step-passive.png"));
    const lineActiveImg = Image(image: AssetImage("assets/imgs/login/line-active.png"));
    const linePassiveImg = Image(image: AssetImage("assets/imgs/login/line-passive.png"));

    var stepList = <Widget>[];

    for (var i = 1; i <= stepSum; i++) {
      if (stepNum >= i && i > 1) {
        stepList.add(lineActiveImg);
      } else if (stepNum < i && i > 1) {
        stepList.add(linePassiveImg);
      } else {}

      if (stepNum > i) {
        stepList.add(stepFinishedImg);
      } else if (stepNum == i) {
        stepList.add(stepActiveImg);
      } else {
        stepList.add(stepPassiveImg);
      }
    }
    num index = min(4, stepNum);
    var stepBarView = Container(margin: const EdgeInsets.all(9.0), child: Image(image: AssetImage('assets/newUI/step_$index.png')));

    var headerView = Column(
      children: [titleView, stepBarView],
    );

    return Stack(
        alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
        children: [headerView]);
  }
}

class BindingDialog extends StatefulWidget {
  String tip;

  BindingDialog({super.key, required this.tip});

  @override
  State<BindingDialog> createState() => _BindingDialogState();
}

class _BindingDialogState extends State<BindingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late int state;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    state = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  showLoadingStyle() {
    setState(() {
      state = 1;
    });
  }

  showLoginSucStyle() {
    setState(() {
      state = 4;
    });
  }

  showBindSucStyle() {
    setState(() {
      state = 2;
    });
  }

  showErrorStyle() {
    setState(() {
      state = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    var contentWidget = switch (state) {
      4 => Column(children: [
          Image.asset('assets/newUI/login/binding_suc.png'),
          const Text(
            '登录成功',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ]),
      2 => Column(children: [
          Image.asset('assets/newUI/login/binding_suc.png'),
          const Text(
            '绑定成功',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ]),
      3 => Column(children: [
          Image.asset('assets/newUI/login/binding_err.png'),
          const Text(
            '失败',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ]),
      _ => Column(children: [
          const SizedBox(
            width: 150,
            height: 150,
            child: Align(
              child: CupertinoActivityIndicator(radius: 25),
            ),
          ),
          Text(
            widget.tip,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ])
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            width: 412,
            height: 270,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF494E59),
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
            ),
            child: Column(
              children: [
                Expanded(flex: 1, child: Container(alignment: Alignment.topCenter, child: contentWidget)),
              ],
            ),
          ),
          if (state == 3)
            Positioned(
              right: 20,
              top: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/newUI/关闭@1x.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
