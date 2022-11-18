// 订阅者回调签名
typedef EventCallback<T> = void Function(T? arg);

class EventBus<T> {
  // 私有构造函数
  EventBus._internal();

  // 保存单例
  static final EventBus _singleton = EventBus._internal();

  // 工厂构造函数
  factory EventBus() => _singleton as EventBus<T>;

  // 保存事件订阅队列，key:事件名(强制为String)，value: 对应事件处理方法队列
  final _emap = <String, List<EventCallback<T>>>{};

  // 添加订阅
  void on(String eventName, EventCallback<T> callback) {
    // 订阅事件未注册，则新建队列
    _emap[eventName] ??= <EventCallback<T>>[];

    // 当前队列必然存在，加入新的事件处理方法
    _emap[eventName]!.add(callback);

  }

  // 订阅销毁
  void off(String eventName, [EventCallback<T>? callback]) {
    var list = _emap[eventName];
    if (list == null) return;

    // 移除事件订阅
    if (callback == null) {
      _emap.remove(eventName);
    }
    // 移除事件订阅队列指定事件处理方法
    else {
      list.remove(callback);
    }
  }

  // 触发事件：参数强制为String，参数列表可选
  // 事件触发后，该事件所有订阅者会被调用
  void emit(String eventName, [T? arg]) {
    var list = _emap[eventName];
    if (list == null) return;

    // 反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (int i = list.length - 1; i > -1; --i) {
      list[i](arg);
    }
  }
}

// 定义一个top-level（全局）变量，页面引入该文件后可以直接使用bus
final bus = EventBus();
