import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../common/global.dart';
import '../states/global_route_observer_notifier.dart';


/// 重新定义组件的生命周期
/// 一个正常的组件生命周期为：onCreate -> onResume -> onDestroy
/// 其他常见的组件生命周期：onCreate -> onResume -> onPause -> onResume  .....   -> onDestroy
///
///

enum LifeCycle {
  uninitialized, destroy, pause, create, resume
}

mixin LifeCycleStateMixin<W extends StatefulWidget> on State<W> implements RouteAware {

  late RouteObserver _routeObserver;

  LifeCycle _state = LifeCycle.uninitialized;

  /// 判断当前组件状态是否大于或者等于给定的状态
  bool isAtLastState(LifeCycle cycle) {
    return LifeCycle.values.indexOf(_state) >= LifeCycle.values.indexOf(cycle);
  }

  @override
  @mustCallSuper
  @protected
  void didPop() {
    _state = LifeCycle.pause;
    onPause();
    _state = LifeCycle.destroy;
    onDestroy();
  }

  @override
  @mustCallSuper
  @protected
  void didPush() {
    _state = LifeCycle.create;
    onCreate();
    _state = LifeCycle.resume;
    onResume();
  }

  @override
  @mustCallSuper
  @protected
  void didPushNext() {
    debugPrint('当前组件$this 状态暂停');
    _state = LifeCycle.pause;
    onPause();
  }

  @override
  @mustCallSuper
  @protected
  void didPopNext() {
    debugPrint('当前组件$this 状态正在前台活动');
    _state = LifeCycle.resume;
    onResume();
  }

  /// 当前组件第一次创建
  @mustCallSuper
  @protected
  void onCreate() {}

  /// 从其他组件返回到当前组件，当前组件显示在前台
  @mustCallSuper
  @protected
  void onResume() {}

  /// 从当前组件离开，当前组件只是临时离开
  @mustCallSuper
  @protected
  void onPause() {}

  /// 当前组件正在被回收
  @mustCallSuper
  @protected
  void onDestroy() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<GlobalRouteObserverNotifier>(context).routeObserver;
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    super.dispose();
    _routeObserver.unsubscribe(this);
  }

}