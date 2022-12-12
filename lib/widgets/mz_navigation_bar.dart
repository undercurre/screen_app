import 'package:flutter/material.dart';

class MzNavigationBar extends StatefulWidget {
  final String title;
  final String? desc;
  final bool power;
  final bool hasPower;
  final bool isLoading;
  final void Function()? onPowerBtnTap;
  final void Function()? onLeftBtnTap;

  const MzNavigationBar({
    super.key,
    this.title = '',
    this.desc,
    this.power = false,
    this.hasPower = false,
    this.isLoading = false,
    this.onPowerBtnTap,
    this.onLeftBtnTap,
  });

  @override
  State<StatefulWidget> createState() => _MzNavigationBarState();
}

class _MzNavigationBarState extends State<MzNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => widget.onLeftBtnTap?.call(),
          child: Container(
            color: Colors.transparent,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Image(
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                image: AssetImage('assets/imgs/plugins/common/arrow_left.png'),
              ),
            ),
          ),
        ),
        // Text(
        //   widget.title,
        //   style: const TextStyle(
        //     fontSize: 24,
        //     color: Colors.white,
        //     fontFamily: "MideaType",
        //     fontWeight: FontWeight.w400,
        //     decoration: TextDecoration.none,
        //   ),
        // ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 28,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        height: 1.6,
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    )),
                SizedBox(
                  width: 28,
                  child: (widget.isLoading)
                      ? const Image(
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          image: AssetImage('assets/imgs/loading.gif'),
                        )
                      : null,
                ),
              ],
            ),
            if (widget.desc != null)
              Text(
                widget.desc!,
                style: const TextStyle(
                  height: 1,
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.w100,
                  decoration: TextDecoration.none,
                ),
              )
          ],
        ),
        GestureDetector(
          onTap: () => widget.onPowerBtnTap?.call(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
            child: widget.hasPower
                ? Image(
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    image: AssetImage(
                      widget.power
                          ? 'assets/imgs/plugins/common/power_on.png'
                          : 'assets/imgs/plugins/common/power_off.png',
                    ),
                  )
                : const SizedBox(
                    width: 60,
                    height: 60,
                  ),
          ),
        )
      ],
    );
  }
}
