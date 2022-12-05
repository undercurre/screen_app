import 'package:flutter/material.dart';

/// A vertical SeekBar build on two [SizedBox] with versatile appearance.
class AdvancedVerticalSeekBar extends StatefulWidget {
  /// The width of the SeekBar. @required
  final double ?  width;
  /// The height of the SeekBar. @required
  final double ? height;
  /// The minimum value of the SeekBar.
  ///
  /// Defaults to 0.0 .
  final double ? min;
  /// The maximum value of the SeekBar.
  ///
  /// Defaults to 10.0 .
  final double ? max;
  /// The step by which the SeekBar's value is incremented.
  ///
  /// Defaults to 1.0 .
  final double ? step;
  /// The initial value of the SeekBar.
  ///
  /// Defaults to [max] - [step].
  final double ? value;
  /// The sensitivity of the SeekBar's edges in pixels.
  ///
  /// A value of 5.0 means that when the SeekBar is less than 5 pixels away
  /// from the top or bottom, it will snap to it. Defaults to 0.0 .
  final double ? accuracy;
  /// The child [Widget] of the fixed [SizedBox].
  ///
  /// Use this to change the appearance of the SeekBar. Defaults to a
  /// [DecoratedBox] with a grey [BoxDecoration].
  final Widget ? fixedBox;
  /// The child [Widget] of the moving [SizedBox].
  ///
  /// Use this to change the appearance of the SeekBar. Defaults to a
  /// [DecoratedBox] with a red [BoxDecoration].
  final Widget ? movingBox;
  /// The function called when the value of the SeekBar changes.
  /// Passes the new value as a parameter.
  final void Function(double) ? onValueChanged;

  const AdvancedVerticalSeekBar({
    Key ? key,
    required this.height,
    required this.width,
    this.onValueChanged,
    this.max,
    this.min,
    this.step,
    this.accuracy,
    this.value,
    this.fixedBox,
    this.movingBox,
  }) : super(key: key);

  _BoxedVerticalSeekBarState createState() => _BoxedVerticalSeekBarState();
}

class _BoxedVerticalSeekBarState extends State<AdvancedVerticalSeekBar>{
  late double ?  _value;
  late double ?  _min;
  late double ?  _max;
  late double ? _step;
  late double ? _currentHeight;
  late double ? _accuracy;
  late Widget ? _movingDecoratedBox;
  late Widget ? _fixedDecoratedBox;

  @override
  initState() {
    super.initState();
    // Initialise all values.
    _min = widget.min ?? 0.0;
    _max = widget.max ?? 10.0;
    _step = widget.step ?? 1.0;
    _value = widget.value ?? 5.0;
    _accuracy = widget.accuracy ?? 0.0;
    _currentHeight = _convertValueToHeight();
    _movingDecoratedBox = widget.movingBox ?? DecoratedBox(
        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10))
    );
    _fixedDecoratedBox = widget.fixedBox ?? DecoratedBox(
      decoration: BoxDecoration(color: const Color(0xFF1a1a1a),borderRadius: BorderRadius.circular(10)),

    );
  }

  // Converts the current value to its respective height.
  double _convertValueToHeight() {
    double? heightTemp=widget.height;
    return (_value! - _min!) * heightTemp! / (_max! - _min!);
  }

  // Converts SizedBox height to its respective value.
  double _convertHeightToValue(double height) {
    double? heightTemp=widget.height;
    var tempValue = height * (_max! - _min!) / heightTemp! + _min!;
    if (tempValue != _max && tempValue != _min) {
      tempValue = tempValue - (tempValue % _step!) + (_min! % _step!);
    }
    return tempValue;
  }

  // Updates height and value when user taps on the SeekBar.
  void _onTapUp(TapUpDetails tapDetails) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      _currentHeight =
          (widget.height! - renderBox.globalToLocal(tapDetails.globalPosition).dy);
      _setValue(_convertHeightToValue(_currentHeight!));
    });
  }

  // Updates height and value when user drags the SeekBar.
  void _onVerticalDragUpdate(DragUpdateDetails dragDetails) {
    if (dragDetails.primaryDelta! >= 1.0  ||  dragDetails.primaryDelta! <= -1.0) {
      double? temp=dragDetails.primaryDelta;
      double? newHeight = _currentHeight! - temp!;
      if (newHeight > (widget.height! - _accuracy!)) {
        newHeight = widget.height;
      } else if (newHeight < _accuracy!) {
        newHeight = 0.0;
      }

      if (newHeight != _currentHeight) {
        setState(() {
          _currentHeight = newHeight;
          _setValue(_convertHeightToValue(_currentHeight!));
        });
      }
    }
  }

  void _setValue(double newValue) {
    _value = newValue;
    widget.onValueChanged!(_value!);
  }

  Widget _buildFixedBox() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _fixedDecoratedBox,
    );
  }

  Widget _buildMovingBox() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: widget.width,
        height: _currentHeight,
        child: _movingDecoratedBox,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapUp,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          _buildFixedBox(),
          _buildMovingBox(),
        ],
      ),
    );
  }
}