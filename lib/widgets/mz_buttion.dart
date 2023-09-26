import 'package:flutter/material.dart';

class MzButton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final String text;
  final VoidCallback onPressed;
  final bool isShowShadow;
  final Color textColor;
  final bool isClickable;


  const MzButton({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.text,
    required this.onPressed,
    this.isShowShadow = true,
    this.textColor = const Color(0xFFFFFFFF),
    this.isClickable=true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isClickable? onPressed:null,
        style: ButtonStyle(
          shadowColor: isShowShadow ? null : MaterialStateProperty.all(const Color(0x00000000)),
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24.0,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
