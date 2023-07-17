import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';

import '../../../widgets/card/main/middle_device.dart';

class CardDialog extends StatefulWidget {
  final String type;
  final String name;
  final String roomName;
  final String modelNumber;

  const CardDialog(
      {super.key,
      required this.type,
      required this.name,
      required this.roomName,
      required this.modelNumber});

  @override
  _CardDialogState createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 在这里构建对话框的外观
    return Align(
      alignment: Alignment.center,
      child: Dialog(
        // 对话框内容
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          height: 265,
          decoration: const BoxDecoration(
            color: Color(0xFF494E59),
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // 调用取消操作
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close_rounded, size: 32),
                  ),
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(_getCardType());
                    },
                    child: const Icon(Icons.check_rounded, size: 32),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    UnconstrainedBox(
                      child: SmallDeviceCardWidget(
                        name: widget.name,
                        icon: Image(
                          image: AssetImage(
                              '${_getIconUrl(widget.type, widget.modelNumber)}'),
                        ),
                        onOff: true,
                        roomName: widget.roomName,
                        characteristic: '',
                        online: true,
                        isFault: false,
                        isNative: false,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.75,
                      child: UnconstrainedBox(
                        child: MiddleDeviceCardWidget(
                          name: widget.name,
                          icon: Image(
                            image: AssetImage(
                                '${_getIconUrl(widget.type, widget.modelNumber)}'),
                          ),
                          onOff: true,
                          roomName: widget.roomName,
                          characteristic: '',
                          online: true,
                          isFault: false,
                          isNative: false,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Transform.translate(
                            offset: const Offset(-45, 0),
                            child: Transform.scale(
                              scale: 0.75,
                              child: BigDeviceLightCardWidget(
                                name: widget.name,
                                onOff: true,
                                roomName: widget.roomName,
                                online: true,
                                isFault: false,
                                isNative: false,
                                brightness: 10,
                                colorTemp: 10,
                                colorPercent: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  onPageChanged: (index) {
                    _handlePageChange(index);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: _currentIndex == 0 ? 22 : 14,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: _currentIndex == 0
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Container(
                    width: _currentIndex == 1 ? 22 : 14,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: _currentIndex == 1
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Container(
                    width: _currentIndex == 2 ? 22 : 14,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: _currentIndex == 2
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    Map<int, String> titleMap = {0: '小卡片', 1: '中卡片', 2: '大卡片'};
    return titleMap[_currentIndex] ?? '卡片';
  }

  CardType _getCardType() {
    Map<int, CardType> cardTypeMap = {0: CardType.Small, 1: CardType.Middle, 2: CardType.Big};
    return cardTypeMap[_currentIndex] ?? CardType.Small;
  }

  _getIconUrl(String type, String modelNum) {
    if (type == '0x21') {
      return 'assets/newUI/device/${type}_${modelNum}.png';
    } else {
      return 'assets/newUI/device/${type}.png';
    }
  }
}
