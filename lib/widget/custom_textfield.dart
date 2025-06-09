import 'package:expense/controller/home_controller.dart';
import 'package:expense/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextfield extends StatelessWidget {
  final String title;
  final String name;
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final HomeController controller;

  const CustomTextfield(
      {super.key,
      required this.title,
      required this.name,
      required this.ctrl,
      required this.focusNode,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        SizedBox(
          width: 10,
        ),
        CustomText(
          text: title,
          color: Theme.of(Get.context!).primaryColor,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: ctrl,
              maxLines: ctrl == controller.descriptionController ? 5 : 1,
              keyboardType: ctrl == controller.expenseAmountController
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: name,
                  hintStyle: TextStyle(
                    fontFamily: 'NotoSerif',
                    color: Theme.of(Get.context!).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  )),
              focusNode: focusNode,
              onFieldSubmitted: (v) {
                if (focusNode == controller.expenserFocusNode) {
                  controller.expenserFocusNode.unfocus();
                  controller.descriptionFocusNode.requestFocus();
                } else if (focusNode == controller.descriptionFocusNode) {
                  controller.descriptionFocusNode.unfocus();
                  controller.expenseAmountFocusNode.requestFocus();
                } else {
                  controller.expenseAmountFocusNode.unfocus();
                }
              },
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
