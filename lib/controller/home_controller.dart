import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final storage = GetStorage();
  var totalExpenses = 0.0.obs;
  var totalIncome = 0.0.obs;
  final key = "expenses";
  final List<Map<String, dynamic>> myList = <Map<String, dynamic>>[].obs;
  final TextEditingController expenserController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final FocusNode expenserFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode expenseAmountFocusNode = FocusNode();
  var passingArgument = "";
  @override
  void onInit() {
    loadInitialDataClear();
    loadInitialData();
    super.onInit();
  }

  loadInitialDataClear() {
    if (!storage.hasData("isFirstInstall")) {
      storage.erase();
      storage.write("isFirstInstall", true);
    }
  }

  submitExpense() async {
    List<String> missingFields = [];
    if (expenserController.text.trim().isEmpty) {
      missingFields.add("Expenser Name");
    }
    if (descriptionController.text.trim().isEmpty) {
      missingFields.add("Description");
    }
    if (expenseAmountController.text.trim().isEmpty) {
      missingFields.add("Amount");
    }
    if (missingFields.isNotEmpty) {
      Get.snackbar(
        "",
        "",
        titleText: Text(
          "Missing Fields",
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontFamily: 'NotoSerif'),
        ),
        messageText: Text(
          "Please fill: ${missingFields.join(', ')}",
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontFamily: 'NotoSerif'),
        ),
        backgroundColor: Colors.redAccent.withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.warning, color: Colors.white),
      );
    } else {
      final newMap = {
        "name": expenserController.text,
        "description": descriptionController.text,
        "amount": expenseAmountController.text,
        "type": passingArgument,
        "date": DateTime.now().toIso8601String(),
      };
      myList.add(newMap);
      await saveExpenses();
      Get.snackbar(
        "",
        "",
        backgroundColor: Colors.green.withAlpha(200),
        titleText: Text(
          "Success",
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontFamily: 'NotoSerif'),
        ),
        messageText: Text(
          "$passingArgument submitted successfully!",
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontFamily: 'NotoSerif'),
        ),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }

  loadInitialData() {
    final savedData = storage.read<List>(key);
    if (savedData != null) {
      myList.addAll(savedData.cast<Map<String, dynamic>>());
    }
  }

  Map<String, double> calculateOverallIncomeExpense(
      List<Map<String, dynamic>> myList) {
    double incomeAmount = 0.0;
    double expenseAmount = 0.0;
    for (var item in myList) {
      final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
      if (item['type'] == "Income") {
        incomeAmount += amount;
      } else if (item['type'] == "Expense") {
        expenseAmount += amount;
      }
    }
    return {
      'income': incomeAmount,
      'expense': expenseAmount,
    };
  }

  Future<void> saveExpenses() async {
    storage.write(key, myList.toList());
    final firestore = FirebaseFirestore.instance;
    await firestore.collection("expenses").add({
      "name": expenserController.text,
      "description": descriptionController.text,
      "amount": expenseAmountController.text,
      "type": passingArgument,
      "date": DateTime.now().toIso8601String(),
      "createAt": FieldValue.serverTimestamp()
    });
    expenserController.clear();
    descriptionController.clear();
    expenseAmountController.clear();
    Get.back(result: "success");
  }
}
