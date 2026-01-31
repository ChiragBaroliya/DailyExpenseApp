class CategoryReport {
  final String category;
  final double total;

  CategoryReport({required this.category, required this.total});

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      category: json['category'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }
}
