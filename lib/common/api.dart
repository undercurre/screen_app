import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import 'global.dart';

class Api {
  // 在网络请求过程中可能会需要使用当前的context信息，比如在请求失败时
  // 打开一个新路由，而打开新路由需要context信息。
  Api(this.context);

  BuildContext context;
  static Dio dio = Dio(BaseOptions(
    baseUrl: Global.isRelease ? '' : 'https://api.github.com/',
    headers: {},
  ));

  static void init() {
    // 设置用户token（可能为null，代表未登录）
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;

    // 在调试模式下需要抓包调试，所以我们使用代理，并禁用HTTPS证书校验
    if (!Global.isRelease) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          return "PROXY 10.95.249.53:8888";
        };
        //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  // 登录接口，登录成功后返回用户信息
  Future<User> login(String login, String pwd) async {
    String basic = 'Basic ${base64.encode(utf8.encode('$login:$pwd'))}';
    var r = await dio.get(
      "/users/$login",
    );
    //登录成功后更新公共头（authorization），此后的所有请求都会带上用户身份信息
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    //更新profile中的token信息
    Global.profile.token = basic;
    return User.fromJson(r.data);
  }
}
