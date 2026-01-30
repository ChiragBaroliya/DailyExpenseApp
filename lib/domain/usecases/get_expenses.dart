import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;
  GetExpenses(this.repository);

  Future<List<Expense>> call() async {
    return repository.getExpenses();
  }
}
