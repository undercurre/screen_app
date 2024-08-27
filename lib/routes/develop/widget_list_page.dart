import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

import '../../common/logcat_helper.dart';

class _TypeWidgetParams {
  String type;

  WidgetBuilder builder;

  _TypeWidgetParams({required this.type, required this.builder});
}

class WidgetListPage extends StatefulWidget {

  final widgets = <_TypeWidgetParams>[
    _TypeWidgetParams(
        type: "Slider",
        builder: (ctx) {
          return MzSlider(
            step: 1,
            value: 0,
            width: 400,
            height: 16,
            min: 0,
            max: 100,
            onChanged: (val, color) {

            },
          );
        }
    ),
    _TypeWidgetParams(
        type: "Slider",
        builder: (ctx) {
          return MzSlider.createDottedLineSlider(
              value: 0.0,
              max: 10,
              min: 0,
              step: 2,
              width: 400,
              height: 40,
              onChanged: (value, _) {
                Log.i("#onChange $value");
              },
              onChanging: (value, _) {
                // Log.i("#onChanging $value");
              });
        }),
  ];

  WidgetListPage({super.key});

  @override
  State<WidgetListPage> createState() => _WidgetListPageState();
}

class _WidgetListPageState extends State<WidgetListPage> {
  late List<_TypeWidgetParams> childWidget;

  @override
  void initState() {
    super.initState();
    Log.d("initState");
    childWidget = [];
    widget.widgets.sort((a, b) => a.type.compareTo(b.type));
    _TypeWidgetParams? lastElement;
    for (var element in widget.widgets) {
      if (lastElement == null || lastElement.type != element.type) {
        childWidget.add(_TypeWidgetParams(
            type: "Divider_Header",
            builder: (ctx) {
              return _DividerHeader(headerText: element.type);
            }));
      }
      lastElement = element;
      childWidget.add(element);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant WidgetListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d("didUpdateWidget");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();},
        ),
        title: const Text("Widget组件"),
      ),
      body: ListView.custom(
          childrenDelegate: SliverChildBuilderDelegate((ctx, index) {
            return childWidget[index].builder(ctx);
          }, childCount: childWidget.length
          )),
    );
  }
}

class _DividerHeader extends StatelessWidget {
  final String headerText;

  const _DividerHeader({super.key, required this.headerText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 40,
      child: ListTile(
        leading: const Icon(Icons.account_balance, color: Colors.orange),
        textColor: Colors.blueAccent,
        title: Text(headerText, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
