import 'package:flutter/material.dart';

import '../../widgets/business/select_room.dart';
import '../../widgets/mz_navigation_bar.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => RoomPageState();
}

class RoomPageState extends State<RoomPage> {

  void goBack() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Container(
            color: Colors.black,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                maxHeight: 60.0,
              ),
              child: MzNavigationBar(
                onLeftBtnTap: goBack,
                title: '选择房间',
                hasPower: false,
              ),
            ),
          ),
          const Expanded(
              flex: 1,
              child: SelectRoom()
          )
        ]
    );
  }
}
