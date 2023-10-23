// import 'dart:convert';
//
// import 'package:flutter/widgets.dart';
//
//
// /// 定义网关运行环境
// enum GatewayPlatform {
//   NONE,
//   MEIJU,
//   HOMLUX;
//
//   bool inMeiju() {
//     return this == MEIJU;
//   }
//
//   bool inHomlux() {
//     return this == HOMLUX;
//   }
// }
//
// /// 网关环境切换通知
// class MideaRuntimePlatform extends ChangeNotifier {
//   GatewayPlatform platform = GatewayPlatform.NONE;
//
//   void setPlatform(GatewayPlatform platform) {
//     this.platform = platform;
//     notifyListeners();
//   }
// }
//
// abstract class MideaChangeNotifier with ChangeNotifier {
//   /// 网关运行平台
//   GatewayPlatform platform;
//
//   /// 记录刷新次数
//   int _refreshCount = 0;
//
//   /// 增加刷新标识
//   String? key = null;
//
//   MideaChangeNotifier(this.platform);
//
//   @override
//   void notifyListeners() {
//     super.notifyListeners();
//     // MideaChangeNotifier.123456 刷新次数: 5
//     print("调用 $runtimeType${key == null ? '' : ".$key"} 刷新次数: ${++_refreshCount}");
//   }
// }
//
// // 定义授权成功的回调方法
// typedef QrCodeAuthCallBack = String Function(String name, int num);
//
// class HomluxApi {
//   static Future<String> getQrCode() async {
//     return "homluxQrCode";
//   }
// }
//
// class MeiJuApi {
//   static Future<String> getQrCode() async {
//     return "MeijuQrCode";
//   }
// }
//
// class QrCodeUIAdapterTest1 extends MideaChangeNotifier {
//   QrCodeUIAdapterTest1(super.platform);
//
//   /// 授权成功的CallBack
//   QrCodeAuthCallBack? authCallBack;
//
//   /// 对望提供统一的二维码数据
//   QrCodeEntity? qrCode;
//
//   /// 请求二维码
//   /// 弊端：UI更新逻辑与数据差异暴露出来。增加对接双方代码冲突。UI层能够感知数据的组装，数据层能够感知UI层的更新。后期不好维护，增加了代码间的耦合
//   /// 优点：UI,数据逻辑处理直观明了
//   Future<void> requireQrCode() async {
//     if (platform.inHomlux()) {
//       String code = await HomluxApi.getQrCode();
//       qrCode = QrCodeEntity.fromHomlux(code);
//     } else if(platform.inMeiju()) {
//       String code = await MeiJuApi.getQrCode();
//       qrCode = QrCodeEntity.fromMeiJu(code);
//     }
//     notifyListeners();
//   }
//
// }
//
// /// 美的照明JsonConvert对象，用于将json Map转换为美的照明相关的实体类上
// dynamic homluxJsonConvert;
// /// 美居JsonConvert对象，用于将json Map转换为美居相关的实体类上
// dynamic meijuJsonConvert;
//
// /// 实体类适配
// class QrCodeEntity {
//
//   QrCodeEntity.fromHomlux(dynamic homluxData) {
//     qrCode = homluxData.qrcode;
//     _homluxData = homluxData;
//   }
//
//   QrCodeEntity.fromMeiJu(dynamic meijuData) {
//     qrCode = meijuData.qrcode;
//     _meijuData = meijuData;
//   }
//
//   String? qrCode;
//
//   // 存放一系列各自平台独有的数据，一定需要下划线，不要暴露到UI层使用
//   dynamic _homluxData;
//   dynamic _meijuData;
//
//   /// 下面两方法对UI层的意义
//   /// 提供 Json -> Object 之间切换
//   /// 意义：方便对UI层的数据快速持久化
//   factory QrCodeEntity.fromJson(Map<String, dynamic> json) {
//     if(json['_homluxData'] != null) {
//       return QrCodeEntity.fromHomlux(homluxJsonConvert.convert(json['homluxData']));
//     } else if(json['_meijuData'] != null) {
//       return QrCodeEntity.fromMeiJu(meijuJsonConvert.convert(json['_meijuData']));
//     } else {
//       throw UnimplementedError("失败：fromJson解析QrCodeEntity失败 解析的数据为：${const JsonEncoder().convert(json)}");
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "_homluxData": _homluxData.toJson(),
//       "_meijuData": _meijuData.toJson()
//     };
//   }
//
// }
//
//
