# screen_app

4寸屏，Flutter project.

## APP代码结构

```
github_client_app
├── android
├── linux
├── assets
│     ├── fonts // 存放字体文件
│     ├── imgs // 存放图片文件
├── jsons // 由于在网络数据传输和持久化时，我们需要通过Json来传输、保存数据；但是在应用开发时我们又需要将Json转成Dart Model类
├── lib // 源代码目录
│     ├── common // 一些工具类，如通用方法类、网络接口类、保存全局变量的静态类等
│     ├── models // Json文件对应的Dart Model类会在此目录下   
│     ├── states // 保存APP中需要跨组件共享的状态类
│     ├── routes // 存放所有路由页面类
│     │     ├── index.dart // 注册路由表
│     │     └── login // 登录页面模块
│     │          └── index.dart // 入口文件
│     └── widgets //APP内封装的一些Widget组件都在该目录下
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

### 状态 (State) 管理-Provider
[文档地址](https://pub.flutter-io.cn/packages/provider)

### json_model
> 一行命令，Json文件转为Dart model类。

[文档地址](https://pub.flutter-io.cn/packages/json_model)

注：
`src` 的[默认值](https://github.com/flutterchina/json_model/blob/master/bin/json_model.dart#L21) 为 `./Json`
windows 下不区分大小写；但在 Linux 将会报错，需要使用 `--src` 指定目录

```bash
# 命令格式(windows)
pub run json_model src=jsons  dist=data

# Linux 下参数格式稍不同，作者文档未提及
pub run json_model --src=jsons --dist=data

```

#### 使用
1. 创建或拷贝Json文件到"jsons" 目录中 ;
2. 运行 `flutter packages pub run json_model` 命令生成Dart model类，生成的文件默认在"lib/models"目录下


### 日志打印工具
可引入`Global`类,调用`logger`进行打印
[文档地址](https://pub.flutter-io.cn/packages/logger)

## 全局变量及共享状态

### 全局状态变量
在`lib/common`目录下创建一个Global类，它主要管理APP的全局状态变量

### 用户信息
在`lib/common/api/api.dart`维护：`Api`类的静态变量`tokenInfo`
