// 说明：网络连接

// _LinkNetwork页面的 dataclass
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  DateTime? lastTime;

  List<dynamic> get pageData => <dynamic>[
    'headerTag',
    if (_data.supportWiFi && _data.isWiFiOn) ...?_data.wifiList,
    'lastTag'
  ];

  _LinkNetworkModel(BuildContext context) {
    _data = _LinkNetworkData(isWiFiOn: false, isEthernetOn: false);
    init();
    // Timer(const Duration(milliseconds: 250), () async {
    //   init();
    // });
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
      _data.wifiList?.removeWhere((element) => element.bssid == state.wiFiScanResult?.bssid);
    } else {
      _data.currentConnect = null;
    }
    notifyListeners();
  }

  void _wiFiListCallback(List<WiFiScanResult> list) {
    if (lastTime != null) {
      if(DateTime.now().millisecondsSinceEpoch - lastTime!.millisecondsSinceEpoch < 5000) {
        return;
      }
    }
    lastTime = DateTime.now();
    if (_data.currentConnect != null && _data.currentConnect?.type == UpdateType.SUCCESS) {
      list.removeWhere((element) => element.bssid == _data.currentConnect?.data.bssid);
    }
    _data.wifiList = list.toSet();
    notifyListeners();
  }

  void changeSwitch(bool wifiOpen, bool ethernetOpen) async {
    if (_data.supportWiFi) {
      await netMethodChannel.enableWiFi(wifiOpen);
      _data.wifiList = null;
      _data.isWiFiOn = wifiOpen && _data.supportWiFi;
      _data.currentConnect = wifiOpen?_data.currentConnect : null;
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
                itemCount: model.pageData.length,
                itemBuilder: (BuildContext context, int index) {
                  if (model.pageData[index] == 'headerTag') {
                    return switchBar(model);
                  } else if(model.pageData[index] == 'lastTag') {
                    if (model.pageData.length > 2) {
                      return lastTag();
                    }
                  } else {
                    WiFiScanResult item = model.pageData[index] as WiFiScanResult;
                    return MzCell(
                        rightIcon: Row(
                          children: [
                            if (item.auth == 'encryption') const Padding(
                              padding: EdgeInsets.only(right: 12.0),
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
                        ),
                        title: item.ssid,
                        titleMaxLines: 1,
                        titleSize: 20,
                        titleMaxWidth: 260,
                        hasBottomBorder: true,
                        topLeftRadius: index == 1 ? 16 : 0,
                        topRightRadius: index == 1 ? 16 : 0,
                        bgColor: const Color.fromRGBO(255, 255, 255, 0.05),
                        onTap: () {
                          if (item.auth == 'open') {
                            // 尝试连接开放型WiFi
                            model.connectWiFi(result: item, password: null, callback: (result) {});
                          } else if (item.alreadyConnected) {
                            // 尝试连接曾经的WiFi
                            model.connectWiFi(
                                result: item,
                                password: null,
                                callback: (result) {
                                  if (!result) {
                                    showInputPasswordDialog(item, model);
                                  }
                                });
                          } else {
                            // 连接新WiFi
                            showInputPasswordDialog(item, model);
                          }
                        }
                    );
                  }
                }
            ),
          );
        })
    );
  }

  Widget switchBar(_LinkNetworkModel model) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: const Color(0x0CFFFFFF),
              borderRadius: BorderRadius.circular(16)
          ),
          child: Column(
            children: [
              MzCell(
                title: "无线局域网",
                titleSize: 24,
                titleColor: const Color(0xFFFFFFFF),
                bgColor: Colors.transparent,
                hasBottomBorder: model._data.currentConnect?.type == UpdateType.LONGING
                    || model._data.currentConnect?.type == UpdateType.SUCCESS? true : false,
                rightSlot: MzSwitch(
                  value: model._data.isWiFiOn,
                  onTap: (e) => model.changeSwitch(!model._data.isWiFiOn, true),
                ),
              ),
              if(model._data.currentConnect?.type == UpdateType.LONGING
                  || model._data.currentConnect?.type == UpdateType.SUCCESS)
                MzCell(
                  title: model._data.currentConnect?.data.ssid ?? "",
                  titleSize: 20,
                  titleMaxWidth: 230,
                  titleMaxLines: 1,
                  titleColor: const Color(0xD8FFFFFF),
                  bgColor: Colors.transparent,
                  rightSlot: model._data.currentConnect?.type == UpdateType.LONGING?
                  const CupertinoActivityIndicator(radius: 12) :
                  Row(
                    children: [
                      if (model._data.currentConnect?.data.auth == 'encryption') const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Image(
                          height: 32,
                          width: 32,
                          image: AssetImage('assets/newUI/lock.png'),
                        ),
                      ),
                      MzWiFiImage(
                          level: model._data.currentConnect?.data.level.toInt() ?? 0,
                          size: const Size.square(28)),
                    ],
                  ),
                  tag: model._data.currentConnect?.type == UpdateType.SUCCESS? "已连接" : null,
                  onLongPress: () {
                    if (model._data.currentConnect?.type == UpdateType.SUCCESS) {
                      showIgnoreDialog(model._data.currentConnect!.data);
                    }
                  },
                ),
            ],
          ),
        ),

        Container(
          width: 432,
          height: 62,
          margin: const EdgeInsets.only(left: 16),
          alignment: Alignment.centerLeft,
          child: const Text(
            '可用网络',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(255, 255, 255, 0.85),
            ),
          ),
        )
      ],
    );
  }

  Widget lastTag() {
    return Container(
      width: 432,
      height: 44,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
      ),
      margin: const EdgeInsets.only(bottom: 40),
      alignment: Alignment.center,
      child: const Text(
        '已经到底了！',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(255, 255, 255, 0.85)
        ),
      ),
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
          color: Color(0xFF494E59),
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
                    backgroundColor: const Color(0xFF939AA6),
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    isShowShadow: false,
                    borderRadius: 29.0,
                    text: '取消',
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                MzButton(
                  width: 152,
                  height: 56,
                  borderRadius: 29.0,
                  backgroundColor: const Color(0xFF267AFF),
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  isShowShadow: false,
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
  bool isLengthOk = false;

  _InputPasswordDialogState();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 435,
        height: 240,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        decoration: const BoxDecoration(
          color: Color(0xFF494E59),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('输入“${toLimitString(widget.result.ssid)}”的密码',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24)),
                        if (widget.connectedError)
                          const Text(
                            '密码错误！',
                            style: TextStyle(color: Color(0xFFFF1111), fontSize: 16),
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
                                  keyboardType: TextInputType.visiblePassword,
                                  autocorrect: false,
                                  style: const TextStyle(fontSize: 18.0),
                                  controller: _nameController,
                                  obscureText: closeEye,
                                  maxLines: 1,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  onChanged: (str) {
                                    if (str.length == 7) {
                                      setState(() {
                                        isLengthOk = false;
                                      });
                                    } else if (str.length == 8) {
                                      setState(() {
                                        isLengthOk = true;
                                      });
                                    }
                                  },
                                )
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    closeEye = !closeEye;
                                  });
                                },
                                icon: closeEye
                                    ? Image.asset(
                                    'assets/newUI/eyeClose.png')
                                    : Image.asset(
                                    'assets/newUI/eyeOpen.png'))
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
                        backgroundColor: const Color(0xFF939AA6),
                        borderColor: Colors.transparent,
                        borderWidth: 0,
                        isShowShadow: false,
                        text: '取消',
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    MzButton(
                      width: 152,
                      height: 56,
                      borderRadius: 29.0,
                      backgroundColor: isLengthOk ? const Color(0xFF267AFF) : const Color(0xFF4065A7),
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      isShowShadow: false,
                      isClickable: (StrUtils.isNullOrEmpty(_nameController.text) ||
                          _nameController.text.length < 8)?false:true,
                      text: '加入',
                      textColor: isLengthOk ? const Color(0xFFFFFFFF) : const Color(0xC8FFFFFF),
                      onPressed: () {
                        if (StrUtils.isNullOrEmpty(_nameController.text) ||
                            _nameController.text.length < 8) {
                          // TipsUtils.toast(content: "请输入8位密码");
                        } else {
                          widget.confirmAction
                              .call(widget.result, _nameController.text);
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  String toLimitString(String str) {
    if(str.isNotEmpty) {
      if(str.length < 13) {
        return str;
      } else {
        return '${str.substring(0, 9)}...${str.substring(str.length - 1)}';
      }
    }
    return str;
  }
}
