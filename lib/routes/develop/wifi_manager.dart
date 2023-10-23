import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/channel/models/manager_devic.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../common/meiju/meiju_global.dart';
import '../../common/system.dart';

final List<FindWiFiResult> list = <FindWiFiResult>[];

class WiFiDeviceManager extends StatelessWidget {
  const WiFiDeviceManager({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WiFi设备测试页面"),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.init(
                      dotenv.get("IOT_URL"),
                      MeiJuGlobal.token?.accessToken ?? "",
                      dotenv.get("HTTP_SIGN_SECRET"),
                      MeiJuGlobal.token?.seed ?? "",
                      MeiJuGlobal.token?.key ?? "",
                      System.deviceId ?? "",
                      MeiJuGlobal.token?.uid ?? "",
                      dotenv.get("IOT_APP_COUNT"),
                      dotenv.get("IOT_SECRET"),
                      dotenv.get("IOT_REQUEST_HEADER_DATA_KEY")
                  );
                  list.clear();
                },
                child: const Text("初始化SDK"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.reset();
                  list.clear();
                },
                child: const Text("重置SDK"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  // 1.判断wifi是否启动
                  netMethodChannel.wifiIsOpen().then((value) {
                    if(value) {
                      // 2.启动发现wifi设备
                      deviceManagerChannel.setFindWiFiCallback((result) {
                        print(result);
                        list.addAll(result);
                      });
                      deviceManagerChannel.findWiFi();
                    } else {
                      print("wifi还没启动，请跳转到wifi设置页，启动wifi");
                    }
                  });
                },
                child: const Text("开始扫描WiFi设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.stopFindWiFi();
                  deviceManagerChannel.setFindWiFiCallback(null);
                },
                child: const Text("停止扫描WiFi设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {

                  // 1.判断当前是否已经连上wifi
                  if(NetUtils.getNetState() != null && NetUtils.getNetState()!.type == NetType.wifi) {
                    // 2.，查询本地有记录连接wifi的密码
                    NetUtils.checkConnectedWiFiRecord().then((value) {
                      if(value != null) {
                        // 3. 进行绑定
                        deviceManagerChannel.setBindWiFiCallback((result) {
                          print(result);
                        });
                        deviceManagerChannel.binWiFi(
                          value.ssid,
                          value.bssid,
                          value.password,
                          value.encryptType,
                          MeiJuGlobal.homeInfo?.homegroupId ?? "",
                          MeiJuGlobal.roomInfo?.roomId ?? "",
                          list // 指定需要绑定的wifi设备
                        );
                      } else {
                        print("当前已连接wifi。但没有查到当前的wifi的密码，希望用户重新输入当前wifi的密码");
                      }
                    });
                  } else {
                    print("请跳转到WiFi设置页面连接wifi");
                  }

                },
                child: const Text("绑定扫描到的WiFi设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.stopBindWiFi();
                },
                child: const Text("停止绑定扫描到的WiFi设备"),
              ),
            ),
          ]),
    );
  }

}