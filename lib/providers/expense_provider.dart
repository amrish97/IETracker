import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseModel> _items = [];
  bool _isLoading = false;

  List<ExpenseModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadExpensesFromDb();
  }

  /// Load all transactions from MySQL Backend Database
  Future<void> loadExpensesFromDb() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> rawData = await ApiService.fetchExpensesFromDb();
    _items.clear();
    for (var map in rawData) {
      _items.add(ExpenseModel.fromMap(map));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Calculate total income
  double get totalIncome {
    double total = 0.0;
    for (var item in _items) {
      if (item.type == 'Income') {
        total += item.amount;
      }
    }
    return total;
  }

  /// Calculate total expenses
  double get totalExpenses {
    double total = 0.0;
    for (var item in _items) {
      if (item.type == 'Expense') {
        total += item.amount;
      }
    }
    return total;
  }

  /// Calculate remaining balance
  double get remainingBalance => totalIncome - totalExpenses;

  /// Add new Income or Expense item to MySQL DB
  Future<void> addExpense({
    required String name,
    required String description,
    required double amount,
    required String type,
  }) async {
    // 1. Optimistic / Immediate UI update
    final tempItem = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      amount: amount,
      type: type,
      date: DateTime.now(),
    );
    _items.insert(0, tempItem);
    notifyListeners();

    // 2. Save to MySQL Database
    final savedData = await ApiService.saveExpenseToDb(
      name: name,
      description: description,
      amount: amount,
      type: type,
    );

    if (savedData != null) {
      // Update with server generated DB ID
      final index = _items.indexWhere((element) => element.id == tempItem.id);
      if (index != -1) {
        _items[index] = ExpenseModel.fromMap(savedData);
        notifyListeners();
      }
    }
  }

  /// Delete item by ID from MySQL DB
  Future<void> deleteExpense(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    await ApiService.deleteExpenseFromDb(id);
  }

  /// Clear all expenses locally
  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}
