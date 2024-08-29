import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/homlux/lan/homlux_lan_control_device_manager.dart';
import 'package:screen_app/states/device_list_notifier.dart';
import 'package:screen_app/states/layout_notifier.dart';
import 'package:screen_app/states/global_route_observer_notifier.dart';
import 'package:screen_app/states/page_change_notifier.dart';
import 'package:screen_app/states/relay_change_notifier.dart';
import 'package:screen_app/states/weather_change_notifier.dart';
import 'package:screen_app/widgets/event_bus.dart';

import './channel/index.dart';
import 'common/crash/android_crash_handler.dart';
import 'common/index.dart';
import 'common/logcat_helper.dart';
import 'common/setting.dart';
import 'routes/index.dart';
import 'states/index.dart';
import 'widgets/pointer_listener.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// 全局获取buildContext类型参数
BuildContext get globalContext => navigatorKey.currentContext!;

void main() async {
  /// 加载环境配置
  await setupConfig();
  /// 初始化intl库的日期
  await initializeDateFormatting('zh_CN');
  /// 初始化系统全局属性
  await System.globalInit();
  /// 初始化Native配置
  buildChannel();
  configChannel.initNativeConfig(const String.fromEnvironment('env'));
  /// 初始化设置配置
  Setting.instant().init();
  /// 调试时，去除因热重载影响。比如：内存泄漏，重复建立监听等等
  /// 导致在调试时代码执行异常
  assert((() {
    bus.clearAllListener();
    HomluxLanControlDeviceManager.getInstant().logout();
    MideaDataAdapter.clearAllAdapter();
    netMethodChannel.unregisterNetChangeCallBack(null);
    netMethodChannel.unregisterNetAvailableChangeCallBack(null);
    netMethodChannel.unregisterScanWiFiCallBack(null);
    netMethodChannel.initChannel();
    return true;
  })());
  /// 检查当前网络连接状态
  netMethodChannel.checkNetState();
  /// 增加全局异常捕获机制
  Catcher2Options debugOptions = Catcher2Options(SilentReportMode(), [ AndroidCrashReportHandler() ]);
  Catcher2Options releaseOptions = Catcher2Options(SilentReportMode(), [ AndroidCrashReportHandler() ]);
  Catcher2(
      rootWidget: const App(),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions,
      navigatorKey: navigatorKey
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StandbyChangeNotifier()),
        ChangeNotifierProvider(create: (_) => GlobalRouteObserverNotifier()),
        ChangeNotifierProvider(create: (_) => LayoutModel()),
        ChangeNotifierProvider(create: (_) => WeatherModel()),
        ChangeNotifierProvider(create: (_) => RelayModel()),
        ChangeNotifierProvider(create: (_) => SceneListModel()),
        ChangeNotifierProvider(create: (_) => DeviceInfoListModel()),
        ChangeNotifierProvider(create: (_) => PageCounter()),
      ],
      child: PointerDownListener(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            theme: ThemeData.dark(),
            darkTheme: ThemeData.dark(),
            initialRoute: "developer", //名为"/"的路由作为应用的home(首页)
            //注册路由表
            routes: routes,
            navigatorObservers: [globalRouteObserver],
            navigatorKey: Catcher2.navigatorKey,
            builder: EasyLoading.init(builder: (context, widget) {
              Catcher2.addDefaultErrorWidget(
                  showStacktrace: false,
                  title: "崩溃",
                  description: "页面开小差了~",
                  maxWidthForSmallMode: 150);
              return widget!;
            }),
          ),
          // 全局点击操作监听
          onPointerDown: (e) {
            debugPrint('onPointDown');
            bus.emit("onPointerDown");
          }),
    );
  }
}

setupConfig() async {
  const env = String.fromEnvironment('env');
  Log.i('当前环境', env);
  if (env != 'sit' && env != 'prod' && env != 'dev') {
    // 如果不传sit或者prod默认使用sit环境
    await dotenv.load(fileName: ".sit.env");
  } else {
    await dotenv.load(fileName: ".$env.env");
  }
}
