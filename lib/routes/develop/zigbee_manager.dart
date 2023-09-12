import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/channel/models/manager_devic.dart';
import 'package:screen_app/widgets/util/net_utils.dart';
import '../../common/meiju/meiju_global.dart';
import '../../common/system.dart';

final List<FindZigbeeResult> list = <FindZigbeeResult>[];

class ZigbeeDeviceManager extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zigbee设备测试页面"),
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
                    if(NetUtils.getNetState() != null) {
                      deviceManagerChannel.setFindZigbeeListener((result) {
                        print(result);
                        list.addAll(result);
                      });
                      deviceManagerChannel.findZigbee(
                          MeiJuGlobal.homeInfo?.homegroupId ?? "",
                          MeiJuGlobal.gatewayApplianceCode ?? "");
                    } else {
                      print("请连接网络再来尝试");
                    }
                  },
                child: const Text("开始扫描Zigbee设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.stopFindZigbee(
                      MeiJuGlobal.homeInfo?.homegroupId ?? "",
                      MeiJuGlobal.gatewayApplianceCode ?? "");
                  deviceManagerChannel.setFindZigbeeListener(null);
                },
                child: const Text("停止扫描Zigbee设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.bindZigbee(
                      MeiJuGlobal.homeInfo?.homegroupId ?? "",
                      MeiJuGlobal.roomInfo?.roomId ?? "",
                      list // 指定需要绑定的zigbee设备
                  );
                },
                child: const Text("绑定扫描到的Zigbee设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  deviceManagerChannel.stopBindZigbee();
                },
                child: const Text("停止绑定扫描到的Zigbee设备"),
              ),
            ),
          ]),
    );
  }

}