# screen_app

4寸屏，Flutter project.

## APP代码结构

```
github_client_app
├── android
├── linux
├── docs // 存放使用文档，如自定义 widgets
├── assets
│     ├── fonts // 存放字体文件
│     ├── imgs // 存放图片文件
├── jsons // 由于在网络数据传输和持久化时，我们需要通过Json来传输、保存数据；但是在应用开发时我们又需要将Json转成Dart Model类
├── lib // 源代码目录
│     ├── common // 一些工具类，如通用方法类、网络接口类、保存全局变量的静态类等
│     │     ├── system.dart // app系统功能api
│     │     └── util.dart // 工具类方法api
│     ├── models // Json文件对应的Dart Model类会在此目录下   
│     ├── states // 保存APP中需要跨组件共享的状态类
│     ├── routes // 存放所有路由页面类
│     │     ├── index.dart // 注册路由表
│     │     └── login // 登录页面模块
│     │          └── index.dart // 入口文件
│     └── widgets // APP内封装的一些Widget组件都在该目录下
│           ├── plugins // 业务组件
│           └── index.dart // 入口文件
└── test
```

每个目录下均由`index.dart`统一暴露接口

## 开发规范
1. 针对`lib`目录下，库，package，文件夹，源文件 中使用 lowercase_with_underscores 方式命名
2. 每个目录模块均以`index.dart`作为入口文件
3. `routes`目录下，每一个页面一个文件夹，存放当前页面业务逻辑代码，以`index.dart`作为页面入口，如`login`为登录页面相关代码

## 已集成插件
### Http请求库-dio
[文档地址](https://github.com/flutterchina/dio/blob/develop/README-ZH.md)

美的中台接口封装： `lib/common/api/api.dart`的`requestMideaIot`

美智中台接口封装： `lib/common/api/api.dart`的`requestMzIot`

### 状态 (State) 管理-Provider
[文档地址](https://pub.flutter-io.cn/packages/provider)

### json_model
> 一行命令，Json文件转为Dart model类。

[文档地址](https://pub.flutter-io.cn/packages/json_model)

#### 使用
1. 创建或拷贝Json文件到 `./jsons/` 目录中 ;
2. 运行以下命令生成Dart model类，生成的文件默认在 `./lib/models/` 目录下

```bash
# windows 下命令格式
flutter packages  pub run json_model src=jsons  dist=data

# Linux 下格式稍不同，参数前加--（作者文档未提及）
flutter packages pub run json_model --src=jsons --dist=lib/models
```

注：
`src` 的[默认值](https://github.com/flutterchina/json_model/blob/master/bin/json_model.dart#L21) 为 `./Json`
windows 下不区分大小写；但在 Linux 将会报错，需要使用 `--src` 指定目录

### 日志打印工具
可引入`Global`类,调用`logger`类实例进行打印
[文档地址](https://pub.flutter-io.cn/packages/logger)

## 全局变量及共享状态

### 全局状态变量
在`lib/common`目录下创建一个Global类，它主要管理APP的全局状态变量

- 用户信息：`Global.user`
- 家庭信息： `Global.profile.homeInfo`

## 全局配置
使用dotenv读取配置，可以在sit环境使用release打包，也可以在prod环境使用debug模式启动，开发和调试更方便，生产环境出问题也可以使用debug模式启动定位问题。
用法：在android studio的启动配置-additional run args加入：`--dart-define=env=sit`或者`--dart-define=env=prod`选择使用的环境。


## 自定义 widget
- Cell [文档地址](./docs/cell.md)
- MzRadio [文档地址](./docs/mz_radio.md)
- MzMetalCard [文档地址](./docs/mz_metal_card.md)
- MzNavigationBar [文档地址](./docs/mz_navigation_bar.md)
- MzSlider [文档地址](./docs/mz_slider.md)
- MzSwitch [文档地址](./docs/mz_switch.md)
- FunctionCard [文档地址](./docs/plugins/function_card.md)
- GearCard [文档地址](./docs/plugins/gear_card.md)
- ModeCard [文档地址](./docs/plugins/mode_card.md)
- ParamCard [文档地址](./docs/plugins/param_card.md)
- TemperatureCard [文档地址](./docs/plugins/temperature_card.md)