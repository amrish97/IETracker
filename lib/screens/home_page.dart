import 'package:expense/binding/home_binding.dart';
import 'package:expense/controller/home_controller.dart';
import 'package:expense/screens/second_page.dart';
import 'package:expense/widget/custom_button.dart';
import 'package:expense/widget/custom_text.dart';
import 'package:expense/widget/extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: CustomText(
          text: "IE Tracker",
          color: Theme.of(context).colorScheme.inversePrimary,
          fontSize: 20,
        ),
      ),
      body: Obx(() {
        return controller.myList.isNotEmpty
            ? ListView.builder(
                itemCount: controller.myList.length,
                itemBuilder: (context, index) {
                  final data = controller.myList[index];
                  DateTime? date;
                  if (data['date'] != null) {
                    if (data['date'] is String) {
                      date = DateTime.tryParse(data['date']);
                    } else if (data['date'] is DateTime) {
                      date = data['date'] as DateTime;
                    }
                  }
                  date ??= DateTime.now();
                  final formatedDate =
                      DateFormat('dd MMM yyyy – hh:mm a').format(date);
                  return Column(
                    children: [
                      if (index == 0 && controller.myList.isNotEmpty) ...[
                        Obx(() {
                          final result = controller
                              .calculateOverallIncomeExpense(controller.myList);
                          controller.totalIncome.value =
                              result['income'] as double;
                          controller.totalExpenses.value =
                              result['expense'] as double;
                          final remaining = controller.totalIncome.value -
                              controller.totalExpenses.value;
                          return Row(
                            children: [
                              getContainer(
                                color: Colors.green,
                                title: "Income",
                                amount: controller.totalIncome.value.toString(),
                                icon: FontAwesomeIcons.arrowTrendUp,
                              ),
                              getContainer(
                                color: Colors.red,
                                title: "Expense",
                                icon: FontAwesomeIcons.wallet,
                                amount:
                                    controller.totalExpenses.value.toString(),
                              ),
                              getContainer(
                                color: Colors.pink,
                                title: "Remains",
                                icon: FontAwesomeIcons.handHoldingDollar,
                                amount: remaining.toString(),
                              ),
                            ],
                          );
                        }),
                      ],
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(Get.context!)
                                .primaryColor
                                .withAlpha(40),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(Get.context!)
                                  .primaryColor
                                  .withAlpha(40),
                              child: CustomText(text: "${index + 1}"),
                            ),
                            title: CustomText(
                                firstText: data['type'] == "Income"
                                    ? "Customer Name: "
                                    : "Expenser Name: ",
                                text: data["name"]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  firstText: "Date & Time: ",
                                  text: formatedDate,
                                ),
                                CustomText(
                                  firstText: "Description: ",
                                  text: data["description"],
                                ),
                              ],
                            ),
                            trailing: CustomText(
                                text: "\u{20B9}${data['amount']}",
                                color: data['type'] == "Income"
                                    ? Colors.green
                                    : Colors.red),
                          ))
                    ],
                  );
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/lottie/empty_popular_services.json",
                      height: 150, width: 150),
                  CustomText(
                    text:
                        "No Expenses are Found you have add a Expense or Income just tap a below Button to add..!",
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                    alignment: TextAlign.center,
                  ).toPadAll(all: 26),
                ],
              );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 95,
          child: Row(
            children: [
              CustomButton(
                text: "Income",
                onTap: () {
                  Get.to(Secondpage(),
                          binding: HomeBinding(),
                          arguments: {"routeName": "Income"})!
                      .then((value) {
                    if (value == "success") {
                      setState(() {});
                    }
                  });
                },
              ),
              CustomButton(
                  text: "Expense",
                  onTap: () {
                    Get.to(Secondpage(),
                        binding: HomeBinding(),
                        arguments: {"routeName": "Expense"});
                  }),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget getContainer(
      {required Color color,
      required String title,
      required String amount,
      required IconData icon}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withAlpha(80),
        ),
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            FaIcon(
              icon,
              size: 18,
            ),
            Column(
              children: [
                CustomText(text: title),
                CustomText(text: "\u{20B9}$amount"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
