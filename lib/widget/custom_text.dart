import 'package:expense/resources/app_colors.dart';
import 'package:expense/widget/extension.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final String firstText;
  final Color color;
  final double fontSize;
  final TextAlign alignment;
  const CustomText(
      {super.key,
      required this.text,
      this.color = AppColors.textColor,
      this.fontSize = 14,
      this.alignment = TextAlign.start,
      this.firstText = ""});

  @override
  Widget build(BuildContext context) {
    return Text(
      firstText + text.toUpperLowerCase(),
      textAlign: alignment,
      softWrap: true,
      style: TextStyle(
        fontFamily: 'NotoSerif',
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.5,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}
