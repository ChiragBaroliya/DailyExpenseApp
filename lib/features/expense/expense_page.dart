import 'package:flutter/material.dart';
import 'add_expense_page.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Expense feature placeholder')),
    );
  }
}

// For convenience allow navigating directly to AddExpensePage from other pages
class ExpenseRoutes {
  static void openAdd(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddExpensePage()));
  }
}
