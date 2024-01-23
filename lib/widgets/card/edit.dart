import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/states/page_change_notifier.dart';

import '../../states/layout_notifier.dart';
import '../event_bus.dart';

class EditCardWidget extends StatelessWidget {
  const EditCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
    // final pageCounterModel = Provider.of<PageCounter>(context);
    // return GestureDetector(
    //   onTap: () async {
    //     /// 跳到编辑页去
    //     Navigator.pushNamed(
    //       context,
    //       'Custom',
    //     );
    //     bus.emit('mainToRecoverState', pageCounterModel.currentPage);
    //   },
    //   child: SizedBox(
    //     width: 440,
    //     height: 88,
    //     child: Align(
    //       alignment: Alignment.center,
    //       child: Container(
    //         width: 172,
    //         height: 56,
    //         decoration: BoxDecoration(
    //           border: Border.all(
    //             color: const Color.fromRGBO(255, 255, 255, 0.23),
    //             width: 1.0,
    //           ),
    //           borderRadius: BorderRadius.circular(31),
    //         ),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Container(
    //               margin: const EdgeInsets.only(right: 10),
    //               child: Icon(Icons.add,
    //                   size: 24, color: Colors.white.withOpacity(0.72)),
    //             ),
    //             Text(
    //               '自定义',
    //               style: TextStyle(
    //                 fontFamily: 'PingFangSC-Regular',
    //                 fontSize: 20,
    //                 color: Colors.white.withOpacity(0.72),
    //                 letterSpacing: 0,
    //                 height: 1.2,
    //                 fontWeight: FontWeight.w400,
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
