import 'package:flutter/material.dart';

class LiangyiEntity extends StatefulWidget {
  final bool light;

  const LiangyiEntity({super.key, required this.light});

  @override
  LiangyiEntityState createState() => LiangyiEntityState();
}

class LiangyiEntityState extends State<LiangyiEntity> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
            top: 123,
            child: Image(
              image: AssetImage('assets/imgs/plugins/0x17/entity_board.png'),
            )),
        const Positioned(
            top: 140,
            left: 60,
            child: Image(
                image:
                    AssetImage('assets/imgs/plugins/0x17/entity_lianzi.png'))),
        const Positioned(
            top: 123,
            child: Image(
                image:
                    AssetImage('assets/imgs/plugins/0x17/entity_light.png'))),
        Positioned(
            top: 123,
            child: Opacity(
              opacity: widget.light ? 1 : 0,
              child: const Image(
              image: AssetImage('assets/imgs/plugins/0x17/entity_light_on.png'),
            ),
          ),
        ),
        const Positioned(
            top: 123,
            child: Image(
                image:
                    AssetImage('assets/imgs/plugins/0x17/entity_handle.png'))),
      ],
    );
  }
}
