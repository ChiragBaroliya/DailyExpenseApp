import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/expense_provider.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, double> _categoryTotals(List<Map<String, dynamic>> items, DateTime month) {
    final Map<String, double> totals = {};
    for (final item in items) {
      final d = _parseDate(item['date'] as String);
      if (d.year == month.year && d.month == month.month) {
        final cat = (item['category'] as String?) ?? 'Other';
        final amt = (item['amount'] as num).toDouble();
        totals[cat] = (totals[cat] ?? 0) + amt;
      }
    }
    return totals;
  }

  double _sum(Map<String, double> map) => map.values.fold(0.0, (a, b) => a + b);

  final List<Color> _palette = const [
    Color(0xFF3366CC),
    Color(0xFFDC3912),
    Color(0xFFFF9900),
    Color(0xFF109618),
    Color(0xFF990099),
    Color(0xFF0099C6),
    Color(0xFFDD4477),
    Color(0xFF66AA00),
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expenses = context.watch<ExpenseProvider>().expenses;
    final catTotals = _categoryTotals(expenses, now);
    final monthlyTotal = _sum(catTotals);

    final sections = <PieChartSectionData>[];
    final entries = catTotals.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final value = e.value;
      final color = _palette[i % _palette.length];
      sections.add(PieChartSectionData(
        color: color,
        value: value,
        title: '${((value / (monthlyTotal > 0 ? monthlyTotal : 1)) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This month total', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('\$${monthlyTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sections.isEmpty
                ? const Center(child: Text('No data for this month'))
                : Column(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final e = entries[index];
                            final color = _palette[index % _palette.length];
                            return ListTile(
                              leading: CircleAvatar(backgroundColor: color, radius: 10),
                              title: Text(e.key),
                              trailing: Text('\$${e.value.toStringAsFixed(2)}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

