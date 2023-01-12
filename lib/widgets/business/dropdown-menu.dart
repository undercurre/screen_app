import 'package:flutter/material.dart';

class DropdownMenu extends StatefulWidget {
  final List<PopupMenuEntry<dynamic>> menu;
  final Widget child;
  final RelativeRect? position;
  final Duration? duration;
  final double menuWidth;
  final void Function(dynamic result)? onSelected;
  final void Function(bool visible)? onVisibled;

  const DropdownMenu({
    super.key,
    required this.menu,
    required this.child,
    this.menuWidth = 140,
    this.position,
    this.duration,
    this.onSelected,
    this.onVisibled,
  });

  @override
  State<StatefulWidget> createState() => DropdownMenuState();
}

class DropdownMenuState extends State<DropdownMenu>
    with TickerProviderStateMixin {
  /// 箭头动画控制器
  late AnimationController _arrowAnimationController;

  /// 箭头动画
  late Animation<double> _arrowAnimation;

  /// 是否显示菜单
  late bool visible = false;

  /// child的key，用于获取位置大小
  GlobalKey childKey = GlobalKey();

  late RelativeRect position;

  @override
  void initState() {
    super.initState();

    // 要先初始化一次，否则RotationTransition会报错
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    CurvedAnimation curve = CurvedAnimation(
        parent: _arrowAnimationController, curve: Curves.easeInOut);
    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            key: childKey,
            child: widget.child,
          ),
          RotationTransition(
            turns: _arrowAnimation,
            child: const Image(
              width: 30,
              height: 30,
              image: AssetImage('assets/imgs/plugins/common/arrow_bottom.png'),
            ),
          )
        ],
      ),
    );
  }

  handleTap() async {
    getPosition();
    visible = true;
    widget.onVisibled?.call(visible);
    doArrawAnimation();
    final res = await showMenu(
      context: context,
      position: position,
      items: widget.menu,
      color: const Color(0xff626262),
      constraints: BoxConstraints(
        minWidth: widget.menuWidth,
        maxWidth: widget.menuWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
    visible = false;
    widget.onVisibled?.call(visible);
    widget.onSelected?.call(res);
    doArrawAnimation();
  }

  doArrawAnimation() {
    // 如果当前动画还在执行，需要先停掉上一次动画
    if (_arrowAnimationController.status == AnimationStatus.forward) {
      _arrowAnimationController.stop();
    }
    // 执行本次动画
    visible
        ? _arrowAnimationController.animateTo(0.5)
        : _arrowAnimationController.animateTo(0);
  }

  getPosition() {
    final RenderBox renderBox =
        childKey.currentContext?.findRenderObject() as RenderBox;
    print(renderBox.localToGlobal(Offset.zero));
    var dx = renderBox.localToGlobal(Offset.zero).dx;
    if (renderBox.size.width > widget.menuWidth) {
      dx = dx + (renderBox.size.width - widget.menuWidth) / 2;
    } else {
      dx = dx - (widget.menuWidth - renderBox.size.width) / 2;
    }
    final dy = renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height;
    position = widget.position ?? RelativeRect.fromLTRB(dx, dy, dx, dy);
  }
}
