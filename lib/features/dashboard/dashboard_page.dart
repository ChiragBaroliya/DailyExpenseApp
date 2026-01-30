import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/expense_provider.dart';
// navigation to add expense uses named routes
// Navigation to expense list uses named routes registered in main.dart

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  double _sumForMonth(List<Map<String, dynamic>> items, DateTime month) {
    return items.fold(0.0, (double acc, item) {
      final d = _parseDate(item['date'] as String);
      if (d.year == month.year && d.month == month.month) {
        return acc + (item['amount'] as num).toDouble();
      }
      return acc;
    });
  }

  double _sumForDay(List<Map<String, dynamic>> items, DateTime day) {
    return items.fold(0.0, (double acc, item) {
      final d = _parseDate(item['date'] as String);
      if (d.year == day.year && d.month == day.month && d.day == day.day) {
        return acc + (item['amount'] as num).toDouble();
      }
      return acc;
    });
  }

  List<Map<String, dynamic>> _recentItems(List<Map<String, dynamic>> items, int count) {
    final copy = List<Map<String, dynamic>>.from(items);
    copy.sort((a, b) {
      final da = _parseDate(a['date'] as String);
      final db = _parseDate(b['date'] as String);
      return db.compareTo(da);
    });
    return copy.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expenses = context.watch<ExpenseProvider>().expenses;
    final monthlyTotal = _sumForMonth(expenses, now);
    final todayTotal = _sumForDay(expenses, now);
    final recent5 = _recentItems(expenses, 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'All expenses',
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.of(context).pushNamed('/expenses'),
          ),
          IconButton(
            tooltip: 'Reports',
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.of(context).pushNamed('/reports'),
          ),
          IconButton(
            tooltip: 'Family',
            icon: const Icon(Icons.family_restroom),
            onPressed: () => Navigator.of(context).pushNamed('/family'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total this month', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('\$${monthlyTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's expense", style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('\$${todayTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/add_expense');
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Recent expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: recent5.isEmpty
                  ? const Center(child: Text('No recent expenses'))
                  : ListView.separated(
                      itemCount: recent5.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = recent5[index];
                        final date = _parseDate(item['date'] as String);
                        final title = item['title'] as String? ?? item['category'] as String;
                        final amount = (item['amount'] as num).toDouble();
                        final payment = item['paymentMode'] as String? ?? '';

                        return ListTile(
                          title: Text(title),
                          subtitle: Text('${date.toLocal()}'.split(' ')[0] + ' • $payment'),
                          trailing: Text('\$${amount.toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
