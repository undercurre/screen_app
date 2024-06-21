# 目录
[toc]

# 📌 项目概况
package:screen_app
4寸屏，Flutter project.

# 📁 代码结构

```
github_client_app
├── android
├── linux
├── docs // 使用文档，如自定义 widgets
│     ├── business // 业务组件文档
│     ├── plugins // 插件组件文档
├── assets
│     ├── fonts // 字体文件
│     ├── imgs // 图片文件
│     ├── video // 视频文件
├── lib // 源代码目录
│     ├── channel // 自定义与原生平台通信的通道
│     ├── common // 一些工具类，如通用方法类、网络接口类、保存全局变量的静态类等
│     │     ├── api // 按功能模块划分的api封装
│     │     ├── global.dart // 全局状态管理类
│     │     ├── system.dart // app系统功能api
│     │     └── util.dart // 工具类方法api
│     ├── generated // FlutterJsonBeanFactory生成目录
│     │     ├── json // *_entity.g.dart 根据实体类生成的类辅助方法
│     │     │     ├── base // 基础公共代码
│     ├── models // 实体类存放目录
│     ├── mixins // 混入方法存放目录
│     ├── routes // 存放所有路由页面类
│     │     ├── index.dart // 注册路由表
│     │     ├── boot // 启动页面
│     │     ├── login // 登录页面
│     │     ├── weather // 待机天气
│     │     └── plugins // 设备插件
│     ├── states // 状态共享
│     └── widgets // APP内封装的一些Widget组件都在该目录下
│           ├── plugins // 业务组件
│           └── index.dart // 入口文件
└── test
```

**每个目录下均由`index.dart`统一暴露接口**

# 🧭 开发规范
1. `lib`目录下，库，package，文件夹，源文件 中使用 lowercase_with_underscores 方式命名
2. 每个目录模块均以`index.dart`作为入口文件
3. `routes`目录下，每一个页面一个文件夹，存放当前页面业务逻辑代码，以`index.dart`作为页面入口，如`login`为登录页面相关代码

# 🍭 插件&工具
## Http请求库-dio
[文档地址](https://github.com/flutterchina/dio/blob/develop/README-ZH.md)

## `FlutterJsonBeanFactory`插件
> Json文件转为Dart model类工具

[使用文档地址](https://www.loongwind.com/archives/374.html)

### 使用
1. 安装 `FlutterJsonBeanFactory` 插件，并生成对应数据实体类
2. 更新维护实体类的属性，每次更新后 `Alt + J` 重新生成代码(可能出现快捷键冲突，导致更新失败，修改默认的快捷键即可)

## 日志打印工具
可引入`Global`类,调用`logger`类实例进行打印
[文档地址](https://pub.flutter-io.cn/packages/logger)

## 字体定义
- `fontFamily: "`MideaType`"`
- `fontWeight`，默认值是`regular`，另外定义了 `w100` ~ `w900`，w100对应纤细体，w900对应粗体

```dart
const TextStyle(
    fontFamily: "MideaType", // ! 非 'MideaType-Regular'
    fontSize: 18,
    fontWeight: FontWeight.w100,
    decoration: TextDecoration.none,
)
```

参见 [pubspec.yaml](./pubspec.yaml#L111)


# ️🔗 接口封装
## 美的中台： `lib/common/api/api.dart`的`requestMideaIot<T>`

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
        isShowLoading: true,
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

## 美智中台： `lib/common/api/api.dart`的`requestMzIot<T>`

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

# 🌏 全局变量、共享状态、工具类

## 全局状态变量
在`lib/common`目录下创建一个Global类，它主要管理APP的全局状态变量

- 用户信息：`Global.user`
- 家庭信息： `Global.profile.homeInfo`

## 全局配置
使用dotenv读取配置，可以在sit环境使用release打包，也可以在prod环境使用debug模式启动，开发和调试更方便，生产环境出问题也可以使用debug模式启动定位问题。
用法：在android studio的启动配置-additional run args加入：`--dart-define=env=sit`或者`--dart-define=env=prod`选择使用的环境。

## 状态 (State) 管理-Provider
[文档地址](https://pub.flutter-io.cn/packages/provider)


## 工具类
- 弹窗工具类-`TipsUtils` [文档地址](./docs/utils/TipsUtils.md)

# 🧩 自定义 widget
## 业务组件
- 选择家庭 `SelectHome` [文档地址](./docs/business/select_home.md)
- 选择房间 `SelectRoom` [文档地址](./docs/business/select_room.md)

## 功能组件
- MzCell [文档地址](./docs/mz_cell.md)
- MzRadio [文档地址](./docs/mz_radio.md)
- MzMetalCard [文档地址](./docs/mz_metal_card.md)
- MzNavigationBar [文档地址](./docs/mz_navigation_bar.md)
- MzSlider [文档地址](./docs/mz_slider.md)
- MzSwitch [文档地址](./docs/mz_switch.md)
- MzDialog [文档地址](./docs/mz_dialog.md)

## 插件组件
- FunctionCard [文档地址](./docs/plugins/function_card.md)
- GearCard [文档地址](./docs/plugins/gear_card.md)
- ModeCard [文档地址](./docs/plugins/mode_card.md)
- ParamCard [文档地址](./docs/plugins/param_card.md)
- SliderButtonCard [文档地址](./docs/plugins/slider_button_card.md)

## 设备——>插件逻辑文档[文档地址](./docs/device/device_card.md)

## 布局逻辑

- 目前布局主要使用第三方瀑布流组件实现flutter_staggered_grid_view
- 该组件主要负责不定大小卡片的自动排列
- 渲染过程，首先需要拿到layoutObject布局对象列表，然后逐个渲染到该组件上
- 布局对象数据由布局器screenLayer计算，该布局器会将屏幕分割为16格，其中配置各个卡片在一屏中布局的所有可能性和优先级
- layoutObject在渲染前要经过screenLayer布局计算数据，然后遍历整个布局对象数组，逐个导入flutter_staggered_grid_view形成瀑布布局
- 因为PageView的滑动需求，每一滑动屏都分别是一个瀑布流.
- 每个卡片本身拥有独立的LongPressDraggable处理来拖拽布局
- 通过绝对定位右上角减号按钮实现删除功能
- layoutObject时还需要将没有被布局的位置使用一个Null布局（实际存在的透明小卡片作为占位），让布局更好地按照我们的预想进行增删及排列
- screenLayer算法实现[https://blog.lirh42.xyz/2023/06/23/%E7%AE%97%E6%B3%95/grid%E6%89%BE%E5%9D%91%E5%A1%AB%E5%85%85%E7%AE%97%E6%B3%95/]