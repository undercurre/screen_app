import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/routes/home/center_control/service.dart';
import 'package:screen_app/routes/sniffer/device_item.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/global.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../widgets/business/dropdown_menu.dart' as ui;
import '../../../widgets/event_bus.dart';
import '../../../widgets/mz_metal_card.dart';
import '../../../widgets/mz_notice.dart';
import '../../../widgets/plugins/slider_button_content.dart';

class ViewPart extends StatefulWidget {
  final String mark;
  final Widget child;

  const ViewPart({super.key, required this.mark, required this.child});

  @override
  ViewPartState createState() => ViewPartState();
}

class ViewPartState extends State<ViewPart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
