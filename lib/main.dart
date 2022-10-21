import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'common/index.dart';
import 'states/index.dart';
import 'routes/index.dart';


void main() {
  Global.init().then((e) => runApp(const App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (providerContext) => UserModel(),
      child: MaterialApp(
        themeMode: ThemeMode.system,
        theme: ThemeData.fallback(),
        darkTheme: ThemeData.dark(),
        //注册路由表
        routes: routes,
      ),
    );
  }
}
