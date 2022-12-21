import 'package:flutter/material.dart';
import 'package:screen_app/mixins/auto_sniffer.dart';

class CenterControlPage extends StatefulWidget {
  const CenterControlPage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _CenterControlPageState();
}

class _CenterControlPageState extends State<CenterControlPage> with AutoSniffer {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
