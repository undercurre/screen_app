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
│     └── widgets //APP内封装的一些Widget组件都在该目录下
└── test
```

每个目录下均由`index.dart`统一暴露接口

## 开发规范
1. 针对`lib`目录下，库，package，文件夹，源文件 中使用 lowercase_with_underscores 方式命名

## 已集成插件
### Http请求库-dio
[文档地址](https://github.com/flutterchina/dio/blob/develop/README-ZH.md)

### json_model 
> 一行命令，Json文件转为Dart model类。

[文档地址](https://pub.flutter-io.cn/packages/json_model)

#### 使用
1. 创建或拷贝Json文件到"jsons" 目录中 ;
2. 运行 `flutter packages pub run json_model` 命令生成Dart model类，生成的文件默认在"lib/models"目录下






