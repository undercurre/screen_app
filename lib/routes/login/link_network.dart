// import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:wifi_iot/wifi_iot.dart';
// import 'package:wifi_scan/wifi_scan.dart';

import '../../common/index.dart';
import '../../models/index.dart';
import '../../states/index.dart';
import '../../widgets/index.dart';

class _LinkNetwork extends State<LinkNetwork> {
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  // ConnectivityResult _connectionResult = ConnectivityResult.none;

  // StreamSubscription<List<WiFiAccessPoint>>? subscription;
  // String? _sPreviousAPSSID = "";
  // String? _sPreviousPreSharedKey = "";

  bool _isWifiOn = false;
  // bool _isConnected = false;
  // bool _isWiFiAPEnabled = false;
  // bool _isWiFiAPSSIDHidden = false;
  // bool _isWifiAPSupported = true;
  // bool _isWifiEnableOpenSettings = false;
  // bool _isWifiDisableOpenSettings = false;

  String staDefaultSsid = "STA_SSID";
  String staDefaultPassword = "STA_PASSWORD";
  // NetworkSecurity staDefaultSecurity = NetworkSecurity.WPA;

  String apDefaultSsid = "xyh_wifi";
  String apDefaultPassword = "12345678";

  @override
  Widget build(BuildContext context) {
    var wifiSwitch = Cell(
        title: '无线局域网',
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        titleSize: 24.0,
        hasTopBorder: true,
        hasSwitch: true,
        initSwitchValue: _isWifiOn,
        onSwitch: changeWifiSwitch
    );

    var wifiListTitle = DecoratedBox(
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
                ])));

    var list = <String>['loadingTag'];

    for (var i = 0; i < 20; i++) {
      list.insert(list.length - 1, 'test: $i');
    }

    var wifiList = ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          if (list[index] == "loadingTag") {
            //已经加载了100条数据，不再获取数据。
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "没有更多了",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Listener(
              onPointerDown: (event) {
                logger.i("item: $index  onPointerDown, $event");
                var userModel = context.read<UserModel>();

                userModel.user = User.fromJson({"name": "test $index"});
              },
              child: Cell(
                avatarIcon: const Icon(
                  Icons.wifi,
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  size: 24.0,
                ),
                rightIcon: const Icon(Icons.lock_outline_sharp, color: Color.fromRGBO(255, 255, 255, 0.85)),
                title: 'Midea-Smart: ${list[index]}',
                titleSize: 18.0,
                hasTopBorder: true,
                bgColor: const Color.fromRGBO(216, 216, 216, 0.1),
              ));
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wifiSwitch,
        wifiListTitle,
        Expanded(
          child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(216,216,216, 0.1)
              ),
              child: wifiList,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // checkConnectivity();
    //
    // WiFiForIoTPlugin.isEnabled().then((val) {
    //   debugPrint('isEnabled: $val');
    //   _isWifiOn = val;
    // });
    //
    // WiFiForIoTPlugin.isConnected().then((val) {
    //   debugPrint('isConnected: $val');
    //   _isConnected = val;
    // });
    //
    // WiFiForIoTPlugin.isWiFiAPEnabled().then((val) {
    //   debugPrint('isWiFiAPEnabled: $val');
    //   _isWiFiAPEnabled = val;
    // }).catchError((val) {
    //   _isWifiAPSupported = false;
    // });
  }

  @override
  dispose() {
    super.dispose();

    // 取消网络连接状态监听
    // _connectivitySubscription.cancel();
    // subscription?.cancel();
  }

  void changeWifiSwitch(bool value) {
    debugPrint('onChanged: $value');
    setState(() {
      _isWifiOn = value;
      // _startScan();
    });
  }

  // void _startScan() async {
  //   // check platform support and necessary requirements
  //   final can = await WiFiScan.instance.canStartScan(askPermissions: true);
  //   switch(can) {
  //     case CanStartScan.yes:
  //     // start full scan async-ly
  //       final isScanning = await WiFiScan.instance.startScan();
  //
  //       final accessPoints = await WiFiScan.instance.getScannedResults();
  //
  //       subscription = WiFiScan.instance.onScannedResultsAvailable.listen((results) {
  //         // update accessPoints
  //         logger.i('onScannedResultsAvailable: $results');
  //       });
  //
  //       logger.i('_startScan: $isScanning \n '
  //           'accessPoints: ${accessPoints}');
  //       //...
  //       break;
  //   // ... handle other cases of CanStartScan values
  //   }
  // }
  //
  //
  // storeAndConnect(String psSSID, String psKey) async {
  //   await storeAPInfos();
  //   await WiFiForIoTPlugin.setWiFiAPSSID(psSSID);
  //   await WiFiForIoTPlugin.setWiFiAPPreSharedKey(psKey);
  // }
  //
  // storeAPInfos() async {
  //   String? sAPSSID;
  //   String? sPreSharedKey;
  //
  //   try {
  //     sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
  //   } on PlatformException {
  //     sAPSSID = "";
  //   }
  //
  //   try {
  //     sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
  //   } on PlatformException {
  //     sPreSharedKey = "";
  //   }
  //
  //   setState(() {
  //     _sPreviousAPSSID = sAPSSID;
  //     _sPreviousPreSharedKey = sPreSharedKey;
  //   });
  // }
  //
  // restoreAPInfos() async {
  //   WiFiForIoTPlugin.setWiFiAPSSID(_sPreviousAPSSID!);
  //   WiFiForIoTPlugin.setWiFiAPPreSharedKey(_sPreviousPreSharedKey!);
  // }
  //
  // // [sAPSSID, sPreSharedKey]
  // Future<List<String>> getWiFiAPInfos() async {
  //   String? sAPSSID;
  //   String? sPreSharedKey;
  //
  //   try {
  //     sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
  //   } on Exception {
  //     sAPSSID = "";
  //   }
  //
  //   try {
  //     sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
  //   } on Exception {
  //     sPreSharedKey = "";
  //   }
  //
  //   return [sAPSSID!, sPreSharedKey!];
  // }
  //
  // Future<WIFI_AP_STATE?> getWiFiAPState() async {
  //   int? iWiFiState;
  //
  //   WIFI_AP_STATE? wifiAPState;
  //
  //   try {
  //     iWiFiState = await WiFiForIoTPlugin.getWiFiAPState();
  //   } on Exception {
  //     iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index;
  //   }
  //
  //   if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_DISABLING.index) {
  //     wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLING;
  //   } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_DISABLED.index) {
  //     wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;
  //   } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLING.index) {
  //     wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLING;
  //   } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED.index) {
  //     wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
  //   } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index) {
  //     wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED;
  //   }
  //
  //   return wifiAPState!;
  // }
  //
  // Future<List<APClient>> getClientList(
  //     bool onlyReachables, int reachableTimeout) async {
  //   List<APClient> htResultClient;
  //
  //   try {
  //     htResultClient = await WiFiForIoTPlugin.getClientList(
  //         onlyReachables, reachableTimeout);
  //   } on PlatformException {
  //     htResultClient = <APClient>[];
  //   }
  //
  //   return htResultClient;
  // }
  //
  // Future<List<WifiNetwork>> loadWifiList() async {
  //   List<WifiNetwork> htResultNetwork;
  //   try {
  //     htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
  //   } on PlatformException {
  //     htResultNetwork = <WifiNetwork>[];
  //   }
  //
  //   return htResultNetwork;
  // }
  //
  // isRegisteredWifiNetwork(String ssid) async {
  //   bool bIsRegistered;
  //
  //   try {
  //     bIsRegistered = await WiFiForIoTPlugin.isRegisteredWifiNetwork(ssid);
  //   } on PlatformException {
  //     bIsRegistered = false;
  //   }
  // }
  //
  // void showClientList() async {
  //   /// Refresh the list and show in console
  //   getClientList(false, 300).then((val) => val.forEach((oClient) {
  //     print("************************");
  //     print("Client :");
  //     print("ipAddr = '${oClient.ipAddr}'");
  //     print("hwAddr = '${oClient.hwAddr}'");
  //     print("device = '${oClient.device}'");
  //     print("isReachable = '${oClient.isReachable}'");
  //     print("************************");
  //   }));
  // }
  //
  // /// 初始化网络设置
  // void checkConnectivity() async {
  //   final Connectivity connectivity = Connectivity();
  //
  //   _connectionResult = await connectivity.checkConnectivity();
  //
  //   // 网络连接状态变化监听
  //   _connectivitySubscription =
  //       connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  //
  //   final info = NetworkInfo();
  //
  //   var wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
  //   var wifiIP = await info.getWifiIP(); // 192.168.1.1
  //   var wifiName = await info.getWifiName(); // FooNetwork
  //
  //   logger.i('_connectionResult: $_connectionResult \n '
  //       'wifiBSSID:$wifiBSSID  \n '
  //       'wifiIP:$wifiIP  \n '
  //       'wifiName:$wifiName');
  // }
  //
  // /// 更新网络连接状态
  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   setState((){
  //     debugPrint('_connectionResult: $result');
  //     _connectionResult = result;
  //   });
  // }
}

class LinkNetwork extends StatefulWidget {
  const LinkNetwork({super.key});

  @override
  State<LinkNetwork> createState() => _LinkNetwork();
}
