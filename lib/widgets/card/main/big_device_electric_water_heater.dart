import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../event_bus.dart';
import '../../mz_slider.dart';
import '../../util/nameFormatter.dart';
import '../method.dart';

class BigDeviceElectricWaterHeaterWidget extends StatefulWidget {
  final String applianceCode;
  final String name;
  final bool online;
  final bool isFault;
  final bool isNative;
  final String roomName;
  final bool disableOnOff;
  final bool discriminative;
  final bool hasMore;
  final bool disabled;

  AdapterGenerateFunction<DeviceCardDataAdapter> adapterGenerateFunction;

  BigDeviceElectricWaterHeaterWidget(
      {super.key,
      required this.name,
      required this.roomName,
      required this.online,
      required this.isFault,
      required this.isNative,
      required this.adapterGenerateFunction,
      this.hasMore = true,
      this.disabled = false,
      this.disableOnOff = true,
      this.discriminative = false,
      required this.applianceCode});

  @override
  _BigDeviceElectricWaterHeaterWidgetState createState() => _BigDeviceElectricWaterHeaterWidgetState();
}

class _BigDeviceElectricWaterHeaterWidgetState extends State<BigDeviceElectricWaterHeaterWidget> {
  late DeviceCardDataAdapter adapter;

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
      Log.i('大卡片状态更新');
      setState(() {
        adapter.data = adapter.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);

    String _getRightText() {
      if (widget.discriminative) {
        return '';
      }
      if (deviceListModel.deviceListHomlux.isEmpty && deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      if (widget.disabled) {
        return '';
      }

      // if (widget.isFault) {
      //   return '故障';
      // }

      if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
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

      // if (adapter.dataState == DataState.ERROR) {
      //   return '离线';
      // }

      return '在线';
    }

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(deviceId: widget.applianceCode, maxLength: 6, startLength: 3, endLength: 2);

      if (widget.disabled) {
        return (nameInModel == '未知id' || nameInModel == '未知设备') ? widget.name : nameInModel;
      }

      if (deviceListModel.deviceListHomlux.isEmpty && deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return nameInModel;
    }

    String getRoomName() {
      String BigCardName = '';

      List<DeviceEntity> curOne =
          deviceListModel.deviceCacheList.where((element) => element.applianceCode == widget.applianceCode).toList();
      if (curOne.isNotEmpty) {
        BigCardName = NameFormatter.formatName(curOne[0].roomName!, 6);
      } else {
        BigCardName = '未知区域';
      }

      if (widget.disabled) {
        return BigCardName;
      }

      if (deviceListModel.deviceListHomlux.isEmpty && deviceListModel.deviceListMeiju.isEmpty) {
        return '';
      }

      return BigCardName;
    }

    BoxDecoration _getBoxDecoration() {
      bool curPower = adapter.getPowerStatus() ?? false;
      bool online = deviceListModel.getOnlineStatus(deviceId: widget.applianceCode);
      if (widget.isFault) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: getBigCardColorBg('fault'),
        );
      }
      if (!online) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'),
        );
      }
      if ((curPower && !widget.disabled)) {
        return BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          gradient: getBigCardColorBg('open'),
        );
      }
      return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: widget.discriminative ? getBigCardColorBg('discriminative') : getBigCardColorBg('disabled'),
      );
    }

    return GestureDetector(
      onTap: () {
        if (adapter.dataState != DataState.SUCCESS) {
          adapter.fetchDataAndCheckWaitLockAuth(widget.applianceCode);
          // TipsUtils.toast(content: '数据缺失，控制设备失败');
          return;
        }
        if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) && !widget.disabled) {
          TipsUtils.toast(content: '设备已离线，请检查连接状态');
          return;
        }
      },
      child: AbsorbPointer(
        absorbing: (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) || adapter.dataState != DataState.SUCCESS),
        child: Container(
          width: 440,
          height: 196,
          decoration: _getBoxDecoration(),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    Log.i('disabled: ${widget.disabled}');
                    if (!widget.disabled && deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
                      adapter.power(
                        adapter.getPowerStatus(),
                      );
                      bus.emit('operateDevice', widget.applianceCode);
                    }
                  },
                  child: Image(
                      width: 40,
                      height: 40,
                      image: AssetImage(
                          adapter.getPowerStatus() ?? false ? 'assets/newUI/card_power_on.png' : 'assets/newUI/card_power_off.png')),
                ),
              ),

              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    if (adapter.dataState != DataState.SUCCESS) {
                      adapter.fetchData();
                      // TipsUtils.toast(content: '数据缺失，控制设备失败');
                    }
                    if (!deviceListModel.getOnlineStatus(deviceId: widget.applianceCode)) {
                      TipsUtils.toast(content: '设备已离线，请检查连接状态');
                      return;
                    }

                    Navigator.pushNamed(context, '0xE2', arguments: {"name": widget.name, "adapter": adapter});
                  },
                  child: widget.hasMore ? const Image(width: 32, height: 32, image: AssetImage('assets/newUI/to_plugin.png')) : Container(),
                ),
              ),
              Positioned(
                top: 10,
                left: 88,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 设备名
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: widget.isNative ? 100 : 140),
                        child: Text(getDeviceName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: 22,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),
                      ),
                    ),
                    // 房间名
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
                      child: Text(" ${_getRightText().isNotEmpty ? '|' : ''} ${_getRightText()}",
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
                          border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
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
              // 加减按钮组
              Positioned(
                top: 62,
                left: 20,
                child: SizedBox(
                  height: 84,
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!widget.disabled &&
                              deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) &&
                              (adapter.getPowerStatus() ?? false)) {
                            int value = adapter!.getCardStatus()?["temperature"] - 5;
                            if (value < 30) {
                              return;
                            }
                            adapter.reduceTo(value);
                            bus.emit('operateDevice', widget.applianceCode);
                          }
                        },
                        child: Image(
                            color: Color.fromRGBO(255, 255, 255, (adapter.getPowerStatus() ?? false) ? 1 : 0.7),
                            width: 36,
                            height: 36,
                            image: const AssetImage('assets/newUI/sub.png')),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_getTempVal()}",
                              style: TextStyle(
                                  height: 1.5,
                                  color: (adapter.getPowerStatus() ?? false) ? const Color(0XFFFFFFFF) : const Color(0XA3FFFFFF),
                                  fontSize: 60,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none)),
                          Text("℃",
                              style: TextStyle(
                                  height: 1.5,
                                  color: (adapter.getPowerStatus() ?? false) ? const Color(0XFFFFFFFF) : const Color(0XA3FFFFFF),
                                  fontSize: 18,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none))
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!widget.disabled &&
                              deviceListModel.getOnlineStatus(deviceId: widget.applianceCode) &&
                              (adapter.getPowerStatus() ?? false)) {
                            int value = adapter!.getCardStatus()?["temperature"] + 5;
                            if (value > 75) {
                              return;
                            }
                            adapter.increaseTo(value);
                            bus.emit('operateDevice', widget.applianceCode);
                          }
                        },
                        child: Image(
                            color: Color.fromRGBO(255, 255, 255, (adapter.getPowerStatus() ?? false) ? 1 : 0.7),
                            width: 36,
                            height: 36,
                            image: const AssetImage('assets/newUI/add.png')),
                      ),
                    ],
                  ),
                ),
              ),
              // 滑动条
              Positioned(
                top: 140,
                left: 4,
                child: MzSlider(
                  step: 5,
                  value: _getTempVal(),
                  width: 390,
                  height: 16,
                  min: 30,
                  max: 75,
                  disabled: widget.disabled ||
                      !(adapter.getPowerStatus() ?? false) ||
                      !deviceListModel.getOnlineStatus(deviceId: widget.applianceCode),
                  activeColors: const [Color(0xFF56A2FA), Color(0xFF6FC0FF)],
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

  num _getTempVal() {
    if (adapter == null || adapter.dataState != DataState.SUCCESS) {
      return 35;
    }
    return adapter!.getCardStatus()?["temperature"];
  }
}
