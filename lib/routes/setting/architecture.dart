// 架构类
enum Type { LONGING, ERROR, SUCCESS }

class UpdateState<T> {
  T _t;
  late Type _type;

  Type get type => _type;

  T get data => _t;

  UpdateState.loading(this._t) {
    _type = Type.LONGING;
  }

  UpdateState.error(this._t) {
    _type = Type.ERROR;
  }

  UpdateState.success(this._t) {
    _type = Type.SUCCESS;
  }

}


