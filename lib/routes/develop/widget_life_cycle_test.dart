import 'package:flutter/cupertino.dart';

import '../../common/logcat_helper.dart';

class WidgetLifeCycleTest extends StatefulWidget {

  final Widget child;

  const WidgetLifeCycleTest({super.key, required this.child});

  @override
  State<WidgetLifeCycleTest> createState() => _WidgetLifeCycleTestState();

}

class _WidgetLifeCycleTestState extends State<WidgetLifeCycleTest> {

  _WidgetLifeCycleTestState() {
    Log.develop("[life] $hashCode MethodName(construct)");
  }

  @override
  void initState() {
    super.initState();
    Log.develop("[life] $hashCode MethodName(initState)");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.develop("[life] $hashCode MethodName(didChangeDependencies)");
  }

  @override
  void didUpdateWidget(covariant WidgetLifeCycleTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.develop("[life] $hashCode MethodName(didUpdateWidget)");
  }

  @override
  void activate() {
    super.activate();
    // Log.develop("[life] $hashCode MethodName(activate)");
  }

  @override
  void deactivate() {
    super.deactivate();
    // Log.develop("[life] $hashCode MethodName(deactivate)");
  }

  @override
  void dispose() {
    super.dispose();
    Log.develop("[life] $hashCode MethodName(dispose)");
  }

  @override
  Widget build(BuildContext context) {
    // Log.develop("[life] $hashCode MethodName(build)");
    return Stack(children: [widget.child]);
  }

}
