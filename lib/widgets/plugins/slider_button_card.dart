import 'package:flutter/material.dart';
import 'package:screen_app/widgets/mz_metal_card.dart';
import 'package:screen_app/widgets/mz_slider.dart';

class SliderButtonCard extends StatefulWidget {
  final String? title;
  final String unit;
  final num min;
  final num max;
  final num value;
  final num step;
  final bool disabled;
  final Duration? duration;
  final void Function(num value)? onChanged;

  const SliderButtonCard({
    super.key,
    this.title,
    this.unit = '°C',
    this.value = 30,
    this.step = 1,
    this.max = 60,
    this.min = 10,
    this.disabled = false,
    this.duration,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _SliderButtonCardState();
}

class _SliderButtonCardState extends State<SliderButtonCard> {
  // value 组件内部值
  late num value;

  // 判断是否需要更新value值
  @override
  void didUpdateWidget(SliderButtonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        value = _value;
      });
    }
  }

  // _value = 组件外实时传值，基于widget.value的计算值
  num get _value {
    final stepString = widget.step.toString();
    final precision = stepString.length - stepString.indexOf('.') - 1;
    var value = widget.value < widget.min
        ? widget.min
        : (widget.value > widget.max ? widget.max : widget.value);
    return num.parse((value).toStringAsFixed(precision));
  }

  @override
  void initState() {
    super.initState();
    value = _value;
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.title != null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 15),
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      fontFamily: "MideaType",
                      fontSize: 18,
                      height: 1.2,
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.only(
              top: widget.title != null ? 5 : 30,
              bottom: widget.title != null ? 0 : 15,
            ),
            child: ConstrainedBox(
              // 设置最小高度，防止fittedBox压缩时导致高度变化
              constraints: const BoxConstraints(minHeight: 64, maxHeight: 64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: RawMaterialButton(
                      onPressed: onDecreaseBtnPressed,
                      elevation: 2.0,
                      fillColor: const Color(0xffd8d8d8),
                      padding: const EdgeInsets.all(4),
                      shape: const CircleBorder(),
                      constraints:
                          const BoxConstraints(minHeight: 32, minWidth: 32),
                      child: const Icon(
                        Icons.remove_rounded,
                        size: 28.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // 先让中间内容占满宽度
                  Expanded(
                    flex: 1,
                    // 然后使用FittedBox保证宽度不会超出Expanded
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 在设计稿中间的数值需要居中，所以左边也需要设置一个等宽的文字，将数值挤到中间
                          Text(
                            widget.unit,
                            style: const TextStyle(
                              fontFamily: 'MideaType',
                              fontSize: 18,
                              height: 1.7,
                              color: Colors.transparent,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            value.toString(),
                            textHeightBehavior: const TextHeightBehavior(
                                applyHeightToLastDescent: false,
                                applyHeightToFirstAscent: false),
                            style: const TextStyle(
                              height: 1,
                              fontFamily: 'MideaType',
                              fontSize: 56,
                              textBaseline: TextBaseline.ideographic,
                              color: Color(0xffd8d8d8),
                              fontWeight: FontWeight.w200,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            widget.unit,
                            style: const TextStyle(
                              fontFamily: 'MideaType',
                              fontSize: 18,
                              height: 1.7,
                              color: Color(0xff959595),
                              fontWeight: FontWeight.w200,
                              decoration: TextDecoration.none,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: RawMaterialButton(
                      onPressed: onIncreaseBtnPressed,
                      elevation: 2.0,
                      fillColor: const Color(0xffd8d8d8),
                      padding: const EdgeInsets.all(4),
                      shape: const CircleBorder(),
                      constraints:
                          const BoxConstraints(minHeight: 32, minWidth: 32),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 28.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MzSlider(
            value: value,
            width: 270,
            max: widget.max,
            min: widget.min,
            step: widget.step,
            disabled: widget.disabled,
            duration: widget.duration ?? const Duration(milliseconds: 100),
            onChanging: (e, _) => setState(() {
              value = e;
            }),
            onChanged: (e, _) => setState(() {
              value = e;
              widget.onChanged?.call(value);
            }),
          )
        ],
      ),
    );
  }

  onDecreaseBtnPressed() {
    setState(() {
      if (widget.disabled) return;
      if (value - widget.step > widget.min) {
        // 下一步没小于最小值，需要用步长进行计算
        final stepString = widget.step.toString();
        if (stepString.contains('.')) {
          // 步长存在小数，需要按照步长的精度进行计算
          final precision = stepString.length - stepString.indexOf('.') - 1;
          value = num.parse((value - widget.step).toStringAsFixed(precision));
        } else {
          value -= widget.step;
        }
      } else {
        // 不能超出最小值范围
        value = widget.min;
      }
      widget.onChanged?.call(value);
    });
  }

  onIncreaseBtnPressed() {
    setState(() {
      if (widget.disabled) return;
      if (value + widget.step < widget.max) {
        final stepString = widget.step.toString();
        if (stepString.contains('.')) {
          final precision = stepString.length - stepString.indexOf('.') - 1;
          value = num.parse((value + widget.step).toStringAsFixed(precision));
        } else {
          value += widget.step;
        }
      } else {
        value = widget.max;
      }
      widget.onChanged?.call(value);
    });
  }
}
