import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'common/index.dart';
import 'states/index.dart';
import 'routes/index.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 加载环境配置
  await setupConfig();
  Global.init().then((e) async {
    await checkLogin();
    runApp(const App());
  });
}

Future checkLogin() async {
  if (Global.isLogin) {
    await MideaApi.autoLogin();

    await MzApi.authToken();
  }
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
    return ChangeNotifierProvider(
      create: (providerContext) => UserModel(),
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark(),
        darkTheme: ThemeData.dark(),
        //注册路由表
        routes: routes,
      ),
    );
  }
}

setupConfig() async {
  const env = String.fromEnvironment('env');
  if (env != 'sit' || env != 'prod') {
    // 如果不传sit或者prod默认使用sit环境
    await dotenv.load(fileName: ".sit.env");
  } else {
    await dotenv.load(fileName: ".$env.env");
  }
}
