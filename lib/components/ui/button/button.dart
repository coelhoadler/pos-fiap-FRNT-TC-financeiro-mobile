import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFF004d61),
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 48.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: borderColor ?? Color(0xFF004d61)),
          ),
          splashFactory: onPressed == null ? NoSplash.splashFactory : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ), 
      ),
    );
  }
}

class CustomButtonVariants {
  static CustomButton primary({
    required String text,
    required VoidCallback? onPressed,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      fontSize: fontSize ?? 16.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      backgroundColor: Color(0xFF004d61),
      textColor: Colors.white,
    );
  }

  static CustomButton primaryOutline({
    required String text,
    required VoidCallback? onPressed,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      fontSize: fontSize ?? 16.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      backgroundColor: Colors.white,
      textColor: Color(0xFF004d61),
      borderColor: Color(0xFF004d61),
    );
  }
}
