import '../../core/network/api_client.dart';
import '../models/expense_request.dart';

class ExpenseService {
  final ApiClient _api;

  ExpenseService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Adds an expense by POSTing to /finance/expense
  Future<void> addExpense(ExpenseRequest req) async {
    await _api.post('/finance/expense', body: req.toJson());
  }
}
