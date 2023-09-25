import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../mz_slider.dart';

class BigDeviceCurtainCardWidget extends StatefulWidget {
  final String applianceCode;
  final String name;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disabled;
  final bool hasMore;
  final bool disableOnOff;
  final bool discriminative;

  final DeviceCardDataAdapter? adapter;

  const BigDeviceCurtainCardWidget(
      {super.key,
      required this.name,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      this.adapter,
      this.hasMore = true,
      this.disabled = false,
      this.disableOnOff = true,
      this.discriminative = false,
      required this.applianceCode});

  @override
  _BigDeviceCurtainCardWidgetState createState() =>
      _BigDeviceCurtainCardWidgetState();
}

class _BigDeviceCurtainCardWidgetState
    extends State<BigDeviceCurtainCardWidget> {
  @override
  void initState() {
    super.initState();
    if (!widget.disabled) {
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void didUpdateWidget(covariant BigDeviceCurtainCardWidget oldWidget) {
    if (!widget.disabled) {
      widget.adapter?.bindDataUpdateFunction(updateCallback);
      widget.adapter?.init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter?.destroy();
    widget.adapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    if (mounted) {
      setState(() {
        widget.adapter?.data = widget.adapter?.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);
    final layoutModel = context.read<LayoutModel>();
    // if (mounted) {
    //   if (layoutModel.hasLayoutWithDeviceId(widget.applianceCode) &&
    //       deviceListModel.deviceCacheList.isNotEmpty) {
    //     List<DeviceEntity> hitList = deviceListModel.deviceCacheList.where((
    //         element) => element.applianceCode == widget.applianceCode).toList();
    //     if (hitList.isEmpty) {
    //       layoutModel.deleteLayout(widget.applianceCode);
    //       TipsUtils.toast(content: '已删除${hitList[0].name}');
    //     }
    //   }
    // }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
        deviceId: widget.applianceCode,
      );

      if (widget.disabled) {
        return (nameInModel == '未知id' || nameInModel == '未知设备')
            ? widget.name
            : nameInModel;
      }

      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '加载中';
      }

      return nameInModel;
    }

    String getRoomName() {
      if (widget.disabled) {
        return widget.roomName;
      }

      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '';
      }

      return deviceListModel.getDeviceRoomName(
          deviceId: widget.applianceCode);
    }

    return Container(
      width: 440,
      height: 196,
      decoration: _getBoxDecoration(),
      child: Stack(
        children: [
          const Positioned(
            top: 14,
            left: 24,
            child: Image(
                width: 40,
                height: 40,
                image: AssetImage('assets/newUI/device/0x14.png')),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)){
                  TipsUtils.toast(content: '设备已离线，请检查连接状态');
                  return;
                }

                if (!widget.disabled) {
                  Navigator.pushNamed(context, '0x14', arguments: {
                    "name": getDeviceName(),
                    "adapter": widget.adapter
                  });
                }
              },
              child: widget.hasMore
                  ? const Image(
                      width: 32,
                      height: 32,
                      image: AssetImage('assets/newUI/to_plugin.png'))
                  : Container(),
            ),
          ),
          Positioned(
            top: 10,
            left: 88,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: widget.isNative ? 100 : 140),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 76,
                            ),
                            child: Text(
                              getDeviceName()
                                  .substring(0, getDeviceName().length - 1),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: 'MideaType',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            getDeviceName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'MideaType',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(getRoomName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(" | ${_getRightText()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0XA3FFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
                if (widget.isNative)
                  Container(
                    alignment: Alignment.center,
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      border:
                          Border.all(color: const Color(0xFFFFFFFF), width: 1),
                    ),
                    margin: const EdgeInsets.fromLTRB(12, 0, 0, 6),
                    child: const Text(
                      "本地",
                      style: TextStyle(
                          height: 1.6,
                          color: Color(0XFFFFFFFF),
                          fontSize: 14,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                    ),
                  )
              ],
            ),
          ),
          Positioned(
            top: 44,
            left: 32,
            child: Text(
                "${widget.adapter!.getCardStatus()?['curtainPosition'] == 0 ? '全关' : widget.adapter!.getCardStatus()?['curtainPosition'] == 100 ? '全开' : widget.adapter!.getCardStatus()?['curtainPosition']}",
                style: const TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 60,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)),
          ),
          if (widget.adapter!.getCardStatus()?['curtainPosition'] > 0 &&
              widget.adapter!.getCardStatus()?['curtainPosition'] < 100)
            const Positioned(
              top: 66,
              left: 114,
              child: Text("%",
                  style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 18,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
            ),
          Positioned(
            top: 74,
            left: 174,
            child: CupertinoSlidingSegmentedControl(
              backgroundColor: (widget.adapter?.getPowerStatus() ?? false)
                  ? const Color(0xFF767D87)
                  : const Color(0xFF4C525E),
              thumbColor: const Color(0xC1B7C4CF),
              padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
              children: {
                0: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                  child: const Text('全开',
                      style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
                1: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                  child: const Text('暂停',
                      style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                ),
                2: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                  child: const Text('全关',
                      style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 16,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)),
                )
              },
              groupValue: _getGroupIndex(),
              onValueChanged: (int? value) {
                if (widget.adapter?.getPowerStatus() != null) {
                  widget.adapter?.tabTo(value);
                }
              },
            ),
          ),
          Positioned(
            top: 140,
            left: 4,
            child: MzSlider(
              value: widget.adapter!.getCardStatus()?['curtainPosition'],
              width: 390,
              height: 16,
              min: 0,
              max: 100,
              disabled: false,
              activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
              onChanged: (val, color) {
                widget.adapter?.slider1To(val.toInt());
              },
            ),
          ),
        ],
      ),
    );
  }

  int? _getGroupIndex() {
    if (widget.adapter == null) {
      return 2;
    }
    ;
    if (widget.adapter!.getCardStatus()?['curtainStatus'] == 'close') {
      return 2;
    }
    if (widget.adapter!.getCardStatus()?['curtainStatus'] == 'stop') {
      return 1;
    }
    if (widget.adapter!.getCardStatus()?['curtainStatus'] == 'open') {
      return 0;
    }
    return 2;
  }

  String? _getRightText() {
    if (widget.isFault) {
      return '故障';
    }
    if (!widget.online) {
      return '离线';
    }

    if (widget.disabled) {
      return '';
    }

    if (widget.adapter?.dataState == DataState.LOADING) {
      return '在线';
    }

    if (widget.adapter?.dataState == DataState.NONE) {
      return '离线';
    }

    if (widget.adapter?.dataState == DataState.ERROR) {
      return '离线';
    }

    return widget.adapter?.getCharacteristic();
  }

  BoxDecoration _getBoxDecoration() {
    bool curPower = widget.adapter?.getPowerStatus() ?? false;
    // if ((curPower && widget.online && !widget.disabled) ||
    //     (widget.disabled && widget.disableOnOff)) {

    if ((curPower && widget.online && !widget.disabled) || widget.disabled) {
      return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF818895),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
        ),
      );
    }
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          widget.discriminative
              ? Colors.white.withOpacity(0.12)
              : const Color(0x33616A76),
          widget.discriminative
              ? Colors.white.withOpacity(0.12)
              : const Color(0x33434852),
        ],
      ),
    );
  }
}
