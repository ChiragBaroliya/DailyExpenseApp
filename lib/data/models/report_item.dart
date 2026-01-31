class ReportItem {
  final DateTime date;
  final double totalAmount;

  ReportItem({required this.date, required this.totalAmount});

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}
