import 'package:expense/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const CustomButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Theme.of(Get.context!).primaryColor.withAlpha(40),
          ),
          child: CustomText(
            text: text,
            alignment: TextAlign.center,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
      ),
    );
  }
}
