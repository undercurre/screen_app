import 'package:screen_app/channel/about_system_channel.dart';
import 'package:screen_app/channel/ali_push_channel.dart';
import 'package:screen_app/channel/bugly_report_channel.dart';
import 'package:screen_app/channel/config_channel.dart';
import 'package:screen_app/channel/device_manager_channel.dart';
import 'package:screen_app/channel/net_method_channel.dart';
import 'package:screen_app/channel/ota_channel.dart';
import 'package:screen_app/channel/setting_method_channel.dart';

import 'ai_method_channel.dart';
import 'gateway_channel.dart';

const String channelMethodNet = "com.midea.light/net";
const String channelConfig = "com.midea.light/config";
const String channelAboutSystem = "com.midea.light/about";
const String channelOTA = "com.midea.light/ota";
const String channelSetting = "com.midea.light/set";
const String channelDeviceManager = "com.midea.light/deviceManager";
const String channelAi = "com.midea.light/ai";
const String channelGateway = "com.midea.light/gateway";
const String channelAliPush = "com.midea.light/push";
const String channelBugly = "com.midea.light/bugly";

late NetMethodChannel netMethodChannel;
// 配置channel
late ConfigChannel configChannel;
// 配置关于页的channel
late AboutSystemChannel aboutSystemChannel;
// 升级的channel
late OtaChannel otaChannel;
// 系统设置channel
late SettingMethodChannel settingMethodChannel;
// 设备管理channel
late DeviceManagerChannel deviceManagerChannel;
// 语音channel
late AiMethodChannel aiMethodChannel;
// 网关channel
late GatewayChannel gatewayChannel;
// 阿里推送channel
late AliPushMethodChannel aliPushChannel;
// Bugly Channel
late BuglyReportChannel buglyReportChannel;

// 构建所有的Channel
void buildChannel() {
  netMethodChannel = NetMethodChannel.fromName(channelMethodNet);
  configChannel = ConfigChannel.fromName(channelConfig);
  aboutSystemChannel = AboutSystemChannel.fromName(channelAboutSystem);
  otaChannel = OtaChannel.fromName(channelOTA);
  settingMethodChannel = SettingMethodChannel.fromName(channelSetting);
  deviceManagerChannel = DeviceManagerChannel.fromName(channelDeviceManager);
  aiMethodChannel = AiMethodChannel.fromName(channelAi);
  gatewayChannel = GatewayChannel.fromName(channelGateway);
  aliPushChannel = AliPushMethodChannel.fromName(channelAliPush);
  buglyReportChannel = BuglyReportChannel.fromName(channelBugly);
}
