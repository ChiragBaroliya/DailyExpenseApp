// Expense model used across the app.

class Expense {
  final double amount;
  final String category;
  final String paymentMode;
  final DateTime date;
  final String? notes;
  final String createdBy; // user id

  const Expense({
    required this.amount,
    required this.category,
    required this.paymentMode,
    required this.date,
    this.notes,
    required this.createdBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      paymentMode: json['paymentMode'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'paymentMode': paymentMode,
      'date': date.toIso8601String(),
      if (notes != null) 'notes': notes,
      'createdBy': createdBy,
    };
  }
}
