import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl();

  // In a real app this would call a local DB or remote API.
  @override
  Future<List<Expense>> getExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      ExpenseModel(id: '1', title: 'Coffee', amount: 3.5, date: now),
      ExpenseModel(id: '2', title: 'Groceries', amount: 24.0, date: now.subtract(const Duration(days: 1))),
    ];
  }
}
