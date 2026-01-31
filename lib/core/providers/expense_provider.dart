import 'package:flutter/foundation.dart';
import '../../core/mock/mock_expenses.dart';
import '../../data/services/expense_service.dart';
import '../../data/models/expense_request.dart';

class ExpenseProvider extends ChangeNotifier {
  // Internal in-memory list of expense maps
  final List<Map<String, dynamic>> _expenses = [];

  

  List<Map<String, dynamic>> get expenses => List.unmodifiable(_expenses);

  final ExpenseService _service;

  ExpenseProvider({ExpenseService? service}) : _service = service ?? ExpenseService() {
    _expenses.addAll(mockExpenses);
  }

  /// Adds an expense through the API and updates local state on success.
  Future<void> addExpense(ExpenseRequest req) async {
    await _service.addExpense(req);

    final map = {
      'id': 'e${DateTime.now().millisecondsSinceEpoch}',
      'title': req.notes ?? req.category,
      'amount': req.amount,
      'category': req.category,
      'date': req.date.split('T').first,
      'paymentMode': req.paymentMode,
      'userId': req.createdBy,
    };
    _expenses.insert(0, map);
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
