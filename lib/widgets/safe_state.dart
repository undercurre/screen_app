import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

enum _StateType { init, build, dispose, idle}
/// 安全类型的State
abstract class SafeState<T extends StatefulWidget> extends State<T> {
  late _StateType _stateType;

  @override
  @mustCallSuper
  void initState() {
    _stateType = _StateType.init;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    _stateType = _StateType.build;
    Widget widget = saveBuild(context);
    _stateType = _StateType.idle;
    return widget;
  }
  
  Widget saveBuild(BuildContext context);

  void setSafeState(VoidCallback fn) {
    if(_StateType.init == _stateType) {
      setState(fn);
    } else if(_StateType.build == _stateType) {
      setState(fn);
    } else if(_StateType.idle == _stateType) {
      setState(fn);
    } else if(_StateType.dispose == _stateType) {
      if(kDebugMode) {
        print('请不要在dispose状态里，去更新ui的状态。因为当前的组件已经被销毁');
      }
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    _stateType = _StateType.dispose;
  }

}