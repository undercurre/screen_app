import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';
import 'package:screen_app/widgets/keep_alive_wrapper.dart';
import 'package:screen_app/widgets/paragraph_indicator.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';

import '../../../common/global.dart';
import '../../../common/logcat_helper.dart';
import '../../../widgets/card/main/middle_device.dart';
import '../../../widgets/card/main/panelNum.dart';
import '../../../widgets/util/deviceEntityTypeInP4Handle.dart';

class CardDialogScene extends StatefulWidget {
  final String sceneId;
  final String name;
  final String? icon;
  int? initPageNum;

  CardDialogScene({super.key, required this.sceneId, required this.name, this.icon, this.initPageNum});

  @override
  _CardDialogSceneState createState() => _CardDialogSceneState();
}

class _CardDialogSceneState extends State<CardDialogScene> {
  late PageController _pageController;
  int _currentIndex = 0;

  // 用于pageView的indicator（指示器）更新
  GlobalKey<ParagraphIndicatorState> indicatorState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initPageNum ?? 0);
    _currentIndex = widget.initPageNum ?? 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int index) {
    _currentIndex = index;
    indicatorState.currentState?.updateIndicator(index);
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
          height: 300,
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
                    NameFormatter.formatName(widget.name, 4),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'MideaType',
                      fontWeight: FontWeight.w400,
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
                child: Column(children: [
                  Text(
                    '点击卡片可试一试场景',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      allowImplicitScrolling: true,
                      children: [
                        if (buildMap[DeviceEntityTypeInP4.Scene]![CardType.Small] != null)
                          KeepAliveWrapper(
                            child: UnconstrainedBox(
                              child: buildMap[DeviceEntityTypeInP4.Scene]![CardType.Small]!(
                                DataInputCard(
                                  disabled: false,
                                  discriminative: true,
                                  disableOnOff: true,
                                  name: widget.name,
                                  icon: widget.icon,
                                  sceneId: widget.sceneId,
                                  type: '',
                                  applianceCode: '',
                                  roomName: '',
                                  masterId: '',
                                  modelNumber: '',
                                  isOnline: '',
                                  onlineStatus: '',
                                ),
                              ),
                            ),
                          ),
                        if (buildMap[DeviceEntityTypeInP4.Scene]![CardType.Middle] != null)
                          KeepAliveWrapper(
                            child: Transform.scale(
                              scale: 0.75,
                              child: UnconstrainedBox(
                                child: buildMap[DeviceEntityTypeInP4.Scene]![CardType.Middle]!(
                                  DataInputCard(
                                    disabled: false,
                                    discriminative: true,
                                    disableOnOff: true,
                                    name: widget.name,
                                    icon: widget.icon,
                                    sceneId: widget.sceneId,
                                    type: '',
                                    applianceCode: '',
                                    roomName: '',
                                    masterId: '',
                                    modelNumber: '',
                                    isOnline: '',
                                    onlineStatus: '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                      onPageChanged: (index) {
                        _handlePageChange(index);
                      },
                    ),
                  ),
                ]),
              ),
              ParagraphIndicator(key: indicatorState, defaultPosition: _currentIndex, itemCount: _getItemCount()),
            ],
          ),
        ),
      ),
    );
  }

  int _getItemCount() {
    int lang = 0;
    if (buildMap[DeviceEntityTypeInP4.Scene]![CardType.Small] != null) lang++;
    if (buildMap[DeviceEntityTypeInP4.Scene]![CardType.Middle] != null) lang++;

    return lang;
  }

  String _getTitle(CardType cardType) {
    Map<CardType, String> titleMap = {CardType.Small: '小卡片', CardType.Middle: '中卡片', CardType.Big: '大卡片'};
    return titleMap[cardType] ?? '卡片';
  }

  CardType _getCardType() {
    Map<int, CardType> cardTypeMap = {0: CardType.Small, 1: CardType.Middle, 2: CardType.Big};
    return cardTypeMap[_currentIndex] ?? CardType.Small;
  }

  CardType _getPanelCardType(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return CardType.Small;
    }
    return panelList[modelNum] ?? CardType.Small;
  }

  bool _isPanel(String modelNum, String? type) {
    if (type != null && (type == 'localPanel1' || type == 'localPanel2')) {
      return true;
    }

    return panelList.containsKey(modelNum);
  }
}
