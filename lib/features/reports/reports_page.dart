import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/providers/expense_provider.dart';
import '../../data/services/report_service.dart';
import '../../data/models/report_item.dart';
import '../../data/models/category_report.dart';
import '../../data/models/pie_category.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportService _service = ReportService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<ReportItem> _report = [];
  List<CategoryReport> _categoryReport = [];
  List<PieCategory> _pieData = [];
  bool _loading = true;

  DateTime _startOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);
  DateTime _endOfMonth(DateTime dt) => DateTime(dt.year, dt.month + 1, 1).subtract(const Duration(days: 1));

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
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final start = _startOfMonth(now);
    final end = _endOfMonth(now);

    String? fg = await _storage.read(key: 'family_group_id');
    fg ??= 'family_1';

    try {
      final results = await Future.wait([
        _service.getDailyMonthlyReport(familyGroupId: fg, start: start, end: end),
        _service.getCategoryWiseReport(familyGroupId: fg, start: start, end: end),
        _service.getPieCategoryChart(familyGroupId: fg, start: start, end: end),
      ]);
      final items = results[0] as List<ReportItem>;
      final cats = results[1] as List<CategoryReport>;
      final pie = results[2] as List<PieCategory>;
      if (mounted) setState(() { _report = items; _categoryReport = cats; _pieData = pie; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _sumReport() => _report.fold(0.0, (a, b) => a + b.totalAmount);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expenses = context.watch<ExpenseProvider>().expenses;
    final sections = <PieChartSectionData>[];
    double monthlyTotal;
    List<MapEntry<String, double>> entries;

    if (_pieData.isNotEmpty) {
      monthlyTotal = _pieData.fold(0.0, (a, b) => a + b.value);
      entries = _pieData.map((c) => MapEntry(c.label, c.value)).toList();
    } else if (_categoryReport.isNotEmpty) {
      monthlyTotal = _categoryReport.fold(0.0, (a, b) => a + b.total);
      entries = _categoryReport.map((c) => MapEntry(c.category, c.total)).toList();
    } else {
      final catTotals = <String, double>{};
      for (final item in expenses) {
        final d = DateTime.tryParse(item['date'] as String) ?? DateTime.now();
        if (d.year == now.year && d.month == now.month) {
          final cat = (item['category'] as String?) ?? 'Other';
          final amt = (item['amount'] as num).toDouble();
          catTotals[cat] = (catTotals[cat] ?? 0) + amt;
        }
      }
      monthlyTotal = _report.isNotEmpty ? _sumReport() : catTotals.values.fold(0.0, (a, b) => a + b);
      entries = catTotals.entries.toList();
    }

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
                    _loading
                        ? const SizedBox(height: 20, child: Center(child: CircularProgressIndicator()))
                        : Text('\$${monthlyTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          itemCount: _report.isNotEmpty ? _report.length : entries.length,
                          itemBuilder: (context, index) {
                            if (_report.isNotEmpty) {
                              final r = _report[index];
                              return ListTile(
                                title: Text(r.date.toLocal().toIso8601String().split('T').first),
                                trailing: Text('\$${r.totalAmount.toStringAsFixed(2)}'),
                              );
                            }
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

