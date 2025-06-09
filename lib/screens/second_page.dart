import 'package:expense/controller/home_controller.dart';
import 'package:expense/widget/custom_button.dart';
import 'package:expense/widget/custom_text.dart';
import 'package:expense/widget/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Secondpage extends StatefulWidget {
  const Secondpage({super.key});

  @override
  State<Secondpage> createState() => _SecondpageState();
}

class _SecondpageState extends State<Secondpage> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    controller.passingArgument = Get.arguments["routeName"];
    controller.expenserController.clear();
    controller.descriptionController.clear();
    controller.expenseAmountController.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: CustomText(
            text: "Add your ${controller.passingArgument}",
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20,
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            spacing: 30,
            children: <Widget>[
              Icon(
                Icons.account_circle_rounded,
                size: 140,
                color: Theme.of(context).primaryColor.withAlpha(40),
              ),
              CustomTextfield(
                title: controller.passingArgument == "Expense"
                    ? "Expenser Name :"
                    : "Customer Name :",
                controller: controller,
                name: "Enter Your Name",
                ctrl: controller.expenserController,
                focusNode: controller.expenserFocusNode,
              ),
              CustomTextfield(
                title: "Description :",
                controller: controller,
                name: "Enter Your Description",
                ctrl: controller.descriptionController,
                focusNode: controller.descriptionFocusNode,
              ),
              CustomTextfield(
                title: "Amount :",
                controller: controller,
                name: "Enter Your ${controller.passingArgument} Amount",
                ctrl: controller.expenseAmountController,
                focusNode: controller.expenseAmountFocusNode,
              ),
              Row(
                children: [
                  CustomButton(
                    text: "submit",
                    onTap: () {
                      controller.submitExpense();
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
