import 'package:flutter/material.dart';
import 'package:screen_app/common/device_mode/mode.dart';

class ModeItem extends StatelessWidget {
  final Mode mode;
  final bool selected; // 当前模式是否选中
  final void Function(Mode mode)? onTap;

  const ModeItem(
      {Key? key, required this.mode, this.selected = false, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selected) return;
        onTap?.call(mode);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selected ? Colors.white : const Color(0x4c000000),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Image(
              height: 42,
              width: 42,
              image: AssetImage(
                selected ? mode.onIcon : mode.offIcon,
              ),
            ),
          ),
          Text(
            mode.name,
            style: const TextStyle(
              fontFamily: 'MideaType-Regular',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0x7AFFFFFF),
              decoration: TextDecoration.none,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
