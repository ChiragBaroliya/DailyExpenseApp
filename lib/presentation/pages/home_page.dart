import 'package:flutter/material.dart';
import '../widgets/expense_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expense'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ExpenseList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open add-expense flow
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
