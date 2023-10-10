import 'package:screen_app/common/exceptions/MideaException.dart';

import '../gateway_platform.dart';
import '../logcat_helper.dart';

/// 声明数据更新的回调函数
/// 用于绑定UI更新的方法 setState();
/// 编程核心：数据驱动UI
typedef DataUpdateFunction = void Function();

typedef AdapterGenerateFunction<T extends MideaDataAdapter> = T Function(String id);
// 所有UI适配器的父类
// 功能包括：运行的环境，统计适配器的刷新次数
// 为了兼容多UI对应同一个类型的UI适配层，特意增加了key字段。规避这种情况下，难以统计具体UI的刷新次数
abstract class MideaDataAdapter {
  Set<DataUpdateFunction>? _dataUpdateFunctionSet;

  static Map<String, MideaDataAdapter> adapterMap = {};

  static T getOrCreateAdapter<T extends MideaDataAdapter>(String id, AdapterGenerateFunction<T> function) {
    if (MideaDataAdapter.contained(id)) {
      return MideaDataAdapter.getAdapter(id);
    } else {
      var adapter = function.call(id);
      assert(() {
        if(adapterMap.containsValue(adapter)) {
          throw Exception("非法调用 当前的adapter 已经绑定");
        }
        return true;
      }.call());
      MideaDataAdapter.addAdapter(id, adapter);
      return adapter;
    }
  }

  static T? getAdapter<T>(String id) {
    if(adapterMap[id] == null) {
      return null;
    } else {
      if(adapterMap[id] is T) {
        return adapterMap[id] as T;
      } else {
        throw MideaException("[adapter] 重复 id 已被 ${adapterMap[id].runtimeType} 占用 传入的adapter类型为 ${T}");
      }
    }
  }

  static bool contained(String id) {
    return adapterMap.containsKey(id);
  }

  static void addAdapter(String id, MideaDataAdapter adapter) {
    if(!adapterMap.containsKey(id)) {
      adapterMap[id] = adapter;
    }
  }

  static void removeAdapter(String id) {
    if(adapterMap.containsKey(id)) {
      adapterMap.remove(id)?.destroy();
    }
  }

  static void clearAllAdapter() {
    adapterMap.clear();
  }

  /// 记录刷新次数
  int _refreshCount = 0;
  /// 增加刷新标识
  String? key;
  /// 网关运行的环境
  GatewayPlatform platform;
  /// 数据加载状态
  DataState dataState = DataState.NONE;

  MideaDataAdapter(this.platform) {
    Log.i('当前DataAdapter $this 处在的平台为：$platform');
  }



  /// 关联数据更新的回调函数
  void bindDataUpdateFunction(DataUpdateFunction function) {
    /// 初始化容器
    _dataUpdateFunctionSet ??= {};
    _dataUpdateFunctionSet?.add(function);
  }

  /// 解除关联数据更新的回调函数
  void unBindDataUpdateFunction(DataUpdateFunction function) {
    _dataUpdateFunctionSet?.remove(function);
  }

  /// 移除所有的数据更新的回调函数
  void clearBindDataUpdateFunction() {
    _dataUpdateFunctionSet?.clear();
  }

  /// 数据驱动UI更新
  void updateUI() {
    try {
      _dataUpdateFunctionSet?.forEach((element) {
        element.call();
      });
    } catch(e) {
      Log.e(e);
    }
    Log.i("调用 $runtimeType${key == null ? '' : ".$key"} 刷新次数: ${++_refreshCount}");
  }

  /// 是否包含UI回调监听
  bool isContainUpdateUIFunction() {
    return _dataUpdateFunctionSet?.isNotEmpty ?? false;
  }

  // 初始化Adapter
  void init() {

  }

  /// 销毁Adapter
  void destroy() {
    clearBindDataUpdateFunction();
    assert((){
      if(adapterMap.containsValue(this)) {
        Log.e("非法删除Adapter = $runtimeType, 该adapter已经记录到adapterMap，请调用removeAdapter方法回收Adapter");
        adapterMap.removeWhere((key, value) => value == this);
      }
      return true;
    }.call());
  }

}

/// 数据状态
/// NONE(还未初始化)，Loading(加载中), Error(加载失败), Success(加载成功)
enum DataState { NONE, LOADING, ERROR, SUCCESS }

