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
│     ├── channel // 自定义与原生平台通信的通道
│     ├── common // 一些工具类，如通用方法类、网络接口类、保存全局变量的静态类等
│     │     ├── system.dart // app系统功能api
│     │     ├── global.dart // 全局状态管理类
│     │     └── util.dart // 工具类方法api
│     ├── models // Json文件对应的Dart Model类会在此目录下   
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

<br>

#### 美的中台接口封装： `lib/common/api/api.dart`的`requestMideaIot<T>`

| 公共body参数 | 公共header参数 |
|------      |------|
| openId |  accessToken
| iotAppId | sign
| reqId |  random
| stamp |
| timestamp |
| uid |
| timestamp |

使用示例：
```dart
MideaResponseEntity<QrCodeEntity> res = await Api.requestMideaIot<QrCodeEntity>(
        "/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': Global.profile.deviceId, 'checkType': 1});
```

响应数据：
```
{
    late int code;
    late String msg;
    late T data;
    
    get isSuccess => code == 0;
}
```

<br>

#### 美智中台接口封装： `lib/common/api/api.dart`的`requestMzIot<T>`

| 公共body参数 | 公共header参数 |
|------|   ------|
| systemSource |   Authorization
| frontendType |  sign
| reqId |  random
| userId |
| timestamp |

使用示例：
```dart
MzResponseEntity<QrCodeEntity> res = await Api.requestMzIot<QrCodeEntity>(
        "/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': Global.profile.deviceId, 'checkType': 1});
```

响应数据：
```
{
  late int code;
  late String msg;
  late T result;
  late bool success;

  get isSuccess => success;
}
```

### 状态 (State) 管理-Provider
[文档地址](https://pub.flutter-io.cn/packages/provider)

### `FlutterJsonBeanFactory`插件
> Json文件转为Dart model类工具

[使用文档地址](https://www.loongwind.com/archives/374.html)

#### 使用
1. 安装`FlutterJsonBeanFactory`插件，并生成对应数据实体类
2. 更新维护实体类的属性，每次更新后`Alt + J`重新生成代码

### 日志打印工具
可引入`Global`类,调用`logger`类实例进行打印
[文档地址](https://pub.flutter-io.cn/packages/logger)

## 字体定义
- `fontFamily: "MideaType"`（`fontFamily: 'MideaType-Regular'` 是引用不了的）
- `fontWeight`，默认值是`regular`，另外定义了 `w100` 和 `w900` 两种，分别对应纤细体和粗体
```dart
style: const TextStyle(
      fontFamily: "MideaType",
      fontSize: 18,
      fontWeight: FontWeight.w100,
      decoration: TextDecoration.none,
    )
```

参见 [pubspec.yaml](./pubspec.yaml#L111)

## 全局变量及共享状态

### 全局状态变量
在`lib/common`目录下创建一个Global类，它主要管理APP的全局状态变量

- 用户信息：`Global.user`
- 家庭信息： `Global.profile.homeInfo`

## 全局配置
使用dotenv读取配置，可以在sit环境使用release打包，也可以在prod环境使用debug模式启动，开发和调试更方便，生产环境出问题也可以使用debug模式启动定位问题。
用法：在android studio的启动配置-additional run args加入：`--dart-define=env=sit`或者`--dart-define=env=prod`选择使用的环境。


## 自定义 widget
### 业务组件
- 选择家庭 `SelectHome` [文档地址](./docs/business/select_home.md)
- 选择房间 `SelectRoom` [文档地址](./docs/business/select_room.md)

### 功能组件
- MzCell [文档地址](./docs/mz_cell.md)
- MzRadio [文档地址](./docs/mz_radio.md)
- MzMetalCard [文档地址](./docs/mz_metal_card.md)
- MzNavigationBar [文档地址](./docs/mz_navigation_bar.md)
- MzSlider [文档地址](./docs/mz_slider.md)
- MzSwitch [文档地址](./docs/mz_switch.md)
- FunctionCard [文档地址](./docs/plugins/function_card.md)
- GearCard [文档地址](./docs/plugins/gear_card.md)
- ModeCard [文档地址](./docs/plugins/mode_card.md)
- ParamCard [文档地址](./docs/plugins/param_card.md)
- SliderButtonCard [文档地址](./docs/plugins/slider_button_card.md)