import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'common/index.dart';
import 'states/index.dart';
import 'routes/index.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/pointer_listener.dart';
import 'widgets/event_bus.dart';

void main() async {
  // 加载环境配置
  await setupConfig();
  Global.init().then((e) async {
    runApp(const App());
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => UserModel()),
        Provider(create: (_) => DeviceListModel()),
      ],
      child: PointerDownListener(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            theme: ThemeData.dark(),
            darkTheme: ThemeData.dark(),
            initialRoute: "/", //名为"/"的路由作为应用的home(首页)
            //注册路由表
            routes: routes,
            builder: EasyLoading.init(),
          ),
          // 全局点击操作监听
          onPointerDown: (e) {
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
