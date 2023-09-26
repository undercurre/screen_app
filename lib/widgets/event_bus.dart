// 订阅者回调签名
import '../common/logcat_helper.dart';

typedef EventCallback<T> = void Function(T arg);

class EventBus {
  // 私有构造函数
  EventBus._internal();

  // 保存单例
  static final EventBus _singleton = EventBus._internal();

  // 工厂构造函数
  factory EventBus() => _singleton;

  // 保存事件订阅队列，key:事件名(强制为String)，value: 对应事件处理方法队列
  final _emap = <String, List<dynamic>>{};

  // 添加订阅
  void on<T>(String eventName, EventCallback<T> callback, [dynamic identity]) {
    // 订阅事件未注册，则新建队列
    _emap[eventName] ??= <dynamic>[];

    // 当前队列必然存在，加入新的事件处理方法
    var list = _emap[eventName]!;
    if(!list.contains(callback)) {
      list.add(callback);
      Log.i('buss $eventName 订阅者${identity?.hashCode} 订阅成功');
    } else {
      Log.i('buss $eventName 重复绑定，无需再绑定');
    }

  }

  // 订阅销毁
  void off<T>(String eventName, [EventCallback<T>? callback, dynamic identity]) {
    var list = _emap[eventName];
    if (list == null) return;

    // 移除事件订阅
    if (callback == null) {
      _emap.remove(eventName);
    }
    // 移除事件订阅队列指定事件处理方法
    else {
      bool result = list.remove(callback);
      Log.i('buss 订阅者者${identity?.hashCode} $eventName ${result? '移除成功': '移除失败'} 监听数量为：${list.length} }');
    }
  }

  // 触发事件：参数强制为String，参数列表可选
  // 事件触发后，该事件所有订阅者会被调用
  void emit(String eventName, [dynamic arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    Log.file('推送事件类型：$eventName 监听者数量：${list.length}');
    // 反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (int i = list.length - 1; i > -1; --i) {
      list[i](arg);
    }
  }

  /// buss HomluxDeviceOnlineStatusChangeEvent 订阅者984106429 订阅成功
  /// buss HomluxDeviceOnlineStatusChangeEvent 订阅者801186494 订阅成功
  /// buss HomluxDeviceOnlineStatusChangeEvent 订阅者293510060 订阅成功
  /// buss 订阅者者1032265174 HomluxDeviceOnlineStatusChangeEvent 移除失败 监听数量为：3 }

  // 基于事件类型销毁订阅
  void typeOff<D>([EventCallback<D>? callback, dynamic identity]) {
    var type = D.toString();
    if(type.contains('?')) {
      type = type.replaceAll("?", '');
    }
    Log.i('销毁订阅的类型为$type');
    if(type == 'Object' || type == 'dynamic') {
      throw Exception('禁止订阅类型为object | dynamic, 请指定具体的订阅类型');
    }
    off(type, callback, identity);
  }

  // 基于事件类型定与
  void typeOn<D>(EventCallback<D> callback, [dynamic identity]) {
    var type = D.toString();
    if(type.contains('?')) {
      type = type.replaceAll("?", '');
    }
    if(type == 'Object' || type == 'dynamic') {
      throw Exception('禁止订阅类型为object | dynamic, 请指定具体的订阅类型');
    }
    Log.i('订阅的类型为$type');
    on(type, callback, identity);
  }

  // 基于事件发送
  void typeEmit<D>(D d) {
    var type = D.toString();
    if(type.contains('?')) {
      type = type.replaceAll("?", '');
    }
    emit(type, d);
    Log.file('发送事件类型 ${d.runtimeType} ${d.toString()}');
  }

}

// 定义一个top-level（全局）变量，页面引入该文件后可以直接使用bus
final bus = EventBus();
