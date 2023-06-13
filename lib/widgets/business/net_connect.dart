// 说明：网络连接

// _LinkNetwork页面的 dataclass
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/widgets/mz_buttion.dart';
import 'package:screen_app/widgets/mz_wifi_image.dart';

import '../../channel/index.dart';
import '../../channel/models/net_state.dart';
import '../../channel/models/wifi_scan_result.dart';
import '../../common/helper.dart';
import '../../common/utils.dart';
import '../mz_cell.dart';
import '../mz_switch.dart';

// _LinkNetwork页面的 dataclass
class _LinkNetworkData {
  bool supportEthernet = false; // 是否支持控制以太网连接
  bool supportWiFi = true; // 是否支持控制WiFi
  bool isWiFiOn; // WiFi 是否打开
  bool isEthernetOn; // 有线以太网 是否打开
  UpdateState<WiFiScanResult>? currentConnect; // 当前连接状态
  Set<WiFiScanResult>? wifiList; // wifi 列表数据
  _LinkNetworkData({required this.isWiFiOn, required this.isEthernetOn});
}

// _LinkNetwork 界面的 业务逻辑层
class _LinkNetworkModel with ChangeNotifier {
  late _LinkNetworkData _data;

  List<dynamic> get pageData => <dynamic>[
    'headerTag',
    if (_data.supportWiFi && _data.isWiFiOn) ...?_data.wifiList
  ];

  _LinkNetworkModel(BuildContext context) {
    _data = _LinkNetworkData(isWiFiOn: false, isEthernetOn: false);
    Timer(const Duration(milliseconds: 250), () async {
      init();
    });
  }

  void init() async {
    bool supportWifi = await netMethodChannel.supportWiFiControl();
    bool supportEthernet = await netMethodChannel.supportEthernetControl();
    bool wifiOpen = await netMethodChannel.wifiIsOpen();
    bool ethernetOpen = await netMethodChannel.ethernetIsOpen();

    _data.supportWiFi = supportWifi;
    _data.supportEthernet = supportEthernet;
    _data.isWiFiOn = wifiOpen;
    _data.isEthernetOn = ethernetOpen;

    /// 假如WiFi与EthernetOpen同时连接，则断开全部
    if (wifiOpen && ethernetOpen) {
      await netMethodChannel.enableWiFi(false);
      await netMethodChannel.enableEthernet(false);
      _data.isWiFiOn = false;
      _data.isEthernetOn = false;
    }

    if (_data.supportWiFi) {
      netMethodChannel.registerScanWiFiCallBack(_wiFiListCallback);
    }

    netMethodChannel.startObserverNetState();
    netMethodChannel.registerNetChangeCallBack(_connectStateCallback);

    if (_data.supportWiFi && _data.isWiFiOn) {
      netMethodChannel.scanNearbyWiFi();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    netMethodChannel.stopObserverNetState();
    netMethodChannel.stopScanNearbyWiFi();
    netMethodChannel.unregisterNetChangeCallBack(_connectStateCallback);
    netMethodChannel.unregisterScanWiFiCallBack(_wiFiListCallback);
  }

  void _connectStateCallback(NetState state) {
    // int ethernetState = state.ethernetState;
    int wifiState = state.wifiState;
    if (wifiState == 2) {
      _data.currentConnect = UpdateState.success(state.wiFiScanResult!);
      _data.wifiList?.removeWhere((element) => element == state.wiFiScanResult);
    } else {
      _data.currentConnect = null;
    }
    notifyListeners();
  }

  void _wiFiListCallback(List<WiFiScanResult> list) {
    _data.wifiList = list.toSet();
    if (_data.currentConnect?.type == UpdateType.SUCCESS) {
      _data.wifiList
          ?.removeWhere((element) => element == _data.currentConnect?.data);
    }
    notifyListeners();
  }

  void changeSwitch(bool wifiOpen, bool ethernetOpen) async {
    if (_data.supportWiFi) {
      await netMethodChannel.enableWiFi(wifiOpen);
      _data.wifiList = null;
      _data.isWiFiOn = wifiOpen && _data.supportWiFi;
      _data.currentConnect = wifiOpen ? _data.currentConnect : null;
      if (wifiOpen) {
        netMethodChannel.scanNearbyWiFi();
      } else {
        netMethodChannel.stopScanNearbyWiFi();
      }
    }
    if (_data.supportEthernet) {
      _data.isEthernetOn = ethernetOpen;
      netMethodChannel.enableEthernet(ethernetOpen);
    }
    notifyListeners();
  }

  void connectWiFi(
      {required WiFiScanResult result,
        String? password,
        required void Function(bool) callback}) async {
    _data.currentConnect = UpdateState.loading(result);
    notifyListeners();
    bool connect =
    await netMethodChannel.connectedWiFi(result.ssid, password, true);
    if (connect) {
      _data.currentConnect = UpdateState.success(result);
      callback.call(true);
      notifyListeners();
    } else {
      _data.currentConnect = UpdateState.error(result);
      callback.call(false);
      notifyListeners();
    }
  }

  String connectedState<T>(UpdateState<T>? state) {
    if (state?.type == UpdateType.LONGING) {
      return "正在连接...";
    } else if (state?.type == UpdateType.SUCCESS) {
      return "连接成功";
    } else {
      return '连接失败';
    }
  }
}

class LinkNetwork extends StatefulWidget {
  final bool isNeedWifiSwitch; // 是否需要Wifi开关栏

  const LinkNetwork({super.key, this.isNeedWifiSwitch = false});

  @override
  State<LinkNetwork> createState() => _LinkNetwork();
}

class _LinkNetwork extends State<LinkNetwork> {
  late _LinkNetworkModel _model;

  @override
  void initState() {
    super.initState();
    _model = _LinkNetworkModel(context);
  }

  @override
  dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_LinkNetworkModel>.value(
        value: _model,
        child: Consumer<_LinkNetworkModel>(builder: (_, model, child) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isNeedWifiSwitch) Container(
                    width: 432,
                    height: model._data.currentConnect?.type == UpdateType.LONGING ? 144 : 71,
                    margin: const EdgeInsets.fromLTRB(0, 12, 0, 10),
                    decoration: const BoxDecoration(
                        color: Color(0x0DFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          left: 20,
                          top: 12,
                          child: Text("无线局域网",
                              style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 24,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none)
                          ),
                        ),
                        Positioned(
                          right: 20,
                          top: 20,
                          child: MzSwitch(
                            value: model._data.isWiFiOn,
                            onTap: (e) => model.changeSwitch(!model._data.isWiFiOn, true),
                          ),
                        ),

                        if (model._data.currentConnect?.type == UpdateType.LONGING) Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 432,
                            height: 72,
                            child: Stack(
                              children: [
                                Positioned(
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
                                  left: 20,
                                  top: 14,
                                  child: Text(model._data.currentConnect?.data.ssid ?? '--',
                                      style: const TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 20,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none)
                                  ),
                                ),
                                const Positioned(
                                  right: 64,
                                  top: 16,
                                  child: Text("连接中…",
                                      style: TextStyle(
                                          color: Color(0XFF1EA8EE),
                                          fontSize: 18,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none)
                                  ),
                                ),
                                const Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Image(
                                    width: 32,
                                    height: 32,
                                    image: AssetImage('assets/newUI/加载@1x.png'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(widget.isNeedWifiSwitch) header(model),
                  Expanded(
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                          child: ListView.builder(
                              itemCount: model.pageData.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == model.pageData.length) {
                                  // 最后一项，显示新增的内容
                                  return Container(
                                    width: 432,
                                    height: 72,
                                    color: Colors.white.withOpacity(0.05),
                                    child: const Center(
                                        child: Text(
                                          '已经到底了！',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.85)),
                                        )),
                                  );
                                } else {
                                  // 有线网络
                                  if (model.pageData[index] == 'headerTag') {
                                    return Container();
                                  }
                                  WiFiScanResult item =
                                  model.pageData[index] as WiFiScanResult;
                                  // wifi的子Item
                                  return MzCell(
                                      avatarIcon: null,
                                      rightIcon: item.auth == 'encryption'
                                          ? Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                right: 12.0),
                                            child: Image(
                                              height: 32,
                                              width: 32,
                                              image: AssetImage('assets/newUI/lock.png'),
                                            ),
                                          ),
                                          MzWiFiImage(
                                              level: item.level.toInt(),
                                              size: const Size.square(28)),
                                        ],
                                      )
                                          : null,
                                      title: item.ssid,
                                      titleSize: 18.0,
                                      hasTopBorder: false,
                                      hasBottomBorder:
                                      index + 1 != model.pageData.length,
                                      bgColor: const Color.fromRGBO(
                                          255, 255, 255, 0.05),
                                      onTap: () {
                                        if (item.auth == 'open') {
                                          // 尝试连接开放型WiFi
                                          model.connectWiFi(
                                              result: item,
                                              password: null,
                                              callback: (result) {});
                                        } else if (item.alreadyConnected) {
                                          // 尝试连接曾经的WiFi
                                          model.connectWiFi(
                                              result: item,
                                              password: null,
                                              callback: (result) {
                                                if (!result) {
                                                  showInputPasswordDialog(
                                                      item, model);
                                                }
                                              });
                                        } else {
                                          // 连接新WiFi
                                          showInputPasswordDialog(item, model);
                                        }
                                      },
                                      onLongPress: () {
                                        if (model._data.currentConnect?.type ==
                                            UpdateType.SUCCESS) {
                                          showIgnoreDialog(
                                              model._data.currentConnect!.data);
                                        }
                                      });
                                }
                              })
                      )
                  ),
                ],
              ));
        }));
  }

  Widget header(_LinkNetworkModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0, bottom: 13.0),
          child: const Text(
            '其他网络',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(255, 255, 255, 0.85),
              letterSpacing: 0,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        // Visibility(
        //     visible: model._data.currentConnect != null &&
        //         model._data.currentConnect!.type != UpdateType.ERROR,
        //     child: MzCell(
        //       avatarIcon: MzWiFiImage(
        //           level: model._data.currentConnect?.data.level.toInt() ?? 0,
        //           size: const Size.square(24)),
        //       rightIcon: model._data.currentConnect?.data.auth == 'encryption'
        //           ? const Icon(Icons.lock_outline_sharp,
        //               color: Color.fromRGBO(255, 255, 255, 0.85))
        //           : null,
        //       rightText: model.connectedState(model._data.currentConnect),
        //       title: model._data.currentConnect?.data.ssid,
        //       titleSize: 18.0,
        //       hasTopBorder: true,
        //       onLongPress: () {
        //         if (model._data.currentConnect?.type == UpdateType.SUCCESS) {
        //           showIgnoreDialog(model._data.currentConnect!.data);
        //         }
        //       },
        //       bgColor: const Color.fromRGBO(216, 216, 216, 0.1),
        //     )),
        // DecoratedBox(
        //   decoration: const BoxDecoration(
        //     border: Border(
        //         top: BorderSide(color: Color.fromRGBO(151, 151, 151, 0.3))),
        //   ),
        //   child: Padding(
        //       padding: const EdgeInsets.fromLTRB(36, 4, 36, 4),
        //       child: Row(
        //           mainAxisAlignment: MainAxisAlignment.start,
        //           children: const [])),
        // )
      ],
    );
  }

  void showInputPasswordDialog(WiFiScanResult result, _LinkNetworkModel model,
      [bool connectedError = false]) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InputPasswordDialog(
            connectedError: connectedError,
            result: result,
            confirmAction: (_, password) {
              model.connectWiFi(
                  result: result,
                  password: password,
                  callback: (suc) {
                    if (!suc) {
                      // 连接失败继续显示弹窗
                      showInputPasswordDialog(result, model, true);
                    }
                  });
            },
          );
        });
  }

  void showIgnoreDialog(WiFiScanResult result) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return IgnorePasswordDialog(result: result);
      },
    );
  }
}

class IgnorePasswordDialog extends StatelessWidget {
  final WiFiScanResult result;

  const IgnorePasswordDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 432,
        height: 232,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(37, 48, 71, 0.90),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '忽略“${result.ssid}”',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MzButton(
                    width: 152,
                    height: 56,
                    borderRadius: 29.0,
                    backgroundColor: Color.fromRGBO(255, 255, 255, 0.10),
                    borderColor: Color.fromRGBO(255, 255, 255, 0.10),
                    borderWidth: 1,
                    text: '取消',
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                MzButton(
                  width: 152,
                  height: 56,
                  borderRadius: 29.0,
                  backgroundColor: const Color(0xFF0092DC),
                  borderColor: const Color(0xFF0092DC),
                  borderWidth: 1,
                  text: '确认',
                  onPressed: () {
                    netMethodChannel.forgetWiFi(result.ssid, result.bssid);
                    Navigator.pop(context);
                  },
                )
                // Expanded(
                //   flex: 1,
                //   child: TextButton(
                //     style: ButtonStyle(
                //         elevation: MaterialStateProperty.all(0),
                //         backgroundColor:
                //             MaterialStateProperty.all(const Color(0xff282828)),
                //         shape: MaterialStateProperty.all(
                //             const RoundedRectangleBorder())),
                //     onPressed: () => Navigator.pop(context),
                //     child: const Text(
                //       '取消',
                //       style: TextStyle(color: Colors.white, fontSize: 18),
                //     ),
                //   ),
                // ),
                // Expanded(
                //   flex: 1,
                //   child: TextButton(
                //     style: ButtonStyle(
                //         elevation: MaterialStateProperty.all(0),
                //         backgroundColor:
                //             MaterialStateProperty.all(const Color(0xff267AFF)),
                //         shape: MaterialStateProperty.all(
                //             const RoundedRectangleBorder())),
                //     onPressed: () {
                //       netMethodChannel.forgetWiFi(result.ssid, result.bssid);
                //       Navigator.pop(context);
                //     },
                //     child: const Text(
                //       '确定',
                //       style: TextStyle(color: Colors.white, fontSize: 18),
                //     ),
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InputPasswordDialog extends StatefulWidget {
  final WiFiScanResult result;
  final void Function(WiFiScanResult result, String password) confirmAction;
  final bool connectedError;

  const InputPasswordDialog(
      {super.key,
        required this.result,
        required this.confirmAction,
        required this.connectedError});

  @override
  State<StatefulWidget> createState() {
    return _InputPasswordDialogState();
  }
}

class _InputPasswordDialogState extends State<InputPasswordDialog> {
  var closeEye = true;
  final TextEditingController _nameController = TextEditingController();

  _InputPasswordDialogState();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 435,
        height: 292,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(37, 48, 71, 0.90),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('输入“${widget.result.ssid}”的密码',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24)),
                        if (widget.connectedError)
                          const Text(
                            '密码错误！',
                            style: TextStyle(color: Color(0xFFFF1111), fontSize: 18),
                          ),
                      ],
                    ))),
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 348,
                      height: 56,
                      child: Container(
                        width: 348,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(216, 216, 216, 0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                          border:
                          widget.connectedError ? Border.all(color: const Color.fromRGBO(255, 0, 0, 1)) : null,
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Text('密码',
                                    style: TextStyle(fontSize: 18.0)),
                                Container(
                                    margin: const EdgeInsets.only(
                                        left: 10.0, right: 20.0),
                                    child: const Text('|',
                                        style: TextStyle(fontSize: 18.0))),
                              ],
                            ),
                            Expanded(
                                child: TextField(
                                  style: const TextStyle(fontSize: 18.0),
                                  controller: _nameController,
                                  obscureText: closeEye,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none),
                                )),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    closeEye = !closeEye;
                                  });
                                },
                                icon: closeEye
                                    ? Image.asset(
                                    'assets/imgs/icon/eye-close.png')
                                    : Image.asset(
                                    'assets/imgs/icon/eye-open.png'))
                          ],
                        ),
                      ),
                    ))),
            Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MzButton(
                        width: 152,
                        height: 56,
                        borderRadius: 29.0,
                        backgroundColor: Color.fromRGBO(255, 255, 255, 0.10),
                        borderColor: Color.fromRGBO(255, 255, 255, 0.10),
                        borderWidth: 1,
                        text: '取消',
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    MzButton(
                      width: 152,
                      height: 56,
                      borderRadius: 29.0,
                      backgroundColor: const Color(0xFF0092DC),
                      borderColor: const Color(0xFF0092DC),
                      borderWidth: 1,
                      text: '加入',
                      onPressed: () {
                        if (StrUtils.isNullOrEmpty(_nameController.text) ||
                            _nameController.text.length < 8) {
                          TipsUtils.toast(content: "请输入8位密码");
                        } else {
                          widget.confirmAction
                              .call(widget.result, _nameController.text);
                          Navigator.pop(context);
                        }
                      },
                    )
                    // Expanded(
                    //     child: TextButton(
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //   },
                    //   style: ButtonStyle(
                    //       backgroundColor: MaterialStateProperty.all(
                    //           const Color.fromRGBO(40, 40, 40, 1)),
                    //       shape: MaterialStateProperty.all(
                    //           const RoundedRectangleBorder())),
                    //   child: const Text(
                    //     '取消',
                    //     style: TextStyle(color: Colors.white, fontSize: 18),
                    //   ),
                    // )),
                    // Container(width: 1),
                    // Expanded(
                    //     child: TextButton(
                    //   style: ButtonStyle(
                    //       backgroundColor: MaterialStateProperty.all(
                    //           const Color(0xff267AFF)),
                    //       shape: MaterialStateProperty.all(
                    //           const RoundedRectangleBorder())),
                    //   onPressed: () {
                    //     if (StrUtils.isNullOrEmpty(_nameController.text) ||
                    //         _nameController.text.length < 8) {
                    //       TipsUtils.toast(content: "请输入8位密码");
                    //     } else {
                    //       widget.confirmAction
                    //           .call(widget.result, _nameController.text);
                    //       Navigator.pop(context);
                    //     }
                    //   },
                    //   child: const Text(
                    //     '加入',
                    //     style: TextStyle(color: Colors.white, fontSize: 18),
                    //   ),
                    // )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
