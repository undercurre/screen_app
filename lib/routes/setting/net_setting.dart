import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';

import '../../channel/index.dart';
import '../../channel/models/net_state.dart';
import '../../channel/models/wifi_scan_result.dart';
import '../../widgets/index.dart';
import './architecture.dart';

class NetSettingPage extends StatefulWidget {
  const NetSettingPage({Key? key});

  @override
  _NetSettingPageState createState() => _NetSettingPageState();
}

class _NetSettingPageState extends State<NetSettingPage> {

  @override
  void initState() {
    super.initState();
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
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 60.0,
                    icon: Image.asset(
                      "assets/imgs/setting/fanhui.png",
                    ),
                  ),
                  const Text("网络设置",
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 30.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        'Home',
                      );
                    },
                    iconSize: 60.0,
                    icon: Image.asset(
                      "assets/imgs/setting/zhuye.png",
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: LinkNetwork(),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(NetSettingPage oldWidget) {
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

abstract class IInputPasswordDialog {
  void showInputPasswordDialog(WiFiScanResult result);
}

// _LinkNetwork页面的 dataclass
class _LinkNetworkData {
  bool supportEthernet = true; // 是否支持控制以太网连接
  bool supportWiFi = true; // 是否支持控制WiFi
  bool isWiFiOn; // WiFi 是否打开
  bool isEthernetOn; // 有线以太网 是否打开
  UpdateState<WiFiScanResult>? currentConnect; // 当前连接状态
  List<WiFiScanResult>? wifiList; // wifi 列表数据
  _LinkNetworkData({required this.isWiFiOn, required this.isEthernetOn});
}

// _LinkNetwork 界面的 业务逻辑层
class _LinkNetworkModel with ChangeNotifier {
  late _LinkNetworkData _data;
  late BuildContext _context;

  List<dynamic> get pageData => <dynamic>['headerTag', if(_data.supportWiFi && _data.isWiFiOn)...?_data.wifiList];

  _LinkNetworkModel(BuildContext context) {
    _data = _LinkNetworkData(isWiFiOn: true, isEthernetOn: false);
    _context = context;
    init();
  }

  void init() async {
    bool supportWifi = await netMethodChannel.supportWiFiControl();
    bool supportEthernet = await netMethodChannel.supportEthernetControl();
    _data.supportWiFi = supportWifi;
    _data.supportEthernet = supportEthernet;
    if(supportWifi) {
      netMethodChannel.scanNearbyWiFi();
      netMethodChannel.registerScanWiFiCallBack(_wiFiListCallback);
    }
    netMethodChannel.startObserverNetState();
    netMethodChannel.registerNetChangeCallBack(_connectStateCallback);
    notifyListeners();
  }


  @override
  void dispose() {
    super.dispose();
    netMethodChannel.stopObserverNetState();
    netMethodChannel.unregisterNetChangeCallBack(_connectStateCallback);
    netMethodChannel.unregisterScanWiFiCallBack(_wiFiListCallback);
  }

  void _connectStateCallback(NetState state) {
    int ethernetState = state.ethernetState;
    int wifiState = state.wifiState;
    if(wifiState == 0) {
      _data.currentConnect = null;
    } else if(wifiState == 2) {
      _data.currentConnect = UpdateState.success(state.wiFiScanResult!);
    }
    notifyListeners();
  }

  void _wiFiListCallback(List<WiFiScanResult> list) {
    _data.wifiList = list;
    notifyListeners();
  }

  void changeSwitch(bool wifiOpen, bool ethernetOpen) {
    debugPrint('wifiOpen = $wifiOpen ethernetOpen = $ethernetOpen');
    if(_data.supportWiFi) {
      netMethodChannel.enableWiFi(wifiOpen);
      _data.wifiList = null;
      _data.isWiFiOn = wifiOpen && _data.supportWiFi;
      _data.currentConnect = wifiOpen ? _data.currentConnect : null;
    }
    if(_data.supportEthernet) {
      _data.isEthernetOn = ethernetOpen;
      netMethodChannel.enableEthernet(ethernetOpen);
    }
    notifyListeners();
  }

  void connectWiFi({required WiFiScanResult result, String? password, required void Function(bool) callback}) async {
    _data.currentConnect = UpdateState.loading(result);
    notifyListeners();
    bool connect = await netMethodChannel.connectedWiFi(result.ssid, password, true);
    if(connect) {
      debugPrint("连接成功");
      _data.currentConnect = UpdateState.success(result);
      callback.call(true);
      notifyListeners();
    } else {
      debugPrint("连接失败");
      _data.currentConnect = UpdateState. error(result);
      callback.call(false);
      notifyListeners();
    }
  }

}

class _LinkNetwork extends State<LinkNetwork> {
  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  String connectedState<T>(UpdateState<T>? state) {
    if (state?.type == Type.LONGING) {
      return "正在连接...";
    } else if (state?.type == Type.SUCCESS) {
      return "连接成功";
    } else {
      return '连接失败';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('***** link_network.dart-build *******');

    return ChangeNotifierProvider<_LinkNetworkModel>.value(
        value: _LinkNetworkModel(context),
        child: Consumer<_LinkNetworkModel>(
            builder: (_, model, child) {

              return Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(216, 216, 216, 0.1)),
                    child: ListView.builder(
                        itemCount: model.pageData.length,
                        itemBuilder: (BuildContext context, int index) {
                          // 有线网络
                          if (model.pageData[index] == 'headerTag') {
                            return header(model);
                          }
                          WiFiScanResult item =
                              model.pageData[index] as WiFiScanResult;
                          // wifi的子Item
                          return MzCell(
                            avatarIcon: const Icon(
                              Icons.wifi,
                              color: Color.fromRGBO(255, 255, 255, 0.85),
                              size: 24.0,
                            ),
                            rightIcon: const Icon(Icons.lock_outline_sharp,
                                color: Color.fromRGBO(255, 255, 255, 0.85)),
                            title: item.ssid,
                            titleSize: 18.0,
                            hasTopBorder: true,
                            bgColor: const Color.fromRGBO(216, 216, 216, 0.1),
                            onTap: () {
                              if(item.auth == 'open') {
                                // 尝试连接开放型WiFi
                                model.connectWiFi(
                                  result: item,
                                  password: null,
                                  callback: (result) {}
                                );
                              } else if(item.alreadyConnected) {
                                // 尝试连接曾经的WiFi
                                model.connectWiFi(
                                    result: item,
                                    password: null,
                                    callback: (result) {
                                      if(!result) {
                                        showInputPasswordDialog(item, model);
                                      }
                                    }
                                );
                              } else {
                                // 连接新WiFi
                                showInputPasswordDialog(item, model);
                              }
                            },
                          );
                        }),
                  ),
              );
            }));
  }

  Widget header(_LinkNetworkModel model) {
    debugPrint(
        " 11111 wifiOn=${model._data.isWiFiOn} etherOn=${model._data.isEthernetOn}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
            visible: model._data.supportEthernet,
            child: MzCell(
                key: UniqueKey(),
                title: '有线网络',
                titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
                titleSize: 24.0,
                hasTopBorder: true,
                hasSwitch: true,
                initSwitchValue: model._data.isEthernetOn,
                onSwitch: (open) => model.changeSwitch(!open, open))),
        Visibility(
            visible: model._data.supportWiFi,
            child: MzCell(
                key: UniqueKey(),
                title: '无线局域网',
                titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
                titleSize: 24.0,
                hasTopBorder: true,
                hasSwitch: true,
                initSwitchValue: model._data.isWiFiOn,
                onSwitch: (open) => model.changeSwitch(open, !open))),
        Visibility(
            visible: model._data.currentConnect != null &&
                model._data.currentConnect!.type != Type.ERROR,
            child: MzCell(
              avatarIcon: const Icon(
                Icons.wifi,
                color: Color.fromRGBO(255, 255, 255, 0.85),
                size: 24.0,
              ),
              rightIcon: model._data.currentConnect?.data.auth == 'encryption'
                  ? const Icon(Icons.lock_outline_sharp,
                      color: Color.fromRGBO(255, 255, 255, 0.85))
                  : null,
              rightText: connectedState(model._data.currentConnect),
              title: model._data.currentConnect?.data.ssid,
              titleSize: 18.0,
              hasTopBorder: true,
              bgColor: const Color.fromRGBO(216, 216, 216, 0.1),
            )),
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(color: Color.fromRGBO(151, 151, 151, 0.3))),
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 4, 36, 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('其他网络',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.68),
                          fontSize: 13.0,
                          fontFamily: "PingFangSC-Regular",
                          decoration: TextDecoration.none,
                        )),
                  ])),
        )
      ],
    );
  }

  void showInputPasswordDialog(WiFiScanResult result, _LinkNetworkModel model) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InputPasswordDialog(
            result: result,
            confirmAction: (_, password) {
              model.connectWiFi(
                result: result,
                password: password,
                callback: (suc) {
                  if(suc) {
                    TipsUtils.toast(content: "连接成功");
                  } else {
                    // 连接失败继续显示弹窗
                    showInputPasswordDialog(result, model);
                  }
                }
              );
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
        return  IgnorePasswordDialog(result: result);
      },
    );
  }
}

class LinkNetwork extends StatefulWidget {
  const LinkNetwork({super.key});

  @override
  State<LinkNetwork> createState() => _LinkNetwork();
}

class IgnorePasswordDialog extends StatelessWidget {
  final WiFiScanResult result;
  const IgnorePasswordDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width:423,
        height: 204,
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
                )
            ),
            Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(40, 40, 40, 1)),
                            shape: MaterialStateProperty.all(const RoundedRectangleBorder())),
                        onPressed: (){},
                        child: const Text('取消', style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(40, 40, 40, 1)),
                          shape: MaterialStateProperty.all(const RoundedRectangleBorder())),
                      onPressed: (){},
                      child: const Text('确定', style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),)
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

class InputPasswordDialog extends StatefulWidget {
  final WiFiScanResult result;
  void Function(WiFiScanResult result, String password) confirmAction;

  InputPasswordDialog({super.key, required this.result, required this.confirmAction});

  @override
  State<StatefulWidget> createState() {
    return _InputPasswordDialogState();
  }
}

class _InputPasswordDialogState extends State<InputPasswordDialog> {
  var obscrue = true;
  final TextEditingController _nameController = TextEditingController();
  _InputPasswordDialogState();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 423,
        height: 204,
        color: const Color(0xff1b1b1b),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: Text('输入“${widget.result.ssid}”的密码',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24)))),
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 357,
                      height: 50,
                      child: Container(
                        decoration:
                            BoxDecoration(color: Color.fromRGBO(40, 40, 40, 1)),
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('密码 '),
                            Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  obscureText: obscrue,
                                  maxLines: 1,
                                  decoration: InputDecoration(border: InputBorder.none),
                                )),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscrue = !obscrue;
                                  });
                                },
                                icon: obscrue ? Image.asset('assets/imgs/icon/eye-close.png') : Image.asset('assets/imgs/icon/eye-open.png'))
                          ],
                        ),
                      ),
                    ))),
            Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(40, 40, 40, 1))),
                          child: const Text('取消', style: TextStyle(color: Colors.white, fontSize: 18),),
                      )),
                      Container(width: 1),
                      Expanded(
                          child: TextButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(40, 40, 40, 1))),
                          onPressed: () {
                            if(StrUtils.isNullOrEmpty(_nameController.text) || _nameController.text.length < 8) {
                              TipsUtils.toast(content: "请输入8位密码");
                            } else {
                              widget.confirmAction.call(widget.result, _nameController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('加入', style: TextStyle(color: Colors.white, fontSize: 18),),
                      )),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
