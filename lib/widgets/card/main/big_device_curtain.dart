import 'dart:async';

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
import '../../event_bus.dart';
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

  final void Function(BuildContext, DeviceCardDataAdapter)? goToPageDetailFunction;

  final AdapterGenerateFunction<DeviceCardDataAdapter> adapterGenerateFunction;

  const BigDeviceCurtainCardWidget(
      {super.key,
      required this.name,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      required this.adapterGenerateFunction,
      this.goToPageDetailFunction,
      this.hasMore = true,
      this.disabled = false,
      this.disableOnOff = true,
      this.discriminative = false,
      required this.applianceCode});

  @override
  _BigDeviceCurtainCardWidgetState createState() => _BigDeviceCurtainCardWidgetState();
}

class _BigDeviceCurtainCardWidgetState
    extends State<BigDeviceCurtainCardWidget> {
  bool _isFetching = false;
  Timer? _debounceTimer;

  late DeviceCardDataAdapter adapter;

  bool isOnlineState() {
    return adapter.fetchOnlineState(context, widget.applianceCode);
  }

  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(const Duration(milliseconds: 10000), () async {
        Log.i('触发更新');
        adapter.fetchData();
        _isFetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    adapter = widget.adapterGenerateFunction.call(widget.applianceCode);
    adapter.init();
    if (!widget.disabled) {
      adapter.bindDataUpdateFunction(updateCallback);
    }
  }

  @override
  void dispose() {
    super.dispose();
    adapter.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    if (mounted) {
      setState(() {
        adapter.data = adapter.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);

    String _getRightText() {
      if (widget.discriminative) {
        return '';
      }
      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      if (widget.disabled) {
        return '';
      }

      // if (widget.isFault) {
      //   return '故障';
      // }

      if (!isOnlineState()) {
        return '离线';
      }
      //
      // if (adapter.dataState == DataState.LOADING) {
      //   return '';
      // }
      //
      // if (adapter.dataState == DataState.NONE) {
      //   return '离线';
      // }

      if (adapter.dataState == DataState.ERROR) {
        return '离线';
      }

      return adapter.getCharacteristic() ?? '';
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: widget.applianceCode,
          maxLength: 6,
          startLength: 3,
          endLength: 2);

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
      String BigCardName = '';

      List<DeviceEntity> curOne = deviceListModel.deviceCacheList
          .where((element) => element.applianceCode == widget.applianceCode)
          .toList();
      if (curOne.isNotEmpty) {
        BigCardName = NameFormatter.formatName(curOne[0].roomName!, 6);
      } else {
        BigCardName = '未知区域';
      }

      if (widget.disabled) {
        return BigCardName;
      }

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return BigCardName;
    }

    BoxDecoration _getBoxDecoration() {
      bool curPower = adapter.getPowerStatus() ?? false;
      bool online = isOnlineState();
      if (!online) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.discriminative
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0x33616A76),
              widget.discriminative
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0x33434852),
            ],
            stops: [0.06, 1.0],
            transform: GradientRotation(213 * (3.1415926 / 360.0)),
          ),
        );
      }
      if ((curPower && !widget.disabled)) {
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

    return GestureDetector(
      onTap: () {
        if (adapter.dataState != DataState.SUCCESS) {
          adapter.fetchDataAndCheckWaitLockAuth(widget.applianceCode);
          TipsUtils.toast(content: '网络服务异常，控制设备失败');
          return;
        }
        if (!isOnlineState() && !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing: (!isOnlineState() || adapter.dataState != DataState.SUCCESS),
        child: Container(
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
                    if (adapter.dataState != DataState.SUCCESS) {
                      adapter.fetchData();
                      // TipsUtils.toast(content: '数据缺失，控制设备失败');
                      return;
                    }
                    if (!isOnlineState()) {
                      TipsUtils.toast(content: '设备已离线，请检查连接状态');
                      return;
                    }
                    if (!widget.disabled) {
                      // 2024/5/23 新增加一种跳入详情页的方式。针对wifi窗帘与zigbee窗帘
                      if (widget.goToPageDetailFunction != null) {
                        widget.goToPageDetailFunction!(context, adapter);
                      } else {
                        Navigator.pushNamed(context, '0x14', arguments: {
                          "name": getDeviceName(),
                          "adapter": adapter
                        });
                      }
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
                        constraints: BoxConstraints(
                            maxWidth: widget.isNative ? 100 : 140),
                        child: SizedBox(
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                getDeviceName(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      child: Text(
                          "${_getRightText().isNotEmpty ? ' | ' : ''}${_getRightText()}",
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          border: Border.all(
                              color: const Color(0xFFFFFFFF), width: 1),
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
                  top: 60,
                  left: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${adapter.getCardStatus()?['curtainPosition']}",
                          style: const TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 60,
                              height: 1.5,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                      const Text("%",
                          style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 18,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ],
                  )),
              Positioned(
                top: 74,
                left: 174,
                child: CupertinoSlidingSegmentedControl(
                  backgroundColor: (adapter.getPowerStatus() ?? false)
                      ? const Color(0xFF767D87)
                      : const Color(0xFF4C525E),
                  thumbColor: const Color(0xC1B7C4CF),
                  padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
                  children: {
                    0: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 11),
                      child: const Text('全开',
                          style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 16,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ),
                    1: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 11),
                      child: const Text('暂停',
                          style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 16,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ),
                    2: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 11),
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
                    if (adapter.getPowerStatus() != null && isOnlineState()) {
                      adapter.tabTo(value);
                      if (value == 1) {
                        _throttledFetchData();
                      }
                      bus.emit('operateDevice', widget.applianceCode);
                    }
                  },
                ),
              ),
              Positioned(
                top: 140,
                left: 4,
                child: MzSlider(
                  value: adapter.getCardStatus()?['curtainPosition'],
                  width: 390,
                  height: 16,
                  min: 0,
                  max: 100,
                  disabled: widget.disabled || !isOnlineState(),
                  activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
                  onChanging: (val, color) {
                    adapter.slider1ToFaker(val.toInt());
                  },
                  onChanged: (val, color) {
                    adapter.slider1To(val.toInt());
                    bus.emit('operateDevice', widget.applianceCode);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _getGroupIndex() {
    if (adapter == null) {
      return 2;
    }

    if (adapter.getCardStatus()?['curtainStatus'] == 'close') {
      return 2;
    }
    if (adapter.getCardStatus()?['curtainStatus'] == 'stop') {
      return 1;
    }
    if (adapter.getCardStatus()?['curtainStatus'] == 'open') {
      return 0;
    }
    return 2;
  }
}
