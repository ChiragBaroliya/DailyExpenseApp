import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';

// Temporary sample data while wiring the architecture
final List<Expense> _sampleExpenses = [
  Expense(id: '1', title: 'Coffee', amount: 3.5, date: DateTime.now()),
  Expense(id: '2', title: 'Groceries', amount: 24.0, date: DateTime.now().subtract(const Duration(days: 1))),
  Expense(id: '3', title: 'Transport', amount: 2.75, date: DateTime.now().subtract(const Duration(days: 2))),
];

class ExpenseList extends StatelessWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    if (_sampleExpenses.isEmpty) {
      return const Center(child: Text('No expenses yet'));
    }

    return ListView.separated(
      itemCount: _sampleExpenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final e = _sampleExpenses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(e.amount.toStringAsFixed(0)),
            ),
            title: Text(e.title),
            subtitle: Text('${e.date.toLocal()}'.split(' ')[0]),
            trailing: Text('\$${e.amount.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}
