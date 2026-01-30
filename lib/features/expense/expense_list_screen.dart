import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/expense_provider.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  List<Map<String, dynamic>> _sortedByDateDesc(List<Map<String, dynamic>> items) {
    final copy = List<Map<String, dynamic>>.from(items);
    copy.sort((a, b) {
      final da = _parseDate(a['date'] as String);
      final db = _parseDate(b['date'] as String);
      return db.compareTo(da);
    });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final sorted = _sortedByDateDesc(expenses);

    return Scaffold(
      appBar: AppBar(title: const Text('All expenses')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: sorted.isEmpty
            ? const Center(child: Text('No expenses yet'))
            : ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = sorted[index];
                  final date = _parseDate(item['date'] as String);
                  final category = item['category'] as String? ?? '';
                  final amount = (item['amount'] as num).toDouble();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(category.isNotEmpty ? category[0] : '?')),
                      title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${date.toLocal()}'.split(' ')[0]),
                      trailing: Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
