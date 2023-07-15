import '../logcat_helper.dart';

/// 声明数据更新的回调函数
/// 用于绑定UI更新的方法 setState();
/// 编程核心：数据驱动UI
typedef DataUpdateFunction = void Function();

// 所有UI适配器的父类
// 功能包括：运行的环境，统计适配器的刷新次数
// 为了兼容多UI对应同一个类型的UI适配层，特意增加了key字段。规避这种情况下，难以统计具体UI的刷新次数
abstract class MideaDataAdapter {
  Set<DataUpdateFunction>? _dataUpdateFunctionSet;

  /// 记录刷新次数
  int _refreshCount = 0;
  /// 增加刷新标识
  String? key;

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
  void update() {
    _dataUpdateFunctionSet?.forEach((element) {
      element.call();
    });
    Log.i("调用 $runtimeType${key == null ? '' : ".$key"} 刷新次数: ${++_refreshCount}");
  }

}
