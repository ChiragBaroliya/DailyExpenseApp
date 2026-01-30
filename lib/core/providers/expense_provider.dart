import 'package:flutter/foundation.dart';
import '../../core/mock/mock_expenses.dart';

class ExpenseProvider extends ChangeNotifier {
  // Internal in-memory list of expense maps
  final List<Map<String, dynamic>> _expenses = [];

  ExpenseProvider() {
    // initialize from mock data
    _expenses.addAll(mockExpenses);
  }

  List<Map<String, dynamic>> get expenses => List.unmodifiable(_expenses);

  void addExpense(Map<String, dynamic> expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  void removeExpenseById(String id) {
    _expenses.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

  void clear() {
    _expenses.clear();
    notifyListeners();
  }
}
