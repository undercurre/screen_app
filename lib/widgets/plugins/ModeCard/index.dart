import 'dart:core';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/GlassCard/index.dart';

class Mode {
  String index;
  String name;
  bool selected;

  Mode(this.index, this.name, this.selected);

  void select() {
    selected = true;
  }
}

class ModeCard extends StatefulWidget {

  const ModeCard({
    super.key,
  });

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  late List<Mode> modeList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GlassCard(child: )

    throw UnimplementedError();
  }

}