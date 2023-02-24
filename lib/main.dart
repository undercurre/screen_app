import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/global_route_observer_notifier.dart';
import 'package:screen_app/widgets/event_bus.dart';
import './channel/index.dart';
import 'common/index.dart';
import 'common/setting.dart';
import 'routes/index.dart';
import 'states/index.dart';
import 'widgets/pointer_listener.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  /// 加载环境配置
  await setupConfig();
  /// 初始化intl库的日期
  await initializeDateFormatting('zh_CN');
  Global.init().then((e) async {
    runApp(const App());
    /// 初始化Native配置
    WidgetsFlutterBinding.ensureInitialized();
    buildChannel();
    configChannel.initNativeConfig(const String.fromEnvironment('env'));
    /// 初始化设置配置
    Setting.instant().init();
  });
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
        ChangeNotifierProvider(create: (_) => DeviceListModel()),
        ChangeNotifierProvider(create: (_) => RoomModel()),
        ChangeNotifierProvider(create: (_) => StandbyChangeNotifier()),
        ChangeNotifierProvider(create: (_) => SceneChangeNotifier()),
        ChangeNotifierProvider(create: (_) => GlobalRouteObserverNotifier())
      ],
      child: PointerDownListener(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            theme: ThemeData.dark(),
            darkTheme: ThemeData.dark(),
            initialRoute: "/", //名为"/"的路由作为应用的home(首页)
            //注册路由表
            routes: routes,
            navigatorObservers: [globalRouteObserver],
            navigatorKey: navigatorKey,
            builder: EasyLoading.init(),
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
  if (env != 'sit' && env != 'prod') {
    // 如果不传sit或者prod默认使用sit环境
    await dotenv.load(fileName: ".sit.env");
  } else {
    await dotenv.load(fileName: ".$env.env");
  }
}
