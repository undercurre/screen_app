import 'package:flutter/cupertino.dart';

import '../../common/logcat_helper.dart';

class WidgetLifeCycleTest extends StatefulWidget {

  final Widget child;

  WidgetLifeCycleTest({super.key, required this.child}) {
    Log.develop("[life] widget $hashCode MethodName(construct)");
  }

  @override
  // ignore: no_logic_in_create_state
  State<WidgetLifeCycleTest> createState() {
    var state = _WidgetLifeCycleTestState();
    Log.develop("[life] widget $hashCode MethodName(createState${state.hashCode})");
    return state;
  }

}

class _WidgetLifeCycleTestState extends State<WidgetLifeCycleTest> {

  _WidgetLifeCycleTestState() {
    Log.develop("[life] state $hashCode MethodName(construct)");
  }

  @override
  void initState() {
    super.initState();
    Log.develop("[life] state $hashCode MethodName(initState)");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.develop("[life] state $hashCode MethodName(didChangeDependencies)");
  }

  @override
  void didUpdateWidget(covariant WidgetLifeCycleTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.develop("[life] state $hashCode MethodName(didUpdateWidget)");
  }

  @override
  void activate() {
    super.activate();
    Log.develop("[life] state $hashCode MethodName(activate)");
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.develop("[life] state $hashCode MethodName(deactivate)");
  }

  @override
  void dispose() {
    super.dispose();
    Log.develop("[life] state $hashCode MethodName(dispose)");
  }

  @override
  Widget build(BuildContext context) {
    Log.develop("[life] state $hashCode MethodName(build)");
    return Stack(children: [widget.child]);
  }

}
