import 'package:flutter/widgets.dart';

class MzRadio<T> extends StatelessWidget {
  const MzRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    this.onTap,
    this.disable = false,
    this.activeColor = const Color.fromRGBO(0, 145, 255, 1),
    this.size = 28,
  }) : super(key: key);

  // 按钮大小
  final double size;

  /// 当前选项的值
  final T value;

  /// 按钮组值
  final T? groupValue;

  /// 点击事件
  final ValueChanged<T?>? onTap;

  final bool disable;

  /// 选中的颜色
  final Color activeColor;

  // 是否被选中
  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    var selectedView = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: activeColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: size * 3 / 7,
            height: size * 3 / 7,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.5),
                  width: 1,
                  style: BorderStyle.solid),
            ),
          ),
        ));

    var normalView = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.18),
            width: 1,
            style: BorderStyle.solid),
      ),
    );

    var view = _isSelected ? selectedView : normalView;

    return disable
        ? view
        : Listener(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: view,
            ),
            onPointerUp: (event) {
              _handleTap();
            },
          );
  }

  void _handleTap() {
    onTap!(value);
  }
}
