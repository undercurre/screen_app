///
/// 说明：架构辅助类
///


/// 为任意对象增加三种状态
/// NONE(还未初始化)，Loading(加载中), Error(加载失败), Success(加载成功)
enum UpdateType { NONE, LONGING, ERROR, SUCCESS }

class UpdateState<T> {
  T _t;
  int? errorCode;
  String? errorMessage;

  late UpdateType _type;

  UpdateType get type => _type;

  T get data => _t;

  UpdateState.none(this._t) {
    _type = UpdateType.NONE;
  }

  UpdateState.loading(this._t) {
    _type = UpdateType.LONGING;
  }

  UpdateState.error(this._t, [int this.errorCode = -1, String this.errorMessage = '加载错误']) {
    _type = UpdateType.ERROR;
  }

  UpdateState.success(this._t) {
    _type = UpdateType.SUCCESS;
  }

}

/// dart因没析构函数 对元组的支持程度不太友好
/// 元组优于数组，一般用于函数执行结果多个值的返回
/// 二元组
class Pair<V1, V2> {
  V1 value1;
  V2 value2;
  Pair.of(this.value1, this.value2);
}
/// 三元组
class Triple<V1, V2, V3> {
  V1 value1;
  V2 value2;
  V3 value3;
  Triple.of(this.value1, this.value2, this.value3);
}



