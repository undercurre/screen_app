import 'package:provider/provider.dart';
import 'index.dart';

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
        routes: <String, WidgetBuilder>{
          '/': (context) => const LinkNetwork(),
          "ScanCode": (context) => const ScanCode(),
        },
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (context) {
            String? routeName = settings.name;

            debugPrint('onGenerateRoute: $routeName');

            return const ScanCode();
            // 如果访问的路由页需要登录，但当前未登录，则直接返回登录页路由，
            // 引导用户登录；其他情况则正常打开路由。
          });
        },
      ),
    );
  }
}
